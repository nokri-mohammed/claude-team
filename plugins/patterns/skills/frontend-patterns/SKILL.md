---
name: frontend-patterns
description: Frontend development patterns for React, Next.js, state management, performance optimization, and UI best practices. Use when building or reviewing React or Next.js components, state, or render performance.
metadata:
  origin: ECC
---

# Frontend Development Patterns

Modern frontend patterns for React, Next.js, and performant user interfaces.

## When to Activate

- Building React components (composition, props, rendering)
- Managing state (useState, useReducer, Zustand, Context)
- Implementing data fetching (SWR, React Query, server components)
- Optimizing performance (memoization, virtualization, code splitting)
- Working with forms (validation, controlled inputs, Zod schemas)
- Handling client-side routing and navigation
- Building accessible, responsive UI patterns

## House Style (applies to every example below)

- `type`, never `interface`, for props, state, and every other object shape.
- Components and handlers are declared with `function`, never arrow functions assigned to a `const`.
- No destructuring in the parameter list. Take a single `props` parameter and read `props.foo` in the body.
- Never inline a return type as `: { ... }`. Give it a name — `type FooReturn = { ... }` — and annotate the function with that name.

```typescript
// FAIL: destructured arrow function, inline return shape
export const Card = ({ children, variant = 'default' }: CardProps) => {
  return <div className={`card card-${variant}`}>{children}</div>
}

// PASS: named function, props object, named return type
type CardProps = {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}

type CardReturnType = JSX.Element

export function Card(props: CardProps): CardReturnType {
  const variant = props.variant ?? 'default'
  return <div className={`card card-${variant}`}>{props.children}</div>
}
```

## Component Patterns

### Composition Over Inheritance

```typescript
type CardProps = {
  children: React.ReactNode
  variant?: 'default' | 'outlined'
}
type CardReturnType = JSX.Element

export function Card(props: CardProps): CardReturnType {
  const variant = props.variant ?? 'default'
  return <div className={`card card-${variant}`}>{props.children}</div>
}

type CardHeaderProps = { children: React.ReactNode }
type CardHeaderReturnType = JSX.Element

export function CardHeader(props: CardHeaderProps): CardHeaderReturnType {
  return <div className="card-header">{props.children}</div>
}

type CardBodyProps = { children: React.ReactNode }
type CardBodyReturnType = JSX.Element

export function CardBody(props: CardBodyProps): CardBodyReturnType {
  return <div className="card-body">{props.children}</div>
}

// Usage
<Card>
  <CardHeader>Title</CardHeader>
  <CardBody>Content</CardBody>
</Card>
```

### Compound Components

```typescript
type TabsContextValue = {
  activeTab: string
  setActiveTab: (tab: string) => void
}

const TabsContext = createContext<TabsContextValue | undefined>(undefined)

type TabsProps = {
  children: React.ReactNode
  defaultTab: string
}
type TabsReturnType = JSX.Element

export function Tabs(props: TabsProps): TabsReturnType {
  const [activeTab, setActiveTab] = useState(props.defaultTab)

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      {props.children}
    </TabsContext.Provider>
  )
}

type TabListProps = { children: React.ReactNode }
type TabListReturnType = JSX.Element

export function TabList(props: TabListProps): TabListReturnType {
  return <div className="tab-list">{props.children}</div>
}

type TabProps = { id: string; children: React.ReactNode }
type TabReturnType = JSX.Element

export function Tab(props: TabProps): TabReturnType {
  const context = useContext(TabsContext)
  if (!context) throw new Error('Tab must be used within Tabs')

  return (
    <button
      className={context.activeTab === props.id ? 'active' : ''}
      onClick={() => context.setActiveTab(props.id)}
    >
      {props.children}
    </button>
  )
}

// Usage
<Tabs defaultTab="overview">
  <TabList>
    <Tab id="overview">Overview</Tab>
    <Tab id="details">Details</Tab>
  </TabList>
</Tabs>
```

### Render Props Pattern

```typescript
type DataLoaderProps<T> = {
  url: string
  children: (data: T | null, loading: boolean, error: Error | null) => React.ReactNode
}
type DataLoaderReturnType = JSX.Element

export function DataLoader<T>(props: DataLoaderProps<T>): DataLoaderReturnType {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<Error | null>(null)

  useEffect(() => {
    (async () => {
      try {
        const res = await fetch(props.url)
        const json = await res.json()
        setData(json)
      } catch (err) {
        setError(err as Error)
      } finally {
        setLoading(false)
      }
    })()
  }, [props.url])

  return <>{props.children(data, loading, error)}</>
}

// Usage
<DataLoader<Market[]> url="/api/markets">
  {(markets, loading, error) => {
    if (loading) return <Spinner />
    if (error) return <Error error={error} />
    return <MarketList markets={markets!} />
  }}
</DataLoader>
```

