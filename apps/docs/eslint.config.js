import js from '@eslint/js';
import globals from 'globals';
import tseslint from 'typescript-eslint';
import pluginReact from 'eslint-plugin-react';
import prettier from 'eslint-plugin-prettier';
import importPlugin from 'eslint-plugin-import';
import jsdoc from 'eslint-plugin-jsdoc';
import jsxA11y from 'eslint-plugin-jsx-a11y';
import promise from 'eslint-plugin-promise';
import reactHooks from 'eslint-plugin-react-hooks';
import betterTailwindcss from 'eslint-plugin-better-tailwindcss';

export default [
  {
    ignores: [
      '**/dist/**',
      '**/node_modules/**',
      '**/build/**',
      '**/out/**',
      '**/.next/**',
      '**/coverage/**',
      '**/generated/**',
      '**/*.js',
      '**/.agents/**',
      '**/.source/**',
      '**/test-results/**',
      'public/flutter/**',
    ],
  },

  {
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 'latest',
      sourceType: 'module',
      globals: {
        ...globals.browser,
        ...globals.node,
        ...globals.es2021,
      },
      parser: tseslint.parser,
      parserOptions: {
        sourceType: 'module',
        projectService: true,
        tsconfigRootDir: import.meta.dirname,
        ecmaFeatures: {
          jsx: true,
        },
      },
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    ...js.configs.recommended,
  },

  ...tseslint.configs.recommendedTypeChecked.map((config) => ({
    ...config,
    files: ['**/*.{ts,tsx}'],
  })),

  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: {
      react: pluginReact,
    },
    rules: {
      'react/react-in-jsx-scope': 'off',
      'react/jsx-uses-react': 'off',
      'react/jsx-no-bind': 'off',
      'react/require-default-props': 'off',
      'react/jsx-props-no-spreading': 'off',
    },
    settings: {
      react: { version: 'detect' },
    },
  },

  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: {
      'react-hooks': reactHooks,
    },
    rules: {
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'error',
    },
  },

  // Tailwind class checks against the real theme in globals.css (unknown,
  // conflicting, duplicate and deprecated classes, also inside cn()). Class
  // order and line wrapping stay with prettier-plugin-tailwindcss.
  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: {
      'better-tailwindcss': betterTailwindcss,
    },
    settings: {
      'better-tailwindcss': {
        entryPoint: `${import.meta.dirname}/src/app/globals.css`,
      },
    },
    rules: {
      ...betterTailwindcss.configs['recommended-error'].rules,
      'better-tailwindcss/enforce-consistent-class-order': 'off',
      'better-tailwindcss/enforce-consistent-line-wrapping': 'off',
      // Plain CSS classes, not Tailwind utilities: the first four are
      // selectors in src/app/globals.css, not-prose is the Fumadocs prose
      // opt-out.
      'better-tailwindcss/no-unknown-classes': [
        'error',
        {
          ignore: [
            '^ink-paper$',
            '^ink-paper-invert$',
            '^ip-range$',
            '^just-press$',
            '^not-prose$',
          ],
        },
      ],
    },
  },

  {
    files: ['src/**/*.{ts,tsx}'],
    plugins: {
      'jsx-a11y': jsxA11y,
    },
    rules: {
      ...jsxA11y.configs.recommended.rules,
      'jsx-a11y/label-has-associated-control': [
        'error',
        {
          labelComponents: ['CustomInputLabel'],
          labelAttributes: ['label'],
          controlComponents: ['CustomInput'],
          depth: 3,
        },
      ],
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      import: importPlugin,
    },
    rules: {
      ...importPlugin.configs.recommended.rules,
      'import/no-extraneous-dependencies': 'off',
      'import/prefer-default-export': 'off',
      'import/extensions': 'off',
      'import/no-anonymous-default-export': 'off',
      'import/no-unresolved': 'off',
      'import/named': 'off',
      'import/order': 'off',
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    rules: {
      semi: ['error', 'always'],
      'no-unused-vars': 'off',
      '@typescript-eslint/no-unused-vars': [
        'error',
        {
          argsIgnorePattern: '^_',
          varsIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_',
        },
      ],
      '@typescript-eslint/no-explicit-any': 'error',
      '@typescript-eslint/no-require-imports': 'off',
      '@typescript-eslint/no-floating-promises': 'error',
      '@typescript-eslint/no-misused-promises': 'error',
      '@typescript-eslint/switch-exhaustiveness-check': 'error',
      '@typescript-eslint/prefer-nullish-coalescing': 'warn',
      '@typescript-eslint/consistent-type-assertions': [
        'error',
        { assertionStyle: 'never' },
      ],
      '@typescript-eslint/no-non-null-assertion': 'error',
      '@typescript-eslint/consistent-type-definitions': ['error', 'interface'],
      '@typescript-eslint/consistent-type-imports': [
        'error',
        { prefer: 'type-imports' },
      ],
      'no-restricted-imports': [
        'error',
        {
          patterns: [
            {
              group: ['../*'],
              message: 'Use @/ alias instead of relative parent imports.',
            },
          ],
        },
      ],
      'no-restricted-properties': [
        'error',
        {
          object: 'process',
          property: 'env',
          message:
            'Direct process.env reads are banned; import env from @/lib/env.',
        },
      ],
      'no-restricted-syntax': [
        'error',
        {
          selector: 'TSEnumDeclaration',
          message: 'Enums are banned. Use const objects with derived unions.',
        },
        {
          selector: "ExpressionStatement > Literal[value='use server']",
          message: 'Server actions are banned.',
        },
      ],
      'no-console': process.env.NODE_ENV === 'production' ? 'error' : 'off',
      'prefer-const': 'error',
      'no-var': 'error',
      'no-case-declarations': 'warn',
      'jsdoc/require-returns': 'off',
      'jsdoc/require-param-description': 'off',
      'jsdoc/require-param-type': 'off',
      'jsdoc/require-returns-type': 'off',
      'jsdoc/require-returns-description': 'off',
      'jsdoc/require-param': 'off',
      'jsdoc/require-jsdoc': 'off',
      'jsdoc/no-undefined-types': 'off',
    },
  },

  {
    files: ['src/components/**/*.tsx'],
    rules: {
      'max-lines': [
        'warn',
        { max: 200, skipBlankLines: true, skipComments: true },
      ],
    },
  },

  // Functions stay under 80 lines in every file, tests and scripts included
  // (docs-web.md). An error, so CI fails on it: `eslint .` passes warnings.
  {
    files: ['**/*.{js,mjs,ts,tsx}'],
    rules: {
      'max-lines-per-function': [
        'error',
        { max: 80, skipBlankLines: true, skipComments: true },
      ],
    },
  },

  {
    files: ['src/lib/**/*.{ts,tsx}'],
    rules: {
      '@typescript-eslint/explicit-module-boundary-types': 'warn',
      'jsdoc/require-jsdoc': [
        'warn',
        {
          publicOnly: true,
          require: {
            FunctionDeclaration: true,
            MethodDefinition: true,
            ClassDeclaration: true,
            ArrowFunctionExpression: true,
            FunctionExpression: true,
          },
        },
      ],
    },
  },

  {
    files: ['src/**/*.{ts,tsx}'],
    ignores: [
      'src/app/**/{page,layout,not-found,error,loading,opengraph-image,sitemap,robots}.tsx',
      'src/app/**/{page,layout,not-found,error,loading,opengraph-image,sitemap,robots}.ts',
    ],
    rules: {
      'no-restricted-syntax': [
        'error',
        {
          selector: 'ExportDefaultDeclaration',
          message: 'Default exports are banned; use named exports.',
        },
      ],
    },
  },

  {
    files: ['src/lib/env.ts', '*.config.*', 'scripts/**', 'test/**', 'e2e/**'],
    rules: {
      'no-restricted-properties': 'off',
    },
  },

  {
    files: ['**/*.test.{ts,tsx}', '**/*.spec.{ts,tsx}', 'test/**', 'e2e/**'],
    rules: {
      'no-console': 'off',
      'no-restricted-imports': 'off',
      '@typescript-eslint/no-explicit-any': 'off',
      '@typescript-eslint/consistent-type-assertions': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
      '@typescript-eslint/no-floating-promises': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'off',
      '@typescript-eslint/no-unsafe-call': 'off',
      '@typescript-eslint/no-unsafe-return': 'off',
      '@typescript-eslint/no-unsafe-argument': 'off',
      '@typescript-eslint/require-await': 'off',
      '@typescript-eslint/unbound-method': 'off',
      '@typescript-eslint/no-unnecessary-type-assertion': 'off',
      '@typescript-eslint/array-type': ['error', { default: 'generic' }],
      'jsdoc/require-jsdoc': 'off',
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      prettier,
    },
    rules: {
      'prettier/prettier': 'off',
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      jsdoc,
    },
    rules: {
      'jsdoc/require-jsdoc': 'off',
      'jsdoc/require-param': 'off',
      'jsdoc/require-param-description': 'off',
      'jsdoc/require-param-type': 'off',
      'jsdoc/require-returns': 'off',
      'jsdoc/require-returns-description': 'off',
      'jsdoc/require-returns-type': 'off',
      'jsdoc/no-undefined-types': 'off',
      'jsdoc/valid-types': 'off',
      'jsdoc/check-types': 'off',
    },
  },

  {
    files: ['**/*.{ts,tsx}'],
    plugins: {
      promise,
    },
    rules: {
      ...promise.configs.recommended.rules,
    },
  },
];
