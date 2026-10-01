'use client';

import { useState } from 'react';
import { primaryButton } from './mock-styles';

export function ButtonMock() {
  const [count, setCount] = useState(0);

  return (
    <button
      type="button"
      onClick={() => setCount((c) => c + 1)}
      data-testid="mock-button"
      className={primaryButton}
    >
      {count === 0 ? 'Add to cart' : `In cart (${count})`}
    </button>
  );
}
