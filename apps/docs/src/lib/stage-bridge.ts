'use client';

import { useEffect, useRef } from 'react';
import type { RefObject } from 'react';

export interface StageReadyEvent {
  type: 'justui-ready';
}

export interface StageMountEvent {
  type: 'justui-mount';
  component: string;
  props?: Record<string, unknown>;
}

export interface StageThemeEvent {
  type: 'justui-theme';
  preset: 'default' | 'neobrutalism';
  mode: 'light' | 'dark';
}

export interface StageTokensEvent {
  type: 'justui-tokens';
  tokens: Record<string, string | number>;
}

export interface StageInteractEvent {
  type: 'justui-interact';
  component: string;
  action: string;
}

export interface StageMountedEvent {
  type: 'justui-mounted';
  component: string;
  success: boolean;
}

export interface StageClearEvent {
  type: 'justui-clear';
}

export interface StageTelemetryEvent {
  type: 'justui-event';
  name: string;
  payload?: Record<string, unknown>;
}

export type StageBridgeEvent =
  | StageReadyEvent
  | StageMountEvent
  | StageThemeEvent
  | StageTokensEvent
  | StageInteractEvent
  | StageMountedEvent
  | StageClearEvent
  | StageTelemetryEvent;

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
  handler: (event: Extract<StageBridgeEvent, { type: T }>) => void
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

      if (
        event.data &&
        typeof event.data === 'object' &&
        event.data.type === type
      ) {
        handlerRef.current(
          event.data as Extract<StageBridgeEvent, { type: T }>
        );
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
