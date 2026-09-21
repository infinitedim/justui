'use client';

import { useState } from 'react';
import {
  Wifi,
  Battery,
  Signal,
  Bell,
  Search,
  Home,
  Layers,
  User,
  Sparkles,
} from 'lucide-react';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import type { PhoneMockupCanvasProps } from './phone-mockup-canvas.types';

export function PhoneMockupCanvas({
  lang = 'en',
  className,
}: PhoneMockupCanvasProps) {
  const t = getStudioDictionary(lang);
  const { resolvedTokens, preset } = useThemeStudio();

  // Internal interactive mockup state
  const [switchOn, setSwitchOn] = useState<boolean>(true);
  const [activeTab, setActiveTab] = useState<'home' | 'catalog' | 'profile'>('home');
  const [buttonPressed, setButtonPressed] = useState<boolean>(false);

  const isNeo = preset === 'neobrutalism';

  // Common transition class for smooth theme interpolation
  const transitionClass =
    'transition-all duration-200 ease-[cubic-bezier(0.05,0.7,0.1,1.0)] motion-reduce:transition-none';

  return (
    <div
      className={cn('flex w-full items-center justify-center p-2 sm:p-4', className)}
      data-testid="phone-mockup-canvas"
    >
      {/* Phone Outer Chassis */}
      <div
        className={cn(
          'relative w-full max-w-[360px] sm:max-w-[375px] shrink-0 select-none overflow-hidden',
          'rounded-[48px] border-[10px] border-zinc-900 bg-zinc-900',
          'shadow-[0_25px_60px_-15px_rgba(0,0,0,0.5),0_0_0_1px_rgba(255,255,255,0.1)]',
          'dark:border-zinc-800 dark:bg-zinc-800'
        )}
      >
        {/* Dynamic Island Pill */}
        <div className="absolute top-3 left-1/2 z-30 h-6 w-28 -translate-x-1/2 rounded-full bg-black flex items-center justify-between px-2.5">
          <span className="h-2.5 w-2.5 rounded-full bg-zinc-900 border border-zinc-800" />
          <span className="h-2 w-2 rounded-full bg-blue-950/80" />
        </div>

        {/* Screen Viewport Container */}
        <div
          className={cn(
            'relative flex flex-col h-[680px] w-full overflow-hidden rounded-[38px]',
            transitionClass
          )}
          style={{
            backgroundColor: resolvedTokens.background,
            color: resolvedTokens.textPrimary,
          }}
        >
          {/* Status Bar */}
          <div
            className="relative z-20 flex h-11 w-full shrink-0 items-center justify-between px-6 pt-1 text-xs"
            style={{
              backgroundColor: resolvedTokens.background,
              color: resolvedTokens.textPrimary,
            }}
          >
            <span className="font-mono text-[11px] font-semibold tracking-tight">
              9:41
            </span>
            <div className="flex items-center gap-1.5 opacity-90">
              <Signal className="h-3 w-3" />
              <Wifi className="h-3 w-3" />
              <Battery className="h-3.5 w-3.5" />
            </div>
          </div>

          {/* App Header */}
          <div
            className="flex shrink-0 items-center justify-between px-5 py-3 border-b"
            style={{
              backgroundColor: resolvedTokens.background,
              borderColor: resolvedTokens.border,
              borderBottomWidth: resolvedTokens.borderWidth,
            }}
          >
            <div className="flex items-center gap-2">
              <div
                className={cn('h-6 w-6 flex items-center justify-center rounded', transitionClass)}
                style={{
                  backgroundColor: resolvedTokens.accent,
                  color: resolvedTokens.accentForeground,
                  borderRadius: resolvedTokens.radiusMd,
                }}
              >
                <Sparkles className="h-3.5 w-3.5" />
              </div>
              <span className="font-mono text-xs font-bold tracking-tight">
                JustUI App
              </span>
            </div>
            <button
              type="button"
              className="relative p-1.5 opacity-80 hover:opacity-100 transition-opacity"
              aria-label="Notifications"
            >
              <Bell className="h-4 w-4" />
              <span
                className="absolute top-1 right-1 h-1.5 w-1.5 rounded-full"
                style={{ backgroundColor: resolvedTokens.error }}
              />
            </button>
          </div>

          {/* Main App Content Flow */}
          <div className="flex flex-1 flex-col gap-4 p-5 overflow-y-auto overflow-x-hidden">
            {/* Search Input Field */}
            <div
              className={cn(
                'flex items-center gap-2.5 px-3 py-2 border shadow-xs',
                transitionClass
              )}
              style={{
                backgroundColor: resolvedTokens.card,
                borderColor: resolvedTokens.border,
                borderWidth: resolvedTokens.borderWidth,
                borderRadius: resolvedTokens.radiusMd,
              }}
            >
              <Search className="h-3.5 w-3.5 opacity-50 shrink-0" />
              <span
                className="text-xs truncate opacity-60"
                style={{ color: resolvedTokens.textSecondary }}
              >
                {t.searchPlaceholder}
              </span>
            </div>

            {/* Featured Hero Card */}
            <div
              className={cn('flex flex-col gap-3 p-4 border', transitionClass)}
              style={{
                backgroundColor: resolvedTokens.card,
                borderColor: resolvedTokens.border,
                borderWidth: resolvedTokens.borderWidth,
                boxShadow: resolvedTokens.shadowSolid,
                borderRadius: resolvedTokens.radiusLg,
              }}
            >
              <div className="flex items-center justify-between">
                <span
                  className="font-mono text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5"
                  style={{
                    backgroundColor: resolvedTokens.accent,
                    color: resolvedTokens.accentForeground,
                    borderRadius: resolvedTokens.radiusMd,
                    borderStyle: isNeo ? 'solid' : 'none',
                    borderWidth: isNeo ? resolvedTokens.borderWidth : '0px',
                    borderColor: resolvedTokens.border,
                  }}
                >
                  {isNeo ? 'NEOBRUTALISM' : 'PREVIEW'}
                </span>
                <span
                  className="text-[10px] font-mono"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  v0.13.2
                </span>
              </div>

              <div>
                <h3
                  className="text-base font-bold tracking-tight"
                  style={{ color: resolvedTokens.textPrimary }}
                >
                  {t.welcomeBack}
                </h3>
                <p
                  className="mt-1 text-xs leading-relaxed"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  {t.exploreComponents}
                </p>
              </div>

              {/* Action Button */}
              <button
                type="button"
                onMouseDown={() => setButtonPressed(true)}
                onMouseUp={() => setButtonPressed(false)}
                onMouseLeave={() => setButtonPressed(false)}
                onClick={() => setSwitchOn((prev) => !prev)}
                className={cn(
                  'mt-1 flex items-center justify-center font-mono text-xs font-semibold py-2.5 px-4 cursor-pointer',
                  buttonPressed
                    ? (isNeo ? 'translate-x-1 translate-y-1' : 'translate-y-0.5')
                    : '',
                  transitionClass
                )}
                style={{
                  backgroundColor: resolvedTokens.accent,
                  color: resolvedTokens.accentForeground,
                  borderColor: resolvedTokens.border,
                  borderStyle: 'solid',
                  borderWidth: resolvedTokens.borderWidth,
                  borderRadius: resolvedTokens.radiusMd,
                  boxShadow: buttonPressed ? 'none' : resolvedTokens.shadowSolid,
                }}
              >
                {t.getStarted}
              </button>
            </div>

            {/* Interactive Switch and Status Row */}
            <div
              className={cn(
                'flex items-center justify-between p-3.5 border',
                transitionClass
              )}
              style={{
                backgroundColor: resolvedTokens.card,
                borderColor: resolvedTokens.border,
                borderWidth: resolvedTokens.borderWidth,
                borderRadius: resolvedTokens.radiusMd,
              }}
            >
              <div className="flex flex-col">
                <span
                  className="text-xs font-semibold"
                  style={{ color: resolvedTokens.textPrimary }}
                >
                  {t.notifications}
                </span>
                <span
                  className="text-[10px]"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  {switchOn ? t.active : t.inactive}
                </span>
              </div>

              {/* Interactive JustSwitch Mockup */}
              <button
                type="button"
                role="switch"
                aria-checked={switchOn}
                onClick={() => setSwitchOn(!switchOn)}
                className={cn(
                  'relative h-6 w-11 cursor-pointer border p-0.5',
                  transitionClass
                )}
                style={{
                  backgroundColor: switchOn ? resolvedTokens.accent : resolvedTokens.background,
                  borderColor: resolvedTokens.border,
                  borderWidth: resolvedTokens.borderWidth,
                  borderRadius: isNeo ? '0px' : '9999px',
                }}
              >
                <span
                  className={cn(
                    'block h-4.5 w-4.5 border transition-transform duration-200',
                    switchOn ? 'translate-x-5' : 'translate-x-0'
                  )}
                  style={{
                    backgroundColor: switchOn
                      ? resolvedTokens.accentForeground
                      : resolvedTokens.textSecondary,
                    borderColor: resolvedTokens.border,
                    borderWidth: isNeo ? resolvedTokens.borderWidth : '1px',
                    borderRadius: isNeo ? '0px' : '9999px',
                  }}
                />
              </button>
            </div>

            {/* Metrics Dual Cards */}
            <div className="grid grid-cols-2 gap-3">
              <div
                className={cn('flex flex-col gap-1 p-3 border', transitionClass)}
                style={{
                  backgroundColor: resolvedTokens.card,
                  borderColor: resolvedTokens.border,
                  borderStyle: 'solid',
                  borderWidth: resolvedTokens.borderWidth,
                  boxShadow: resolvedTokens.shadowSolid,
                  borderRadius: resolvedTokens.radiusMd,
                }}
              >
                <span
                  className="text-[10px] font-mono uppercase"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  FPS
                </span>
                <span
                  className="text-base font-bold font-mono"
                  style={{ color: resolvedTokens.success }}
                >
                  120 FPS
                </span>
                <span
                  className="text-[9px]"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  Zero heap alloc
                </span>
              </div>

              <div
                className={cn('flex flex-col gap-1 p-3 border', transitionClass)}
                style={{
                  backgroundColor: resolvedTokens.card,
                  borderColor: resolvedTokens.border,
                  borderStyle: 'solid',
                  borderWidth: resolvedTokens.borderWidth,
                  boxShadow: resolvedTokens.shadowSolid,
                  borderRadius: resolvedTokens.radiusMd,
                }}
              >
                <span
                  className="text-[10px] font-mono uppercase"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  COMPONENTS
                </span>
                <span
                  className="text-base font-bold font-mono"
                  style={{ color: resolvedTokens.accent }}
                >
                  30+
                </span>
                <span
                  className="text-[9px]"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  Production ready
                </span>
              </div>
            </div>
          </div>

          {/* Bottom Tab Navigation Bar */}
          <div
            className={cn(
              'shrink-0 z-20 flex h-14 w-full items-center justify-around border-t px-2',
              transitionClass
            )}
            style={{
              backgroundColor: resolvedTokens.card,
              borderColor: resolvedTokens.border,
              borderTopWidth: resolvedTokens.borderWidth,
            }}
          >
            <button
              type="button"
              onClick={() => setActiveTab('home')}
              className={cn(
                'flex flex-col items-center gap-0.5 p-1 transition-colors',
                activeTab === 'home' ? 'opacity-100 font-semibold' : 'opacity-60 hover:opacity-80'
              )}
              style={{
                color: activeTab === 'home' ? resolvedTokens.accent : resolvedTokens.textSecondary,
              }}
            >
              <Home className="h-4 w-4" />
              <span className="font-mono text-[9px]">Home</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('catalog')}
              className={cn(
                'flex flex-col items-center gap-0.5 p-1 transition-colors',
                activeTab === 'catalog' ? 'opacity-100 font-semibold' : 'opacity-60 hover:opacity-80'
              )}
              style={{
                color: activeTab === 'catalog' ? resolvedTokens.accent : resolvedTokens.textSecondary,
              }}
            >
              <Layers className="h-4 w-4" />
              <span className="font-mono text-[9px]">Catalog</span>
            </button>

            <button
              type="button"
              onClick={() => setActiveTab('profile')}
              className={cn(
                'flex flex-col items-center gap-0.5 p-1 transition-colors',
                activeTab === 'profile' ? 'opacity-100 font-semibold' : 'opacity-60 hover:opacity-80'
              )}
              style={{
                color: activeTab === 'profile' ? resolvedTokens.accent : resolvedTokens.textSecondary,
              }}
            >
              <User className="h-4 w-4" />
              <span className="font-mono text-[9px]">Profile</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
