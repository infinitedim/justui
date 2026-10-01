'use client';

import { useId, useState } from 'react';
import {
  Wifi,
  Battery,
  Signal,
  Bell,
  Search,
  Layers,
  Users,
  ListChecks,
} from 'lucide-react';
import { cn } from '@/lib/cn';
import { useThemeStudio } from '@/lib/theme-studio-context';
import { getStudioDictionary } from '@/lib/theme-studio-translations';
import type { PhoneMockupCanvasProps } from './phone-mockup-canvas.types';

type MockTab = 'pipeline' | 'contacts' | 'tasks';

export function PhoneMockupCanvas({
  lang = 'en',
  className,
}: PhoneMockupCanvasProps) {
  const t = getStudioDictionary(lang);
  const { resolvedTokens } = useThemeStudio();
  const remindersLabelId = useId();

  // Internal interactive mockup state
  const [switchOn, setSwitchOn] = useState<boolean>(true);
  const [activeTab, setActiveTab] = useState<MockTab>('pipeline');
  const [buttonPressed, setButtonPressed] = useState<boolean>(false);

  const tabs = [
    { id: 'pipeline', icon: Layers, label: t.mockTabPipeline },
    { id: 'contacts', icon: Users, label: t.mockTabContacts },
    { id: 'tasks', icon: ListChecks, label: t.mockTabTasks },
  ] as const satisfies readonly { id: MockTab; icon: unknown; label: string }[];

  // Common transition class for smooth theme interpolation
  const transitionClass =
    'transition-all duration-200 ease-[cubic-bezier(0.05,0.7,0.1,1.0)] motion-reduce:transition-none';

  return (
    <div
      className={cn(
        'flex w-full items-center justify-center p-2 sm:p-4',
        className
      )}
      data-testid="phone-mockup-canvas"
    >
      {/* Phone Outer Chassis */}
      <div
        className={cn(
          'relative w-full max-w-[360px] shrink-0 overflow-hidden select-none sm:max-w-[375px]',
          'rounded-[48px] border-[10px] border-zinc-900 bg-zinc-900',
          'shadow-2xl',
          'dark:border-zinc-800 dark:bg-zinc-800'
        )}
      >
        {/* Dynamic Island Pill */}
        <div className="absolute top-3 left-1/2 z-30 flex h-6 w-28 -translate-x-1/2 items-center justify-between rounded-full bg-black px-2.5">
          <span className="h-2.5 w-2.5 rounded-full border border-zinc-800 bg-zinc-900" />
          <span className="h-2 w-2 rounded-full bg-blue-950/80" />
        </div>

        {/* Screen Viewport Container */}
        <div
          className={cn(
            'relative flex h-[680px] w-full flex-col overflow-hidden rounded-[38px]',
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
            <span className="text-xs font-semibold tracking-tight">9:41</span>
            <div className="flex items-center gap-1.5 opacity-90">
              <Signal className="h-3 w-3" />
              <Wifi className="h-3 w-3" />
              <Battery className="h-3.5 w-3.5" />
            </div>
          </div>

          {/* App Header */}
          <div
            className="flex shrink-0 items-center justify-between border-b px-5 py-3"
            style={{
              backgroundColor: resolvedTokens.background,
              borderColor: resolvedTokens.border,
              borderBottomWidth: resolvedTokens.borderWidth,
            }}
          >
            <div className="flex items-center gap-2">
              <span
                aria-hidden="true"
                className={cn(
                  'flex h-6 w-6 items-center justify-center text-xs font-semibold',
                  transitionClass
                )}
                style={{
                  backgroundColor: resolvedTokens.accent,
                  color: resolvedTokens.accentForeground,
                  borderRadius: resolvedTokens.radiusMd,
                }}
              >
                R
              </span>
              <span className="text-sm font-semibold tracking-tight">
                {t.mockAppName}
              </span>
            </div>
            <button
              type="button"
              className="relative p-1.5"
              aria-label={t.mockNotifications}
              style={{ color: resolvedTokens.textSecondary }}
            >
              <Bell className="h-4 w-4" aria-hidden="true" />
            </button>
          </div>

          {/* Main App Content Flow */}
          <div className="flex flex-1 flex-col gap-4 overflow-x-hidden overflow-y-auto p-5">
            {/* Search Field */}
            <div
              className={cn(
                'flex items-center gap-2.5 border px-3 py-2',
                transitionClass
              )}
              style={{
                backgroundColor: resolvedTokens.card,
                borderColor: resolvedTokens.border,
                borderWidth: resolvedTokens.borderWidth,
                borderRadius: resolvedTokens.radiusMd,
                color: resolvedTokens.textSecondary,
              }}
            >
              <Search className="h-3.5 w-3.5 shrink-0" aria-hidden="true" />
              <span className="truncate text-sm">
                {t.mockSearchPlaceholder}
              </span>
            </div>

            {/* Follow-ups Card */}
            <div
              className={cn('flex flex-col gap-3 border p-4', transitionClass)}
              style={{
                backgroundColor: resolvedTokens.card,
                borderColor: resolvedTokens.border,
                borderWidth: resolvedTokens.borderWidth,
                boxShadow: resolvedTokens.shadowSolid,
                borderRadius: resolvedTokens.radiusLg,
              }}
            >
              <div>
                <h3
                  className="text-base font-semibold tracking-tight"
                  style={{ color: resolvedTokens.textPrimary }}
                >
                  {t.mockFollowUpsTitle}
                </h3>
                <p
                  className="mt-1 text-sm leading-relaxed"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  {t.mockFollowUpsSummary}
                </p>
              </div>

              <button
                type="button"
                onPointerDown={() => setButtonPressed(true)}
                onPointerUp={() => setButtonPressed(false)}
                onPointerLeave={() => setButtonPressed(false)}
                className={cn(
                  'mt-1 flex cursor-pointer items-center justify-center px-4 py-2.5 text-sm font-medium',
                  transitionClass
                )}
                style={{
                  backgroundColor: resolvedTokens.accent,
                  color: resolvedTokens.accentForeground,
                  borderColor: resolvedTokens.border,
                  borderStyle: 'solid',
                  borderWidth: resolvedTokens.borderWidth,
                  borderRadius: resolvedTokens.radiusMd,
                  transform: buttonPressed
                    ? resolvedTokens.pressTransform
                    : undefined,
                  boxShadow: buttonPressed
                    ? 'none'
                    : resolvedTokens.shadowSolid,
                }}
              >
                {t.mockLogCall}
              </button>
            </div>

            {/* Reminder Switch Row */}
            <div
              className={cn(
                'flex items-center justify-between border p-3.5',
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
                  id={remindersLabelId}
                  className="text-sm font-medium"
                  style={{ color: resolvedTokens.textPrimary }}
                >
                  {t.mockReminders}
                </span>
                <span
                  className="text-xs"
                  style={{ color: resolvedTokens.textSecondary }}
                >
                  {switchOn ? t.mockOn : t.mockOff}
                </span>
              </div>

              {/* Switch track: pills stay round in every preset. The thumb
                  shrinks by twice the border width so a 2.5px border never
                  overlaps it (inward border, see AGENTS.md section 10). */}
              <button
                type="button"
                role="switch"
                aria-checked={switchOn}
                aria-labelledby={remindersLabelId}
                onClick={() => setSwitchOn((prev) => !prev)}
                className={cn(
                  'relative h-6 w-11 shrink-0 cursor-pointer border p-0.5',
                  transitionClass
                )}
                style={{
                  backgroundColor: switchOn
                    ? resolvedTokens.accent
                    : resolvedTokens.background,
                  borderColor: resolvedTokens.border,
                  borderWidth: resolvedTokens.borderWidth,
                  borderRadius: '9999px',
                }}
              >
                <span
                  className={cn(
                    'block border transition-transform duration-200',
                    switchOn ? 'translate-x-5' : 'translate-x-0'
                  )}
                  style={{
                    width: `calc(20px - 2 * ${resolvedTokens.borderWidth})`,
                    height: `calc(20px - 2 * ${resolvedTokens.borderWidth})`,
                    backgroundColor: switchOn
                      ? resolvedTokens.accentForeground
                      : resolvedTokens.textSecondary,
                    borderColor: resolvedTokens.border,
                    borderWidth: resolvedTokens.borderWidth,
                    borderRadius: '9999px',
                  }}
                />
              </button>
            </div>
          </div>

          {/* Bottom Tab Navigation Bar */}
          <nav
            aria-label={t.mockTabsLabel}
            className={cn(
              'z-20 flex h-14 w-full shrink-0 items-center justify-around border-t px-2',
              transitionClass
            )}
            style={{
              backgroundColor: resolvedTokens.card,
              borderColor: resolvedTokens.border,
              borderTopWidth: resolvedTokens.borderWidth,
            }}
          >
            {tabs.map(({ id, icon: Icon, label }) => {
              const active = activeTab === id;
              return (
                <button
                  key={id}
                  type="button"
                  onClick={() => setActiveTab(id)}
                  aria-current={active ? 'page' : undefined}
                  className={cn(
                    'flex min-w-14 flex-col items-center gap-0.5 p-1 transition-colors',
                    active && 'font-semibold'
                  )}
                  style={{
                    color: active
                      ? resolvedTokens.accentText
                      : resolvedTokens.textSecondary,
                  }}
                >
                  <Icon className="h-4 w-4" aria-hidden="true" />
                  <span className="text-xs">{label}</span>
                </button>
              );
            })}
          </nav>
        </div>
      </div>
    </div>
  );
}
