import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Navbar } from '@/components/navbar';

// Mock next-themes
const mockSetTheme = vi.fn();
let mockResolvedTheme = 'dark';
vi.mock('next-themes', () => ({
  useTheme: () => ({
    resolvedTheme: mockResolvedTheme,
    setTheme: mockSetTheme,
  }),
}));

// Mock next/navigation
let mockPathname = '/id';
vi.mock('next/navigation', () => ({
  usePathname: () => mockPathname,
}));

// Mock next/link to render simple anchors
vi.mock('next/link', () => ({
  default: ({ children, href, className, onClick, ...props }: any) => (
    <a href={href} className={className} onClick={onClick} {...props}>
      {children}
    </a>
  ),
}));

describe('Navbar & SearchModal Components', () => {
  it('renders correctly with different stargazer counts', () => {
    // Test null stars
    const { rerender } = render(<Navbar starCount={null} lang="id" />);
    expect(screen.getByText('Stars')).toBeInTheDocument();

    // Test standard stars
    rerender(<Navbar starCount={450} lang="id" />);
    expect(screen.getByText('450')).toBeInTheDocument();

    // Test k stars
    rerender(<Navbar starCount={1200} lang="id" />);
    expect(screen.getByText('1.2k')).toBeInTheDocument();
  });

  it('renders LanguageSwitcher correctly', () => {
    const { rerender } = render(<Navbar starCount={100} lang="id" />);
    const linkId = screen.getByRole('link', { name: /ganti ke EN/i });
    expect(linkId).toHaveAttribute('href', '/en');

    mockPathname = '/en';
    rerender(<Navbar starCount={100} lang="en" />);
    const linkEn = screen.getByRole('link', { name: /ganti ke ID/i });
    expect(linkEn).toHaveAttribute('href', '/id');
  });

  it('toggles theme correctly via ThemeSwitcher', () => {
    mockResolvedTheme = 'dark';
    const { rerender } = render(<Navbar starCount={100} lang="id" />);
    const themeBtn = screen.getByRole('button', { name: /toggle tema/i });
    
    fireEvent.click(themeBtn);
    expect(mockSetTheme).toHaveBeenCalledWith('light');

    mockResolvedTheme = 'light';
    rerender(<Navbar starCount={100} lang="id" />);
    fireEvent.click(themeBtn);
    expect(mockSetTheme).toHaveBeenCalledWith('dark');
  });

  it('opens and closes search modal via button clicks, input search and navigation links', () => {
    render(<Navbar starCount={100} lang="en" />);
    
    // Search modal should be closed initially
    expect(screen.queryByPlaceholderText(/Search components, docs\.\.\./i)).not.toBeInTheDocument();

    // Click search button to open
    const searchBtn = screen.getByRole('button', { name: /buka pencarian/i });
    fireEvent.click(searchBtn);

    // Search modal should be open
    const input = screen.getByPlaceholderText(/Search components, docs\.\.\./i) as HTMLInputElement;
    expect(input).toBeInTheDocument();

    // Type query to filter results
    fireEvent.change(input, { target: { value: 'button' } });
    expect(input.value).toBe('button');

    // Click result link to close
    const resultLink = screen.getByRole('link', { name: /button/i });
    fireEvent.click(resultLink);
    expect(screen.queryByPlaceholderText(/Search components, docs\.\.\./i)).not.toBeInTheDocument();
  });

  it('opens search modal via Ctrl+K shortcut, and closes via Escape key / overlay click', () => {
    render(<Navbar starCount={100} lang="id" />);
    
    // Press Ctrl+K
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });
    expect(screen.getByPlaceholderText(/Search components, docs\.\.\./i)).toBeInTheDocument();

    // Press Escape
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(screen.queryByPlaceholderText(/Search components, docs\.\.\./i)).not.toBeInTheDocument();

    // Press Cmd+K (metaKey)
    fireEvent.keyDown(document, { metaKey: true, key: 'k' });
    expect(screen.getByPlaceholderText(/Search components, docs\.\.\./i)).toBeInTheDocument();

    // Click overlay background to close
    const overlay = screen.getByRole('button', { name: /close search overlay/i });
    fireEvent.click(overlay);
    expect(screen.queryByPlaceholderText(/Search components, docs\.\.\./i)).not.toBeInTheDocument();
  });

  it('closes search modal via Space/Enter keys on overlay role target', () => {
    render(<Navbar starCount={100} lang="en" />);
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });
    
    const overlay = screen.getByRole('button', { name: /close search overlay/i });
    
    // Test Space key on non-overlay click target (ignored)
    fireEvent.keyDown(overlay, { key: ' ' });
    expect(screen.queryByPlaceholderText(/Search components, docs\.\.\./i)).not.toBeInTheDocument();
  });
});
