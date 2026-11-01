---
name: design-system-patterns
description: Build scalable design systems with design tokens, theming infrastructure, and component architecture patterns. Use when creating design tokens, implementing theme switching, building component libraries, or establishing design system foundations.
---

# Design System Patterns

Master design system architecture to create consistent, maintainable, and scalable UI foundations across web and mobile applications.

## When to Use This Skill

- Creating design tokens for colors, typography, spacing, and shadows
- Implementing light/dark theme switching with CSS custom properties
- Building multi-brand theming systems
- Architecting component libraries with consistent APIs
- Establishing design-to-code workflows with Figma tokens
- Creating semantic token hierarchies (primitive, semantic, component)
- Setting up design system documentation and guidelines

## Core Capabilities

### 1. Design Tokens

- Primitive tokens (raw values: colors, sizes, fonts)
- Semantic tokens (contextual meaning: text-primary, surface-elevated)
- Component tokens (specific usage: button-bg, card-border)
- Token naming conventions and organization
- Multi-platform token generation (CSS, iOS, Android)

### 2. Theming Infrastructure

- CSS custom properties architecture
- Theme context providers in React
- Dynamic theme switching
- System preference detection (prefers-color-scheme)
- Persistent theme storage
- Reduced motion and high contrast modes

### 3. Component Architecture

- Compound component patterns
- Polymorphic components (as prop)
- Variant and size systems
- Slot-based composition
- Headless UI patterns
- Style props and responsive variants

### 4. Token Pipeline

- Figma to code synchronization
- Style Dictionary configuration
- Token transformation and formatting
- CI/CD integration for token updates

### 5. Component Styling: Modular SCSS

- **SCSS Modules, never plain CSS.** File extension is always `.module.scss`, not `.module.css` or
  a global `.css` file — Sass gives nesting, variables, and mixins on top of CSS Modules' per-component
  scoped class names.
- Every component imports its own stylesheet as a `styles` object: `import styles from './Card.module.scss'`.
- Reference every class or id through that object — `styles.card`, `styles.cardHeader` — never a
  hardcoded string className.
- Write class/id names in the `.module.scss` file as **camelCase** (`.cardHeader`, not `.card-header`).
  A hyphenated name only works through bracket access (`styles['card-header']`), which defeats the
  point of the `styles.foo` convention — so don't hyphenate component-scoped class names.
- Requires the `sass` package as a dev dependency (`npm install --save-dev sass`); Next.js and Vite
  both compile `.module.scss` natively once it's present, no extra loader config needed.

### 6. Primitive Components: React Aria Components (Headless Foundation)

- **Every primitive comes from `react-aria-components` (Adobe, React Spectrum, Apache-2.0) first.**
  Never hand-build interaction logic, keyboard handling, focus management, or ARIA semantics from
  scratch — `react-aria-components` already solves this, tested against real screen readers, and
  ships zero styles of its own, so it drops cleanly into the SCSS Modules convention above with no
  Tailwind/utility-class conflict (unlike shadcn/ui, which is Tailwind-coupled and was ruled out for
  that reason).
- **Primitives live in their own isolated layer** — `src/primitives/`, separate from every
  feature/page component. One file per primitive (`Button.tsx`, `TextField.tsx`, `Select.tsx`,
  `Dialog.tsx`, ...), each wrapping exactly one `react-aria-components` export plus its own
  `.module.scss`.
- **Feature and page components never import from `react-aria-components` directly** — only from
  `primitives/`. This keeps the headless-library dependency in one place: swapping or upgrading it
  later touches the primitives layer only, never the rest of the app.
- A primitive's own job is strictly: wrap the React Aria Component, apply the project's SCSS Module
  class, expose the project's own typed props. It adds no new behavior — behavior is
  `react-aria-components`' job, not the primitive's.
- `react-aria-components` exposes interaction state as `data-*` attributes (`data-hovered`,
  `data-pressed`, `data-focused`, `data-disabled`, ...) instead of requiring manual
  `onMouseEnter`/`onFocus` handlers. Style those states directly in SCSS via attribute selectors —
  don't reimplement hover/press/focus state by hand.

## Quick Start

```typescript
// Design tokens with CSS custom properties
const tokens = {
  colors: {
    // Primitive tokens
    gray: {
      50: "#fafafa",
      100: "#f5f5f5",
      900: "#171717",
    },
    blue: {
      500: "#3b82f6",
      600: "#2563eb",
    },
  },
  // Semantic tokens (reference primitives)
  semantic: {
    light: {
      "text-primary": "var(--color-gray-900)",
      "text-secondary": "var(--color-gray-600)",
      "surface-default": "var(--color-white)",
      "surface-elevated": "var(--color-gray-50)",
      "border-default": "var(--color-gray-200)",
      "interactive-primary": "var(--color-blue-500)",
    },
    dark: {
      "text-primary": "var(--color-gray-50)",
      "text-secondary": "var(--color-gray-400)",
      "surface-default": "var(--color-gray-900)",
      "surface-elevated": "var(--color-gray-800)",
      "border-default": "var(--color-gray-700)",
      "interactive-primary": "var(--color-blue-400)",
    },
  },
};
```

