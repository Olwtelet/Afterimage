/**
 * Slugs para URLs em português.
 *
 * O site antigo trocava cada caractere acentuado por um hífen, produzindo
 * /tags/a-o/ para "ação" e /tags/fic-o-cient-fica/ para "ficção científica".
 * Aqui os acentos são transliterados, que é o que o leitor e o buscador esperam.
 */
export function slugify(input: string): string {
  return input
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '') // remove os diacríticos separados pelo NFD
    .replace(/ç/gi, 'c')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
}
