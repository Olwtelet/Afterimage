-- =============================================================================
-- A plataforma
--
-- Perfis, catálogo, favoritos, assistidos, avaliações, comentários e ranking.
--
-- Duas regras atravessam o arquivo inteiro:
--
--   1. NADA é confiado ao cliente. Cada tabela tem RLS, e cada política é escrita
--      supondo que o JavaScript do navegador foi reescrito por quem está usando.
--      O que protege o banco é o Postgres, não a interface.
--
--   2. O ranking é ORNAMENTAL. Ele não aparece em política nenhuma, não abre
--      permissão, não desbloqueia recurso. Posição alta e conta nova têm
--      exatamente os mesmos direitos — por construção, não por promessa.
--
-- Aplicar depois de 0001_audience.sql.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Administração
--
-- Uma tabela em vez de um ID no código: trocar quem administra não deveria exigir
-- deploy. Ninguém a lê pelo cliente — só a função `is_admin()`, que roda com os
-- privilégios do dono.
-- -----------------------------------------------------------------------------

create table if not exists public.admins (
  discord_id text        primary key,
  note       text,
  created_at timestamptz not null default now()
);

alter table public.admins enable row level security;
-- Sem policy: nenhuma role anônima ou autenticada enxerga esta tabela.


-- -----------------------------------------------------------------------------
-- Perfis
--
-- Espelha auth.users com o que vem do Discord. Criado por trigger no cadastro,
-- então não existe usuário autenticado sem perfil.
-- -----------------------------------------------------------------------------

create table if not exists public.profiles (
  id           uuid        primary key references auth.users (id) on delete cascade,
  discord_id   text        unique not null,
  username     text        unique not null,
  display_name text        not null,
  avatar_url   text,
  banner_url   text,
  bio          text,
  -- Espelho do Discord, atualizado no login. Puramente informativo: nenhuma
  -- política deste arquivo lê estas colunas.
  guild_member boolean     not null default false,
  guild_roles  jsonb       not null default '[]'::jsonb,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint profiles_username_format check (username ~ '^[a-z0-9._-]{2,32}$'),
  constraint profiles_display_length  check (char_length(display_name) between 1 and 64),
  constraint profiles_bio_length      check (bio is null or char_length(bio) <= 280)
);

create index if not exists profiles_username_idx   on public.profiles (username);
create index if not exists profiles_discord_id_idx on public.profiles (discord_id);


-- Verificação de administração.
--
-- `security definer` para poder consultar `admins`, que é invisível a todos.
-- Toda política de escrita no catálogo passa por aqui.
create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles p
    join public.admins a on a.discord_id = p.discord_id
    where p.id = auth.uid()
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to anon, authenticated;


-- Criação do perfil no cadastro.
--
-- O Discord entrega os dados em raw_user_meta_data. `username` precisa ser único
-- e o Discord permite trocá-lo, então colisão é tratada com sufixo numérico em
-- vez de deixar o cadastro falhar.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  meta        jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  base_name   text;
  final_name  text;
  suffix      integer := 0;
