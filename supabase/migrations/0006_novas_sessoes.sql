-- =============================================================================
-- Sessões novas
--
-- As fichas em src/content/films/ continuam sendo a fonte das páginas públicas.
-- Estas linhas existem pelo mesmo motivo de 0003_catalogo.sql: dar às
-- interações — favoritos, assistidos, avaliações, anotações — uma chave estável
-- para referenciar, e ao painel administrativo o que editar.
--
-- Um filme sem linha aqui aparece normalmente no site, mas a seção de anotações
-- se esconde e os botões de marcação não têm onde gravar.
--
-- Idempotente: `on conflict do nothing` em tudo. A 0003 não é tocada — o que já
-- foi aplicado continua como está.
--
-- Aplicar depois de 0005_ajustes.sql.
-- =============================================================================

-- eyes-wide-shut-1999 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'eyes-wide-shut-1999',
  'Até onde você iria para descobrir os desejos escondidos por trás de uma vida perfeita?',
  'Um suspense hipnótico e provocador sobre desejo, ciúme, poder e os segredos escondidos por trás das aparências',
  'Uma única conversa desfaz as certezas de um casamento perfeito. O que vem depois é uma noite inteira atravessando Nova York atrás de uma resposta',
  'Algumas histórias começam com uma ameaça.

Esta começa com uma conversa.

Nossa indicação desta semana é o último filme dirigido por Stanley Kubrick — um suspense psicológico que transforma uma noite comum em uma travessia hipnótica por desejo, ciúme e segredo. *De Olhos Bem Fechados* não grita em momento nenhum. Ele apenas abre uma porta atrás da outra, e cada uma leva um pouco mais fundo.

> “Nenhum sonho é apenas um sonho.”

## A Premissa

William Harford é um médico bem-sucedido que leva uma vida aparentemente perfeita ao lado de sua esposa, Alice.

O apartamento é bonito. O casamento é estável. As festas são as certas.

Até que uma conversa sobre desejo, fidelidade e fantasias secretas desmonta, em poucos minutos, tudo o que ele acreditava saber sobre a mulher com quem divide a vida.

Perturbado, William sai pela madrugada de Nova York.

O que começa como uma caminhada sem destino vira uma sequência de encontros inesperados, identidades ocultas e, no fim, uma sociedade secreta cercada por máscaras, poder e perigo.

Quanto mais fundo ele avança, mais difícil fica distinguir desejo de obsessão, sonho de realidade — e curiosidade de ameaça.

## Por que esta indicação?

Kubrick passou mais de um ano filmando *De Olhos Bem Fechados* e morreu poucos dias depois de mostrar o corte final.

O resultado é um filme construído com uma precisão quase insuportável: cada corredor, cada máscara e cada silêncio existe para manter quem assiste exatamente onde o protagonista está — sem chão, sem certeza, sem saber o que é real.

Em vez de explicar, o filme insinua. Em vez de responder, devolve a pergunta.

É por isso que ele continua sendo discutido quase três décadas depois: cada pessoa sai da sessão com uma leitura diferente, e nenhuma delas é claramente a errada.

## O que esperar

### Suspense psicológico

Não há sustos, perseguições nem reviravoltas ruidosas.

A tensão nasce da sensação constante de estar sendo observado, e de que algo muito maior se move logo abaixo da superfície.

### Um mistério sem chão

A cada nova cena, o filme oferece uma pista e retira outra.

Personagens aparecem, dizem exatamente o suficiente e desaparecem — deixando a impressão de que a resposta estava ali e passou.

### Desejo como ameaça

O que move a história não é um vilão.

É o que os personagens querem, o que escondem e o que fariam se ninguém estivesse olhando.

---

## Sem Spoilers

*De Olhos Bem Fechados* é um filme sobre descobrir aos poucos.

Evite explicações, teorias e análises antes da sessão — boa parte da experiência está em atravessar a noite junto com o protagonista, sem saber mais do que ele.

Entre sabendo apenas a premissa.

O resto acontece atrás da máscara.

## Conclusão

*De Olhos Bem Fechados* é a despedida de um dos maiores diretores do cinema, e ela chega em forma de enigma.

Misturando drama, mistério e suspense psicológico, o filme usa um casamento aparentemente perfeito para investigar o que existe embaixo de qualquer aparência: desejo, poder, medo e a distância entre o que se mostra e o que se sente.

