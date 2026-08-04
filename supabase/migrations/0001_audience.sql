-- =============================================================================
-- Audiência e mural
--
-- O site é estático e conversa com o Supabase direto do navegador, usando a
-- chave publishable. Por isso quem define o que pode ser lido e escrito é o RLS
-- desta migração — nunca o JavaScript do cliente, que qualquer pessoa reescreve.
--
-- Aplicar com:  supabase db push
-- ou colando no SQL Editor do projeto.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Audiência
--
-- Substitui o contador público de terceiro que o site usava antes, que era
-- inflável por qualquer GET e ficava fora do controle do projeto.
--
-- A tabela tem uma linha só e NÃO é exposta ao cliente: o navegador só alcança
-- a função abaixo, que incrementa no máximo uma vez e devolve o total.
-- -----------------------------------------------------------------------------

create table if not exists public.audience (
  id    smallint primary key default 1,
  total bigint   not null    default 0,
  constraint audience_single_row check (id = 1)
);

insert into public.audience (id, total)
values (1, 0)
on conflict (id) do nothing;

alter table public.audience enable row level security;
-- Sem policy: nenhuma role anônima lê ou escreve a tabela diretamente.

create or replace function public.bump_audience(should_increment boolean default true)
returns bigint
language plpgsql
security definer
set search_path = public
as $$
declare
  result bigint;
begin
  if should_increment then
    update public.audience set total = total + 1 where id = 1
    returning total into result;
  else
    select total into result from public.audience where id = 1;
  end if;

  return coalesce(result, 0);
end;
$$;

revoke all on function public.bump_audience(boolean) from public;
grant execute on function public.bump_audience(boolean) to anon, authenticated;


-- -----------------------------------------------------------------------------
-- Mural
--
-- Recados de visitantes. `approved` nasce falso: nada aparece no site sem passar
-- pela moderação. O cliente pode inserir e pode ler apenas o que já foi
-- aprovado — jamais a fila de pendentes, e jamais atualizar ou apagar.
-- -----------------------------------------------------------------------------

create table if not exists public.mural_entries (
  id         uuid        primary key default gen_random_uuid(),
  name       text        not null,
  website    text,
  message    text        not null,
  vibe       text,
  approved   boolean     not null default false,
  created_at timestamptz not null default now(),

  constraint mural_name_length    check (char_length(name)    between 1 and 40),
  constraint mural_message_length check (char_length(message) between 1 and 500),
  constraint mural_website_scheme check (website is null or website ~* '^https?://')
);

-- Reconciliação com a tabela do site antigo.
--
-- `create table if not exists` pula a tabela INTEIRA quando ela já existe — e
-- ela provavelmente existe, porque a versão anterior do site usava este mesmo
-- projeto e este mesmo nome. Nesse caso os defaults e as constraints acima nunca
-- seriam aplicados, e o mural passaria a aceitar recado sem limite de tamanho e,
-- pior, com `approved` indefinido. O bloco abaixo garante o estado final
-- independentemente de a tabela ter nascido aqui ou já estar lá.

do $$
begin
  -- Colunas que podem faltar numa versão antiga da tabela.
  alter table public.mural_entries add column if not exists vibe       text;
  alter table public.mural_entries add column if not exists website    text;
  alter table public.mural_entries add column if not exists approved   boolean;
  alter table public.mural_entries add column if not exists created_at timestamptz;

  -- Nada entra aprovado. Esta é a linha que sustenta a moderação inteira.
  update public.mural_entries set approved   = false where approved   is null;
  update public.mural_entries set created_at = now() where created_at is null;

  alter table public.mural_entries alter column approved   set default false;
  alter table public.mural_entries alter column approved   set not null;
  alter table public.mural_entries alter column created_at set default now();
  alter table public.mural_entries alter column created_at set not null;
end
$$;

-- Constraints são adicionadas à parte: `add constraint` não aceita `if not
-- exists`, então cada uma é criada só quando ausente.
do $$
declare
  wanted record;
begin
  for wanted in
    select *
    from (values
      ('mural_name_length',    'check (char_length(name) between 1 and 40)'),
      ('mural_message_length', 'check (char_length(message) between 1 and 500)'),
      ('mural_website_scheme', 'check (website is null or website ~* ''^https?://'')')
    ) as t(name, definition)
  loop
    if not exists (
      select 1 from pg_constraint
      where conrelid = 'public.mural_entries'::regclass
        and conname  = wanted.name
    ) then
      execute format(
        'alter table public.mural_entries add constraint %I %s',
        wanted.name, wanted.definition
      );
    end if;
  end loop;
end
$$;

create index if not exists mural_entries_approved_created_idx
  on public.mural_entries (created_at desc)
  where approved;

alter table public.mural_entries enable row level security;

drop policy if exists "mural: leitura pública dos aprovados" on public.mural_entries;
create policy "mural: leitura pública dos aprovados"
  on public.mural_entries
  for select
  to anon, authenticated
  using (approved);

drop policy if exists "mural: qualquer um assina, ninguém se autoaprova" on public.mural_entries;
create policy "mural: qualquer um assina, ninguém se autoaprova"
  on public.mural_entries
  for insert
  to anon, authenticated
  with check (approved is false);
