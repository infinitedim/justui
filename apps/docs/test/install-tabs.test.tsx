import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it } from 'vitest';
import { InstallTabs } from '@/components/molecules/install-tabs';

describe('InstallTabs', () => {
  it('renders 3 platform tabs', () => {
    render(<InstallTabs />);
    expect(
      screen.getByRole('tab', { name: /macOS \/ Linux/i })
    ).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: /Windows/i })).toBeInTheDocument();
    expect(screen.getByRole('tab', { name: /Cargo/i })).toBeInTheDocument();
  });

  it('defaults to curl platform and renders bash command', () => {
    render(<InstallTabs />);
    const curlTab = screen.getByRole('tab', { name: /macOS \/ Linux/i });
    expect(curlTab).toHaveAttribute('aria-selected', 'true');
    expect(
      screen.getByText('curl -fsSL https://justui.dev/install.sh | bash')
    ).toBeInTheDocument();
  });

  it('switches to PowerShell when Windows tab is clicked', () => {
    render(<InstallTabs />);
    const windowsTab = screen.getByRole('tab', { name: /Windows/i });
    fireEvent.click(windowsTab);

    expect(windowsTab).toHaveAttribute('aria-selected', 'true');
    expect(
      screen.getByText('irm https://justui.dev/install.ps1 | iex')
    ).toBeInTheDocument();
  });

  it('switches to Cargo when Cargo tab is clicked', () => {
    render(<InstallTabs />);
    const cargoTab = screen.getByRole('tab', { name: /Cargo/i });
    fireEvent.click(cargoTab);

    expect(cargoTab).toHaveAttribute('aria-selected', 'true');
    expect(screen.getByText('cargo install justui_cli')).toBeInTheDocument();
  });

  it('renders copy button for active command', () => {
    render(<InstallTabs />);
    const copyButton = screen.getByRole('button', {
      name: /copy curl -fsSL/i,
    });
    expect(copyButton).toBeInTheDocument();
  });
});
