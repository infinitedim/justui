/** Replaces `{name}` placeholders in a dictionary string. */
export function formatMessage(
  template: string,
  values: Record<string, string | number>
): string {
  return template.replace(/\{(\w+)\}/g, (whole, key: string) =>
    key in values ? String(values[key]) : whole
  );
}
