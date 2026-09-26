'use client';

import { useEffect, useRef } from 'react';
import type { RefObject } from 'react';
import { z } from 'zod';

const recordSchema = z.record(z.string(), z.unknown());

/**
 * Runtime schema for every message exchanged over the stage bridge.
 * `window.postMessage` accepts data from any same-origin frame or script, so
 * incoming messages are parsed instead of trusted by their `type` field.
 */
export const stageBridgeEventSchema = z.discriminatedUnion('type', [
  z.object({ type: z.literal('justui-ready') }),
  z.object({
    type: z.literal('justui-mount'),
    component: z.string(),
    props: recordSchema.optional(),
  }),
  z.object({
    type: z.literal('justui-theme'),
    preset: z.enum(['default', 'neobrutalism']),
    mode: z.enum(['light', 'dark']),
  }),
  z.object({
    type: z.literal('justui-tokens'),
    tokens: z.record(z.string(), z.union([z.string(), z.number()])),
  }),
  z.object({
    type: z.literal('justui-interact'),
    component: z.string(),
    action: z.string(),
  }),
  z.object({
    type: z.literal('justui-mounted'),
    component: z.string(),
    success: z.boolean(),
  }),
  z.object({ type: z.literal('justui-clear') }),
  z.object({
    type: z.literal('justui-event'),
    name: z.string(),
    payload: recordSchema.optional(),
  }),
]);

export type StageBridgeEvent = z.infer<typeof stageBridgeEventSchema>;
type StageEventOf<T extends StageBridgeEvent['type']> = Extract<
  StageBridgeEvent,
  { type: T }
>;

export type StageReadyEvent = StageEventOf<'justui-ready'>;
export type StageMountEvent = StageEventOf<'justui-mount'>;
export type StageThemeEvent = StageEventOf<'justui-theme'>;
export type StageTokensEvent = StageEventOf<'justui-tokens'>;
export type StageInteractEvent = StageEventOf<'justui-interact'>;
export type StageMountedEvent = StageEventOf<'justui-mounted'>;
export type StageClearEvent = StageEventOf<'justui-clear'>;
export type StageTelemetryEvent = StageEventOf<'justui-event'>;

export function dispatchStageEvent(
  event: StageBridgeEvent,
  iframeRef?: RefObject<HTMLIFrameElement | null>,
  targetOrigin?: string
): void {
  if (typeof window === 'undefined') {
    return;
  }
  const resolvedOrigin =
    targetOrigin ??
    (window.location.origin && window.location.origin !== 'null'
      ? window.location.origin
      : '*');
  window.postMessage(event, resolvedOrigin);
  if (iframeRef?.current?.contentWindow) {
    iframeRef.current.contentWindow.postMessage(event, resolvedOrigin);
  }
}

export function useStageListener<T extends StageBridgeEvent['type']>(
  type: T,
  handler: (event: StageEventOf<T>) => void
): void {
  const handlerRef = useRef(handler);
  handlerRef.current = handler;

  useEffect(() => {
    if (typeof window === 'undefined') {
      return;
    }
    const listener = (event: MessageEvent) => {
      // Security: Validate origin if present
      if (
        event.origin &&
        window.location.origin &&
        window.location.origin !== 'null' &&
        event.origin !== window.location.origin
      ) {
        return;
      }

      const parsed = stageBridgeEventSchema.safeParse(event.data);
      if (parsed.success && parsed.data.type === type) {
        handlerRef.current(parsed.data as StageEventOf<T>);
      }
    };
    window.addEventListener('message', listener);
    return () => {
      window.removeEventListener('message', listener);
    };
  }, [type]);
}

export function emitStageTelemetry(
  name: string,
  payload?: Record<string, unknown>
): void {
  dispatchStageEvent({
    type: 'justui-event',
    name,
    payload,
  });
}
