-- =============================================================================
-- Catálogo inicial
--
-- Gerado a partir das 14 fichas em src/content/films/. As páginas públicas
-- continuam sendo renderizadas do Markdown; estas linhas existem para dar às
-- interações — favoritos, assistidos, avaliações, comentários — uma chave
-- estável para referenciar, e para o painel administrativo ter o que editar.
--
-- Idempotente: `on conflict do nothing` em tudo. Rodar de novo não duplica nem
-- sobrescreve o que o painel já tiver alterado.
--
-- Os pôsteres são servidos de public/posters/. As páginas públicas continuam
-- usando as versões otimizadas de src/assets/films/ via astro:assets; estas
-- cópias existem para que poster_url aponte para algo que de fato responde —
-- caminho quebrado no banco é pior que campo vazio.
--
-- Regenerar após editar as fichas:  npm run seed:catalogo
--
-- Aplicar depois de 0002_plataforma.sql.
-- =============================================================================

-- the-long-walk-2025 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-long-walk-2025',
  'Continue caminhando — parar nunca foi uma opção',
  null,
  'Cem jovens. Uma única regra. Continue andando. Quem parar, morre',
  'Algumas histórias impressionam pelo tamanho das explosões.

Outras conseguem prender sua atenção apenas com uma pergunta.

**Até onde você iria para continuar vivo?**

Nossa indicação desta semana adapta uma das obras mais marcantes de Stephen King, entregando um suspense psicológico que transforma uma caminhada em uma disputa brutal pela sobrevivência. Sem monstros, sem superpoderes e sem grandes reviravoltas artificiais. Apenas pessoas comuns enfrentando seus próprios limites.

## A Premissa

Em um futuro distópico, cem adolescentes são escolhidos para participar da competição mais assistida do país.

Seu nome é **A Longa Marcha**.

As regras são simples.

Continue caminhando.

Existe uma velocidade mínima que deve ser mantida o tempo todo.

Quem diminui o ritmo recebe advertências.

Quem insiste em desacelerar... morre.

A competição termina apenas quando resta um único sobrevivente.

Em troca, o vencedor pode pedir qualquer coisa que desejar.

## Por que esta indicação?

A grande força de *The Long Walk* não está apenas na violência de sua premissa.

Está na forma como ela revela o comportamento humano diante do medo, do desgaste físico e da inevitabilidade da morte.

Enquanto a marcha avança, amizades surgem, rivalidades aparecem e cada personagem encontra uma maneira diferente de enfrentar o impossível.

Stephen King utiliza uma ideia extremamente simples para criar uma das histórias mais desconfortáveis de sua carreira, explorando temas como obediência, manipulação, esperança e sobrevivência.

É uma distopia que incomoda justamente porque parece cada vez menos impossível.

## O que esperar

### Suspense psicológico

O verdadeiro perigo não está apenas na competição.

Está na pressão constante, no desgaste emocional e na sensação de que qualquer pequeno erro pode ser definitivo.

### Uma distopia inquietante

O filme apresenta uma sociedade que transforma sofrimento em espetáculo, levantando questões sobre violência, poder e entretenimento.

Sem exageros, a crítica social se torna tão impactante quanto a própria competição.

### Personagens que evoluem juntos

Cada participante chega com suas próprias motivações, medos e expectativas.

Conforme a caminhada avança, suas relações se tornam uma parte essencial da experiência, tornando cada escolha ainda mais difícil.

---

## Sem Spoilers

Este é um daqueles filmes cuja experiência depende totalmente da descoberta.

Quanto menos você souber antes da sessão, maior será o impacto de cada decisão, de cada conversa e de cada quilômetro percorrido.

Entre na marcha sabendo apenas uma coisa:

**Parar nunca foi uma opção.**

## Conclusão

Muito além de uma competição de sobrevivência, *The Long Walk* é uma reflexão sobre resistência, sacrifício e os limites que alguém é capaz de ultrapassar quando não existe alternativa.

É um suspense que não depende de sustos para prender o espectador, mas da tensão crescente construída a cada passo.