begin
  base_name := lower(coalesce(
    meta ->> 'user_name',
    meta ->> 'preferred_username',
    meta ->> 'name',
    'espectador'
  ));

  -- Reduz ao alfabeto aceito pela constraint.
  base_name := regexp_replace(base_name, '[^a-z0-9._-]', '', 'g');
  if char_length(base_name) < 2 then
    base_name := 'espectador';
  end if;
  base_name := left(base_name, 28);

  final_name := base_name;
  while exists (select 1 from public.profiles where username = final_name) loop
    suffix := suffix + 1;
    final_name := base_name || suffix::text;
  end loop;

  insert into public.profiles (id, discord_id, username, display_name, avatar_url)
  values (
    new.id,
    coalesce(meta ->> 'provider_id', meta ->> 'sub', new.id::text),
    final_name,
    coalesce(meta ->> 'full_name', meta ->> 'name', meta ->> 'user_name', final_name),
    meta ->> 'avatar_url'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();


alter table public.profiles enable row level security;

-- Perfis são públicos: é o que permite a página de perfil e a lista de ranking
-- funcionarem para quem nem está logado.
drop policy if exists "perfis: leitura pública" on public.profiles;
create policy "perfis: leitura pública"
  on public.profiles for select
  to anon, authenticated
  using (true);

-- Cada um edita o seu. As colunas de identidade e de espelho do Discord são
-- travadas pelo gatilho abaixo, não por esta política.
drop policy if exists "perfis: cada um edita o seu" on public.profiles;
create policy "perfis: cada um edita o seu"
  on public.profiles for update
  to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- Trava as colunas que o usuário não pode reescrever sobre si mesmo.
--
-- Sem isto, `discord_id` seria editável pelo dono do perfil — e como `is_admin()`
-- resolve administração POR discord_id, qualquer pessoa se tornaria administrador
-- com um único UPDATE. A política acima autoriza a linha; este gatilho decide
-- quais colunas dela podem mudar.
create or replace function public.protect_profile_columns()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if public.is_admin() then
    return new;
  end if;

  new.id           := old.id;
  new.discord_id   := old.discord_id;
  new.guild_member := old.guild_member;
  new.guild_roles  := old.guild_roles;
  new.created_at   := old.created_at;
  new.updated_at   := now();
  return new;
end;
$$;

drop trigger if exists profiles_protect_columns on public.profiles;
create trigger profiles_protect_columns
  before update on public.profiles
  for each row execute function public.protect_profile_columns();


-- -----------------------------------------------------------------------------
-- Catálogo
--
-- Passa a viver no banco porque o painel precisa criar, editar e excluir. As
-- páginas de ficha continuam sendo servidas do CDN — o que muda é a origem do
-- dado, não a estratégia de entrega.
-- -----------------------------------------------------------------------------

create table if not exists public.films (
  id           uuid        primary key default gen_random_uuid(),
  slug         text        unique not null,

  headline     text        not null,
  kicker       text,
  summary      text        not null,
  body         text,

  poster_url   text,
  banner_url   text,
  trailer_url  text,

  -- Cor curada da sessão. É dela que sai a barra SMPTE da ficha.
  tone         text        not null default '#C0C0C0',

  session_at   timestamptz,
  room         text,
  room_url     text,

  genres       text[]      not null default '{}',
  tags         text[]      not null default '{}',
  links        jsonb       not null default '[]'::jsonb,

  published    boolean     not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),

  constraint films_slug_format check (slug ~ '^[a-z0-9-]{2,80}$'),
  constraint films_tone_format check (tone ~* '^#[0-9a-f]{6}$')
);

create index if not exists films_session_at_idx on public.films (session_at desc);
create index if not exists films_published_idx  on public.films (session_at desc) where published;

-- Exibições de uma sessão. Sessão dupla tem duas; as demais, uma.
create table if not exists public.film_features (
  id        uuid    primary key default gen_random_uuid(),
  film_id   uuid    not null references public.films (id) on delete cascade,
  position  smallint not null default 1,

  title     text    not null,
  year      smallint,
  director  text,
  cast_list text[]  not null default '{}',
  runtime   smallint,
  rating    text,
  genres    text[]  not null default '{}',
  starts_at time,

  constraint film_features_year    check (year is null or year between 1888 and 2100),
  constraint film_features_runtime check (runtime is null or runtime > 0),
  unique (film_id, position)
);

create index if not exists film_features_film_idx on public.film_features (film_id, position);

alter table public.films         enable row level security;
alter table public.film_features enable row level security;

-- Catálogo publicado é público; rascunho só o administrador enxerga.
drop policy if exists "filmes: leitura do que está publicado" on public.films;
create policy "filmes: leitura do que está publicado"
  on public.films for select
  to anon, authenticated
  using (published or public.is_admin());

