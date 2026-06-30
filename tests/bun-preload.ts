import { JSDOM } from 'jsdom';
import { mock } from 'bun:test';
import { vi as viRoot } from 'vitest';
import { docs } from '../apps/docs/test/mocks/collections-server';

// 1. Initialize JSDOM
const dom = new JSDOM('<!DOCTYPE html><html><body></body></html>', {
  url: 'http://localhost',
  pretendToBeVisual: true,
});

globalThis.window = dom.window as any;
globalThis.document = dom.window.document;
globalThis.navigator = dom.window.navigator;

// Copy JSDOM window properties to globalThis
const windowProps = Object.getOwnPropertyNames(dom.window)
  .filter((p) => !p.startsWith('_'))
  .filter((p) => !(p in globalThis));

for (const prop of windowProps) {
  Object.defineProperty(globalThis, prop, {
    get: () => dom.window[prop as any],
    set: (val) => {
      dom.window[prop as any] = val;
    },
    configurable: true,
  });
}

globalThis.requestAnimationFrame = dom.window.requestAnimationFrame || ((cb) => setTimeout(cb, 0));
globalThis.cancelAnimationFrame = dom.window.cancelAnimationFrame || ((id) => clearTimeout(id));

// Helper to get the currently executing test file name from the stack trace
const getCallerFile = (): string | null => {
  const stack = new Error().stack;
  if (!stack) return null;
  const match = stack.match(/([\w-]+\.(test|spec)\.tsx?)/);
  return match ? match[1] : null;
};

// Helper to register mock for both bare name and resolved ESM paths (root and workspace)
const registerMock = (moduleName: string, factory: () => any) => {
  mock.module(moduleName, factory);
  
  // Resolve ESM entry point relative to root
  try {
    const resolved = import.meta.resolve(moduleName);
    const path = resolved.startsWith('file://') ? resolved.slice(7) : resolved;
    mock.module(path, factory);
  } catch (e) {}

  // Resolve ESM entry point relative to apps/docs
  try {
    const referrer = import.meta.resolve('../apps/docs/package.json');
    const resolved = import.meta.resolve(moduleName, referrer);
    const path = resolved.startsWith('file://') ? resolved.slice(7) : resolved;
    mock.module(path, factory);
  } catch (e) {}
};

// Generic factory to create a proxy that delegates to file-isolated mocks or defaults
const createFileIsolatedProxy = (realModule: any, defaultMock: any) => {
  const fileMocks = new Map<string, any>();

  const proxy = new Proxy({}, {
    get(target, prop) {
      // Capture the caller file at import time (when the property is accessed on the proxy)
      const importTimeCallerFile = getCallerFile();

      const getValue = (callerFile: string | null) => {
        const fileMock = callerFile ? fileMocks.get(callerFile) : null;
        if (fileMock && prop in fileMock) {
          return fileMock[prop];
        }
        if (defaultMock && prop in defaultMock) {
          return defaultMock[prop];
        }
        return realModule ? realModule[prop] : undefined;
      };

      const val = getValue(importTimeCallerFile);
      if (typeof val !== 'function') {
        return val;
      }

      // Return a dynamic forwarding function that closes over the import-time caller file
      const wrapper = function(this: any, ...args: any[]) {
        const activeVal = getValue(importTimeCallerFile);
        if (typeof activeVal === 'function') {
          return activeVal.apply(this, args);
        }
        return activeVal;
      };

      // Forward static properties (like displayName or React elements) to the active mock at runtime
      return new Proxy(wrapper, {
        get(wTarget, wProp) {
          const activeVal = getValue(importTimeCallerFile);
          if (activeVal && (typeof activeVal === 'object' || typeof activeVal === 'function')) {
            return Reflect.get(activeVal, wProp);
          }
          return undefined;
        },
        has(wTarget, wProp) {
          const activeVal = getValue(importTimeCallerFile);
          if (activeVal && (typeof activeVal === 'object' || typeof activeVal === 'function')) {
            return Reflect.has(activeVal, wProp);
          }
          return false;
        }
      });
    },
    has(target, prop) {
      const callerFile = getCallerFile();
      const fileMock = callerFile ? fileMocks.get(callerFile) : null;
      if (fileMock && prop in fileMock) return true;
      if (defaultMock && prop in defaultMock) return true;
      return realModule ? prop in realModule : false;
    },
    ownKeys(target) {
      const callerFile = getCallerFile();
      const fileMock = callerFile ? fileMocks.get(callerFile) : null;
      const keys = new Set<string | symbol>();
      if (fileMock) {
        Reflect.ownKeys(fileMock).forEach((k) => keys.add(k));
      } else if (defaultMock) {
        Reflect.ownKeys(defaultMock).forEach((k) => keys.add(k));
      }
      if (realModule) {
        Reflect.ownKeys(realModule).forEach((k) => keys.add(k));
      }
      return Array.from(keys);
    },
    getOwnPropertyDescriptor(target, prop) {
      const callerFile = getCallerFile();
      const fileMock = callerFile ? fileMocks.get(callerFile) : null;
      let desc;
      if (fileMock && prop in fileMock) {
        desc = Reflect.getOwnPropertyDescriptor(fileMock, prop);
      } else if (defaultMock && prop in defaultMock) {
        desc = Reflect.getOwnPropertyDescriptor(defaultMock, prop);
      } else if (realModule) {
        desc = Reflect.getOwnPropertyDescriptor(realModule, prop);
      }
      if (desc) {
        return {
          ...desc,
          configurable: true,
        };
      }
      return undefined;
    },
  });

  return {
    proxy,
    setMock: (file: string, mockVal: any) => {
      fileMocks.set(file, mockVal);
    },
    clearMocks: () => {
      fileMocks.clear();
    },
  };
};