Uma excelente escolha para quem gosta de distopias, histórias psicológicas e adaptações de Stephen King que permanecem na mente muito depois dos créditos finais.',
  '/posters/the-long-walk-2025.jpg',
  '#C93C3C',
  '2026-04-18T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Thriller', 'Distopia', 'Suspense'],
  array['thriller', 'suspense', 'distopia', 'sobrevivência', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-long-walk-2025'), 1, 'The Long Walk', 2025, 'Francis Lawrence', array['Thriller', 'Distopia', 'Suspense'], 108, '16', null)
on conflict (film_id, position) do nothing;

-- the-running-man-2026 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-running-man-2026',
  'Sobreviva por 30 dias enquanto o mundo te caça',
  null,
  'Quando sobreviver se torna entretenimento, cada segundo pode ser o último',
  'Quando o entretenimento ultrapassa qualquer limite, sobreviver deixa de ser uma questão de sorte e passa a ser um espetáculo assistido pelo mundo inteiro.

Nossa indicação desta semana coloca um homem comum diante da maior audiência do planeta, onde cada passo é transmitido ao vivo e cada erro pode custar sua vida. Um thriller de ação que mistura tensão, crítica social e ficção científica em um ritmo que dificilmente dá espaço para respirar.

## A Premissa

Em um futuro dominado pelo entretenimento extremo, um homem é escolhido para participar de um reality show mortal.

Seu objetivo parece simples.

Sobreviver por trinta dias.

Enquanto tenta escapar, caçadores profissionais, drones de vigilância e milhões de espectadores acompanham cada segundo da perseguição.

Quanto maior a audiência, mais perigoso o jogo se torna.

## Por que esta indicação?

Além das sequências de ação, *The Running Man* utiliza sua premissa para discutir temas cada vez mais atuais.

- A espetacularização da violência.
- A influência da mídia sobre a opinião pública.
- A obsessão por audiência.
- O limite entre entretenimento e ética.

Tudo isso sem deixar de entregar um blockbuster intenso e extremamente divertido.

## O que esperar

### Ação constante

A perseguição nunca desacelera.

Cada ambiente cria um novo desafio e obriga o protagonista a improvisar para continuar vivo.

### Ficção científica próxima da realidade

O filme constrói um futuro que parece exagerado apenas até percebermos quantas de suas ideias já fazem parte do presente.

### Suspense

A tensão aumenta conforme a caçada evolui.

O espectador acompanha cada decisão sabendo que qualquer erro pode ser fatal.

---

## Conclusão

Mais do que uma grande produção de ação, *The Running Man* propõe uma reflexão sobre até onde o entretenimento pode chegar quando audiência vale mais do que vidas.

Uma excelente escolha para quem gosta de suspense, perseguições inteligentes e ficção científica com críticas sociais.',
  '/posters/the-running-man-2026.jpg',
  '#FF3B30',
  '2026-04-25T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Ação', 'Thriller', 'Ficção Científica'],
  array['ação', 'thriller', 'ficção-científica', 'sobrevivência', 'indicação-da-semana', 'distopia', 'suspense'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-running-man-2026'), 1, 'The Running Man', 2025, 'Edgar Wright', array['Ação', 'Thriller', 'Ficção Científica'], 137, '16', null)
on conflict (film_id, position) do nothing;

-- vivarium-2019 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'vivarium-2019',
  'Nem toda casa é um lar',
  'Um dos conceitos mais perturbadores e originais do cinema moderno',
  'Uma casa perfeita. Um bairro perfeito. Um pesadelo do qual simplesmente não existe saída',
  'Comprar uma casa costuma representar o início de uma nova vida.

Em *Vivarium*, esse mesmo sonho se transforma em um dos pesadelos mais inquietantes do cinema contemporâneo.

Nossa indicação desta semana apresenta uma ficção científica perturbadora que mistura suspense psicológico, horror existencial e uma crítica silenciosa à rotina, ao conformismo e às expectativas impostas pela sociedade. Um filme que inquieta muito mais pelas perguntas que faz do que pelas respostas que oferece.

## A Premissa

Em busca da casa ideal, um jovem casal visita um condomínio recém-construído, composto por ruas vazias e casas absolutamente idênticas.

A visita deveria durar apenas alguns minutos.

Mas, ao tentarem ir embora, eles descobrem que todas as ruas levam exatamente ao mesmo lugar.

Sem saída.

Sem vizinhos.

Sem explicações.

Pouco tempo depois, uma caixa misteriosa aparece diante da casa contendo um bebê e uma única instrução.

**Criem a criança. Sobrevivam.**

A partir desse momento, a realidade passa a seguir regras que desafiam toda lógica.

## Por que esta indicação?

*Vivarium* é um daqueles filmes que permanecem na mente muito depois dos créditos finais.

Utilizando uma premissa simples, o diretor Lorcan Finnegan constrói uma narrativa que provoca desconforto constante, explorando temas como isolamento, repetição, identidade e o peso das convenções sociais.

Mais do que explicar seu universo, o filme convida o espectador a vivenciá-lo.

Cada detalhe do ambiente, dos personagens e da própria rotina contribui para criar uma atmosfera sufocante, onde o verdadeiro terror nasce da monotonia e da sensação de estar preso em um lugar do qual talvez nunca seja possível escapar.

## O que esperar

### Suspense psicológico

A tensão cresce de maneira gradual, sustentada muito mais pela atmosfera do que por sustos.

O desconhecido está presente em cada nova descoberta, mantendo uma sensação constante de inquietação.

### Ficção científica inquietante

Sem recorrer a grandes efeitos visuais, *Vivarium* constrói um universo estranho e fascinante, onde o cotidiano perde completamente sua lógica.

Quanto mais os personagens tentam compreender aquele lugar, mais distante parece qualquer possibilidade de resposta.

### Horror existencial

O verdadeiro desconforto não nasce apenas da situação vivida pelos protagonistas.

Nasce da possibilidade de reconhecer, naquele cenário absurdo, reflexos da própria realidade.

---

## Sem Spoilers

*Vivarium* funciona melhor quando cada descoberta acontece no momento certo.

Evite trailers completos, comentários e explicações sobre sua história.

Entre sabendo apenas o essencial.

O restante faz parte da experiência.

## Conclusão

Com uma proposta original e uma atmosfera que mistura estranhamento, suspense e reflexão, *Vivarium* transforma um ambiente comum em um dos cenários mais perturbadores do cinema recente.

É um filme que divide interpretações, provoca debates e desafia o espectador a encontrar significado em cada detalhe.

Uma excelente escolha para quem aprecia ficção científica inteligente, terror psicológico e histórias que permanecem ecoando muito depois do fim da sessão.',
  '/posters/vivarium-2019.jpg',
  '#7BAF7A',
  '2026-06-13T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Ficção Científica', 'Suspense', 'Terror Psicológico'],
  array['ficção-científica', 'suspense', 'terror', 'perturbador', 'obscuro', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'vivarium-2019'), 1, 'Vivarium', 2019, 'Lorcan Finnegan', array['Ficção Científica', 'Suspense', 'Terror Psicológico'], 97, '14', null)
on conflict (film_id, position) do nothing;

-- inglourious-basterds-2009 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'inglourious-basterds-2009',
  'A guerra será reescrita',
  'Um dos filmes mais marcantes de Quentin Tarantino, combinando diálogos memoráveis, tensão constante e uma releitura ousada da história',
  'Quentin Tarantino transforma um dos períodos mais sombrios da história em uma releitura ousada, marcada por diálogos inesquecíveis, tensão e vingança',
  'Existem filmes de guerra que buscam retratar a História.

Outros escolhem reimaginá-la.

Nesta semana, nossa sessão apresenta uma das obras mais icônicas de Quentin Tarantino, um filme que mistura ação, suspense e humor ácido para criar uma narrativa tão ousada quanto inesquecível. Com personagens marcantes, diálogos eletrizantes e uma tensão construída cena após cena, *Bastardos Inglórios* se tornou um dos grandes clássicos do cinema moderno.

## A Premissa

Durante a Segunda Guerra Mundial, um grupo de soldados judeus-americanos liderado pelo Tenente Aldo Raine inicia uma missão nada convencional.

Seu objetivo não é apenas vencer a guerra.

É espalhar medo entre as tropas nazistas.

Ao mesmo tempo, uma jovem francesa administra um cinema em Paris enquanto guarda um plano de vingança contra aqueles que destruíram sua família anos antes.

Quando esses caminhos finalmente se cruzam, o destino da guerra passa a depender de uma única noite.

## Por que esta indicação?

Poucos diretores possuem um estilo tão reconhecível quanto Quentin Tarantino.

Em *Bastardos Inglórios*, ele utiliza acontecimentos históricos apenas como ponto de partida para criar uma história completamente própria, onde o suspense nasce dos diálogos tanto quanto das cenas de ação.

Cada personagem possui personalidade marcante, cada conversa parece uma disputa silenciosa e cada encontro carrega uma tensão capaz de prender o espectador por longos minutos.

O resultado é um filme que equilibra violência, humor, drama e entretenimento de maneira única.

## O que esperar

### Diálogos inesquecíveis

Grande parte da força do filme está em suas conversas.

Mesmo nas cenas aparentemente mais simples, a tensão cresce palavra após palavra, tornando cada diálogo um verdadeiro espetáculo.

### Suspense em estado puro

