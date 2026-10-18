import { Check, File, FilePlus, Folder } from 'lucide-react';
import type { FileTreeProps } from './cut-sequence.types';

const icon = { size: 14, 'aria-hidden': true, className: 'shrink-0' } as const;
const existing = 'text-ip-text-secondary flex h-7 items-center gap-2';
const written = 'text-ip-text-primary inline-flex h-7 items-center gap-2';

/**
 * The project the part lands in. Nodes the sequence reveals carry
 * `data-cut`; their base state is fully shown (the finished layout).
 */
export function FileTree({
  folder,
  shared,
  files,
  sharedMore,
  verify,
}: FileTreeProps) {
  const [main = '', ...rest] = files;
  return (
    <div className="bg-ip-sunken min-w-0 flex-[1_1_340px] rounded-[16px] px-[clamp(16px,2.5vw,28px)] py-5 font-mono text-sm/7">
      <div className={existing}>
        <Folder {...icon} />
        my_app/
      </div>
      <div className={`${existing} pl-[22px]`}>
        <Folder {...icon} />
        lib/
      </div>
      <div className={`${existing} pl-11`}>
        <File {...icon} />
        main.dart
      </div>
      <div className="pl-11">
        <span data-cut="folder" className={`${written} font-medium`}>
          <Folder {...icon} />
          {folder}
        </span>
      </div>
      <div className="pl-[66px]">
        <span data-cut="landing" className={`${written} font-semibold`}>
          <FilePlus {...icon} />
          {main}
        </span>
      </div>
      {rest.map((file) => (
        <div key={file} className="pl-[66px]">
          <span data-cut="row" className={written}>
            <FilePlus {...icon} />
            {file}
          </span>
        </div>
      ))}
      <div data-cut="shared" className={`${existing} pl-11`}>
        <Folder {...icon} />
        <span>{shared}</span>
        <span className="text-ip-text-tertiary">{sharedMore}</span>
      </div>
      <div className={`${existing} pl-[22px]`}>
        <File {...icon} />
        justui.config.yaml
      </div>
      <div className={`${existing} pl-[22px]`}>
        <File {...icon} />
        pubspec.yaml
      </div>
      <div
        data-cut="verify"
        className="border-ip-border-subtle text-ip-text-primary font-ip mt-3.5 flex items-start gap-2 border-t pt-3.5 text-[13px]/5 font-semibold"
      >
        <Check size={16} aria-hidden="true" className="mt-0.5 shrink-0" />
        <span>{verify}</span>
      </div>
    </div>
  );
}