// Polyfill missing Vitest `vi` methods using Bun's primitives
const mockFunctions = new Set<any>();
const vi = {
  fn: (impl?: any) => {
    const m = mock(impl);
    mockFunctions.add(m);
    return m;
  },
  clearAllMocks: () => {
    for (const m of mockFunctions) {
      if (m && typeof m.mockClear === 'function') {
        m.mockClear();
      }
    }
    return vi;
  },
  stubEnv: (name: string, value: string) => {
    process.env[name] = value;
    return vi;
  },
  unstubAllEnvs: () => {
    delete process.env.GITHUB_TOKEN;
    return vi;
  },
  mock: (moduleName: string, factory: () => any) => {
    const callerFile = getCallerFile();
    console.log(`DEBUG: vi.mock called for "${moduleName}" from callerFile = "${callerFile}"`);
    if (!callerFile) {
      registerMock(moduleName, factory);
      return vi;
    }

    if (moduleName === '@/lib/github') {
      githubMockHelper.setMock(callerFile, factory());
    } else if (moduleName === '@/lib/source') {
      sourceMockHelper.setMock(callerFile, factory());
    } else if (moduleName === 'next/navigation') {
      nextNavigationHelper.setMock(callerFile, factory());
    } else if (moduleName === 'next-themes') {
      nextThemesHelper.setMock(callerFile, factory());
    } else if (moduleName === 'next/link') {
      nextLinkHelper.setMock(callerFile, factory());
    } else if (moduleName === 'next/font/google') {
      nextFontGoogleHelper.setMock(callerFile, factory());
    } else if (moduleName === 'fumadocs-ui/provider/next') {
      fumadocsProviderNextHelper.setMock(callerFile, factory());
    } else if (moduleName === 'fumadocs-ui/layouts/docs') {
      fumadocsLayoutsDocsHelper.setMock(callerFile, factory());
    } else if (moduleName === 'fumadocs-ui/page') {
      fumadocsPageHelper.setMock(callerFile, factory());
    } else if (moduleName === 'fumadocs-core/search/client') {
      fumadocsSearchClientHelper.setMock(callerFile, factory());
    } else if (moduleName === 'fumadocs-ui/components/dialog/search') {
      fumadocsDialogSearchHelper.setMock(callerFile, factory());
    } else {
      registerMock(moduleName, factory);
    }
    return vi;
  }
};