Tarantino transforma pequenos momentos em sequências memoráveis, construindo uma atmosfera onde qualquer detalhe pode mudar completamente o rumo da história.

É um filme que prende pela expectativa tanto quanto pela ação.

### Uma releitura ousada da História

Sem compromisso com os fatos históricos, *Bastardos Inglórios* propõe uma versão alternativa da Segunda Guerra Mundial, utilizando o cinema como ferramenta de imaginação, justiça e vingança.

---

## Sem Spoilers

Uma das maiores qualidades de *Bastardos Inglórios* está na forma como suas cenas evoluem.

Quanto menos você souber sobre seus personagens, seus planos e seus encontros, mais intensa será a experiência.

Prepare-se para assistir a um filme que surpreende não apenas pelo que acontece, mas pela maneira como tudo é conduzido.

## Conclusão

Mais do que um filme de guerra, *Bastardos Inglórios* é uma celebração do poder do cinema de reinventar histórias.

Com atuações memoráveis, diálogos brilhantes, personagens inesquecíveis e a assinatura inconfundível de Quentin Tarantino, esta é uma obra que continua sendo referência mais de uma década após seu lançamento.

Uma escolha obrigatória para quem aprecia grandes roteiros, suspense bem construído e filmes capazes de transformar cada cena em um momento memorável.',
  '/posters/inglourious-basterds-2009.jpg',
  '#8B1E1E',
  '2026-06-27T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Guerra', 'Drama', 'Ação'],
  array['ação', 'drama', 'guerra', 'vingança', 'clássico', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'inglourious-basterds-2009'), 1, 'Bastardos Inglórios', 2009, 'Quentin Tarantino', array['Guerra', 'Drama', 'Ação'], 153, '18', null)
on conflict (film_id, position) do nothing;

-- the-menu-2022 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-menu-2022',
  'Nada será servido por acaso',
  'Cardápio da noite: tensão, ironia e desconforto psicológico',
  'Um jantar exclusivo. Um chef lendário. Um cardápio preparado para revelar muito mais do que sabores',
  'Alguns filmes conseguem transformar situações comuns em experiências inesquecíveis.

Outros fazem você nunca mais olhar da mesma forma para algo tão simples quanto um jantar.

Nossa indicação desta semana mistura suspense, humor ácido e terror psicológico em uma história que satiriza a alta gastronomia, o elitismo e a obsessão pela perfeição. O resultado é um filme elegante, desconfortável e imprevisível do começo ao fim.

## A Premissa

Um jovem casal recebe a oportunidade de jantar em um restaurante exclusivo localizado em uma ilha isolada.

O local é comandado por um chef renomado, conhecido mundialmente por transformar cada refeição em uma verdadeira obra de arte.

Os convidados esperam viver uma experiência gastronômica inesquecível.

E realmente vivem.

À medida que novos pratos são servidos, fica claro que aquela noite nunca foi apenas sobre comida.

Cada etapa do menu revela algo inesperado.

E nenhum dos convidados está ali por acaso.

## Por que esta indicação?

*The Menu* utiliza uma premissa criativa para construir uma crítica afiada sobre status, consumo, obsessão por exclusividade e a forma como transformamos experiências em símbolos de poder.

Ao mesmo tempo em que provoca risadas com seu humor sombrio, o filme mantém uma atmosfera constante de tensão, fazendo o espectador questionar o que realmente está acontecendo até os momentos finais.

É uma obra que equilibra suspense, ironia e desconforto com uma elegância rara.

## O que esperar

### Suspense crescente

A sensação de que existe algo errado está presente desde os primeiros minutos.

A cada prato servido, a tensão aumenta de forma quase imperceptível, criando uma atmosfera que prende a atenção até o último instante.

### Humor ácido

Mesmo nos momentos mais desconfortáveis, o filme encontra espaço para ironizar comportamentos, críticas sociais e o universo da alta gastronomia.

É um humor inteligente, muitas vezes tão incômodo quanto divertido.

### Terror psicológico

Sem depender de sustos constantes, *The Menu* constrói seu horror através da expectativa, dos diálogos e da inquietação provocada por cada nova revelação.

---

## Sem Spoilers

Parte da experiência de *The Menu* está justamente em descobrir seus ingredientes conforme a noite avança.

Quanto menos você souber antes da sessão, melhor.

Aceite o convite.

Sente-se à mesa.

E aproveite cada prato.

## Conclusão

Muito além de um suspense ambientado em um restaurante, *The Menu* entrega uma experiência cinematográfica que mistura crítica social, humor inteligente e tensão psicológica de maneira extremamente original.

É um daqueles filmes que convida o espectador a interpretar cada detalhe, tornando cada diálogo e cada cena parte de um grande banquete cuidadosamente preparado.