Uma escolha certeira para quem gosta de filmes que não entregam a resposta pronta e continuam trabalhando na cabeça de quem assistiu muito depois do fim da sessão.',
  '/posters/eyes-wide-shut-1999.jpg',
  '#A0288F',
  '2026-08-29T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Drama', 'Mistério', 'Suspense Psicológico'],
  array['suspense', 'drama', 'mistério', 'perturbador', 'obsessão', 'clássico', 'cult', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'eyes-wide-shut-1999'), 1, 'De Olhos Bem Fechados', 1999, 'Stanley Kubrick', array['Drama', 'Mistério', 'Suspense Psicológico'], 159, '18', null)
on conflict (film_id, position) do nothing;

-- django-unchained-2012 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'django-unchained-2012',
  'Até onde um homem está disposto a ir para conquistar sua liberdade e salvar quem ama?',
  'Um faroeste explosivo sobre liberdade, vingança, coragem e a força de um homem determinado a recuperar tudo o que lhe foi tirado',
  'Um homem escravizado ganha a liberdade, um cavalo e uma arma. O que ele quer de volta, porém, está guardado na fazenda mais perigosa do sul',
  'Faroeste é um gênero feito de códigos: o forasteiro, o duelo, a cidade pequena, a lei que chega tarde.

*Django Livre* usa todos eles — e depois vira cada um do avesso.

Nossa indicação desta semana é o faroeste de Quentin Tarantino, uma história de liberdade e vingança ambientada no sul dos Estados Unidos dois anos antes da Guerra Civil. Tem humor, tem tensão, tem diálogos que se esticam até o limite. E tem, no centro de tudo, um homem tentando recuperar a única coisa que lhe importa.

> “O ‘D’ é mudo.”

## A Premissa

Django é um homem escravizado que tem sua liberdade comprada pelo misterioso Dr. King Schultz, um caçador de recompensas alemão que precisa de sua ajuda para identificar criminosos procurados.

O acordo é simples: Django aponta os rostos, Schultz cobra as recompensas.

Concluída a missão, os dois formam uma parceria improvável e passam a atravessar o sul dos Estados Unidos juntos.

Mas Django tem um objetivo muito maior do que dinheiro: encontrar e libertar sua esposa, Broomhilda, das mãos do cruel proprietário de terras Calvin Candie.

Para resgatá-la, os dois terão de entrar em uma das plantações mais perigosas da região — um lugar onde qualquer erro custa a vida, e onde a mentira precisa se sustentar até o fim.

## Por que esta indicação?

Tarantino nunca faz filme de época para reproduzir a época. Ele faz para reescrevê-la.

Aqui o alvo é a escravidão americana, tratada sem eufemismo nenhum: o filme mostra a brutalidade do sistema e depois entrega a arma ao homem que a sofreu.

A parceria entre Django e Schultz é o coração da história — dois estranhos que se respeitam antes de gostarem um do outro — e é ela que sustenta as quase três horas de tensão crescente até a plantação de Candie.

O resultado combina ação, humor, crítica histórica e algumas das melhores cenas de mesa já filmadas por Tarantino.

## O que esperar

### Faroeste em estado puro

Poeira, cavalo, chapéu e revólver. O filme leva a gramática do gênero a sério antes de subvertê-la.

### Diálogos que valem por um duelo

Nas melhores cenas ninguém saca a arma.

A disputa acontece na conversa, e a tensão vem de saber que uma palavra errada encerra o assunto.

### Uma vingança construída com paciência

*Django Livre* não tem pressa em chegar ao acerto de contas.

Ele constrói o motivo, cena após cena, até que a resposta pareça inevitável.

---

## Sem Spoilers

Boa parte da força do filme está em como a farsa se sustenta — e em quando ela deixa de se sustentar.

Quanto menos você souber sobre o plano, sobre a plantação e sobre quem enxerga o quê, mais intensa será a experiência.

Entre sabendo apenas a premissa.

## Conclusão

*Django Livre* rendeu a Tarantino o Oscar de roteiro original e a Christoph Waltz o de ator coadjuvante, e não é difícil entender por quê: é um filme em que cada conversa carrega peso e cada personagem tem exatamente o tamanho certo.

Mais do que um faroeste, é uma história sobre liberdade conquistada à força, sobre a coragem de voltar ao pior lugar possível por alguém, e sobre o prazer muito específico de ver um sistema violento receber de volta o que entregou.

Uma escolha obrigatória para quem gosta de grandes roteiros, personagens marcantes e filmes que equilibram brutalidade e humor sem perder o controle de nenhum dos dois.',
  '/posters/django-unchained-2012.jpg',
  '#C98A16',
  '2026-09-05T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Faroeste', 'Ação', 'Drama'],
  array['ação', 'drama', 'faroeste', 'vingança', 'clássico', 'crime', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'django-unchained-2012'), 1, 'Django Livre', 2012, 'Quentin Tarantino', array['Faroeste', 'Ação', 'Drama'], 165, '16', null)
