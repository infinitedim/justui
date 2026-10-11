import defaultMdxComponents from 'fumadocs-ui/mdx';
import { Tab, Tabs } from 'fumadocs-ui/components/tabs';
import { ButtonPlayground } from '@/components/docs/button-playground';
import { CheckoutDemo } from '@/components/docs/checkout-demo';
import { JustButtonPreview } from '@/components/docs/just-button-preview';

/**
 * Global component map available to MDX content.
 * Centralized in a single module to control per-page bundles.
 */
export const mdxComponents = {
  ...defaultMdxComponents,
  Tabs,
  Tab,
  ButtonPlayground,
  CheckoutDemo,
  JustButtonPreview,
};
