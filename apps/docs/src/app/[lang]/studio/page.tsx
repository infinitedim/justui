import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { Navbar } from '@/components/organisms/navbar';
import { Footer } from '@/components/organisms/footer';
import { StudioTemplate } from '@/components/templates';
import { fetchStarCount } from '@/lib/github';
import { StudioClient } from './studio-client';
import { isLocale, localeStaticParams } from '@/lib/i18n';
import { deserializeStudioState } from '@/lib/theme/url-serializer';

type StudioSearchParams = Record<string, string | Array<string> | undefined>;

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  const isId = lang === 'id';

  return {
    title: isId ? 'Theme Studio - JustUI' : 'Theme Studio - JustUI',
    description: isId
      ? 'Konfigurasi design token secara visual dan ekspor kode siap produksi.'
      : 'Configure your design tokens visually and export production-ready code.',
  };
}

export async function generateStaticParams() {
  return localeStaticParams();
}

export default async function StudioPage({
  params,
  searchParams,
}: {
  params: Promise<{ lang: string }>;
  searchParams: Promise<StudioSearchParams>;
}) {
  const { lang } = await params;

  if (!isLocale(lang)) {
    notFound();
  }

  const starCount = await fetchStarCount();

  // Parsed server-side so the studio renders with the shared theme from the
  // very first paint, instead of flashing the default seed/preset/dark mode
  // until a client-only effect corrects it after mount.
  const resolvedSearchParams = await searchParams;
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(resolvedSearchParams)) {
    const first = Array.isArray(value) ? value[0] : value;
    if (first !== undefined) query.set(key, first);
  }
  const initialState = deserializeStudioState(query);

  return (
    <StudioTemplate
      navbar={<Navbar starCount={starCount} lang={lang} />}
      studioContent={
        <StudioClient
          lang={lang}
          initialSeedColor={initialState.seedColor}
          initialIsDark={initialState.isDark}
          initialPreset={initialState.preset}
          initialColorSpace={initialState.colorSpace}
        />
      }
      footer={<Footer lang={lang} />}
    />
  );
}
