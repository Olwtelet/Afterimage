-- =============================================================================
-- Sessões de outubro
--
-- Mesmo papel de 0006_novas_sessoes.sql: as fichas em src/content/films/
-- continuam sendo a fonte das páginas públicas, e estas linhas dão às
-- interações — favoritos, assistidos, avaliações, anotações — uma chave estável
-- para referenciar, e ao painel administrativo o que editar.
--
-- Sem a linha aqui a sessão aparece normalmente no site, mas a seção de
-- anotações se esconde e os botões de marcação não têm onde gravar.
--
-- Idempotente: `on conflict do nothing` em tudo. Nenhuma migração anterior é
-- tocada — reescrever migração já aplicada é pedir para as cópias divergirem.
--
-- Aplicar depois de 0007_uma_anotacao.sql.
-- =============================================================================

-- the-lobster-2015 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-lobster-2015',
  'Num mundo onde estar sozinho é um crime, encontrar alguém é uma questão de sobrevivência',
  'Uma distopia seca e desconfortavelmente engraçada sobre solidão, imposição afetiva e as regras que inventamos para não ficar sozinhos',
  'David tem 45 dias para encontrar um par. O prazo é literal, a punição é literal, e fugir do hotel não significa escapar das regras',
  'Numa comédia romântica, a história começa quando duas pessoas se encontram.

*O Lagosta* começa com um prazo.

Nossa indicação desta semana é uma distopia em que estar solteiro deixou de ser uma situação e passou a ser uma infração. Há um hotel, há um regulamento e há uma contagem de dias. Ninguém no filme acha isso estranho, e é justamente essa naturalidade que torna tudo tão desconfortável.

> “Você tem 45 dias para encontrar um parceiro. Caso contrário, será transformado em um animal.”

## A Premissa

Em uma sociedade que proíbe a vida solitária, pessoas sem par são levadas a um hotel no campo.

Lá, cada hóspede tem 45 dias para encontrar alguém. Quem não consegue é transformado em um animal de sua escolha.

David chega recém-separado, acompanhado de um cão, e passa a seguir a rotina da casa: refeições em horário, danças organizadas, palestras didáticas sobre as vantagens de não estar sozinho.

O regulamento é detalhado e o pessoal do hotel o aplica sem hesitar.

Para dar certo, um casal precisa comprovar que tem algo em comum. Uma característica, um defeito, uma condição. Qualquer coisa que sirva de justificativa aceitável.

Quando o hotel se torna insustentável, David foge para a floresta e se junta aos Solitários, um grupo clandestino que vive escondido e rejeita qualquer forma de relacionamento.

E descobre, ali, que viver sozinho também tem seu próprio código de conduta.

## Por que esta indicação?

*O Lagosta* é o primeiro filme em inglês de Yorgos Lanthimos, grego que já havia chamado atenção com *Dente Canino*, e que aqui trouxe o mesmo método para uma coprodução europeia com elenco internacional.

O Prêmio do Júri em Cannes, em 2015, era um destino previsível para um filme assim. A indicação ao Oscar de roteiro não era: a Academia raramente olha para uma premissa que ameaça transformar gente em animal.

Colin Farrell e Rachel Weisz conduzem a história num registro muito específico: a atuação deadpan e a dicção monocórdia são escolha deliberada de direção, aplicada a todo o elenco.

Ninguém entona, ninguém enfatiza, ninguém reage no volume que a cena pediria. As pessoas dizem o que sentem como quem lê um informe.

Esse recurso faz duas coisas ao mesmo tempo. Produz humor, porque a distância entre o que é dito e o tom em que é dito é absurda. E produz desconforto, porque a frieza expõe o que a história está realmente discutindo.

O alvo do filme não é um governo totalitário imaginário. É a pressão cotidiana e perfeitamente familiar de ter que estar com alguém, e a facilidade com que se aceita qualquer arranjo para cumprir essa exigência.

## O que esperar

### Comédia por absurdo

O riso vem da seriedade com que todos tratam regras insanas.

Nenhum personagem comenta o absurdo. A piada existe exatamente por isso.

### Um mundo com regras firmes

A distopia não é explicada em prólogo nem em letreiro.

Ela aparece em procedimentos, formulários e punições aplicadas na frente da câmera, relatados por uma narração que informa sem nunca justificar, até que o espectador entenda sozinho como aquilo opera.

