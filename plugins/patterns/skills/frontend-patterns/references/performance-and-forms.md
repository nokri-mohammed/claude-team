## Performance Optimization

### Memoization — React Compiler is the default, hand-written memoization is the fallback

Every project this hub bootstraps enables the React Compiler in the build. Install it and turn it
on before writing any component:

```bash
npm install --save-dev babel-plugin-react-compiler eslint-plugin-react-hooks@latest
```

Enable it in the framework config — check the current framework docs for the exact key, since this
moved between `experimental` and stable across recent releases:

```javascript
// next.config.js
module.exports = {
  experimental: { reactCompiler: true } // or the stable top-level key on current Next.js
}
```

```javascript
// vite.config.js — via @vitejs/plugin-react's compiler option (check current docs for your
// @vitejs/plugin-react / Vite major version; Vite 8 moved the default transform to oxc)
```

**With the compiler on: do not hand-write `useMemo`, `useCallback`, or `React.memo` for render-cost
optimization.** The compiler infers this automatically and more precisely than a human will. Adding
it anyway is not "being careful" — it's dead code that adds a dependency array to get wrong, and in
some cases fights the compiler's own memoization. Just write the plain computation, plain function,
plain component:

```typescript
// PASS: compiler on - no useMemo, just the computation
// Copy before sorting - Array.prototype.sort mutates in place
const sortedMarkets = [...markets].sort((a, b) => b.volume - a.volume)

// PASS: compiler on - no useCallback, just the function
function handleSearch(query: string): void {
  setSearchQuery(query)
}

// PASS: compiler on - no React.memo, just the component
type MarketCardProps = { market: Market }
type MarketCardReturnType = JSX.Element

function MarketCard(props: MarketCardProps): MarketCardReturnType {
  return (
    <div className="market-card">
      <h3>{props.market.name}</h3>
      <p>{props.market.description}</p>
    </div>
  )
}
```

Manual memoization is still correct in two narrow cases, compiler on or not:

1. **Referential identity needed by something outside render** — a value handed to an external
   subscription, an imperative API, or a `useEffect` dependency that must stay stable across
   renders. The compiler optimizes re-renders, not external-system identity contracts.
2. **A component the compiler bails out on** — `eslint-plugin-react-hooks` reports compiler
   bailouts. Fix the cause of the bailout first; reach for manual memoization only as a last resort,
   never as the first response.

### Manual fallback (compiler not enabled on this project)

```typescript
// PASS: useMemo for expensive computations
// Copy before sorting - Array.prototype.sort mutates in place
const sortedMarkets = useMemo(() => {
  return [...markets].sort((a, b) => b.volume - a.volume)
}, [markets])

// PASS: useCallback for functions passed to children
function handleSearch(query: string): void {
  setSearchQuery(query)
}
const memoizedHandleSearch = useCallback(handleSearch, [])

// PASS: React.memo for pure components, still a named function underneath
type MarketCardProps = { market: Market }
type MarketCardReturnType = JSX.Element

function MarketCardImpl(props: MarketCardProps): MarketCardReturnType {
  return (
    <div className="market-card">
      <h3>{props.market.name}</h3>
      <p>{props.market.description}</p>
    </div>
  )
}
export const MarketCard = React.memo(MarketCardImpl)
```

### Code Splitting & Lazy Loading

```typescript
import { lazy, Suspense } from 'react'

// PASS: Lazy load heavy components
const HeavyChart = lazy(() => import('./HeavyChart'))
const ThreeJsBackground = lazy(() => import('./ThreeJsBackground'))

type DashboardReturnType = JSX.Element

export function Dashboard(): DashboardReturnType {
  return (
    <div>
      <Suspense fallback={<ChartSkeleton />}>
        <HeavyChart data={data} />
      </Suspense>

      <Suspense fallback={null}>
        <ThreeJsBackground />
      </Suspense>
    </div>
  )
}
```

### Virtualization for Long Lists

```typescript
import { useVirtualizer } from '@tanstack/react-virtual'

type VirtualMarketListProps = { markets: Market[] }
type VirtualMarketListReturnType = JSX.Element

export function VirtualMarketList(props: VirtualMarketListProps): VirtualMarketListReturnType {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: props.markets.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 100,  // Estimated row height
    overscan: 5  // Extra items to render
  })

  return (
    <div ref={parentRef} style={{ height: '600px', overflow: 'auto' }}>
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          position: 'relative'
        }}
      >
        {virtualizer.getVirtualItems().map(virtualRow => (
          <div
            key={virtualRow.index}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`
            }}
          >
            <MarketCard market={props.markets[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

## Form Handling Patterns

### Controlled Form with Validation

```typescript
type FormData = {
  name: string
  description: string
  endDate: string
}

type FormErrors = {
  name?: string
  description?: string
  endDate?: string
}

type CreateMarketFormReturnType = JSX.Element

export function CreateMarketForm(): CreateMarketFormReturnType {
  const [formData, setFormData] = useState<FormData>({
    name: '',
    description: '',
    endDate: ''
  })

  const [errors, setErrors] = useState<FormErrors>({})

  function validate(): boolean {
    const newErrors: FormErrors = {}

    if (!formData.name.trim()) {
      newErrors.name = 'Name is required'
    } else if (formData.name.length > 200) {
      newErrors.name = 'Name must be under 200 characters'
    }

    if (!formData.description.trim()) {
      newErrors.description = 'Description is required'
    }

    if (!formData.endDate) {
      newErrors.endDate = 'End date is required'
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  async function handleSubmit(e: React.FormEvent): Promise<void> {
    e.preventDefault()

    if (!validate()) return

    try {
      await createMarket(formData)
      // Success handling
    } catch (error) {
      // Error handling
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={formData.name}
        onChange={e => setFormData(prev => ({ ...prev, name: e.target.value }))}
        placeholder="Market name"
      />
      {errors.name && <span className="error">{errors.name}</span>}

      {/* Other fields */}

      <button type="submit">Create Market</button>
    </form>
  )
}
```

Prefer the Zod-validated form pattern in **API Service Layer** below over hand-rolled `validate()`
functions like the one above once a backend schema exists to validate against.

## Error Boundary Pattern

```typescript
type ErrorBoundaryProps = { children: React.ReactNode }
type ErrorBoundaryState = {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState> {
  state: ErrorBoundaryState = {
    hasError: false,
    error: null
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
    console.error('Error boundary caught:', error, errorInfo)
  }

  render(): React.ReactNode {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>{this.state.error?.message}</p>
          <button onClick={() => this.setState({ hasError: false })}>
            Try again
          </button>
        </div>
      )
    }

    return this.props.children
  }
}

// Usage
<ErrorBoundary>
  <App />
</ErrorBoundary>
```