## Custom Hooks Patterns

### State Management Hook

```typescript
type UseToggleReturnType = [boolean, () => void]

export function useToggle(initialValue = false): UseToggleReturnType {
  const [value, setValue] = useState(initialValue)

  const toggle = useCallback(() => {
    setValue(v => !v)
  }, [])

  return [value, toggle]
}

// Usage
const [isOpen, toggleOpen] = useToggle()
```

### Async Data Fetching Hook

```typescript
type UseQueryOptions<T> = {
  onSuccess?: (data: T) => void
  onError?: (error: Error) => void
  enabled?: boolean
}

type UseQueryReturnType<T> = {
  data: T | null
  error: Error | null
  loading: boolean
  refetch: () => Promise<void>
}

export function useQuery<T>(
  key: string,
  fetcher: () => Promise<T>,
  options?: UseQueryOptions<T>
): UseQueryReturnType<T> {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(false)

  // Keep the latest fetcher/options in refs so refetch stays referentially
  // stable even when callers pass inline functions and object literals.
  // Without this, every render creates a new refetch, and the effect below
  // re-runs after each state update - an infinite fetch loop.
  const fetcherRef = useRef(fetcher)
  const optionsRef = useRef(options)
  useEffect(() => {
    fetcherRef.current = fetcher
    optionsRef.current = options
  })

  const refetch = useCallback(async () => {
    setLoading(true)
    setError(null)

    try {
      const result = await fetcherRef.current()
      setData(result)
      optionsRef.current?.onSuccess?.(result)
    } catch (err) {
      const error = err as Error
      setError(error)
      optionsRef.current?.onError?.(error)
    } finally {
      setLoading(false)
    }
  }, [])

  const enabled = options?.enabled !== false

  useEffect(() => {
    if (enabled) {
      refetch()
    }
  }, [key, enabled, refetch])

  return { data, error, loading, refetch }
}

// Usage
const { data: markets, loading, error, refetch } = useQuery(
  'markets',
  async () => {
    const res = await fetch('/api/markets')
    return res.json()
  },
  {
    onSuccess: data => console.log('Fetched', data.length, 'markets'),
    onError: err => console.error('Failed:', err)
  }
)
```

### Debounce Hook

```typescript
type UseDebounceReturnType<T> = T

export function useDebounce<T>(value: T, delay: number): UseDebounceReturnType<T> {
  const [debouncedValue, setDebouncedValue] = useState<T>(value)

  useEffect(() => {
    const handler = setTimeout(() => {
      setDebouncedValue(value)
    }, delay)

    return () => clearTimeout(handler)
  }, [value, delay])

  return debouncedValue
}

// Usage
const [searchQuery, setSearchQuery] = useState('')
const debouncedQuery = useDebounce(searchQuery, 500)

useEffect(() => {
  if (debouncedQuery) {
    performSearch(debouncedQuery)
  }
}, [debouncedQuery])
```

## State Management Patterns

### Context + Reducer Pattern

```typescript
type State = {
  markets: Market[]
  selectedMarket: Market | null
  loading: boolean
}

type Action =
  | { type: 'SET_MARKETS'; payload: Market[] }
  | { type: 'SELECT_MARKET'; payload: Market }
  | { type: 'SET_LOADING'; payload: boolean }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'SET_MARKETS':
      return { ...state, markets: action.payload }
    case 'SELECT_MARKET':
      return { ...state, selectedMarket: action.payload }
    case 'SET_LOADING':
      return { ...state, loading: action.payload }
    default:
      return state
  }
}

type MarketContextValue = {
  state: State
  dispatch: Dispatch<Action>
}

const MarketContext = createContext<MarketContextValue | undefined>(undefined)

type MarketProviderProps = { children: React.ReactNode }
type MarketProviderReturnType = JSX.Element

export function MarketProvider(props: MarketProviderProps): MarketProviderReturnType {
  const [state, dispatch] = useReducer(reducer, {
    markets: [],
    selectedMarket: null,
    loading: false
  })

  return (
    <MarketContext.Provider value={{ state, dispatch }}>
      {props.children}
    </MarketContext.Provider>
  )
}

type UseMarketsReturnType = MarketContextValue

export function useMarkets(): UseMarketsReturnType {
  const context = useContext(MarketContext)
  if (!context) throw new Error('useMarkets must be used within MarketProvider')
  return context
}
```


## Further Reference

Performance optimization, form handling, and error boundaries are in
`references/performance-and-forms.md`. Animation, accessibility, and the Zod-validated API
service layer are in `references/animation-a11y-api.md`. Load whichever one the task needs.