### Frieza como método

Planos simétricos, câmera parada, música clássica em volume alto demais.

A forma é controlada do mesmo jeito que o hotel controla seus hóspedes, e o efeito é cumulativo.

---

## Sem Spoilers

O regulamento de *O Lagosta* chega item por item, e o filme nunca sinaliza qual deles vai apertar.

Evite resenhas detalhadas, compilados de cenas e qualquer texto que liste as regras do hotel.

Descobrir cada nova regra no momento em que ela aparece é metade da experiência.

Vale também não procurar explicação sobre o que vem depois da primeira metade. O filme muda de chão mais de uma vez, e cada mudança rende mais quando chega de surpresa.

Entre sabendo apenas o que está escrito aqui: um hotel, um prazo de 45 dias e uma floresta.

## Conclusão

*O Lagosta* é uma ficção científica que não gasta um minuto construindo tecnologia, cidade futurista ou explicação científica.

Toda a sua estranheza vem de levar uma única exigência social até a consequência literal, e então filmar as pessoas obedecendo.

Misturando ficção científica, comédia sombria e drama, o filme transforma um prazo arbitrário em conversa sobre coisas bem concretas: solidão, conveniência, a tentação de forjar afinidade para não ficar de fora e o custo de recusar o combinado.

Funciona para quem gosta de distopias secas, de piadas ditas em tom de protocolo e de filmes que levam o absurdo tão a sério quanto um manual de instruções.',
  '/posters/the-lobster-2015.jpg',
  '#4F7A4A',
  '2026-10-17T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Ficção Científica', 'Comédia Sombria', 'Drama'],
  array['ficção-científica', 'distopia', 'comédia', 'drama', 'bizarro', 'cult', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-lobster-2015'), 1, 'O Lagosta', 2015, 'Yorgos Lanthimos', array['Ficção Científica', 'Comédia Sombria', 'Drama'], 119, '16', null)
on conflict (film_id, position) do nothing;

-- pulp-fiction-1994 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'pulp-fiction-1994',
  'Você nunca sabe o que vai acontecer depois',
  'Um mosaico criminal contado fora de ordem sobre acaso, código de conduta e conversas que pesam mais do que tiros',
  'Três histórias de crime em Los Angeles se cruzam fora de ordem. Uma maleta, uma luta marcada e um assalto em uma lanchonete bastam para desarrumar tudo',
  'Quase todo filme conta os fatos na ordem em que acontecem. É o acordo silencioso entre quem filma e quem assiste.

*Pulp Fiction: Tempo de Violência* desfaz esse acordo no primeiro corte.

Nossa indicação desta semana é o filme que reorganizou o cinema americano dos anos 1990: três histórias de crime em Los Angeles, contadas fora de ordem cronológica, que se cruzam em pontos que só ficam claros depois de passarem. O diálogo se alonga, o humor é seco, a violência chega sem transição — e nunca dá para prever qual das três coisas vem na próxima cena.

> “O caminho dos justos é cercado por todos os lados pelas iniquidades dos egoístas.”

## A Premissa

Vincent Vega e Jules Winnfield são dois assassinos de aluguel que trabalham para Marsellus Wallace.

A tarefa do dia é simples no papel: recuperar uma maleta que pertence ao chefe.

Enquanto isso, um boxeador veterano chamado Butch Coolidge recebe a ordem de perder uma luta e precisa decidir o que fazer com ela.

Em outra ponta da cidade, um casal de pequenos criminosos conclui que assaltar uma lanchonete é mais seguro do que assaltar uma loja de bebidas.

Nenhuma dessas histórias existe sozinha.

Los Angeles aqui é um lugar pequeno demais para tanta gente armada, e as vidas de assassinos, gângsteres, lutadores, garçons e clientes comuns se encostam em sequência. Às vezes por acaso. Às vezes porque alguém tomou uma decisão ruim três cenas antes.

## Por que esta indicação?

Quentin Tarantino tinha dirigido um único longa quando levou este roteiro a Cannes.

Saiu de lá com a Palma de Ouro de 1994 e, no ano seguinte, dividiu com Roger Avary o Oscar de roteiro original.

O traço mais conhecido do filme é a estrutura: os capítulos não estão na ordem em que acontecem, e cabe a quem assiste montar a cronologia enquanto a história avança.

Não é truque gratuito. Reorganizar o tempo muda o peso de cada cena, porque informação que normalmente chegaria antes chega depois.

O elenco é a outra metade. John Travolta voltou ao primeiro plano depois de anos fora, Samuel L. Jackson construiu aqui o papel que carrega até hoje, e Uma Thurman e Bruce Willis ocupam blocos inteiros do filme em registros completamente diferentes.

Financiado e distribuído pela Miramax, com orçamento modesto para o resultado, *Pulp Fiction* transformou o cinema independente americano em assunto de bilheteria.

E a maleta, que move boa parte da trama, nunca tem o conteúdo mostrado. O filme abre a maleta em cena, mas só deixa ver o brilho que vem de dentro, e nunca revela o que há ali. Essa omissão virou parte do mito dele.

## O que esperar

### Diálogo como ação

As cenas mais tensas acontecem em mesas, carros e apartamentos.

Dois personagens conversam sobre banalidades até que a conversa deixe de ser banal, e a passagem de uma coisa para a outra é o mecanismo central do filme.

### Humor e violência no mesmo plano

A piada e o susto dividem a mesma cena com frequência.

A troca nunca vem sinalizada. É o que mantém a tensão de pé por duas horas e meia.

### Uma estrutura que recompensa atenção

Personagens reaparecem em momentos que você já viu de outro ângulo.

Detalhes soltos no primeiro capítulo fazem sentido no terceiro, e nada disso é explicado em voz alta.

---

## Sem Spoilers

O prazer de *Pulp Fiction* depende de não saber para onde cada capítulo vai.

Evite resumos cronológicos, vídeos que colocam o filme “na ordem certa” e listas de cenas famosas.

Evite também as teorias sobre a maleta.

Entre sabendo apenas que existem três histórias e que elas se tocam.

## Conclusão

*Pulp Fiction: Tempo de Violência* é um filme de crime montado como quebra-cabeça, e os 154 minutos passam sem peso nenhum.

Misturando crime, drama e comédia sombria, ele acompanha dois assassinos de aluguel, um boxeador encurralado e um casal desastrado para chegar sempre ao mesmo assunto: acaso, código de conduta e decisões tomadas em poucos segundos.

Três décadas depois, continua sendo citado, copiado e discutido. E continua funcionando pelo motivo mais simples que existe: as cenas são boas isoladas e melhores juntas.

Vale a sessão para quem gosta de grandes diálogos, de estruturas narrativas fora do comum e de filmes em que o imprevisto é método, não acidente.',
  '/posters/pulp-fiction-1994.jpg',
  '#C8A23A',
  '2026-10-24T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Crime', 'Drama', 'Comédia Sombria'],
  array['crime', 'drama', 'comédia', 'suspense', 'clássico', 'cult', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'pulp-fiction-1994'), 1, 'Pulp Fiction: Tempo de Violência', 1994, 'Quentin Tarantino', array['Crime', 'Drama', 'Comédia Sombria'], 154, '18', null)
