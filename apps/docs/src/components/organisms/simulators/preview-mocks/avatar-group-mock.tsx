'use client';

import { useCatalogI18n } from '@/lib/catalog-i18n/context';

const MEMBERS = [
  { initials: 'RW', name: 'Rina Wulandari' },
  { initials: 'BP', name: 'Bagas Pratama' },
  { initials: 'DL', name: 'Dewi Lestari' },
] as const;
const HIDDEN_COUNT = 2;

const avatar =
  'bg-accent-muted text-foreground border-card flex h-10 w-10 items-center justify-center rounded-full border-2 text-xs font-semibold';

export function AvatarGroupMock() {
  const { crm } = useCatalogI18n();

  return (
    <div className="flex flex-col items-center gap-2">
      <p className="text-muted text-xs">{crm.avatarGroup.label}</p>
      <ul data-testid="mock-avatar-group" className="flex -space-x-2">
        {MEMBERS.map((member) => (
          <li key={member.initials} className={avatar} title={member.name}>
            <span aria-hidden="true">{member.initials}</span>
            <span className="sr-only">{member.name}</span>
          </li>
        ))}
        <li className={`${avatar} bg-card text-muted`}>
          <span aria-hidden="true">+{HIDDEN_COUNT}</span>
          <span className="sr-only">{crm.avatarGroup.more(HIDDEN_COUNT)}</span>
        </li>
      </ul>
    </div>
  );
}
