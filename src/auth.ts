// src/auth.ts
import { betterAuth } from 'better-auth';
import { prismaAdapter } from 'better-auth/adapters/prisma';
import { prisma } from './lib/prisma.js';

export const auth = betterAuth({
  //   Core 
  database: prismaAdapter(prisma, {
    provider: 'postgresql',
  }),
  secret: process.env.BETTER_AUTH_SECRET,
  baseURL: process.env.BETTER_AUTH_URL,

  //   Email + Password
  emailAndPassword: {
    enabled: true,
    minPasswordLength: 8,
    maxPasswordLength: 128,
    requireEmailVerification: false,
  },

  //   Session
  session: {
    expiresIn: 60 * 60 * 24 * 7,  // 7 days
    updateAge: 60 * 60 * 24,       // slide expiry once per day on activity
    cookieCache: {
      enabled: true,               // cache session in cookie to avoid DB hit per request
      maxAge: 5 * 60,              // 5-minute client-side cache
    },
  },

  //   CORS / trusted origins
  trustedOrigins: process.env.FRONTEND_URL ? [process.env.FRONTEND_URL] : [],

  //   Cookies
  advanced: {
    useSecureCookies: process.env.NODE_ENV === 'production',
  },

  //   Plugins
  plugins: [],
});

// Re-export inferred types for use across the codebase
export type Session = typeof auth.$Infer.Session;
export type AuthUser = typeof auth.$Infer.Session.user;