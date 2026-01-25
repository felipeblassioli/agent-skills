---
title: Use Pressable Instead of Touchable Components
impact: LOW
impactDescription: modern API, more flexible
tags: ui, pressable, touchable, gestures
---

## Use Pressable Instead of Touchable Components

Never use `TouchableOpacity` or `TouchableHighlight`. Use `Pressable` from
`react-native` or `react-native-gesture-handler` instead. Pressable is the
modern API with more flexibility for styling press states.

**Incorrect (legacy Touchable components):**

```tsx
import { TouchableOpacity } from 'react-native'

function MyButton({ onPress }: { onPress: () => void }) {
  return (
    <TouchableOpacity onPress={onPress} activeOpacity={0.7}>
      <Text>Press me</Text>
    </TouchableOpacity>
  )
}
```

**Correct (Pressable with style function):**

```tsx
import { Pressable } from 'react-native'

function MyButton({ onPress }: { onPress: () => void }) {
  return (
    <Pressable
      onPress={onPress}
      style={({ pressed }) => ({ opacity: pressed ? 0.7 : 1 })}
    >
      <Text>Press me</Text>
    </Pressable>
  )
}
```

**Correct (Pressable from gesture handler for lists):**

```tsx
import { Pressable } from 'react-native-gesture-handler'

function ListItem({ onPress }: { onPress: () => void }) {
  return (
    <Pressable onPress={onPress}>
      <Text>Item</Text>
    </Pressable>
  )
}
```

Use `react-native-gesture-handler` Pressable inside scrollable lists for better
gesture coordination, as long as you are using the ScrollView from
`react-native-gesture-handler` as well.
