'use client';

import { useState } from 'react';
import { Heart } from 'lucide-react';
import { cn } from '@/lib/cn';
import { hint, outlineButton } from './mock-styles';

export function IconButtonMock() {
  const [saved, setSaved] = useState(false);

  return (
    <div className="flex items-center gap-3">
      <button
        type="button"
        onClick={() => setSaved((s) => !s)}
        aria-label="Save for later"
        aria-pressed={saved}
        data-testid="mock-icon-button"
        className={cn(outlineButton, 'w-9 px-0')}
      >
        <Heart
          className={cn('h-4 w-4', saved && 'fill-error text-error')}
          aria-hidden="true"
        />
      </button>
      <span className={hint}>
        {saved ? 'Saved for later' : 'Save for later'}
      </span>
    </div>
  );
}
