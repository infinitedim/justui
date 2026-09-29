import { defineDocs, defineConfig } from 'fumadocs-mdx/config';
import { justuiLight, justuiDark } from './src/lib/justui-shiki-theme';

export const docs = defineDocs({
  dir: 'content/docs',
});

export default defineConfig({
  mdxOptions: {
    rehypeCodeOptions: {
      themes: {
        light: justuiLight as never,
        dark: justuiDark as never,
      },
    },
  },
});
