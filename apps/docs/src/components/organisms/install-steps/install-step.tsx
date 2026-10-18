import { CopyControl } from '@/components/molecules/copy-control';
import type {
  CommandBoxProps,
  InstallStepProps,
  WrittenFilesProps,
} from './install-steps.types';

/**
 * One numbered step. The rule above it draws in on scroll and the numeral
 * settles to full ink when its rule completes; the base state is drawn.
 */
export function InstallStep({ number, title, children }: InstallStepProps) {
  return (
    <li className="border-ip-border-control relative flex min-w-0 flex-col gap-3.5 border-t pt-5">
      <div
        data-step-rule
        aria-hidden="true"
        className="bg-ip-text-primary absolute inset-x-0 -top-0.5 h-0.75 origin-left"
      />
      <span
        data-step-number
        className="text-5xl leading-none font-bold tracking-[-0.03em]"
      >
        {number}
      </span>
      <h3 className="mt-2 text-[19px] font-semibold">{title}</h3>
      {children}
    </li>
  );
}

/** A one-line command with its copy button. */
export function CommandBox({
  command,
  copyLabel,
  copyText,
  copiedText,
}: CommandBoxProps) {
  return (
    <div className="bg-ip-sunken flex h-11 items-center gap-2 rounded-[10px] pr-1 pl-3.5">
      <code className="text-ip-text-primary min-w-0 flex-1 truncate font-mono text-sm">
        {command}
      </code>
      <CopyControl
        text={command}
        label={copyLabel}
        copyText={copyText}
        copiedText={copiedText}
      />
    </div>
  );
}

/** "Writes" / "Lands in" and the paths under it. */
export function WrittenFiles({ label, children }: WrittenFilesProps) {
  return (
    <div className="flex flex-col gap-1">
      <span className="text-ip-text-tertiary text-[13px] font-semibold">
        {label}
      </span>
      {children}
    </div>
  );
}