on conflict (film_id, position) do nothing;

-- doctor-sleep-2019 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'doctor-sleep-2019',
  'Alguns fantasmas nunca abandonam os lugares onde nasceram',
  'Uma continuação sombria e emocionante sobre trauma, redenção e a coragem necessária para enfrentar os fantasmas do passado',
  'Danny Torrance cresceu, mas o Overlook não o esqueceu. Proteger uma menina com o mesmo dom vai obrigá-lo a voltar ao lugar onde tudo começou',
  'Toda continuação carrega uma pergunta difícil: o que sobrou?

*Doutor Sono* responde do jeito menos confortável possível — sobrou a criança.

Nossa indicação desta semana acompanha Danny Torrance décadas depois do Hotel Overlook, já adulto, ainda tentando afogar aquilo que viu quando era menino. É um filme de terror sobre trauma, dependência e a possibilidade de reconstruir alguma coisa em cima do que restou.

> “O mundo é um lugar faminto — e sombrio.”

## A Premissa

Décadas após os acontecimentos traumáticos do Hotel Overlook, Danny Torrance ainda carrega as marcas da infância e passa os dias fugindo dos fantasmas que continuam encontrando o caminho até ele.

Sua vida muda quando estabelece uma conexão à distância com Abra Stone, uma jovem cujo brilho é mais forte do que o de qualquer pessoa que ele já tenha encontrado.

O problema é que esse dom não passa despercebido.

O Verdadeiro Nó — um grupo que atravessa o país há muito mais tempo do que deveria — se alimenta exatamente dessa energia, e caça crianças que a possuem.

Para proteger Abra, Danny precisará encarar os próprios medos, revisitar o passado e voltar ao lugar onde seus piores pesadelos começaram.

## Por que esta indicação?

Mike Flanagan assumiu uma tarefa que parecia impossível: fazer uma continuação de *O Iluminado* que respeitasse ao mesmo tempo o livro de Stephen King e o filme de Stanley Kubrick — duas obras que o próprio King passou décadas dizendo serem incompatíveis.

O resultado não tenta repetir o original. Ele muda de assunto.

Onde *O Iluminado* era sobre um homem se perdendo, *Doutor Sono* é sobre a criança que sobreviveu a ele e precisou aprender a viver com isso.

O terror continua presente, mas a espinha do filme é outra: trauma herdado, vício e a chance de usar o próprio dano para proteger alguém.

## O que esperar

### Terror com paciência

Flanagan constrói o medo por acúmulo, e não por sobressalto.

A ameaça aparece cedo, se move devagar e nunca deixa de estar em cena.

### Uma continuação que se sustenta sozinha

Conhecer *O Iluminado* enriquece a experiência, mas o filme se explica.

Quem chega sem o original entende tudo; quem chega com ele reconhece muito mais.

### Fantasia sombria

O brilho não é apenas um sinal de perigo aqui: é um sistema com regras próprias, e o filme dedica tempo a mostrá-las funcionando.

---

## Sem Spoilers

Boa parte do impacto de *Doutor Sono* está em como ele reencontra o passado — e em quanto tempo leva até chegar lá.

Evite comparações, listas de referências e explicações sobre o terceiro ato.

Entre sabendo apenas quem é Danny e o que ele carrega.

O resto o filme entrega no tempo certo.

## Conclusão

*Doutor Sono* é uma continuação improvável que funciona justamente por não tentar ser o filme anterior.

Misturando terror, suspense e fantasia sombria, ele transforma uma história de assombração em uma história de sobrevivência — e sobre o que uma pessoa faz com o dano que recebeu quando finalmente aparece alguém que precisa dela.

Uma excelente escolha para quem gosta de terror construído com calma, personagens bem desenhados e histórias que tratam o passado como algo que se enfrenta, e não como algo do qual se foge.',
  '/posters/doctor-sleep-2019.jpg',
  '#33507A',
  '2026-09-19T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Terror', 'Suspense', 'Fantasia Sombria'],
  array['terror', 'suspense', 'drama', 'perturbador', 'sobrevivência', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'doctor-sleep-2019'), 1, 'Doutor Sono', 2019, 'Mike Flanagan', array['Terror', 'Suspense', 'Fantasia Sombria'], 152, '16', null)
on conflict (film_id, position) do nothing;

-- under-the-silver-lake-2018 · 1 exibição(ões)
insert into public.films
  (slug, headline, kicker, summary, body, poster_url, tone,
   session_at, room, room_url, genres, tags, published)
