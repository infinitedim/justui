import Link from 'next/link';
import { ArrowLeft } from 'lucide-react';
import { localizedHref } from '@/lib/i18n';
import type {
  NotFoundExitsProps,
  NotFoundStatementProps,
} from './not-found-runner.types';

const exit =
  'inline-flex h-12 items-center gap-2.5 rounded-[10px] px-5 text-[15px] font-semibold whitespace-nowrap transition-colors';

/** "Part 404 isn't on this runner." and the path that was asked for. */
export function NotFoundStatement({ path, t }: NotFoundStatementProps) {
  return (
    <div className="max-w-[820px] min-w-0 flex-[1_1_480px]">
      <h1 className="text-[clamp(36px,4.8vw,68px)] leading-[1.04] font-bold tracking-[-0.03em] text-balance">
        {t.title}
      </h1>
      <p className="text-ip-text-secondary mt-5 max-w-[60ch] text-lg leading-[1.6] text-pretty">
        {path ? (
          <code className="bg-ip-sunken text-ip-text-primary rounded-[4px] px-2 py-[3px] font-mono text-base [overflow-wrap:anywhere]">
            {path}
          </code>
        ) : (
          t.thisPage
        )}
        {t.pathTail}
      </p>
    </div>
  );
}

/** Home (ink-filled) and docs (outlined). */
export function NotFoundExits({ lang, t }: NotFoundExitsProps) {
  return (
    <div className="flex flex-wrap gap-3">
      <Link
        href={localizedHref(lang, '')}
        className={`${exit} bg-ip-inverse text-ip-on-inverse hover:bg-ip-inverse-hover`}
      >
        <ArrowLeft size={16} aria-hidden="true" />
        {t.home}
      </Link>
      <Link
        href={localizedHref(lang, '/docs/introduction')}
        className={`${exit} border-ip-border-control text-ip-text-primary hover:bg-ip-hover border`}
      >
        {t.docs}
      </Link>
    </div>
  );
}