on conflict (film_id, position) do nothing;

-- the-hateful-eight-2015 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-hateful-eight-2015',
  'Ninguém chega aqui por acaso. Ninguém sai daqui inocente',
  'Um faroeste de porta fechada sobre desconfiança, mentira e o que acontece quando oito estranhos ficam presos no mesmo lugar',
  'Uma nevasca tranca oito desconhecidos na mesma hospedaria. Um deles veio para tirar a prisioneira de lá, e ninguém sabe qual',
  'O faroeste foi construído ao ar livre, na planície, na estrada longa, debaixo de céu aberto.

*Os Oito Odiados* passa quase todo o tempo dentro de uma sala.

Nossa indicação desta semana é um filme em que a ameaça não vem de fora. A nevasca tranca a porta, a cidade está longe e todos os suspeitos estão sentados à mesma mesa. O resto é descobrir quem mentiu ao entrar.

> “Você pode confiar em um estranho. Mas nunca confie em um homem desesperado.”

## A Premissa

Wyoming, poucos anos depois da Guerra Civil. Uma diligência atravessa a neve rumo a Red Rock.

Dentro dela viajam o caçador de recompensas John Ruth, conhecido como The Hangman, e Daisy Domergue, a prisioneira que ele pretende entregar viva para que seja enforcada com as formalidades devidas.

No caminho, a diligência recolhe dois homens presos na neve: o major Marquis Warren, outro caçador de recompensas, e um sujeito que se apresenta como o novo xerife de Red Rock.