Uma escolha perfeita para quem aprecia histórias imprevisíveis, personagens marcantes e filmes que continuam provocando discussões muito depois dos créditos finais.',
  '/posters/the-menu-2022.jpg',
  '#C46B2A',
  '2026-06-30T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Suspense', 'Terror Psicológico', 'Comédia Sombria'],
  array['suspense', 'terror', 'comédia', 'perturbador', 'obsessão', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-menu-2022'), 1, 'The Menu', 2022, 'Mark Mylod', array['Suspense', 'Terror Psicológico', 'Comédia Sombria'], 107, '16', null)
on conflict (film_id, position) do nothing;

-- obsession-2026 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'obsession-2026',
  'Alguns desejos nunca deveriam ser realizados',
  'Um dos terrores mais comentados de 2026, transformando um simples desejo em uma espiral de horror psicológico',
  'Um desejo realizado pode parecer um presente. Mas, às vezes, é apenas o começo do verdadeiro pesadelo',
  'Todos nós já imaginamos como seria ter um desejo realizado.

Mas e se esse presente viesse acompanhado de consequências impossíveis de controlar?

Nossa indicação desta semana mergulha em um terror psicológico que combina romance, suspense e elementos sobrenaturais para explorar uma pergunta inquietante: até onde alguém iria para conquistar aquilo que mais deseja?

## A Premissa

Bear é um jovem apaixonado por sua melhor amiga.

Incapaz de revelar seus sentimentos, ele vive preso entre a esperança e o medo da rejeição.

Tudo muda quando ele encontra um misterioso artefato capaz de realizar um único desejo.

O impossível acontece.

Mas aquilo que parecia a resposta para todos os seus problemas rapidamente revela um lado sombrio.

Cada escolha possui um preço.

E alguns desejos nunca deveriam ser concedidos.

## Por que esta indicação?

*Obsessão* utiliza uma premissa simples para construir uma narrativa marcada por tensão constante e desconforto crescente.

O filme brinca com a ideia de que nossos maiores desejos podem esconder nossos maiores medos, conduzindo o espectador por uma história onde romance, obsessão e horror caminham lado a lado.

Em vez de depender apenas de sustos, a obra aposta em uma atmosfera inquietante e em consequências cada vez mais imprevisíveis, criando uma experiência que permanece na mente muito depois dos créditos finais.

## O que esperar

### Terror psicológico

O medo nasce das escolhas dos personagens e das consequências que surgem a cada novo acontecimento.

A tensão cresce de forma gradual, tornando cada decisão ainda mais angustiante.

### Romance sombrio

No centro da história existe um sentimento genuíno.

Mas, quando amor e obsessão deixam de ser separados por limites, tudo pode tomar um rumo inesperado.

### Horror sobrenatural

O artefato misterioso é apenas o ponto de partida para uma narrativa repleta de mistério, desconforto e acontecimentos difíceis de explicar.

---

## Sem Spoilers

*Obsessão* foi pensado para surpreender.

Quanto menos você souber sobre seus personagens e sobre os rumos da história, maior será o impacto de cada revelação.

Permita-se entrar na sessão conhecendo apenas a premissa.

O restante faz parte do preço desse desejo.

## Conclusão

*Obsessão* mostra que o verdadeiro horror nem sempre está em criaturas ou aparições, mas nas consequências das decisões tomadas quando o desejo fala mais alto que a razão.

Misturando suspense, terror psicológico e drama, o filme entrega uma experiência intensa, capaz de provocar reflexões sobre amor, obsessão e o custo de alterar aquilo que parecia destinado a nunca acontecer.

Uma excelente escolha para quem procura um terror moderno, inquietante e repleto de tensão do início ao fim.

---

```',
  '/posters/obsession-2026.jpg',
  '#5B0F18',
  '2026-07-02T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Terror', 'Suspense', 'Romance Sombrio'],
  array['terror', 'suspense', 'obsessão', 'perturbador', 'drama', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'obsession-2026'), 1, 'Obsessão', 2025, 'Curry Barker', array['Terror', 'Suspense', 'Romance Sombrio'], 108, '18', null)
on conflict (film_id, position) do nothing;

-- v-for-vendetta-2005 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'v-for-vendetta-2005',
  'Ideias são à prova de balas',
  'Um clássico moderno sobre liberdade, resistência e o poder das ideias',
  'Em um futuro dominado pelo medo, um homem mascarado desafia um regime totalitário e prova que nenhuma ideia pode ser executada',
  'Alguns filmes entretêm.

Outros permanecem relevantes por décadas.

*V de Vingança* é uma dessas obras. Muito além da ação e da estética marcante de seu protagonista, o filme utiliza a ficção científica para discutir liberdade, autoritarismo, manipulação da informação e o verdadeiro significado da resistência.

Uma história que continua provocando reflexões sempre que retorna às telas.

## A Premissa

Em uma Inglaterra governada por um regime totalitário, o medo tornou-se a principal ferramenta de controle da população.

É nesse cenário que surge um homem mascarado conhecido apenas como **V**.

Com inteligência, planejamento e uma determinação inabalável, ele inicia uma campanha contra o governo, desafiando um sistema construído sobre censura, vigilância e opressão.

Enquanto suas ações inspiram milhares de pessoas, uma jovem chamada Evey acaba envolvida nessa jornada e descobre que revoluções nem sempre começam com armas.

Às vezes, elas começam com uma ideia.

## Por que esta indicação?

Poucos filmes conseguiram transformar um símbolo em um fenômeno cultural como *V de Vingança*.

A máscara de Guy Fawkes ultrapassou as telas e passou a representar movimentos sociais em diversas partes do mundo, mas a força do filme vai muito além de sua iconografia.

Com diálogos memoráveis, personagens complexos e uma narrativa envolvente, a obra convida o espectador a refletir sobre os limites entre segurança e liberdade, poder e responsabilidade, conformismo e resistência.

É um filme que permanece atual justamente porque suas perguntas continuam relevantes.

## O que esperar

### Ficção científica com crítica social

O futuro apresentado pelo filme serve como um espelho para discutir temas que ainda fazem parte da realidade.

Sem depender de grandes efeitos, a narrativa constrói uma distopia convincente e inquietante.

### Personagens inesquecíveis

Cada personagem possui motivações claras e evolui de maneira marcante ao longo da história.

As relações construídas durante a narrativa dão ainda mais força aos conflitos apresentados.

### Diálogos que marcaram o cinema

Mais do que cenas de ação, *V de Vingança* é lembrado por discursos, conversas e reflexões que permanecem na memória muito depois dos créditos finais.

---

## Sem Spoilers

*V de Vingança* é um filme que recompensa quem o assiste sem conhecer todos os seus acontecimentos.

Permita que seus personagens, seus diálogos e seus mistérios conduzam a experiência.

Algumas ideias só revelam toda a sua força quando descobertas no momento certo.

## Conclusão

Mais do que um clássico da ficção científica, *V de Vingança* é uma obra sobre coragem, identidade e o poder transformador das ideias.

Com uma narrativa envolvente, atuações memoráveis e reflexões que permanecem atuais, o filme continua sendo uma das adaptações mais impactantes dos quadrinhos para o cinema.

Uma escolha indispensável para quem aprecia histórias inteligentes, personagens marcantes e filmes capazes de inspirar debates muito depois do encerramento da sessão.',
  '/posters/v-for-vendetta-2005.jpg',
  '#A31222',
  '2026-07-04T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Ação', 'Drama', 'Ficção Científica'],
  array['ação', 'drama', 'ficção-científica', 'cult', 'clássico', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'v-for-vendetta-2005'), 1, 'V de Vingança', 2005, 'James McTeigue', array['Ação', 'Drama', 'Ficção Científica'], 132, '16', null)
on conflict (film_id, position) do nothing;

-- lord-of-war-2005 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'lord-of-war-2005',
  'A guerra pode acabar — o comércio nunca',
  'Uma das críticas mais inteligentes e provocativas sobre o comércio internacional de armas já feitas no cinema',
  'Enquanto guerras começam e terminam, um homem transforma o caos em um dos negócios mais lucrativos do planeta',
  'Toda guerra precisa de soldados.

Mas, antes deles, alguém precisou vender as armas.

Nossa indicação desta semana apresenta um dos thrillers mais inteligentes dos anos 2000, baseado em fatos que parecem inacreditáveis. Com uma narrativa envolvente e uma atuação marcante de Nicolas Cage, *O Senhor das Armas* revela os bastidores de um mercado bilionário que prospera justamente onde o mundo mais sofre.

## A Premissa

Yuri Orlov é um imigrante que enxerga uma oportunidade onde quase ninguém ousaria procurar.

Enquanto conflitos explodem em diferentes partes do mundo, ele constrói uma carreira como traficante internacional de armas, negociando com governos, guerrilhas, mercenários e ditadores.

Quanto maior o conflito, maior o lucro.

Mas viver entre fronteiras, guerras e interesses políticos significa estar constantemente cercado por inimigos.

Enquanto tenta expandir seu império, Yuri passa a ser perseguido por um obstinado agente da Interpol, ao mesmo tempo em que vê sua vida pessoal se deteriorar diante das consequências de suas escolhas.

## Por que esta indicação?

*O Senhor das Armas* consegue equilibrar entretenimento e crítica social de maneira impressionante.

Sem recorrer ao sensacionalismo, o filme expõe como interesses econômicos, corrupção e política internacional caminham lado a lado em um mercado que movimenta bilhões todos os anos.

O roteiro evita apresentar respostas fáceis, preferindo colocar o espectador diante de dilemas morais complexos, onde lucro, poder e responsabilidade raramente seguem o mesmo caminho.

É um daqueles filmes que entretêm enquanto provocam reflexão.

## O que esperar

### Crime baseado em uma realidade desconfortável

Embora apresente personagens fictícios, a narrativa foi inspirada em histórias reais do comércio internacional de armas.

Essa proximidade com acontecimentos do mundo real torna cada negociação ainda mais impactante.

### Um protagonista fascinante

Yuri Orlov está longe de ser um herói.

Seu carisma, inteligência e frieza fazem dele um personagem complexo, capaz de conquistar o espectador ao mesmo tempo em que provoca questionamentos sobre suas escolhas.

### Crítica política e econômica

Muito além da ação, o filme convida o público a refletir sobre quem realmente lucra com as guerras e como interesses financeiros influenciam conflitos ao redor do mundo.

---

## Sem Spoilers

Grande parte da força de *O Senhor das Armas* está na maneira como sua história se desenvolve.

Evite pesquisar sobre seus acontecimentos antes da sessão.

Permita que cada negociação, cada decisão e cada consequência revelem, pouco a pouco, o verdadeiro alcance desse império construído sobre conflitos.

## Conclusão

Com um roteiro afiado, diálogos memoráveis e uma abordagem surpreendentemente atual, *O Senhor das Armas* permanece como uma das obras mais inteligentes sobre poder, corrupção e o custo humano dos grandes conflitos internacionais.

É um filme que vai além do gênero policial, oferecendo uma reflexão provocativa sobre ética, ambição e a indústria que prospera nas sombras das guerras.

Uma escolha indispensável para quem aprecia histórias baseadas em realidades desconfortáveis e filmes que continuam relevantes mesmo décadas após seu lançamento.',
  '/posters/lord-of-war-2005.jpg',
  '#6B4A2B',
  '2026-07-11T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Crime', 'Drama', 'Suspense'],
  array['crime', 'drama', 'suspense', 'cult', 'clássico', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'lord-of-war-2005'), 1, 'O Senhor das Armas', 2005, 'Andrew Niccol', array['Crime', 'Drama', 'Suspense'], 122, '16', null)
on conflict (film_id, position) do nothing;

-- what-you-wish-for-2023 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'what-you-wish-for-2023',
  'A oportunidade perfeita pode esconder um preço impagável',
  'Um thriller elegante que transforma ambição, identidade e privilégio em um jogo mortal de consequências imprevisíveis',
  'Um chef endividado encontra a chance de viver a vida que sempre sonhou. Mas alguns privilégios escondem segredos impossíveis de suportar',
  'Todos já imaginaram como seria começar do zero.

Uma nova identidade.

Uma nova vida.

Uma nova chance.

Nossa indicação desta semana apresenta um thriller elegante que transforma essa fantasia em um pesadelo cuidadosamente construído. Misturando suspense psicológico, drama e crime, *Aquilo que Você Deseja* conduz o espectador por uma história onde cada escolha aproxima seu protagonista de um caminho sem volta.

## A Premissa

Ryan é um chef talentoso.

Apesar de sua habilidade na cozinha, sua vida está desmoronando por causa de dívidas e escolhas equivocadas.

Buscando escapar do passado, ele aceita o convite de um antigo amigo para passar alguns dias em uma luxuosa propriedade na América Latina.

Mas um acontecimento inesperado muda completamente o rumo da viagem.

De repente, Ryan recebe a oportunidade de assumir uma nova identidade e viver uma vida cercada por riqueza, prestígio e conforto.

O problema é que esse novo mundo esconde um segredo muito mais sombrio do que ele poderia imaginar.

## Por que esta indicação?

*Aquilo que Você Deseja* foge do suspense tradicional ao construir sua tensão através das decisões do protagonista.

O filme explora temas como identidade, ambição, privilégio e culpa, mostrando como um sonho aparentemente perfeito pode se transformar em uma armadilha impossível de abandonar.

Com uma atmosfera sofisticada e um roteiro que evita respostas fáceis, a narrativa mantém o espectador constantemente desconfiado, fazendo com que cada nova descoberta aumente ainda mais a sensação de perigo.

## O que esperar

### Suspense crescente

A tensão não depende de grandes explosões ou perseguições.

Ela nasce das mentiras, dos silêncios e da constante sensação de que tudo pode desmoronar a qualquer instante.

### Um thriller elegante

Entre mansões luxuosas, alta gastronomia e personagens enigmáticos, o filme constrói um ambiente refinado que contrasta com o clima cada vez mais inquietante da história.

### Dilemas morais

Mais do que sobreviver, Ryan precisa decidir até onde está disposto a ir para manter a vida que sempre sonhou.

Cada escolha cobra um preço.

---

## Sem Spoilers

*Aquilo que Você Deseja* é um daqueles filmes que revelam suas cartas aos poucos.

Evite trailers completos e comentários sobre a trama.

Quanto menos você souber antes da sessão, mais impactante será acompanhar cada descoberta ao lado do protagonista.

## Conclusão

Com uma narrativa envolvente, atuações marcantes e uma atmosfera de constante tensão, *Aquilo que Você Deseja* transforma uma oportunidade aparentemente perfeita em um jogo perigoso de mentiras, ambição e sobrevivência.

É um thriller que mostra como os maiores riscos nem sempre surgem daquilo que tememos, mas daquilo que mais desejamos conquistar.

Uma excelente escolha para quem aprecia histórias inteligentes, cheias de suspense e reviravoltas capazes de manter o público preso até os momentos finais.

---

```',
  '/posters/what-you-wish-for-2023.webp',
  '#4B2E1F',
  '2026-07-16T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Suspense', 'Thriller', 'Drama'],
  array['suspense', 'thriller', 'drama', 'crime', 'obsessão', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'what-you-wish-for-2023'), 1, 'Aquilo que Você Deseja', 2023, 'Nicholas Tomnay', array['Suspense', 'Thriller', 'Drama'], 102, '16', null)
