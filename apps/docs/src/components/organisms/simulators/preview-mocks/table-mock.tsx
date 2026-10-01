'use client';

import { useState } from 'react';
import { ArrowDown, ArrowUp } from 'lucide-react';
import { useCatalogI18n } from '@/lib/catalog-i18n/context';
import { focusRing, surface } from '@/lib/ui-classes';
import { cn } from '@/lib/cn';

const DEALS = [
  { company: 'Hotel Arunika', stage: 'proposal', value: 18_450_000 },
  { company: 'Kopi Senja', stage: 'qualified', value: 7_200_000 },
  { company: 'Warung Nusantara', stage: 'lead', value: 3_150_000 },
] as const;

const rupiah = new Intl.NumberFormat('id-ID');

export function TableMock() {
  const { crm } = useCatalogI18n();
  const [descending, setDescending] = useState(true);
  const rows = [...DEALS].sort((a, b) =>
    descending ? b.value - a.value : a.value - b.value
  );

  return (
    <div className={cn(surface, 'w-full max-w-68 overflow-hidden')}>
      <table data-testid="mock-table" className="w-full text-left text-xs">
        <caption className="sr-only">{crm.table.caption}</caption>
        <thead className="text-muted border-border border-b border-b-(length:--just-border-width)">
          <tr>
            <th scope="col" className="px-2.5 py-1.5 font-medium">
              {crm.table.company}
            </th>
            <th scope="col" className="px-2.5 py-1.5 font-medium">
              {crm.table.stage}
            </th>
            <th
              scope="col"
              aria-sort={descending ? 'descending' : 'ascending'}
              className="px-2.5 py-1.5 text-right font-medium"
            >
              <button
                type="button"
                onClick={() => setDescending((d) => !d)}
                aria-label={crm.table.sortByValue}
                className={cn(
                  focusRing,
                  'hover:text-foreground inline-flex items-center gap-1 rounded-(--just-radius-xs)'
                )}
              >
                {crm.table.value}
                {descending ? (
                  <ArrowDown className="h-3 w-3" aria-hidden="true" />
                ) : (
                  <ArrowUp className="h-3 w-3" aria-hidden="true" />
                )}
              </button>
            </th>
          </tr>
        </thead>
        <tbody className="divide-border text-foreground divide-y">
          {rows.map((row) => (
            <tr key={row.company}>
              <td className="px-2.5 py-1.5">{row.company}</td>
              <td className="text-muted px-2.5 py-1.5">
                {crm.stages[row.stage]}
              </td>
              <td className="px-2.5 py-1.5 text-right tabular-nums">
                {rupiah.format(row.value)}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
