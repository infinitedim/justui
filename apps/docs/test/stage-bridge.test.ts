import { describe, expect, it, vi } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import {
  dispatchStageEvent,
  useStageListener,
  emitStageTelemetry,
  type StageBridgeEvent,
} from '@/lib/stage-bridge';

describe('stage-bridge', () => {
  it('dispatches events to window and iframe', () => {
    const windowSpy = vi.spyOn(window, 'postMessage');
    const iframePostMessage = vi.fn();
    const mockIframeRef = {
      current: {
        contentWindow: {
          postMessage: iframePostMessage,
        },
      } as unknown as HTMLIFrameElement,
    };

    const event: StageBridgeEvent = {
      type: 'justui-mount',
      component: 'button',
    };

    dispatchStageEvent(event, mockIframeRef);

    expect(windowSpy).toHaveBeenCalledWith(event, window.location.origin);
    expect(iframePostMessage).toHaveBeenCalledWith(event, window.location.origin);
  });

  it('listens for matched stage events through useStageListener hook', () => {
    const handler = vi.fn();
    renderHook(() => useStageListener('justui-mount', handler));

    act(() => {
      window.dispatchEvent(
        new MessageEvent('message', {
          data: {
            type: 'justui-mount',
            component: 'card',
          },
        })
      );
    });

    expect(handler).toHaveBeenCalledWith({
      type: 'justui-mount',
      component: 'card',
    });
  });

  it('listens for justui-tokens events', () => {
    const handler = vi.fn();
    renderHook(() => useStageListener('justui-tokens', handler));

    act(() => {
      window.dispatchEvent(
        new MessageEvent('message', {
          data: {
            type: 'justui-tokens',
            tokens: { radius: '8px' },
          },
        })
      );
    });

    expect(handler).toHaveBeenCalledWith({
      type: 'justui-tokens',
      tokens: { radius: '8px' },
    });
  });

  it('dispatches telemetry event via emitStageTelemetry', () => {
    const windowSpy = vi.spyOn(window, 'postMessage');
    emitStageTelemetry('canvas-render', { fps: 60 });

    expect(windowSpy).toHaveBeenCalledWith(
      {
        type: 'justui-event',
        name: 'canvas-render',
        payload: { fps: 60 },
      },
      window.location.origin
    );
  });

  it('handles incoming justui-event in useStageListener', () => {
    const handler = vi.fn();
    renderHook(() => useStageListener('justui-event', handler));

    act(() => {
      window.dispatchEvent(
        new MessageEvent('message', {
          data: {
            type: 'justui-event',
            name: 'canvas-render',
            payload: { fps: 60 },
          },
        })
      );
    });

    expect(handler).toHaveBeenCalledWith({
      type: 'justui-event',
      name: 'canvas-render',
      payload: { fps: 60 },
    });
  });

  it('ignores unrelated messages', () => {
    const handler = vi.fn();
    renderHook(() => useStageListener('justui-ready', handler));

    act(() => {
      window.dispatchEvent(
        new MessageEvent('message', {
          data: {
            type: 'unrelated-event',
          },
        })
      );
    });

    expect(handler).not.toHaveBeenCalled();
  });

  it('rejects messages from untrusted origins in useStageListener', () => {
    const handler = vi.fn();
    renderHook(() => useStageListener('justui-mount', handler));

    act(() => {
      window.dispatchEvent(
        new MessageEvent('message', {
          origin: 'https://malicious-attacker.com',
          data: {
            type: 'justui-mount',
            component: 'card',
          },
        })
      );
    });

    expect(handler).not.toHaveBeenCalled();
  });
});
