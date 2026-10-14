import { z } from 'zod';

export const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']).default('development'),
  PORT: z.coerce.number().default(3000),

  // Database
  DATABASE_URL: z.string().url(),

  // Better Auth
  BETTER_AUTH_SECRET: z.string().min(32, 'BETTER_AUTH_SECRET must be at least 32 characters'),
  BETTER_AUTH_URL: z.string().url(),
  FRONTEND_URL: z.string().url(),
});

export type EnvironmentVariables = z.infer<typeof envSchema>;

export type TypedConfigService = {
  get<K extends keyof EnvironmentVariables>(key: K): EnvironmentVariables[K];
};

export const validateEnv = (config: Record<string, unknown>) => {
  const result = envSchema.safeParse(config);

  if (!result.success) {
    console.error('Invalid environment configuration:');
    console.error(JSON.stringify(result.error.format(), null, 2));
    throw new Error('Environment validation failed');
  }

  return result.data;
};
