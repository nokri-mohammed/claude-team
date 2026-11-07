## Animation Patterns

### Framer Motion Animations

```typescript
import { motion, AnimatePresence } from 'framer-motion'

// PASS: List animations
type AnimatedMarketListProps = { markets: Market[] }
type AnimatedMarketListReturnType = JSX.Element

export function AnimatedMarketList(props: AnimatedMarketListProps): AnimatedMarketListReturnType {
  return (
    <AnimatePresence>
      {props.markets.map(market => (
        <motion.div
          key={market.id}
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          exit={{ opacity: 0, y: -20 }}
          transition={{ duration: 0.3 }}
        >
          <MarketCard market={market} />
        </motion.div>
      ))}
    </AnimatePresence>
  )
}

// PASS: Modal animations
type ModalProps = {
  isOpen: boolean
  onClose: () => void
  children: React.ReactNode
}
type ModalReturnType = JSX.Element

export function Modal(props: ModalProps): ModalReturnType {
  return (
    <AnimatePresence>
      {props.isOpen && (
        <>
          <motion.div
            className="modal-overlay"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={props.onClose}
          />
          <motion.div
            className="modal-content"
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
          >
            {props.children}
          </motion.div>
        </>
      )}
    </AnimatePresence>
  )
}
```

## Accessibility Patterns

### Keyboard Navigation

```typescript
type DropdownProps = {
  options: string[]
  onSelect: (option: string) => void
}
type DropdownReturnType = JSX.Element

export function Dropdown(props: DropdownProps): DropdownReturnType {
  const [isOpen, setIsOpen] = useState(false)
  const [activeIndex, setActiveIndex] = useState(0)

  function handleKeyDown(e: React.KeyboardEvent): void {
    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault()
        setActiveIndex(i => Math.min(i + 1, props.options.length - 1))
        break
      case 'ArrowUp':
        e.preventDefault()
        setActiveIndex(i => Math.max(i - 1, 0))
        break
      case 'Enter':
        e.preventDefault()
        props.onSelect(props.options[activeIndex])
        setIsOpen(false)
        break
      case 'Escape':
        setIsOpen(false)
        break
    }
  }

  return (
    <div
      role="combobox"
      aria-expanded={isOpen}
      aria-haspopup="listbox"
      onKeyDown={handleKeyDown}
    >
      {/* Dropdown implementation */}
    </div>
  )
}
```

### Focus Management

```typescript
type ModalProps = {
  isOpen: boolean
  onClose: () => void
  children: React.ReactNode
}
type ModalReturnType = JSX.Element | null

export function Modal(props: ModalProps): ModalReturnType {
  const modalRef = useRef<HTMLDivElement>(null)
  const previousFocusRef = useRef<HTMLElement | null>(null)

  useEffect(() => {
    if (props.isOpen) {
      // Save currently focused element
      previousFocusRef.current = document.activeElement as HTMLElement

      // Focus modal
      modalRef.current?.focus()
    } else {
      // Restore focus when closing
      previousFocusRef.current?.focus()
    }
  }, [props.isOpen])

  return props.isOpen ? (
    <div
      ref={modalRef}
      role="dialog"
      aria-modal="true"
      tabIndex={-1}
      onKeyDown={e => e.key === 'Escape' && props.onClose()}
    >
      {props.children}
    </div>
  ) : null
}
```

## API Service Layer (Zod Validation)

Never call `fetch` directly from a component. Put every REST call behind a service function that
parses the response through a Zod schema first — this is the frontend's own validation layer, so a
backend contract drift (a renamed field, a null where a string was promised) fails loudly at the
service boundary instead of silently corrupting component state or crashing deep in render.

```typescript
// schemas/market.ts
import { z } from 'zod'

export const MarketSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string(),
  volume: z.number(),
  endDate: z.string()
})

export type Market = z.infer<typeof MarketSchema>

export const MarketListSchema = z.array(MarketSchema)

export const CreateMarketRequestSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1),
  endDate: z.string()
})

export type CreateMarketRequest = z.infer<typeof CreateMarketRequestSchema>
```

```typescript
// services/api-client.ts
import { z } from 'zod'

export class ApiValidationError extends Error {
  constructor(public readonly issues: z.ZodIssue[], message: string) {
    super(message)
  }
}

type RequestJsonOptions<TResponse> = {
  schema: z.ZodType<TResponse>
  path: string
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE'
  body?: unknown
}

type RequestJsonReturnType<TResponse> = Promise<TResponse>

export async function requestJson<TResponse>(
  options: RequestJsonOptions<TResponse>
): RequestJsonReturnType<TResponse> {
  const response = await fetch(options.path, {
    method: options.method ?? 'GET',
    headers: options.body ? { 'Content-Type': 'application/json' } : undefined,
    body: options.body ? JSON.stringify(options.body) : undefined
  })

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status} ${response.statusText}`)
  }

  const raw: unknown = await response.json()
  const result = options.schema.safeParse(raw)

  if (!result.success) {
    throw new ApiValidationError(
      result.error.issues,
      `Response from ${options.path} did not match the expected schema`
    )
  }

  return result.data
}
```

```typescript
// services/market-service.ts
import { requestJson } from './api-client'
import {
  MarketSchema,
  MarketListSchema,
  CreateMarketRequestSchema,
  type Market,
  type CreateMarketRequest
} from '../schemas/market'

type GetMarketsReturnType = Promise<Market[]>

export function getMarkets(): GetMarketsReturnType {
  return requestJson({ path: '/api/markets', schema: MarketListSchema })
}

type GetMarketReturnType = Promise<Market>

export function getMarket(id: string): GetMarketReturnType {
  return requestJson({ path: `/api/markets/${id}`, schema: MarketSchema })
}

type CreateMarketReturnType = Promise<Market>

export function createMarket(request: CreateMarketRequest): CreateMarketReturnType {
  // Validate on the way out too - catches a caller bug before it ever reaches the network.
  const body = CreateMarketRequestSchema.parse(request)
  return requestJson({ path: '/api/markets', method: 'POST', body, schema: MarketSchema })
}
```

```typescript
// Usage inside a component - the component never sees an unvalidated value
import { useQuery } from '../hooks/useQuery'
import { getMarkets } from '../services/market-service'

type MarketListReturnType = JSX.Element

export function MarketList(): MarketListReturnType {
  const { data: markets, loading, error } = useQuery('markets', getMarkets)

  if (loading) return <Spinner />
  if (error) return <Error error={error} />

  return (
    <div>
      {markets?.map(market => <MarketCard key={market.id} market={market} />)}
    </div>
  )
}
```

**Remember**: Modern frontend patterns enable maintainable, performant user interfaces. Choose patterns that fit your project complexity.
