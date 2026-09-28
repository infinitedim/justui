import { render, screen, fireEvent } from '@testing-library/react';
import { describe, expect, it, vi } from 'vitest';
import { Navbar } from '@/components/organisms/navbar';

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
}));

// Mock next/link to render simple anchors
vi.mock('next/link', () => ({
  default: ({ children, href, className, onClick, ...props }: any) => (
    <a href={href} className={className} onClick={onClick} {...props}>
      {children}
    </a>
  ),
}));

// The real CustomSearchDialog renders fumadocs-ui's SearchDialog, which
// requires a FrameworkProvider this unit test doesn't set up (and performs a
// real fetch against /api/search). Its own behavior is covered by
// test/search.test.tsx; here we only need to verify Navbar correctly wires
// the open state, keyboard shortcut, and lang prop to it.
vi.mock('@/components/search', () => ({
  default: ({
    open,
    onOpenChange,
    lang,
  }: {
    open: boolean;
    onOpenChange: (open: boolean) => void;
    lang: string;
  }) =>
    open ? (
      <div data-testid="search-dialog-stub" data-lang={lang}>
        <button type="button" onClick={() => onOpenChange(false)}>
          close
        </button>
      </div>
    ) : null,
}));

describe('Navbar & search dialog wiring', () => {
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

  it('opens the search dialog via button click, passing the active lang', () => {
    render(<Navbar starCount={100} lang="en" />);

    expect(screen.queryByTestId('search-dialog-stub')).not.toBeInTheDocument();

    const searchBtn = screen.getAllByRole('button', {
      name: /open search/i,
    })[0];
    fireEvent.click(searchBtn);

    const dialog = screen.getByTestId('search-dialog-stub');
    expect(dialog).toBeInTheDocument();
    expect(dialog).toHaveAttribute('data-lang', 'en');

    fireEvent.click(screen.getByText('close'));
    expect(screen.queryByTestId('search-dialog-stub')).not.toBeInTheDocument();
  });

  it('opens the search dialog via Ctrl+K and Cmd+K shortcuts', () => {
    render(<Navbar starCount={100} lang="id" />);

    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });
    expect(screen.getByTestId('search-dialog-stub')).toBeInTheDocument();

    fireEvent.click(screen.getByText('close'));
    expect(screen.queryByTestId('search-dialog-stub')).not.toBeInTheDocument();

    fireEvent.keyDown(document, { metaKey: true, key: 'k' });
    expect(screen.getByTestId('search-dialog-stub')).toBeInTheDocument();
  });

  it('renders correct navigation destinations for Docs, Components, and Studio', () => {
    render(<Navbar starCount={100} lang="en" />);
    const docsLink = screen.getByRole('link', { name: 'Docs' });
    const componentsLink = screen.getByRole('link', { name: 'Components' });
    const studioLink = screen.getByRole('link', { name: 'Studio' });

    expect(docsLink).toHaveAttribute('href', '/en/docs/introduction');
    expect(componentsLink).toHaveAttribute('href', '/en/components');
    expect(studioLink).toHaveAttribute('href', '/en/studio');
  });

  it('marks studio as active link when pathname is /en/studio', () => {
    mockPathname = '/en/studio';
    render(<Navbar starCount={100} lang="en" />);
    const studioLink = screen.getByRole('link', { name: 'Studio' });
    expect(studioLink).toHaveClass('text-foreground');
    expect(studioLink).not.toHaveClass('text-muted');
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

  it('renders Studio link in mobile drawer with active state and closes on link click', () => {
    mockPathname = '/en/studio';
    render(<Navbar starCount={100} lang="en" />);

    const menuBtn = screen.getByRole('button', {
      name: /open navigation menu/i,
    });
    fireEvent.click(menuBtn);

    const drawer = screen.getByTestId('mobile-navigation-drawer');
    expect(drawer).toBeInTheDocument();

    const mobileNav = screen.getByRole('navigation', {
      name: /mobile navigation/i,
    });
    const studioLink = mobileNav.querySelector('a[href="/en/studio"]');
    expect(studioLink).toBeInTheDocument();
    expect(studioLink).toHaveTextContent('Studio');
    expect(studioLink).toHaveClass('bg-accent-muted');

    fireEvent.click(studioLink!);
    expect(
      screen.queryByTestId('mobile-navigation-drawer')
    ).not.toBeInTheDocument();
  });
});
