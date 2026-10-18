export interface KitSwitchProps {
  label: string;
  defaultChecked?: boolean;
  className?: string;
}

export interface KitCheckboxProps {
  label: string;
  defaultChecked?: boolean;
  className?: string;
}

export interface KitRadioGroupProps {
  /** Accessible name of the group. */
  label: string;
  /** Shared `name` of the native radios; unique per page. */
  name: string;
  options: readonly string[];
  defaultIndex?: number;
  className?: string;
}

export interface KitToggleProps {
  /** Accessible name; the toggle shows only an icon. */
  label: string;
  defaultPressed?: boolean;
  className?: string;
}
