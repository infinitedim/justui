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
      ? 'Pilih satu warna, lihat palet terang dan gelap yang lolos WCAG AA, lalu salin config untuk justui init.'
      : 'Pick one color, see light and dark palettes that pass WCAG AA, then copy the config for justui init.',
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

  // Parsed server-side so the studio renders with the shared seed, mode and
  // color space from the very first paint. The preset is site-wide state; the
  // Studio applies a shared `?preset=` to it on mount.
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
          initialColorSpace={initialState.colorSpace}
        />
      }
      footer={<Footer lang={lang} />}
    />
  );
}
