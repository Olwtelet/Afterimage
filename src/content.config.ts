import { defineCollection } from 'astro:content';
import { glob } from 'astro/loaders';
import { z } from 'astro/zod';

/**
 * Uma exibição — um filme dentro de uma sessão.
 * Sessões simples têm uma; a Sessão Dupla tem duas, cada uma com seu horário.
 */
const feature = z.object({
  title: z.string().min(1),
  year: z.number().int().min(1888).max(2100),
  director: z.string().min(1),
  runtime: z.number().int().positive().describe('duração em minutos'),
  genres: z.array(z.string().min(1)).min(1),
  /** Classificação indicativa brasileira. Ausente quando a ficha não informa. */
  rating: z.enum(['L', '10', '12', '14', '16', '18']).optional(),
  /** Só em sessão dupla, onde cada exibição tem horário próprio. */
  time: z
    .string()
    .regex(/^\d{2}:\d{2}$/)
    .optional(),
});

export type Feature = z.infer<typeof feature>;

const films = defineCollection({
  loader: glob({ pattern: '**/*.md', base: './src/content/films' }),
  schema: ({ image }) =>
    z.object({
      /** A manchete editorial — a provocação, não o nome do filme. */
      headline: z.string().min(1),
      /** Frase de fecho da ficha, quando existe. */
      kicker: z.string().min(1).optional(),
      summary: z.string().min(1).max(300),
      poster: image(),
      posterAlt: z.string().min(1),
      /**
       * Cor curada do filme. É ela que decide a qual barra SMPTE a sessão
       * pertence — ver src/lib/smpte.ts.
       */
      tone: z
        .string()
        .regex(/^#[0-9A-Fa-f]{6}$/, 'use hexadecimal de 6 dígitos, ex. #C0C000'),
      session: z.object({
        date: z.coerce.date(),
        time: z.string().regex(/^\d{2}:\d{2}$/),
        room: z.string().min(1),
        // z.url() no lugar de z.string().url(), que está depreciado nesta versão.
        roomUrl: z.url(),
      }),
      features: z.array(feature).min(1).max(4),
      tags: z.array(z.string().min(1)).min(1),
    }),
});

export const collections = { films };
