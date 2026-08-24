-- =============================================================================
-- Uma anotação por pessoa em cada filme
--
-- A seção nunca foi um fio de conversa: é a margem de um caderno, onde cada
-- pessoa registra o que ficou daquela sessão. Empilhar anotações no mesmo filme
-- transformava a margem em thread — e mudar de ideia já tinha um caminho, que é
-- editar a anotação que existe.
--
-- A interface passa a esconder o formulário de quem já anotou. Mas limite de
-- interface é sugestão: quem manda a requisição direto passa por cima. Quem
-- impõe é a constraint.
--
-- Aplicar depois de 0006_novas_sessoes.sql.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Sobras da regra antiga
--
-- Onde alguém tiver mais de uma anotação no mesmo filme, a PRIMEIRA fica e as
-- demais saem — do contrário a constraint não pode ser criada. O `id` entra no
-- desempate para que duas anotações gravadas no mesmo instante ainda tenham uma
-- ordem definida, em vez de a escolha depender do plano de execução.
--
-- Sem duplicatas, este comando não apaga nada.
-- -----------------------------------------------------------------------------

delete from public.comments atual
using public.comments anterior
where atual.user_id = anterior.user_id
  and atual.film_id = anterior.film_id
  and (anterior.created_at, anterior.id) < (atual.created_at, atual.id);


-- -----------------------------------------------------------------------------
-- A regra
-- -----------------------------------------------------------------------------

alter table public.comments drop constraint if exists comments_uma_por_filme;

alter table public.comments
  add constraint comments_uma_por_filme unique (user_id, film_id);
