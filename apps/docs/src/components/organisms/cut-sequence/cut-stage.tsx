import { PresetStage } from '@/components/organisms/preset-stage';
import { CLI_DEFAULTS } from '@/lib/components.generated';
import { formatMessage } from '@/lib/format-message';
import { PART_COUNT, partDir } from '@/lib/parts';
import { CutMover } from './cut-mover';
import { CutRunner } from './cut-runner';
import { FileTree } from './file-tree';
import type { CutStageProps } from './cut-sequence.types';

/** A folder relative to `lib/` (`lib/widgets/button` -> `widgets/button/`). */
function underLib(dir: string): string {
  return `${dir.split('/').slice(1).join('/')}/`;
}

/**
 * The runner, the project tree and the flying copy, in one positioned box
 * scoped to the visitor's preset (so the copy matches the part).
 */
export function CutStage({
  stageRef,
  part,
  files,
  shared,
  t,
  kit,
}: CutStageProps) {
  return (
    <PresetStage animated={false}>
      <div
        ref={stageRef}
        className="relative flex flex-wrap items-start gap-x-16 gap-y-8"
      >
        <CutRunner
          kit={kit}
          cutEmpty={t.cutEmpty}
          partsCount={formatMessage(t.partsCount, { count: PART_COUNT })}
        />
        <FileTree
          folder={underLib(partDir(part))}
          shared={underLib(CLI_DEFAULTS.sharedDir)}
          files={files}
          sharedMore={formatMessage(t.sharedMore, { count: shared })}
          verify={formatMessage(t.verify, {
            total: files.length + shared,
            own: files.length,
            shared,
            name: part,
          })}
        />
        <CutMover label={kit.saveChanges} file={files[0] ?? ''} />
      </div>
    </PresetStage>
  );
}