on conflict (film_id, position) do nothing;

-- bugonia-2025 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'bugonia-2025',
  'E se a conspiração fosse real?',
  'Uma sátira perturbadora sobre paranoia, poder e conspirações, dirigida por um dos cineastas mais originais da atualidade',
  'Dois conspiracionistas sequestram uma poderosa CEO acreditando que ela é uma alienígena infiltrada. Mas a verdade pode ser ainda mais desconcertante',
  'Teorias da conspiração costumam nascer da desconfiança.

Mas o que acontece quando alguém decide agir como se todas elas fossem verdade?

Nossa indicação desta semana mergulha em uma mistura incomum de suspense psicológico, ficção científica e humor sombrio. Com a assinatura provocativa de Yorgos Lanthimos, o filme transforma uma premissa absurda em uma experiência desconfortável, imprevisível e cheia de interpretações.

## A Premissa

Dois homens completamente obcecados por teorias conspiratórias chegam a uma conclusão perturbadora.

A CEO de uma poderosa empresa não é humana.

Convencidos de que ela faz parte de uma raça alienígena infiltrada na Terra, eles decidem sequestrá-la para impedir uma suposta ameaça à humanidade.

O que começa como um plano aparentemente insano rapidamente evolui para um intenso jogo psicológico, onde cada conversa levanta novas dúvidas.

