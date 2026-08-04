-- =============================================================================
-- Ajustes
--
-- Aplicar depois de 0004_sem_cargos.sql.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Anotações: limite de 500 caracteres
--
-- A interface já limita o campo, mas limite de interface é sugestão: quem manda
-- a requisição direto passa por cima. Quem impõe é a constraint.
--
-- Anotações mais longas que isso, se existirem, são cortadas — do contrário a
-- constraint não pode ser criada.
-- -----------------------------------------------------------------------------

update public.comments
set body = left(body, 500)
where char_length(body) > 500;

alter table public.comments drop constraint if exists comments_body_length;

alter table public.comments
  add constraint comments_body_length
  check (char_length(body) between 1 and 500);


-- -----------------------------------------------------------------------------
-- Audiência: garantir que a função existe
--
-- A migração 0001 já a cria. Esta repetição existe porque o contador é a peça
-- mais fácil de ficar para trás: ele degrada em silêncio, exibindo traços, então
-- uma migração não aplicada não produz erro nenhum — só um mostrador que nunca
-- funciona e ninguém sabe por quê.
--
-- `create or replace` é seguro de rodar sobre a versão que já estiver lá.
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
