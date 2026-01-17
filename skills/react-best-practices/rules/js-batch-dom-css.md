---
title: Avoid Layout Thrashing
impact: MEDIUM
impactDescription: prevents forced synchronous layouts and reduces performance bottlenecks
tags: javascript, dom, css, performance, reflow, layout-thrashing
---

## Avoid Layout Thrashing

Avoid interleaving style changes with layout queries. Browsers batch style recalculations automatically, but certain methods/properties force immediate layout computation, causing performance issues.

**This is OK (browser batches style changes):**
```typescript
function updateElementStyles(element: HTMLElement) {
  // Each line invalidates style, but browser batches the recalculation
  element.style.width = '100px'
  element.style.height = '200px'
  element.style.backgroundColor = 'blue'
  element.style.border = '1px solid black'
}
```

**Incorrect (forces multiple layout recalculations):**
```typescript
function layoutThrashing(element: HTMLElement) {
  // Invalidates style
  element.style.width = '100px'
  // Forces immediate layout recalculation
  const rect1 = element.getBoundingClientRect()
  
  // Invalidates style again
  element.style.height = '200px'
  // Forces another layout recalculation
  const rect2 = element.getBoundingClientRect()
}
```

**Correct (batch reads, then writes):**
```typescript
function avoidThrashing(element: HTMLElement) {
  // Read phase - all layout queries first
  const rect1 = element.getBoundingClientRect()
  const rect2 = element.getBoundingClientRect()
  
  // Write phase - all style changes after
  element.style.width = '100px'
  element.style.height = '200px'
}
```

**Correct (add class - single reflow):**
```typescript
// CSS file
.highlighted-box {
  width: 100px;
  height: 200px;
  background-color: blue;
  border: 1px solid black;
}
// JavaScript
function updateElementStyles(element: HTMLElement) {
  element.classList.add('highlighted-box')
}
```

**Correct (change cssText - single reflow):**
```typescript
function updateElementStyles(element: HTMLElement) {
  element.style.cssText = `
    width: 100px;
    height: 200px;
    background-color: blue;
    border: 1px solid black;
  `
}
```

**React example:**
```tsx
// Incorrect: interleaving style changes with layout queries
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  const ref = useRef<HTMLDivElement>(null)
  
  useEffect(() => {
    if (ref.current && isHighlighted) {
      ref.current.style.width = '100px'
      const width = ref.current.offsetWidth // Forces layout
      ref.current.style.height = '200px'
    }
  }, [isHighlighted])
  
  return <div ref={ref}>Content</div>
}

// Correct: toggle class
function Box({ isHighlighted }: { isHighlighted: boolean }) {
  return (
    <div className={isHighlighted ? 'highlighted-box' : ''}>
      Content
    </div>
  )
}
```

Prefer CSS classes over inline styles when possible. Classes are cached by the browser and provide better separation of concerns.

See [this gist](https://gist.github.com/paulirish/5d52fb081b3570c81e3a) and [CSS Triggers](https://csstriggers.com/) for more information on layout-forcing operations.