A nevasca fecha o caminho antes do fim da viagem, e o grupo é forçado a buscar abrigo em uma hospedaria isolada no meio da estrada, a Minnie’s Haberdashery, onde outros viajantes já esperam que o tempo passe.

Lá dentro há um ex-oficial confederado, um carrasco inglês, um cowboy de poucas palavras e um mexicano que diz estar cuidando da casa na ausência da dona.

Ruth tem uma certeza desconfortável: ninguém escolta um prisioneiro de dez mil dólares sem atrair companhia interessada. Confinados pela tempestade, os oito começam a medir cada frase que ouvem, e a desconfiança, ali, custa mais caro que a neve.

## Por que esta indicação?

Este é o oitavo longa de Quentin Tarantino, e o segundo faroeste dele depois de *Django Livre* — dois filmes muito diferentes feitos do mesmo gênero.

A diferença mais visível está na forma. Tarantino rodou *Os Oito Odiados* em Ultra Panavision 70, um formato de tela larguíssima que não era usado desde os anos 1960, e exibiu o filme numa versão roadshow mais longa, com abertura musical e intervalo, como se fosse um épico de outra época.

A piada é deliberada: a tela mais larga possível para contar uma história que acontece praticamente num único interior. Com aquele enquadramento, o espaço da hospedaria fica sempre visível por inteiro, e o filme passa quase três horas obrigando quem assiste a vigiar o fundo do plano.

A trilha original é de Ennio Morricone, que havia escrito a música dos maiores faroestes italianos e voltou ao gênero aqui, aos 87 anos. Ela lhe rendeu o Oscar — o primeiro da carreira dele em competição.

O elenco foi montado como um tabuleiro de peças fixas: Kurt Russell e Samuel L. Jackson puxam o filme por lados opostos, Walton Goggins e Tim Roth ocupam posições que mudam de sentido conforme a noite avança, e Jennifer Jason Leigh faz a prisioneira acorrentada a um homem que não a solta.

É um filme de conversa, de posição e de paciência.

## O que esperar

### Um filme de interior

Quase tudo acontece numa sala, com as mesmas pessoas, à vista uma da outra.

A geografia do lugar importa: quem está perto da porta, quem está perto da arma, quem acabou de sair.

### Interrogatório disfarçado de conversa

Ninguém pergunta diretamente o que quer saber.

As cenas demoram de propósito: é falando demais que alguém acaba se contradizendo.

### Violência seca e sem aviso

Quando a calma se rompe, ela se rompe de uma vez e sem coreografia.

É um filme de classificação 18 e usa esse espaço sem pedir licença.

---

## Sem Spoilers

*Os Oito Odiados* é construído como um enigma de sala fechada, e qualquer informação adiantada estraga o jogo.

Evite sinopses longas, discussões sobre a ordem dos capítulos e vídeos que expliquem a identidade dos personagens.

Entre sabendo apenas isto: uma prisioneira, um caçador de recompensas e uma hospedaria cheia de gente que afirma estar ali por coincidência.

O filme cuida do resto na ordem que escolheu.

## Conclusão

*Os Oito Odiados* é o filme mais contido de Tarantino e, ao mesmo tempo, o mais barulhento na forma: setenta milímetros de tela para mostrar oito pessoas sem ter para onde ir.

Misturando faroeste, mistério e suspense, ele pega a estrutura de um romance policial de ambiente fechado e a planta na neve do Wyoming, onde a lei é uma palavra que cada um usa do jeito que lhe convém.

A tensão nasce de uma coisa simples e muito antiga: todos estão armados, todos têm motivo para mentir, e a tempestade não deixa ninguém sair.

Uma escolha certeira para quem gosta de roteiros que trabalham na conversa, de ambientes fechados e de histórias em que a dúvida sobre quem é cada um vale mais do que qualquer tiroteio.',
  '/posters/the-hateful-eight-2015.jpg',
  '#8E9BA3',
  '2026-10-31T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Faroeste', 'Mistério', 'Suspense'],
  array['faroeste', 'mistério', 'suspense', 'crime', 'vingança', 'perturbador', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-hateful-eight-2015'), 1, 'Os Oito Odiados', 2015, 'Quentin Tarantino', array['Faroeste', 'Mistério', 'Suspense'], 168, '18', null)
on conflict (film_id, position) do nothing;