Quem está dizendo a verdade?

Quem realmente perdeu o controle da realidade?

## Por que esta indicação?

Poucos cineastas conseguem transformar situações absurdas em histórias tão fascinantes quanto Yorgos Lanthimos.

Em *Bugonia*, a paranoia se mistura à crítica social, explorando temas como manipulação, poder, fanatismo, desinformação e a facilidade com que crenças podem moldar a percepção da realidade.

O filme desafia o espectador a questionar constantemente aquilo que vê, evitando respostas fáceis e conduzindo a narrativa por caminhos inesperados.

É uma obra que provoca tanto quanto entretém.

## O que esperar

### Suspense psicológico

A tensão cresce a partir dos diálogos, das atitudes dos personagens e da incerteza sobre o que realmente está acontecendo.

Cada nova cena faz a linha entre realidade e delírio parecer ainda mais tênue.

### Humor ácido

Mesmo abordando situações inquietantes, o filme encontra espaço para uma sátira inteligente sobre conspirações, extremismos e o comportamento humano.

O resultado é um humor desconfortável, característico das obras de Lanthimos.

### Ficção científica provocativa

Mais interessada em ideias do que em grandes efeitos visuais, a narrativa utiliza elementos de ficção científica para levantar perguntas sobre identidade, verdade e confiança.

---

## Sem Spoilers

*Bugonia* foi pensado para surpreender.

Quanto menos você souber sobre seus personagens e sobre os rumos da história, maior será o impacto de cada revelação.

Permita-se entrar na sessão apenas com a pergunta que move todo o filme:

**E se eles estiverem certos?**

## Conclusão

Misturando paranoia, humor sombrio e ficção científica de forma singular, *Bugonia* entrega uma experiência que desafia expectativas e convida o público a questionar suas próprias certezas.

É um filme que prefere provocar dúvidas em vez de oferecer respostas prontas, mantendo a tensão até seus momentos finais.

Uma excelente escolha para quem aprecia histórias originais, sátiras inteligentes e obras que permanecem abertas à interpretação muito depois do encerramento da sessão.',
  '/posters/bugonia-2025.webp',
  '#556B2F',
  '2026-07-18T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Suspense Psicológico', 'Ficção Científica', 'Comédia Sombria'],
  array['suspense', 'ficção-científica', 'comédia', 'perturbador', 'bizarro', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'bugonia-2025'), 1, 'Bugonia', 2025, 'Yorgos Lanthimos', array['Suspense Psicológico', 'Ficção Científica', 'Comédia Sombria'], 118, '18', null)
on conflict (film_id, position) do nothing;

-- ready-or-not-double-feature-2026 · 2 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'ready-or-not-double-feature-2026',
  'Duas histórias, um único dia de sobrevivência',
  'Sessão Dupla Especial — uma noite inteira dedicada ao horror',
  'Uma noiva, dois jogos mortais e uma tradição capaz de transformar um casamento em uma luta desesperada pela sobrevivência',
  'Algumas famílias têm tradições.

A família Le Domas tem um ritual.

Nesta Sessão Dupla Especial, revisitamos um dos maiores sucessos do terror moderno e, em seguida, acompanhamos sua aguardada continuação. Misturando horror, suspense e humor ácido, os dois filmes transformam uma celebração em uma noite onde sobreviver é a única forma de vencer.

Prepare-se para uma maratona repleta de tensão, violência estilizada e reviravoltas.

---

## 1ª EXIBIÇÃO — Casamento Sangrento (2019)

**Horário:** **19:30 (Horário de Brasília)**

### A Premissa

Grace acredita estar vivendo o dia mais feliz de sua vida ao se casar com o herdeiro de uma família extremamente rica e tradicional.

Antes da comemoração terminar, porém, ela descobre que existe um antigo ritual que todo novo integrante deve cumprir.

O que começa como uma inocente brincadeira transforma-se rapidamente em um jogo mortal de esconde-esconde.

Para sobreviver até o amanhecer, Grace precisará enfrentar uma família disposta a fazer qualquer coisa para preservar sua tradição.

#### O que esperar

- Terror com muito humor ácido.
- Suspense crescente do início ao fim.
- Personagens memoráveis.
- Uma protagonista impossível de esquecer.

---

## 2ª EXIBIÇÃO — Casamento Sangrento: A Viúva (2026)

**Horário:** **21:30 (Horário de Brasília)**

### A Premissa

Momentos após sobreviver ao massacre que mudou sua vida, Grace descobre que sua luta estava longe de terminar.

Agora, um novo jogo mortal coloca diferentes famílias ocultistas em rota de colisão, enquanto antigos segredos e novas alianças ampliam a dimensão daquele ritual macabro.

Mais perigosa do que nunca, ela precisará enfrentar um inimigo muito maior do que imaginava.

#### O que esperar

- Escala ainda maior que a do primeiro filme.
- Novos personagens e novas regras.
- Humor sombrio aliado a cenas de tensão constante.
- Continuação direta dos acontecimentos do original. :contentReference[oaicite:0]{index=0}

---

## Por que esta Sessão Dupla?

Poucas continuações conseguem expandir o universo do filme original sem abandonar sua identidade.