drop policy if exists "filmes: só a administração escreve" on public.films;
create policy "filmes: só a administração escreve"
  on public.films for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "exibições: acompanham a ficha" on public.film_features;
create policy "exibições: acompanham a ficha"
  on public.film_features for select
  to anon, authenticated
  using (exists (
    select 1 from public.films f
    where f.id = film_id and (f.published or public.is_admin())
  ));

drop policy if exists "exibições: só a administração escreve" on public.film_features;
create policy "exibições: só a administração escreve"
  on public.film_features for all
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());


-- -----------------------------------------------------------------------------
-- Interações
--
-- Três tabelas com a mesma forma: (usuário, filme) único, dono escreve, todo
-- mundo lê. A leitura é pública porque o perfil é público.
-- -----------------------------------------------------------------------------

create table if not exists public.favorites (
  user_id    uuid        not null references public.profiles (id) on delete cascade,
  film_id    uuid        not null references public.films (id)    on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, film_id)
);

create table if not exists public.watched (
  user_id    uuid        not null references public.profiles (id) on delete cascade,
  film_id    uuid        not null references public.films (id)    on delete cascade,
  watched_at timestamptz not null default now(),
  primary key (user_id, film_id)
);

create table if not exists public.ratings (
  user_id    uuid        not null references public.profiles (id) on delete cascade,
  film_id    uuid        not null references public.films (id)    on delete cascade,
  score      smallint    not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (user_id, film_id),

  -- Escala de três. Não é uma limitação técnica: meia-estrela em escala de dez
  -- convida à precisão falsa, e a curadoria aqui é uma opinião, não uma métrica.
  constraint ratings_score_range check (score between 1 and 3)
);

create table if not exists public.comments (
  id         uuid        primary key default gen_random_uuid(),
  user_id    uuid        not null references public.profiles (id) on delete cascade,
  film_id    uuid        not null references public.films (id)    on delete cascade,
  body       text        not null,
  edited     boolean     not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint comments_body_length check (char_length(body) between 1 and 2000)
);

create index if not exists favorites_film_idx  on public.favorites (film_id);
create index if not exists favorites_user_idx  on public.favorites (user_id, created_at desc);
create index if not exists watched_film_idx    on public.watched   (film_id);
create index if not exists watched_user_idx    on public.watched   (user_id, watched_at desc);
create index if not exists ratings_film_idx    on public.ratings   (film_id);
create index if not exists ratings_user_idx    on public.ratings   (user_id, updated_at desc);
create index if not exists comments_film_idx   on public.comments  (film_id, created_at desc);
create index if not exists comments_user_idx   on public.comments  (user_id, created_at desc);

alter table public.favorites enable row level security;
alter table public.watched   enable row level security;
alter table public.ratings   enable row level security;
alter table public.comments  enable row level security;

do $$
declare
  t text;
begin
  foreach t in array array['favorites', 'watched', 'ratings'] loop
    execute format($p$
      drop policy if exists "%1$s: leitura pública" on public.%1$I;
      create policy "%1$s: leitura pública"
        on public.%1$I for select to anon, authenticated using (true);

      drop policy if exists "%1$s: cada um escreve o seu" on public.%1$I;
      create policy "%1$s: cada um escreve o seu"
        on public.%1$I for all to authenticated
        using (user_id = auth.uid())
        with check (user_id = auth.uid());
    $p$, t);
  end loop;
end
$$;

drop policy if exists "comentários: leitura pública" on public.comments;
create policy "comentários: leitura pública"
  on public.comments for select
  to anon, authenticated
  using (true);

drop policy if exists "comentários: escreve o próprio" on public.comments;
create policy "comentários: escreve o próprio"
  on public.comments for insert
  to authenticated
  with check (user_id = auth.uid());

drop policy if exists "comentários: edita o próprio" on public.comments;
create policy "comentários: edita o próprio"
  on public.comments for update
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

