import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { InstallTabs } from '@/components/molecules/install-tabs';

describe('InstallTabs', () => {
  it('renders 2 platform tabs', () => {
    render(<InstallTabs />);
    expect(
      screen.getByRole('tab', { name: /macOS \/ Linux/i })
    ).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: /Windows/i })).toBeInTheDocument();
    expect(
      screen.queryByRole('tab', { name: /Cargo/i })
    ).not.toBeInTheDocument();
  });

  it('defaults to curl platform and renders sh command', () => {
    render(<InstallTabs />);
    const curlTab = screen.getByRole('tab', { name: /macOS \/ Linux/i });
    expect(curlTab).toHaveAttribute('aria-selected', 'true');
    expect(
      screen.getByText('curl -fsSL https://justui.vercel.app/install.sh | sh')
    ).toBeInTheDocument();
  });

  it('switches to PowerShell when Windows tab is clicked', () => {
    render(<InstallTabs />);
    const windowsTab = screen.getByRole('tab', { name: /Windows/i });
    fireEvent.click(windowsTab);

    expect(windowsTab).toHaveAttribute('aria-selected', 'true');
    expect(
      screen.getByText('irm https://justui.vercel.app/install.ps1 | iex')
    ).toBeInTheDocument();
  });

  it('renders copy button for active command', () => {
    render(<InstallTabs />);
    const copyButton = screen.getByRole('button', {
      name: /copy curl -fsSL/i,
    });
    expect(copyButton).toBeInTheDocument();
  });
});
