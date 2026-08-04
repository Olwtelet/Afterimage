-- =============================================================================
-- Remove os cargos do Discord
--
-- A ideia de espelhar cargos foi abandonada. Nada na plataforma os exibia, e
-- mantê-los custava uma segunda ida à API do Discord dentro do fluxo de login
-- para alimentar uma coluna que ninguém lia.
--
-- O pertencimento ao servidor (`guild_member`) permanece: continua sendo exibido
-- no perfil como selo, e continua sem conceder permissão nenhuma.
--
-- Opcional. Deixar a coluna não quebra nada — ela só ocupa espaço descrevendo
-- algo que o código não usa mais.
-- =============================================================================

alter table public.profiles drop column if exists guild_roles;
