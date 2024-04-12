import { defineConfig } from '@adonisjs/auth'
import { tokensGuard, tokensUserProvider } from '@adonisjs/auth/access_tokens'
import { Authenticators, InferAuthEvents } from '@adonisjs/auth/types'

export const authProvider = tokensUserProvider({
  tokens: 'accessTokens',
  model: () => import('#models/user'),
})

const authConfig = defineConfig({
  default: 'api',
  guards: {
    api: tokensGuard({
      provider: authProvider,
    }),
  },
})

export default authConfig

/**
 * Inferring types from the configured auth
 * guards.
 */
declare module '@adonisjs/auth/types' {
  interface Authenticators extends InferAuthenticators<typeof authConfig> {}
}
declare module '@adonisjs/core/types' {
  interface EventsList extends InferAuthEvents<Authenticators> {}
}
