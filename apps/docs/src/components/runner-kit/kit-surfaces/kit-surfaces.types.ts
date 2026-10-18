import type { ReactNode } from 'react';

export type KitSurfaceSize = 'sm' | 'md';

export interface KitCardProps {
  title: string;
  description: string;
  size?: KitSurfaceSize;
  children?: ReactNode;
  className?: string;
}

export interface KitToastProps {
  title: string;
  body: string;
  size?: KitSurfaceSize;
  className?: string;
}

export interface KitDialogProps {
  title: string;
  cancel: string;
  confirm: string;
  className?: string;
}

export interface KitSheetProps {
  title: string;
  className?: string;
}
