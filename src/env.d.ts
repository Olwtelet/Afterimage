/// <reference types="astro/client" />

import type { Session } from './lib/auth';

declare global {
  namespace App {
    interface Locals {
      /**
       * Sessão resolvida pelo middleware, uma vez por requisição.
       *
       * Sempre `null` em rota pré-renderizada: ali não existe requisição para
       * interceptar. Páginas estáticas resolvem o estado de login no cliente.
       */
      session: Session | null;
    }
  }
}

export {};
