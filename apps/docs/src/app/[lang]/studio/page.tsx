import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { Navbar } from '@/components/navbar';
import { Footer } from '@/components/organisms/footer';
import { StudioTemplate } from '@/components/templates';
import { fetchStarCount } from '@/lib/github';
import { StudioClient } from './studio-client';

const validLangs = ['en', 'id'] as const;

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
  return [{ lang: 'en' }, { lang: 'id' }];
}

export default async function StudioPage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;

  if (!(validLangs as readonly string[]).includes(lang)) {
    notFound();
  }

  const starCount = await fetchStarCount();

  return (
    <StudioTemplate
      navbar={<Navbar starCount={starCount} lang={lang} />}
      studioContent={<StudioClient lang={lang} />}
      footer={<Footer lang={lang} />}
    />
  );
}