values (
  'under-the-silver-lake-2018',
  'E se todas as músicas, símbolos e coincidências escondessem uma mensagem secreta?',
  'Um mistério surreal e imprevisível sobre obsessão, conspirações e os códigos secretos escondidos por trás da cultura de Los Angeles',
  'A vizinha desaparece sem explicação e Sam decide investigar sozinho. Cada pista o afunda mais em uma Los Angeles feita de códigos, símbolos e paranoia',
  'Toda cidade tem seus mitos. Los Angeles tem uma indústria inteira produzindo os dela.

*O Mistério de Silver Lake* parte dessa ideia e a leva longe demais — de propósito.

Nossa indicação desta semana é um mistério surreal sobre um homem que decide que tudo significa alguma coisa: as letras das músicas, os símbolos nas embalagens, os mapas antigos, as capas dos discos. Quanto mais ele procura, mais encontra. E é exatamente aí que a coisa começa a ficar perigosa.

> “Toda cidade esconde um código. Algumas pessoas não deveriam decifrá-lo.”

## A Premissa

Sam é um jovem sem emprego, sem plano e sem pressa, que passa os dias observando a vida ao redor do próprio apartamento em Los Angeles.

Tudo muda quando ele conhece Sarah, uma vizinha misteriosa que desaparece de um dia para o outro sem deixar explicação.

Obcecado em descobrir o que aconteceu, Sam começa a investigar por conta própria.

A busca o leva a um labirinto de símbolos, mensagens escondidas, músicas tocadas ao contrário, mapas, revistas em quadrinhos e teorias espalhadas pela cidade inteira.

Quanto mais pistas encontra, mais a investigação se transforma em outra coisa — uma jornada em que realidade, paranoia e cultura pop deixam de ter fronteira clara.

## Por que esta indicação?

David Robert Mitchell fez *Corrente do Mal* e, em seguida, este — um filme que praticamente ninguém esperava e que dividiu opiniões desde a estreia em Cannes.

*O Mistério de Silver Lake* é uma investigação noir que nunca se compromete a ser apenas isso.

Ele funciona como paródia de Hollywood, como retrato de uma geração parada e como estudo sobre alguém que precisa que o mundo tenha um significado escondido — porque a alternativa é aceitar que não tem.

É um filme longo, estranho e deliberadamente frustrante em alguns momentos. E é justamente por isso que virou cult.

## O que esperar

### Mistério em camadas

Cada pista abre outra. Poucas fecham.

O prazer está mais em acompanhar a obsessão do protagonista do que em chegar a uma resposta limpa.

### Comédia sombria

O filme leva Sam a sério e ri dele ao mesmo tempo.

Boa parte do humor vem de vê-lo tratar coincidências banais como revelações históricas.

### Los Angeles como personagem

Piscinas, festas, mansões, colinas e outdoors.

A cidade aparece exatamente como ela se vende — e o filme passa duas horas procurando o que existe atrás disso.

---

## Sem Spoilers

*O Mistério de Silver Lake* é feito de descobertas, e quase todas perdem a graça quando contadas antes.

Evite explicações, vídeos de análise e listas de referências escondidas.

Entre sabendo apenas que uma vizinha desapareceu e que Sam decidiu procurar.

O resto é o filme.

## Conclusão

*O Mistério de Silver Lake* é um daqueles filmes que não cabem em uma frase.

Misturando mistério, suspense e comédia sombria, ele usa uma investigação improvável para falar sobre obsessão, fracasso, cultura pop e a vontade muito humana de acreditar que existe um código por trás de tudo.

Saiu de cartaz sem consenso e continua rendendo discussão anos depois — que é, no fim, exatamente o que ele queria.

Uma escolha certeira para quem gosta de filmes imprevisíveis, atmosferas estranhas e histórias que preferem deixar perguntas em aberto a fechar tudo com uma explicação.',
  '/posters/under-the-silver-lake-2018.jpg',
  '#3FA9A5',
  '2026-09-26T20:30:00-03:00'::timestamptz,
  'Sala 24',
  'https://discord.gg/B5DKdJuuWc',
  array['Mistério', 'Suspense', 'Comédia Sombria'],
  array['mistério', 'suspense', 'comédia', 'obsessão', 'cult', 'bizarro', 'indicação-da-semana'],
  true
)
on conflict (slug) do nothing;

insert into public.film_features
  (film_id, position, title, year, director, genres, runtime, rating, starts_at)
values
  ((select id from public.films where slug = 'under-the-silver-lake-2018'), 1, 'O Mistério de Silver Lake', 2018, 'David Robert Mitchell', array['Mistério', 'Suspense', 'Comédia Sombria'], 139, '18', null)
on conflict (film_id, position) do nothing;