Assistir aos dois filmes na mesma noite permite acompanhar a evolução da protagonista, entender melhor os segredos por trás da família Le Domas e perceber como a franquia amplia seu universo mantendo a mistura de terror, humor ácido e sobrevivência que conquistou o público.

É uma oportunidade perfeita para experimentar essa história da maneira como ela foi construída: um capítulo levando diretamente ao outro.

---

### Programação

🕢 **19:30** — Casamento Sangrento (2019)

🕤 **21:30** — Casamento Sangrento: A Viúva (2026)

## Sem Spoilers

Os dois filmes funcionam como uma experiência única.

Evite pesquisar sobre a sequência antes da primeira exibição e preserve todas as surpresas entre um filme e outro.

Cada revelação faz parte da diversão.

## Conclusão

Da tensão claustrofóbica do primeiro jogo à expansão do universo apresentada na sequência, esta Sessão Dupla reúne duas das produções mais divertidas do terror contemporâneo.

Violência estilizada, humor ácido, personagens marcantes e muita adrenalina fazem desta uma maratona perfeita para quem gosta de horror moderno.

Uma noite inteira dedicada à sobrevivência.',
  '/posters/ready-or-not-double-feature-2026.jpg',
  '#8B0000',
  '2026-07-25T19:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Terror', 'Suspense', 'Comédia Sombria'],
  array['sessão-dupla', 'terror', 'suspense', 'comédia', 'sobrevivência'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'ready-or-not-double-feature-2026'), 1, 'Casamento Sangrento', 2019, 'Matt Bettinelli-Olpin & Tyler Gillett', array['Terror', 'Suspense', 'Comédia Sombria'], 95, null, '19:30'),
  ((select id from public.films where slug = 'ready-or-not-double-feature-2026'), 2, 'Casamento Sangrento: A Viúva', 2026, 'Matt Bettinelli-Olpin & Tyler Gillett', array['Terror', 'Suspense', 'Comédia Sombria'], 108, null, '21:30')
on conflict (film_id, position) do nothing;

-- truth-treachery-2026 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'truth-treachery-2026',
  'Quando a lealdade ao país entra em conflito com a consciência',
  'Uma emocionante história de coragem, consciência e resistência inspirada em fatos reais',
  'Inspirado em uma história real, um jovem desafia um dos regimes mais cruéis da história ao escolher a verdade acima do medo',
  'A maioria das grandes histórias de guerra acontece nos campos de batalha.

Esta acontece dentro da consciência de um adolescente.

Nossa indicação desta semana resgata uma história real de coragem extraordinária, mostrando que resistir nem sempre exige armas. Às vezes, basta recusar uma mentira. Em meio ao avanço do nazismo, um jovem decide enfrentar um regime construído sobre medo, propaganda e silêncio.

## A Premissa

Durante a Segunda Guerra Mundial, o jovem **Helmuth Hübener**, de apenas dezesseis anos, começa a perceber que a realidade apresentada pelo governo nazista está muito distante da verdade.

Movido por sua consciência, ele passa a ouvir transmissões estrangeiras proibidas e descobre informações que o regime fazia de tudo para esconder.

Ao lado de seus amigos Karl e Rudi, Helmuth organiza uma pequena rede clandestina para produzir e distribuir panfletos denunciando as mentiras da propaganda oficial.

Cada folha entregue representa um ato de resistência.

E cada nova decisão aproxima o grupo de consequências irreversíveis.

## Por que esta indicação?

*Verdade e Traição* não é apenas um drama histórico.

É uma reflexão poderosa sobre integridade, coragem e responsabilidade individual diante da injustiça.

Inspirado em acontecimentos reais, o filme mostra como pessoas comuns podem realizar atos extraordinários quando escolhem agir de acordo com seus princípios.

Sem recorrer a grandes batalhas, a narrativa constrói uma tensão constante através das escolhas dos personagens, lembrando que, em tempos de opressão, dizer a verdade pode ser o maior gesto de coragem.

## O que esperar

### Uma história baseada em fatos reais

O impacto do filme cresce ao saber que seus acontecimentos foram inspirados na vida de Helmuth Hübener, um dos mais jovens integrantes da resistência alemã contra o nazismo.

### Drama humano

Mais do que retratar um período histórico, o filme acompanha o amadurecimento de jovens obrigados a fazer escolhas impossíveis diante de um regime brutal.

### Suspense constante

Cada panfleto distribuído, cada encontro secreto e cada decisão carregam o risco de colocar tudo a perder.

A tensão acompanha toda a narrativa, mesmo sem depender de cenas de ação.

---

## Sem Spoilers

Esta é uma história cujo verdadeiro impacto está em acompanhar as escolhas de seus personagens.

Evite pesquisar detalhes sobre os acontecimentos antes da sessão.

Permita que cada descoberta, cada risco e cada momento de coragem aconteçam naturalmente.

## Conclusão

Com sensibilidade, tensão e um profundo respeito pelos acontecimentos que inspiraram sua narrativa, *Verdade e Traição* presta homenagem àqueles que escolheram enfrentar a injustiça mesmo quando tudo parecia perdido.

É um filme sobre coragem silenciosa, consciência e o poder transformador da verdade, lembrando que, em alguns momentos da história, o ato mais revolucionário foi simplesmente se recusar a aceitar uma mentira.

Uma excelente escolha para quem aprecia dramas históricos inspiradores, histórias reais e personagens cuja bravura permanece atual décadas depois.

---

