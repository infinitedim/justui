import { PRESET_LABELS } from '@/lib/presets';
import type { TokenTableProps } from './feature-rows.types';

/**
 * What a runner changes, per preset. Values follow
 * packages/core/lib/src/theme/preset_tokens.dart and, for shadow.sm, the
 * design spec (prd/02-design-spec.md: no default shadow below md).
 */
const TOKEN_ROWS = [
  ['borderWidth', '1.0', '2.5'],
  ['radius', 'md (8)', 'zero'],
  ['shadow.sm', 'none', 'offset 4, 4'],
  ['press', 'scale 0.97', 'translate 4, 4'],
  ['focus', '150 ms', '50 ms'],
] as const;

const cell = 'py-2 pr-3 text-left align-top';

/** Token, Default, Neobrutalism. */
export function TokenTable({ tokenColumn }: TokenTableProps) {
  return (
    <div className="bg-ip-sunken overflow-x-auto rounded-[12px] px-4.5 py-2">
      <table className="w-full border-collapse text-[13px]/5">
        <thead>
          <tr className="text-ip-text-tertiary">
            <th scope="col" className={`${cell} font-semibold`}>
              {tokenColumn}
            </th>
            <th scope="col" className={`${cell} font-semibold`}>
              {PRESET_LABELS.default}
            </th>
            <th scope="col" className={`${cell} pr-0 font-semibold`}>
              {PRESET_LABELS.neobrutalism}
            </th>
          </tr>
        </thead>
        <tbody>
          {TOKEN_ROWS.map(([token, base, neo]) => (
            <tr key={token} className="border-ip-border-subtle border-t">
              <th scope="row" className={`${cell} font-normal`}>
                <code className="font-mono">{token}</code>
              </th>
              <td className={cell}>
                <code className="font-mono">{base}</code>
              </td>
              <td className={`${cell} pr-0`}>
                <code className="font-mono">{neo}</code>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
