'use client';

import { useEffect, useRef, useState } from 'react';
import { useTheme } from 'next-themes';
import { usePreset } from '@/lib/preset-context';

export function ShowcaseFrame() {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [supported, setSupported] = useState(true);
  const [isReady, setIsReady] = useState(false);
  const { resolvedTheme } = useTheme();
  const { preset } = usePreset();

  useEffect(() => {
    // Deteksi Wasm support dasar — Flutter Web Wasm butuh browser modern
    const hasWasm = typeof WebAssembly === 'object';
    setSupported(hasWasm);
  }, []);

  // Listen for ready signal from Flutter
  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data?.type === 'justui-ready') {
        setIsReady(true);
      }
    };
    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  // Kirim theme + preset ke Flutter setiap kali salah satunya berubah atau ketika Flutter ready
  useEffect(() => {
    if (!isReady) return;
    iframeRef.current?.contentWindow?.postMessage(
      {
        type: 'justui-theme',
        preset,
        mode: resolvedTheme === 'dark' ? 'dark' : 'light',
      },
      '*'
    );
  }, [resolvedTheme, preset, isReady]);

  if (!supported) {
    return (
      <div className="border-border bg-card flex h-45 w-full items-center justify-center border">
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
    />
  );
}