```',
  '/posters/truth-treachery-2026.webp',
  '#4A4A4A',
  '2026-08-08T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Drama', 'Histórico', 'Suspense'],
  array['drama', 'suspense', 'histórico', 'guerra', 'clássico', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'truth-treachery-2026'), 1, 'Verdade e Traição', 2025, 'Matt Whitaker', array['Drama', 'Histórico', 'Suspense'], 121, '16', null)
on conflict (film_id, position) do nothing;

-- the-inheritance-2025 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'the-inheritance-2025',
  'A fortuna da família está à venda — e ele pretende comprá-la com vingança',
  'Uma comédia de humor ácido onde vingança, ambição e herança se encontram em um plano tão inteligente quanto imprevisível',
  'Deserdado desde o nascimento, um homem transforma a disputa por uma herança bilionária em um jogo mortal repleto de humor ácido e reviravoltas',
  'Famílias brigam por heranças desde que o mundo é mundo.

Mas poucas disputas chegam tão longe quanto esta.

Nossa indicação desta semana mistura suspense, humor ácido e uma boa dose de ironia para contar a história de um homem disposto a recuperar aquilo que acredita ser seu por direito. Em um jogo onde ambição, vingança e interesses milionários se cruzam, ninguém pode confiar que estará vivo até o fim da disputa.

## A Premissa

Becket Redfellow nasceu cercado por riqueza.

Mas nunca teve direito a ela.

Deserdado por sua poderosa família ainda no nascimento, ele cresce alimentando um único objetivo: recuperar a fortuna que acredita lhe pertencer.

Para isso, coloca em prática um plano meticuloso.

Enquanto os herdeiros disputam a fortuna da família, uma sucessão de acidentes cuidadosamente planejados começa a reduzir a lista de sucessores.

Quanto menos herdeiros restam...

Mais próximo Becket chega de sua vingança.

## Por que esta indicação?

*Manual Prático da Vingança Lucrativa* utiliza uma premissa clássica para construir um suspense leve, divertido e repleto de humor sombrio.

O filme brinca com a ganância, os conflitos familiares e a obsessão por dinheiro, transformando uma disputa por herança em um verdadeiro jogo de estratégia.

Entre reviravoltas, personagens excêntricos e situações imprevisíveis, a narrativa mantém um equilíbrio constante entre tensão e comédia, entregando uma experiência tão divertida quanto imprevisível.

## O que esperar

### Humor ácido

O filme encontra humor justamente nas situações mais absurdas, utilizando a disputa familiar como combustível para momentos de ironia e sarcasmo.

### Suspense com reviravoltas

À medida que os acontecimentos se desenrolam, novas alianças surgem e diferentes interesses entram em conflito, mantendo a dúvida sobre quem realmente está no controle.

### Uma disputa por milhões

Mais do que uma história sobre dinheiro, o filme explora até onde alguém é capaz de ir quando acredita que a vida lhe deve uma reparação.

---

## Sem Spoilers

As maiores surpresas de *Manual Prático da Vingança Lucrativa* acontecem justamente quando menos se espera.

Evite pesquisar detalhes sobre a trama antes da sessão.

Quanto menos você souber sobre os personagens e seus planos, mais divertida será a experiência.

## Conclusão

Misturando suspense, humor ácido e personagens movidos pela ambição, *Manual Prático da Vingança Lucrativa* transforma uma disputa por herança em um jogo de manipulação, estratégia e vingança.

É um filme que diverte ao mesmo tempo em que satiriza a obsessão por riqueza e poder, mostrando que, quando milhões estão em jogo, até os laços familiares podem se tornar descartáveis.

Uma excelente escolha para quem aprecia comédias sombrias, histórias cheias de reviravoltas e personagens capazes de fazer qualquer coisa para alcançar seus objetivos.

---

```',
  '/posters/the-inheritance-2025.webp',
  '#7A4B1F',
  '2026-08-15T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Comédia', 'Suspense'],
  array['comédia', 'suspense', 'crime', 'vingança', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'the-inheritance-2025'), 1, 'Manual Prático da Vingança Lucrativa', 2025, 'Dan Berk & Robert Olsen', array['Comédia', 'Suspense'], 99, '16', null)
on conflict (film_id, position) do nothing;

-- limitless-2011 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'limitless-2011',
  'E se você pudesse desbloquear todo o potencial da sua mente?',
  'Um thriller inteligente que explora os limites da ambição, da inteligência e do preço do poder',
  'Uma droga experimental promete liberar todo o potencial da mente humana. O problema é que nenhum poder vem sem consequências',
  'Todos já imaginaram como seria ter uma memória perfeita.

Aprender qualquer idioma em poucos dias.

Resolver problemas impossíveis em segundos.

Nossa indicação desta semana parte dessa fantasia para construir um thriller envolvente sobre ambição, poder e as consequências de ultrapassar os limites da mente humana. *Sem Limites* combina ficção científica e suspense em uma história que faz o espectador se perguntar o que faria se pudesse alcançar seu potencial máximo.

## A Premissa

Eddie Morra é um escritor talentoso, mas completamente perdido.

Sem dinheiro, sem inspiração e preso em uma rotina frustrante, ele vê sua vida mudar ao experimentar o **NZT-48**, uma droga experimental capaz de ampliar drasticamente suas capacidades cognitivas.

De repente, tudo faz sentido.

Sua memória se torna perfeita.

Seu raciocínio é quase instantâneo.

O sucesso financeiro e profissional chega mais rápido do que ele jamais imaginou.

Mas cada nova dose aproxima Eddie de um preço que talvez ele não esteja preparado para pagar.

## Por que esta indicação?

*Sem Limites* utiliza uma ideia fascinante para discutir temas muito atuais, como obsessão pelo desempenho, busca incessante pelo sucesso e o desejo de superar as próprias limitações.

O filme prende a atenção ao mostrar como um poder extraordinário pode se transformar em dependência, levantando dilemas éticos e pessoais sem perder o ritmo de um excelente thriller.

É uma obra que mistura entretenimento e reflexão, mantendo o suspense do início ao fim.

## O que esperar

### Uma premissa instigante

A pergunta que move o filme é simples, mas poderosa:

O que você faria se pudesse utilizar todo o potencial da sua mente?

A partir dessa ideia, a narrativa constrói situações cada vez mais intensas.

### Suspense inteligente

Mais do que ação, o filme aposta em estratégia, manipulação e decisões difíceis, criando uma tensão constante conforme as consequências do NZT-48 começam a surgir.

### Reflexões sobre ambição

*Sem Limites* questiona até onde vale a pena ir para alcançar riqueza, influência e sucesso.

Quando tudo parece possível, o verdadeiro desafio passa a ser manter o controle.

---

## Sem Spoilers

Grande parte da experiência de *Sem Limites* está em acompanhar a transformação de Eddie e descobrir, pouco a pouco, as consequências de suas escolhas.

Evite pesquisar detalhes da trama antes da sessão.

Quanto menos você souber, maior será o impacto de cada descoberta.

## Conclusão

Com uma ideia original, ritmo envolvente e uma atuação marcante de Bradley Cooper, *Sem Limites* continua sendo um dos thrillers de ficção científica mais interessantes de sua geração.

É um filme que combina entretenimento, suspense e questionamentos sobre inteligência, ambição e dependência, mostrando que o maior poder nem sempre é aquele que conseguimos conquistar, mas aquele que somos capazes de controlar.

Uma excelente escolha para quem gosta de histórias inteligentes, cheias de tensão e conceitos capazes de provocar reflexão muito depois dos créditos finais.

---

```',
  '/posters/limitless-2011.jpg',
  '#2E5FA8',
  '2026-08-22T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Ficção Científica', 'Suspense', 'Thriller'],
  array['ficção-científica', 'suspense', 'thriller', 'drama', 'obsessão', 'cult', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'limitless-2011'), 1, 'Sem Limites', 2011, 'Neil Burger', array['Ficção Científica', 'Suspense', 'Thriller'], 105, '14', null)
on conflict (film_id, position) do nothing;
