'use client';

import { cn } from '@/lib/cn';
import { surface } from './mock-styles';

const rows = [
  { id: '#1042', status: 'Shipped', total: '$48.00' },
  { id: '#1038', status: 'Delivered', total: '$19.50' },
  { id: '#1031', status: 'Refunded', total: '$12.00' },
];

export function TableMock() {
  return (
    <div
      data-testid="mock-table"
      className={cn(surface, 'w-full max-w-64 overflow-hidden')}
    >
      <table className="w-full text-sm">
        <thead>
          <tr className="border-border text-secondary border-b border-b-(length:--just-border-width) text-left text-xs">
            <th className="px-3 py-2 font-medium">Order</th>
            <th className="px-3 py-2 font-medium">Status</th>
            <th className="px-3 py-2 text-right font-medium">Total</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((r) => (
            <tr
              key={r.id}
              className="border-border border-b border-b-(length:--just-border-width) last:border-b-0"
            >
              <td className="text-foreground px-3 py-2 font-medium">{r.id}</td>
              <td className="text-secondary px-3 py-2">{r.status}</td>
              <td className="text-foreground px-3 py-2 text-right">
                {r.total}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