// Mutate vitest exports directly in the module cache so that files importing vitest get our wrapped versions
const mutateVi = (viObj: any) => {
  if (!viObj) return;
  viObj.mock = vi.mock;
  viObj.fn = vi.fn;
  viObj.clearAllMocks = vi.clearAllMocks;
  viObj.stubEnv = vi.stubEnv;
  viObj.unstubAllEnvs = vi.unstubAllEnvs;
};

mutateVi(viRoot);

try {
  const viDocs = require('../apps/docs/node_modules/vitest').vi;
  mutateVi(viDocs);
} catch (e) {}

// 2. Mock 'collections/server' FIRST (so that requiring source.ts uses the mock)
registerMock('collections/server', () => ({
  docs,
}));

// 3. Load the real local modules
const realGithub = require('../apps/docs/src/lib/github');
const realSource = require('../apps/docs/src/lib/source');

// Create proxies for local modules
const githubMockHelper = createFileIsolatedProxy(realGithub, null);

// Rich default mock for @/lib/source to satisfy routing, static params, and page rendering
const defaultSource = {
  getPage: (slugs: string[], lang?: string) => {
    if ((globalThis as any).mockGetPage) {
      return (globalThis as any).mockGetPage(slugs, lang);
    }
    return {
      title: 'Introduction',
      description: 'Welcome to JustUI',
      data: {
        title: 'Introduction',
        description: 'Welcome to JustUI',
        body: () => {
          const React = require('../apps/docs/node_modules/react');
          return React.createElement('div', { 'data-testid': 'mdx-content' }, 'MDX Text');
        },
        toc: [],
        full: false,
      },
    };
  },
  getPages: () => {
    if ((globalThis as any).mockGetPages) {
      return (globalThis as any).mockGetPages();
    }
    return [
      {
        slugs: ['intro'],
        url: '/docs/intro',
        data: { title: 'Introduction' },
      }
    ];
  },
  generateParams: () => {
    if ((globalThis as any).mockGenerateParams) {
      return (globalThis as any).mockGenerateParams();
    }
    return [
      {
        lang: 'en',
        slug: ['intro'],
      }
    ];
  },
  pageTree: {
    id: {},
    en: {},
  },
};

// The @/lib/source module exports a `source` object, so we must nest the default mock accordingly
const defaultSourceModule = {
  source: defaultSource,
};

const sourceMockHelper = createFileIsolatedProxy(realSource, defaultSourceModule);

const resolveLocal = (p: string) => {
  try {
    return require.resolve(p);
  } catch (e) {
    return p;
  }
};

mock.module('@/lib/github', () => githubMockHelper.proxy);
mock.module(resolveLocal('../apps/docs/src/lib/github'), () => githubMockHelper.proxy);

mock.module('@/lib/source', () => sourceMockHelper.proxy);
mock.module(resolveLocal('../apps/docs/src/lib/source'), () => sourceMockHelper.proxy);

// 4. Create dynamic delegating mocks for Next.js and Fumadocs modules
const defaultNextNavigation = {
  usePathname: () => (globalThis as any).mockPathname || '/id',
  useRouter: () => ({
    push: () => {},
    replace: () => {},
    prefetch: () => {},
  }),
  notFound: () => {
    if ((globalThis as any).mockNotFound) {
      (globalThis as any).mockNotFound();
    }
    throw new Error('NEXT_NOT_FOUND');
  },
};

const defaultNextThemes = {
  useTheme: () => ({
    get resolvedTheme() {
      return (globalThis as any).mockResolvedTheme || 'dark';
    },
    setTheme: (theme: string) => {
      if ((globalThis as any).mockSetTheme) {
        (globalThis as any).mockSetTheme(theme);
      }
    },
  }),
  ThemeProvider: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('div', { 'data-testid': 'theme-provider' }, children);
  },
};

const defaultNextLink = {
  default: ({ children, href, ...props }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('a', { href, ...props }, children);
  },
};

const defaultFumadocsProviderNext = {
  RootProvider: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('div', { 'data-testid': 'root-provider' }, children);
  },
};

