export type ExportTab = 'yaml' | 'dart' | 'cli';

export interface CodeExportDrawerProps {
  lang?: string;
  className?: string;
  defaultTab?: ExportTab;
}
