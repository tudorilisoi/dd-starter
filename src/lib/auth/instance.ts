// src/lib/auth/instance.ts
import type { betterAuth } from 'better-auth'

type AuthInstance = ReturnType<typeof betterAuth>

let authInstance: AuthInstance | null = null

export function setAuthInstance(auth: AuthInstance): void {
  authInstance = auth
}

export function getAuthInstance(): AuthInstance {
  if (!authInstance) {
    throw new Error('Auth not initialized')
  }
  return authInstance
}
