'use client';

import { useEffect, useRef, useState } from 'react';
import { useTheme } from 'next-themes';
import { usePreset } from '@/lib/preset-context';

export function ShowcaseFrame() {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [supported, setSupported] = useState(true);
  const { resolvedTheme } = useTheme();
  const { preset } = usePreset();

  useEffect(() => {
    // Deteksi Wasm support dasar — Flutter Web Wasm butuh browser modern
    const hasWasm = typeof WebAssembly === 'object';
    setSupported(hasWasm);
  }, []);

  // Kirim theme + preset ke Flutter setiap kali salah satunya berubah
  useEffect(() => {
    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'justui-theme',
        preset,
        mode: resolvedTheme === 'dark' ? 'dark' : 'light',
      },
      '*',
    );
  }, [resolvedTheme, preset]);

  const handleLoad = () => {
    // Kirim juga saat iframe pertama kali load
    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'justui-theme',
        preset,
        mode: resolvedTheme === 'dark' ? 'dark' : 'light',
      },
      '*',
    );
  };

  if (!supported) {
    return (
      <div className="flex h-[180px] w-full items-center justify-center border border-border bg-card">
        <img
          src="/showcase-fallback.png"
          alt="JustUI component showcase"
          className="max-h-full max-w-full"
        />
      </div>
    );
  }

  return (
    <iframe
      ref={iframeRef}
      src="/showcase/index.html"
      title="JustUI component showcase"
      className="w-full border-0"
      style={{ height: '180px' }}
      loading="lazy"
      onLoad={handleLoad}
    />
  );
}
