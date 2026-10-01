import Link from 'next/link';

export default function NotFound() {
  return (
    <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4 text-center">
      <h1 className="font-mono text-6xl font-bold tracking-tighter">404</h1>
      <p className="text-muted text-lg">Page not found.</p>
      <Link
        href="/en"
        className="text-accent-text hover:text-accent-text/80 font-mono text-sm underline underline-offset-4 transition-colors"
      >
        &larr; Back to home
      </Link>
    </div>
  );
}
