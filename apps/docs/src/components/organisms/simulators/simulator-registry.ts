import React from 'react';
import { ButtonMock } from './preview-mocks/button-mock';
import { IconButtonMock } from './preview-mocks/icon-button-mock';
import { InputMock } from './preview-mocks/input-mock';
import { BadgeMock } from './preview-mocks/badge-mock';
import { AvatarMock } from './preview-mocks/avatar-mock';
import { SelectMock } from './preview-mocks/select-mock';
import { ProgressMock } from './preview-mocks/progress-mock';
import { AccordionMock } from './preview-mocks/accordion-mock';
import { ToggleMock } from './preview-mocks/toggle-mock';
import { CheckboxMock } from './preview-mocks/checkbox-mock';
import { RadioMock } from './preview-mocks/radio-mock';
import { SwitchMock } from './preview-mocks/switch-mock';
import { CardMock } from './preview-mocks/card-mock';
import { SeparatorMock } from './preview-mocks/separator-mock';
import { ScrollAreaMock } from './preview-mocks/scroll-area-mock';
import { ResizableMock } from './preview-mocks/resizable-mock';
import { CarouselMock } from './preview-mocks/carousel-mock';
import { SkeletonMock } from './preview-mocks/skeleton-mock';
import { SliderMock } from './preview-mocks/slider-mock';
import { BreadcrumbMock } from './preview-mocks/breadcrumb-mock';
import { TabsMock } from './preview-mocks/tabs-mock';
import { BottomNavMock } from './preview-mocks/bottom-nav-mock';
import { SidebarMock } from './preview-mocks/sidebar-mock';
import { ToastMock } from './preview-mocks/toast-mock';
import { DialogMock } from './preview-mocks/dialog-mock';
import { SheetMock } from './preview-mocks/sheet-mock';
import { TooltipMock } from './preview-mocks/tooltip-mock';
import { AvatarGroupMock } from './preview-mocks/avatar-group-mock';
import { RadioGroupMock } from './preview-mocks/radio-group-mock';
import { TableMock } from './preview-mocks/table-mock';
import { DatePickerMock } from './preview-mocks/date-picker-mock';
import { DateRangePickerMock } from './preview-mocks/date-range-picker-mock';
import { TimePickerMock } from './preview-mocks/time-picker-mock';

export type SimulatorMockComponent = React.ComponentType<{
  preset?: 'default' | 'neobrutalism';
}>;

export const SIMULATOR_REGISTRY: Record<string, SimulatorMockComponent> = {
  // Primitives (9)
  button: ButtonMock,
  'icon-button': IconButtonMock,
  input: InputMock,
  badge: BadgeMock,
  avatar: AvatarMock,
  select: SelectMock,
  progress: ProgressMock,
  accordion: AccordionMock,
  toggle: ToggleMock,

  // Selection (3)
  checkbox: CheckboxMock,
  radio: RadioMock,
  switch: SwitchMock,

  // Layout (6)
  card: CardMock,
  separator: SeparatorMock,
  'scroll-area': ScrollAreaMock,
  resizable: ResizableMock,
  carousel: CarouselMock,
  skeleton: SkeletonMock,

  // Forms (1)
  slider: SliderMock,

  // Navigation (4)
  breadcrumb: BreadcrumbMock,
  tabs: TabsMock,
  'bottom-nav': BottomNavMock,
  sidebar: SidebarMock,

  // Overlays (4)
  toast: ToastMock,
  dialog: DialogMock,
  sheet: SheetMock,
  tooltip: TooltipMock,

  // Composite (6)
  'avatar-group': AvatarGroupMock,
  'radio-group': RadioGroupMock,
  table: TableMock,
  'date-picker': DatePickerMock,
  'date-range-picker': DateRangePickerMock,
  'time-picker': TimePickerMock,
};
