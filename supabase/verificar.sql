-- =============================================================================
-- Verificação
--
-- Cole no SQL Editor DEPOIS de aplicar a migração. Cada linha do resultado é uma
-- afirmação sobre o estado do banco, com "ok" ou "FALHOU" na primeira coluna.
--
-- Não altera nada: só lê o catálogo do Postgres e faz uma chamada de leitura à
-- função da audiência.
-- =============================================================================

with checagens as (

  -- --- Audiência -------------------------------------------------------------

  select
    1 as ordem,
    'tabela audience existe' as item,
    to_regclass('public.audience') is not null as passou

  union all
  select
    2,
    'audience tem exatamente uma linha',
    (select count(*) = 1 from public.audience)

  union all
  select
    3,
    'RLS ligado em audience (cliente não alcança a tabela)',
    coalesce((select relrowsecurity from pg_class where oid = 'public.audience'::regclass), false)

  union all
  select
    4,
    'audience SEM policy (nenhum acesso anônimo direto)',
    not exists (select 1 from pg_policies where tablename = 'audience')

  union all
  select
    5,
    'função bump_audience existe',
    exists (
      select 1 from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public' and p.proname = 'bump_audience'
    )

  union all
  select
    6,
    'anon pode executar bump_audience',
    has_function_privilege('anon', 'public.bump_audience(boolean)', 'execute')

  union all
  select
    7,
    'bump_audience responde (leitura, sem incrementar)',
    public.bump_audience(false) >= 0

  -- --- Mural -----------------------------------------------------------------

  union all
  select
    8,
    'tabela mural_entries existe',
    to_regclass('public.mural_entries') is not null

  union all
  select
    9,
    'approved tem default false',
    (
      select column_default = 'false'
      from information_schema.columns
      where table_schema = 'public'
        and table_name   = 'mural_entries'
        and column_name  = 'approved'
    )

  union all
  select
    10,
    'as 3 constraints de validação existem',
    (
      select count(*) = 3
      from pg_constraint
      where conrelid = 'public.mural_entries'::regclass
        and conname in ('mural_name_length', 'mural_message_length', 'mural_website_scheme')
    )

  union all
  select
    11,
    'RLS ligado em mural_entries',
    coalesce((select relrowsecurity from pg_class where oid = 'public.mural_entries'::regclass), false)

  union all
  select
    12,
    'existe policy de SELECT restrita a aprovados',
    exists (
      select 1 from pg_policies
      where tablename = 'mural_entries' and cmd = 'SELECT' and qual ilike '%approved%'
    )

  union all
  select
    13,
    'existe policy de INSERT que barra autoaprovação',
    exists (
      select 1 from pg_policies
      where tablename = 'mural_entries' and cmd = 'INSERT' and with_check ilike '%approved%'
    )

  union all
  select
    14,
    'NÃO existe policy de UPDATE ou DELETE para o cliente',
    not exists (
      select 1 from pg_policies
      where tablename = 'mural_entries' and cmd in ('UPDATE', 'DELETE')
    )
)

select
  case when passou then 'ok' else 'FALHOU' end as status,
  item
from checagens
order by ordem;


-- -----------------------------------------------------------------------------
-- Fila de moderação — recados aguardando aprovação
-- -----------------------------------------------------------------------------
-- select id, name, message, created_at
-- from public.mural_entries
-- where not approved
-- order by created_at desc;

-- Aprovar um recado:
-- update public.mural_entries set approved = true where id = 'cole-o-id-aqui';