-- Apagar: o dono, ou a administração (moderação).
drop policy if exists "comentários: apaga o próprio ou a moderação" on public.comments;
create policy "comentários: apaga o próprio ou a moderação"
  on public.comments for delete
  to authenticated
  using (user_id = auth.uid() or public.is_admin());

-- Marca a edição no servidor: `edited` não é enviado pelo cliente.
create or replace function public.mark_comment_edited()
returns trigger
language plpgsql
as $$
begin
  if new.body is distinct from old.body then
    new.edited     := true;
    new.updated_at := now();
  end if;
  new.user_id := old.user_id;
  new.film_id := old.film_id;
  return new;
end;
$$;

drop trigger if exists comments_mark_edited on public.comments;
create trigger comments_mark_edited
  before update on public.comments
  for each row execute function public.mark_comment_edited();


-- -----------------------------------------------------------------------------
-- Ranking
--
-- Uma view, não uma tabela: não há nada para gravar, adulterar ou dessincronizar.
-- A pontuação é sempre derivada do que a pessoa efetivamente fez.
--
-- Vale repetir, porque é a parte que costuma escorregar: este número não aparece
-- em nenhuma política de acesso deste arquivo. Ele descreve participação e não
-- concede absolutamente nada.
-- -----------------------------------------------------------------------------

create or replace view public.community_ranking as
select
  p.id,
  p.username,
  p.display_name,
  p.avatar_url,
  p.created_at,
  coalesce(w.total, 0) as watched_count,
  coalesce(f.total, 0) as favorite_count,
  coalesce(r.total, 0) as rating_count,
  coalesce(c.total, 0) as comment_count,
  -- Sessão assistida pesa mais porque é o ato central da comunidade; comentar
  -- pesa mais que avaliar porque custa mais.
  coalesce(w.total, 0) * 4
    + coalesce(c.total, 0) * 3
    + coalesce(r.total, 0) * 2
    + coalesce(f.total, 0) as score
from public.profiles p
left join (select user_id, count(*) total from public.watched   group by user_id) w on w.user_id = p.id
left join (select user_id, count(*) total from public.favorites group by user_id) f on f.user_id = p.id
left join (select user_id, count(*) total from public.ratings   group by user_id) r on r.user_id = p.id
left join (select user_id, count(*) total from public.comments  group by user_id) c on c.user_id = p.id;

-- A view herda o RLS das tabelas de origem, todas de leitura pública.
alter view public.community_ranking set (security_invoker = true);
grant select on public.community_ranking to anon, authenticated;


-- Agregados por filme, para a ficha não precisar baixar todas as interações.
create or replace view public.film_stats as
select
  f.id as film_id,
  f.slug,
  coalesce(fav.total, 0)  as favorite_count,
  coalesce(wat.total, 0)  as watched_count,
  coalesce(rat.total, 0)  as rating_count,
  round(rat.average, 2)   as rating_average,
  coalesce(com.total, 0)  as comment_count
from public.films f
left join (select film_id, count(*) total from public.favorites group by film_id) fav on fav.film_id = f.id
left join (select film_id, count(*) total from public.watched   group by film_id) wat on wat.film_id = f.id
left join (select film_id, count(*) total, avg(score)::numeric average
           from public.ratings group by film_id) rat on rat.film_id = f.id
left join (select film_id, count(*) total from public.comments  group by film_id) com on com.film_id = f.id;

alter view public.film_stats set (security_invoker = true);
grant select on public.film_stats to anon, authenticated;


-- -----------------------------------------------------------------------------
-- updated_at
-- -----------------------------------------------------------------------------

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

do $$
declare
  t text;
begin
  foreach t in array array['films', 'ratings'] loop
    execute format(
      'drop trigger if exists %1$s_touch on public.%1$I;
       create trigger %1$s_touch before update on public.%1$I
       for each row execute function public.touch_updated_at();',
      t
    );
  end loop;
end
$$;
