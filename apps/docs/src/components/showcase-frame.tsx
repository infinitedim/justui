'use client';

import { useEffect, useRef, useState } from 'react';
import { useTheme } from 'next-themes';

export function ShowcaseFrame() {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [height, setHeight] = useState(480);
  const [supported, setSupported] = useState(true);
  const { resolvedTheme } = useTheme();

  useEffect(() => {
    // Deteksi Wasm support dasar — Flutter Web Wasm butuh browser modern
    const hasWasm = typeof WebAssembly === 'object';
    setSupported(hasWasm);
  }, []);

  useEffect(() => {
    function handleMessage(event: MessageEvent) {
      if (event.data?.type === 'justui-showcase-height') {
        setHeight(event.data.height);
      }
    }
    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  useEffect(() => {
    // Kirim theme mode ke iframe setiap kali resolvedTheme berubah
    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'justui-theme',
        preset: 'neobrutalism',
        mode: resolvedTheme === 'dark' ? 'dark' : 'light',
      },
      '*',
    );
  }, [resolvedTheme]);

  if (!supported) {
    return (
      <div className="flex h-120 w-full items-center justify-center rounded-lg border border-border bg-card">
        {/* 
          TODO: Capture screenshot of the showcase grid when running locally,
          then save it to apps/docs/public/showcase-fallback.png as a fallback
          for non-WASM browsers.
        */}
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
      style={{ height }}
      loading="lazy"
    />
  );
}
