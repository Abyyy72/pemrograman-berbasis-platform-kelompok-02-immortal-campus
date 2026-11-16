/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{svelte,js,ts,jsx,tsx}'],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'primary': '#0050cb',
        'primary-container': '#0066ff',
        'on-primary': '#ffffff',
        'on-primary-container': '#f8f7ff',
        'primary-fixed': '#dae1ff',
        'primary-fixed-dim': '#b3c5ff',
        'on-primary-fixed': '#001849',
        'on-primary-fixed-variant': '#003fa4',
        'inverse-primary': '#b3c5ff',

        'secondary': '#006688',
        'secondary-container': '#00c1fd',
        'on-secondary': '#ffffff',
        'on-secondary-container': '#004b65',
        'secondary-fixed': '#c2e8ff',
        'secondary-fixed-dim': '#75d1ff',
        'on-secondary-fixed': '#001e2b',
        'on-secondary-fixed-variant': '#004d67',

        'tertiary': '#4b41d2',
        'tertiary-container': '#655dec',
        'on-tertiary': '#ffffff',
        'on-tertiary-container': '#faf6ff',
        'tertiary-fixed': '#e3dfff',
        'tertiary-fixed-dim': '#c3c0ff',
        'on-tertiary-fixed': '#100069',
        'on-tertiary-fixed-variant': '#372abf',

        'surface': '#f8f9ff',
        'surface-bright': '#f8f9ff',
        'surface-dim': '#cbdbf5',
        'surface-card': '#FFFFFF',
        'surface-muted': '#F1F5F9',
        'surface-canvas': '#F8FAFC',
        'surface-container-lowest': '#ffffff',
        'surface-container-low': '#eff4ff',
        'surface-container': '#e5eeff',
        'surface-container-high': '#dce9ff',
        'surface-container-highest': '#d3e4fe',
        'surface-variant': '#d3e4fe',
        'surface-tint': '#0054d6',

        'on-surface': '#0b1c30',
        'on-surface-variant': '#424656',
        'inverse-surface': '#213145',
        'inverse-on-surface': '#eaf1ff',
        'background': '#f8f9ff',
        'on-background': '#0b1c30',

        'outline': '#727687',
        'outline-variant': '#c2c6d8',
        'border-subtle': '#E2E8F0',
        'accent-glow': 'rgba(0, 102, 255, 0.12)',

        'text-primary': '#0F172A',
        'text-secondary': '#475569',
        'text-tertiary': '#94A3B8',

        'status-published': '#10B981',
        'status-draft': '#64748B',
        'status-review': '#EAB308',
        'status-revision': '#F97316',
        'status-rejected': '#EF4444',
        'status-submitted': '#0284C7',

        'error': '#ba1a1a',
        'error-container': '#ffdad6',
        'on-error': '#ffffff',
        'on-error-container': '#93000a'
      },
      borderRadius: {
        DEFAULT: '0.25rem',
        lg: '0.5rem',
        xl: '0.75rem',
        full: '9999px'
      },
      spacing: {
        'space-xs': '0.25rem',
        'space-sm': '0.5rem',
        'space-md': '1rem',
        'space-lg': '1.5rem',
        'space-xl': '2.5rem',
        'gutter': '1.5rem',
        'gutter-mobile': '1rem',
        'margin': '2rem',
        'margin-mobile': '1rem'
      },
      fontFamily: {
        'display-hero': ['Plus Jakarta Sans', 'sans-serif'],
        'headline-xl': ['Plus Jakarta Sans', 'sans-serif'],
        'headline-lg': ['Plus Jakarta Sans', 'sans-serif'],
        'headline-md': ['Plus Jakarta Sans', 'sans-serif'],
        'headline-sm': ['Plus Jakarta Sans', 'sans-serif'],
        'body-lg': ['Plus Jakarta Sans', 'sans-serif'],
        'body-md': ['Plus Jakarta Sans', 'sans-serif'],
        'body-sm': ['Plus Jakarta Sans', 'sans-serif'],
        'label-badge': ['Plus Jakarta Sans', 'sans-serif'],
        'label-caption': ['Plus Jakarta Sans', 'sans-serif'],
        'label-mono-sm': ['JetBrains Mono', 'monospace'],
        'sans': ['Plus Jakarta Sans', 'system-ui', 'sans-serif']
      },
      fontSize: {
        'display-hero': ['56px', { lineHeight: '64px', letterSpacing: '-0.03em', fontWeight: '800' }],
        'display-hero-mobile': ['36px', { lineHeight: '44px', letterSpacing: '-0.02em', fontWeight: '800' }],
        'headline-xl': ['32px', { lineHeight: '40px', letterSpacing: '-0.02em', fontWeight: '700' }],
        'headline-xl-mobile': ['26px', { lineHeight: '34px', letterSpacing: '-0.02em', fontWeight: '700' }],
        'headline-lg': ['24px', { lineHeight: '32px', letterSpacing: '-0.015em', fontWeight: '700' }],
        'headline-md': ['20px', { lineHeight: '28px', letterSpacing: '-0.01em', fontWeight: '600' }],
        'headline-sm': ['16px', { lineHeight: '24px', letterSpacing: '-0.005em', fontWeight: '600' }],
        'body-lg': ['18px', { lineHeight: '28px', fontWeight: '400' }],
        'body-md': ['15px', { lineHeight: '24px', fontWeight: '400' }],
        'body-sm': ['13px', { lineHeight: '20px', fontWeight: '400' }],
        'label-badge': ['12px', { lineHeight: '16px', letterSpacing: '0.01em', fontWeight: '600' }],
        'label-caption': ['11px', { lineHeight: '14px', letterSpacing: '0.02em', fontWeight: '500' }],
        'label-mono-sm': ['12px', { lineHeight: '16px', letterSpacing: '0.02em', fontWeight: '500' }]
      }
    }
  },
  plugins: []
};

