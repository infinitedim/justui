import Link from 'next/link';
import { ComponentCard } from '@/components/component-card';
import { HeroGraphic } from '@/components/hero-graphic';
import { InstallSnippet } from '@/components/install-snippet';
import { Navbar } from '@/components/navbar';
import { fetchStarCount } from '@/lib/github';
import { components } from '@/lib/components-data';

export default async function HomePage({
  params = Promise.resolve({ lang: 'en' }),
}: {
  params?: Promise<{ lang: string }>;
} = {}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();

  return (
    <div className="min-h-screen bg-black text-white">
      <Navbar starCount={starCount} lang={lang} />

      <main>
        <section className="mx-auto grid min-h-[calc(100vh-56px)] max-w-6xl items-center gap-16 px-4 py-20 sm:px-6 lg:grid-cols-2 lg:px-8 lg:py-24">
          <div className="max-w-2xl">
            <p className="text-accent mb-5 font-mono text-sm font-medium">
              Copy-paste Flutter components
            </p>
            <h1 className="max-w-4xl text-5xl font-medium tracking-tight text-white sm:text-6xl lg:text-7xl">
              Copy. Paste. Ship.
            </h1>
            <p className="mt-6 max-w-xl text-lg leading-8 text-(--color-gray-3)">
              A zero-dependency, copy-paste component library for Flutter. No
              Material. No boilerplate. Just UI.
            </p>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row">
              <Link
                href={`/${lang}/docs/introduction`}
                className="bg-accent hover:bg-accent-deep inline-flex h-10 items-center justify-center rounded-md px-4 text-sm font-medium text-[#1a2e05] transition-colors"
              >
                Get started →
              </Link>
              <Link
                href={`/${lang}/docs/components`}
                className="hover:border-accent-dark hover:bg-accent-muted inline-flex h-10 items-center justify-center rounded-md border border-(--color-gray) bg-transparent px-4 text-sm font-medium text-white transition-colors"
              >
                Browse components
              </Link>
            </div>

            <div className="mt-6">
              <InstallSnippet />
            </div>
          </div>

          <div className="mx-auto w-full max-w-120 lg:ml-auto">
            <HeroGraphic />
          </div>
        </section>

        <section className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
          <h2 className="mb-8 text-2xl font-medium text-white">Components</h2>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
            {components.map((component) => (
              <ComponentCard
                key={component.slug}
                component={component}
                lang={lang}
              />
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}