### Modular SCSS worked example

```scss
// Card.module.scss
.card {
  display: flex;
  flex-direction: column;
  border-radius: var(--radius-md);
  background: var(--color-surface-default);

  &.outlined {
    border: 1px solid var(--color-border-default);
  }
}

.cardHeader {
  padding: var(--space-4);
  font-weight: 600;
  color: var(--color-text-primary);
}
```

```typescript
// Card.tsx
import styles from './Card.module.scss'

type CardProps = {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}
type CardReturnType = JSX.Element

export function Card(props: CardProps): CardReturnType {
  const variant = props.variant ?? 'default'
  const className = variant === 'outlined' ? `${styles.card} ${styles.outlined}` : styles.card

  return <div className={className}>{props.children}</div>
}

type CardHeaderProps = { children: React.ReactNode }
type CardHeaderReturnType = JSX.Element

export function CardHeader(props: CardHeaderProps): CardHeaderReturnType {
  return <div className={styles.cardHeader}>{props.children}</div>
}
```

### Primitive Component worked example (React Aria Components)

```scss
// primitives/Button.module.scss
.button {
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  font-weight: 600;
  background: var(--color-interactive-primary);
  color: var(--color-text-on-interactive);
  border: none;

  &[data-hovered] {
    opacity: 0.9;
  }

  &[data-pressed] {
    opacity: 0.8;
  }

  &[data-focus-visible] {
    outline: 2px solid var(--color-interactive-primary);
    outline-offset: 2px;
  }

  &[data-disabled] {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

.secondary {
  background: transparent;
  border: 1px solid var(--color-border-default);
  color: var(--color-text-primary);
}
```

```typescript
// primitives/Button.tsx
import { Button as AriaButton, type ButtonProps as AriaButtonProps } from 'react-aria-components'
import styles from './Button.module.scss'

type ButtonProps = {
  children: React.ReactNode
  variant?: 'primary' | 'secondary'
  onPress?: AriaButtonProps['onPress']
  isDisabled?: boolean
}
type ButtonReturnType = JSX.Element

export function Button(props: ButtonProps): ButtonReturnType {
  const variant = props.variant ?? 'primary'
  const className = variant === 'secondary' ? `${styles.button} ${styles.secondary}` : styles.button

  return (
    <AriaButton className={className} onPress={props.onPress} isDisabled={props.isDisabled}>
      {props.children}
    </AriaButton>
  )
}
```

```typescript
// features/create-market/CreateMarketForm.tsx
// PASS: feature code imports the primitive, never react-aria-components directly
import { Button } from '../../primitives/Button'

// FAIL: never do this from a feature/page component
// import { Button } from 'react-aria-components'
```

## Detailed patterns and worked examples

Detailed pattern documentation lives in `references/details.md`. Read that file when the navigation tier above is insufficient.

## Best Practices

1. **Name Tokens by Purpose**: Use semantic names (text-primary) not visual descriptions (dark-gray)
2. **Maintain Token Hierarchy**: Primitives > Semantic > Component tokens
3. **Document Token Usage**: Include usage guidelines with token definitions
4. **Version Tokens**: Treat token changes as API changes with semver
5. **Test Theme Combinations**: Verify all themes work with all components
6. **Automate Token Pipeline**: CI/CD for Figma-to-code synchronization
7. **Provide Migration Paths**: Deprecate tokens gradually with clear alternatives
8. **SCSS Modules Over Plain CSS**: `.module.scss` + a `styles` import on every component, camelCase class names, no global stylesheets
9. **Primitives Come From React Aria Components**: never hand-build a primitive's accessibility/interaction logic; wrap `react-aria-components` in an isolated `primitives/` layer and style its `data-*` state attributes

## Common Issues

- **Token Sprawl**: Too many tokens without clear hierarchy
- **Inconsistent Naming**: Mixed conventions (camelCase vs kebab-case)
- **Missing Dark Mode**: Tokens that don't adapt to theme changes
- **Hardcoded Values**: Using raw values instead of tokens
- **Circular References**: Tokens referencing each other in loops
- **Platform Gaps**: Tokens missing for some platforms (web but not mobile)
- **Primitives Built From Scratch**: Hand-rolling keyboard/focus/ARIA behavior instead of wrapping `react-aria-components`
- **Primitives Layer Bypassed**: Feature components importing `react-aria-components` directly instead of going through `primitives/`
