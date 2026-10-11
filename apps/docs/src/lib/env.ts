import { z } from 'zod';

/**
 * Validated environment variables schema for the docs application.
 * Only read via this module; direct process.env reads are restricted.
 */
const envSchema = z.object({
  NODE_ENV: z
    .enum(['development', 'production', 'test'])
    .default('development'),
  GITHUB_TOKEN: z.string().optional(),
  NEXT_PUBLIC_SITE_URL: z.string().url().optional(),
});

export const env = {
  get NODE_ENV(): 'development' | 'production' | 'test' {
    const val = process.env.NODE_ENV;
    if (val === 'production' || val === 'test') {
      return val;
    }
    return 'development';
  },
  get GITHUB_TOKEN(): string | undefined {
    return process.env.GITHUB_TOKEN;
  },
  get NEXT_PUBLIC_SITE_URL(): string | undefined {
    return process.env.NEXT_PUBLIC_SITE_URL;
  },
  validate(): z.infer<typeof envSchema> {
    return envSchema.parse({
      NODE_ENV: process.env.NODE_ENV,
      GITHUB_TOKEN: process.env.GITHUB_TOKEN,
      NEXT_PUBLIC_SITE_URL: process.env.NEXT_PUBLIC_SITE_URL,
    });
  },
};
