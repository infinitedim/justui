import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Navbar } from '@/components/navbar';

// Mock next-themes
const mockSetTheme = vi.fn((theme) => {
  console.log('DEBUG: mockSetTheme called with:', theme);
});

(globalThis as any).mockSetTheme = mockSetTheme;

let mockResolvedTheme = 'dark';
Object.defineProperty(globalThis, 'mockResolvedTheme', {
  get: () => mockResolvedTheme,
  set: (val) => {
    mockResolvedTheme = val;
  },
  configurable: true,
});

vi.mock('next-themes', () => ({
  useTheme: () => ({
    resolvedTheme: mockResolvedTheme,
    setTheme: mockSetTheme,
  }),
}));

// Mock next/navigation
let mockPathname = '/id';
const mockPush = vi.fn();
const mockPush = vi.fn();
Object.defineProperty(globalThis, 'mockPathname', {
  get: () => mockPathname,
  set: (val) => {
    mockPathname = val;
  },
  configurable: true,
});

vi.mock('next/navigation', () => ({
  usePathname: () => mockPathname,
  useRouter: () => ({
    push: mockPush,
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
  useRouter: () => ({
    push: mockPush,
    replace: vi.fn(),
    prefetch: vi.fn(),
  }),
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
    const linkId = screen.getByRole('link', {
      name: /ganti ke Bahasa Inggris/i,
    });
    expect(linkId).toHaveAttribute('href', '/en');

    mockPathname = '/en';
    rerender(<Navbar starCount={100} lang="en" />);
    const linkEn = screen.getByRole('link', { name: /Switch to Indonesian/i });
    expect(linkEn).toHaveAttribute('href', '/id');
  });

  it('toggles theme correctly via ThemeSwitcher', () => {
    mockResolvedTheme = 'dark';
    const { rerender } = render(<Navbar starCount={100} lang="id" />);
    const themeBtn = screen.getByRole('button', { name: /ubah tema/i });

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
    expect(
      screen.queryByPlaceholderText(/Search components, docs\.\.\./i)
    ).not.toBeInTheDocument();

    // Click search button to open
    const searchBtn = screen.getAllByRole('button', {
      name: /open search/i,
    })[0];
    const searchBtn = screen.getAllByRole('button', {
      name: /open search/i,
    })[0];
    fireEvent.click(searchBtn);

    // Search modal should be open
    const input = screen.getByPlaceholderText(
      /Search components, docs\.\.\./i
    ) as HTMLInputElement;
    expect(input).toBeInTheDocument();

    // Type query to filter results
    fireEvent.change(input, { target: { value: 'button' } });
    expect(input.value).toBe('button');

    // Click result link to close
    const resultLink = screen.getByRole('link', { name: /^JustButton/i });
    const resultLink = screen.getByRole('link', { name: /^JustButton/i });
    fireEvent.click(resultLink);
    expect(
      screen.queryByPlaceholderText(/Search components, docs\.\.\./i)
    ).not.toBeInTheDocument();
  });

  it('opens search modal via Ctrl+K shortcut, and closes via Escape key / overlay click', () => {
    render(<Navbar starCount={100} lang="id" />);

    // Press Ctrl+K
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });
    expect(
      screen.getByPlaceholderText(/Search components, docs\.\.\./i)
    ).toBeInTheDocument();

    // Press Escape
    fireEvent.keyDown(document, { key: 'Escape' });
    expect(
      screen.queryByPlaceholderText(/Search components, docs\.\.\./i)
    ).not.toBeInTheDocument();

    // Press Cmd+K (metaKey)
    fireEvent.keyDown(document, { metaKey: true, key: 'k' });
    expect(
      screen.getByPlaceholderText(/Search components, docs\.\.\./i)
    ).toBeInTheDocument();

    // Click overlay background to close
    const overlay = screen.getByTestId('search-overlay');
    const overlay = screen.getByTestId('search-overlay');
    fireEvent.click(overlay);
    expect(
      screen.queryByPlaceholderText(/Search components, docs\.\.\./i)
    ).not.toBeInTheDocument();
  });

  it('closes search modal via close button and handles keyboard navigation', () => {
  it('closes search modal via close button and handles keyboard navigation', () => {
    render(<Navbar starCount={100} lang="en" />);
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });

    const closeBtn = screen.getByRole('button', {
      name: /close search/i,
    const closeBtn = screen.getByRole('button', {
      name: /close search/i,
    });
    fireEvent.click(closeBtn);
    fireEvent.click(closeBtn);
    expect(
      screen.queryByPlaceholderText(/Search components, docs\.\.\./i)
    ).not.toBeInTheDocument();

    // Re-open and test keyboard navigation
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });
    const input = screen.getByPlaceholderText(/Search components, docs\.\.\./i);
    fireEvent.keyDown(input, { key: 'ArrowDown' });
    fireEvent.keyDown(input, { key: 'Enter' });
    expect(mockPush).toHaveBeenCalled();
  });

  it('renders correct navigation destinations for Docs and Components', () => {
    render(<Navbar starCount={100} lang="en" />);
    const docsLink = screen.getByRole('link', { name: 'Docs' });
    const componentsLink = screen.getByRole('link', { name: 'Components' });

    expect(docsLink).toHaveAttribute('href', '/en/docs/introduction');
    expect(componentsLink).toHaveAttribute('href', '/en/components');
  });

  it('toggles mobile navigation drawer', () => {
    render(<Navbar starCount={100} lang="en" />);
    const menuBtn = screen.getByRole('button', {
      name: /open navigation menu/i,
    });
    expect(menuBtn).toHaveAttribute('aria-expanded', 'false');

    fireEvent.click(menuBtn);
    expect(menuBtn).toHaveAttribute('aria-expanded', 'true');

    fireEvent.click(menuBtn);
    expect(menuBtn).toHaveAttribute('aria-expanded', 'false');
  });

  it('renders correct navigation destinations for Docs and Components', () => {
    render(<Navbar starCount={100} lang="en" />);
    const docsLink = screen.getByRole('link', { name: 'Docs' });
    const componentsLink = screen.getByRole('link', { name: 'Components' });

    expect(docsLink).toHaveAttribute('href', '/en/docs/introduction');
    expect(componentsLink).toHaveAttribute('href', '/en/components');
  });

  it('toggles mobile navigation drawer', () => {
    render(<Navbar starCount={100} lang="en" />);
    const menuBtn = screen.getByRole('button', {
      name: /open navigation menu/i,
    });
    expect(menuBtn).toHaveAttribute('aria-expanded', 'false');

    fireEvent.click(menuBtn);
    expect(menuBtn).toHaveAttribute('aria-expanded', 'true');

    fireEvent.click(menuBtn);
    expect(menuBtn).toHaveAttribute('aria-expanded', 'false');
  });
});