const defaultDocsLayout = {
  DocsLayout: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('div', { 'data-testid': 'docs-layout' }, children);
  },
};

const defaultDocsPage = {
  DocsPage: ({ children }: any) => children,
  DocsBody: ({ children }: any) => children,
  DocsTitle: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('h1', null, children);
  },
  DocsDescription: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('p', null, children);
  },
};

const defaultSearchDialog = {
  SearchDialog: ({ children, open }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return open ? React.createElement('div', { 'data-testid': 'search-dialog' }, children) : null;
  },
  SearchDialogList: ({ items }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement(
      'div',
      { 'data-testid': 'search-list' },
      items ? items.map((item: any, idx: number) => React.createElement('div', { key: idx }, item.title)) : 'No items'
    );
  },
  SearchDialogInput: (props: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('input', {
      'data-testid': 'search-input',
      onChange: (e: any) => {
        if ((globalThis as any).mockSetSearch) {
          (globalThis as any).mockSetSearch(e.target.value);
        }
        if (props.onChange) {
          props.onChange(e);
        }
      },
      ...props
    });
  },
  SearchDialogContent: ({ children }: any) => {
    const React = require('../apps/docs/node_modules/react');
    return React.createElement('div', { 'data-testid': 'search-content' }, children);
  },
};

const defaultFumadocsSearchClient = {
  useDocsSearch: () => ({
    search: 'test query',
    setSearch: (val: string) => {
      if ((globalThis as any).mockSetSearch) {
        (globalThis as any).mockSetSearch(val);
      }
    },
    get query() {
      return (globalThis as any).mockQueryData || { data: 'empty' };
    },
  }),
};

// Create proxies for framework modules
const nextNavigationHelper = createFileIsolatedProxy(null, defaultNextNavigation);
const nextThemesHelper = createFileIsolatedProxy(null, defaultNextThemes);
const nextLinkHelper = createFileIsolatedProxy(null, defaultNextLink);
const nextFontGoogleHelper = createFileIsolatedProxy(null, {
  IBM_Plex_Mono: () => ({ variable: 'font-mono' }),
  IBM_Plex_Sans: () => ({ variable: 'font-sans' }),
});
const fumadocsProviderNextHelper = createFileIsolatedProxy(null, defaultFumadocsProviderNext);
const fumadocsLayoutsDocsHelper = createFileIsolatedProxy(null, defaultDocsLayout);
const fumadocsPageHelper = createFileIsolatedProxy(null, defaultDocsPage);
const fumadocsSearchClientHelper = createFileIsolatedProxy(null, defaultFumadocsSearchClient);
const fumadocsDialogSearchHelper = createFileIsolatedProxy(null, defaultSearchDialog);

// Register the delegating mocks
registerMock('next/navigation', () => nextNavigationHelper.proxy);
registerMock('next-themes', () => nextThemesHelper.proxy);
registerMock('next/link', () => nextLinkHelper.proxy);
registerMock('next/font/google', () => nextFontGoogleHelper.proxy);
registerMock('fumadocs-ui/provider/next', () => fumadocsProviderNextHelper.proxy);
registerMock('fumadocs-ui/layouts/docs', () => fumadocsLayoutsDocsHelper.proxy);
registerMock('fumadocs-ui/page', () => fumadocsPageHelper.proxy);
registerMock('fumadocs-core/search/client', () => fumadocsSearchClientHelper.proxy);
registerMock('fumadocs-ui/components/dialog/search', () => fumadocsDialogSearchHelper.proxy);

const allHelpers = [
  githubMockHelper,
  sourceMockHelper,
  nextNavigationHelper,
  nextThemesHelper,
  nextLinkHelper,
  nextFontGoogleHelper,
  fumadocsProviderNextHelper,
  fumadocsLayoutsDocsHelper,
  fumadocsPageHelper,
  fumadocsSearchClientHelper,
  fumadocsDialogSearchHelper,
];

// 6. Globally mock fetch to prevent network calls from reaching the sandbox boundaries
globalThis.fetch = mock(() => {
  return Promise.resolve(new Response(JSON.stringify({}), { status: 404 }));
}) as any;
