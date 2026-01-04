# Flutter Deprecation Replacement Guide

This guide lists common deprecated classes and methods in Flutter and their modern alternatives. Use this as a reference when refactoring code.

## Material State -> Widget State
Starting from Flutter 3.19/3.22, `MaterialState` is deprecated in favor of `WidgetState`.

| Deprecated | Modern Replacement |
| :--- | :--- |
| `MaterialState` | `WidgetState` |
| `MaterialStateProperty` | `WidgetStateProperty` |
| `MaterialStateProperty.all` | `WidgetStateProperty.all` |
| `MaterialStateProperty.resolveWith` | `WidgetStateProperty.resolveWith` |
| `MaterialStateColor` | `WidgetStateColor` |
| `MaterialStateBorderSide` | `WidgetStateBorderSide` |
| `MaterialStateMouseCursor` | `WidgetStateMouseCursor` |
| `MaterialStateOutlinedBorder` | `WidgetStateOutlinedBorder` |
| `MaterialStateTextStyle` | `WidgetStateTextStyle` |

**Example:**
```dart
// OLD
style: ButtonStyle(
  backgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.pressed)) return Colors.blue;
    return Colors.red;
  }),
)

// NEW
style: ButtonStyle(
  backgroundColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.pressed)) return Colors.blue;
    return Colors.red;
  }),
)
```

## Navigation -> PopScope
`WillPopScope` is deprecated. Use `PopScope` instead.

| Deprecated | Modern Replacement |
| :--- | :--- |
| `WillPopScope` | `PopScope` |

**Example:**
```dart
// OLD
return WillPopScope(
  onWillPop: () async => false, // Return false to block pop
  child: Scaffold(...),
);

// NEW
return PopScope(
  canPop: false, // Set to false to block pop
  onPopInvoked: (didPop) {
    if (didPop) return;
    // Handle blocked pop here (e.g., show dialog)
  },
  child: Scaffold(...),
);
```

## Theme Data
Typography and color properties have evolved.

| Deprecated | Modern Replacement |
| :--- | :--- |
| `Theme.of(context).headline6` | `Theme.of(context).textTheme.titleLarge` |
| `Theme.of(context).bodyText1` | `Theme.of(context).textTheme.bodyLarge` |
| `Theme.of(context).bodyText2` | `Theme.of(context).textTheme.bodyMedium` |
| `Theme.of(context).subtitle1` | `Theme.of(context).textTheme.titleMedium` |
| `Theme.of(context).subtitle2` | `Theme.of(context).textTheme.titleSmall` |
| `Theme.of(context).backgroundColor` | `Theme.of(context).colorScheme.background` (or `.surface` in newer Material 3) |
| `Theme.of(context).errorColor` | `Theme.of(context).colorScheme.error` |
| `Theme.of(context).primaryColor` (in usage) | Prefer `Theme.of(context).colorScheme.primary` |

## Color Opacity
Directly modifying opacity on generic types is sometimes flagged or less optimized than using the color method.

| Deprecated | Modern Replacement |
| :--- | :--- |
| `Color(0xFF...).withOpacity(0.5)` | Use `Color.fromRGBO` or `Color.fromARGB` if const is needed, otherwise `withOpacity` is still often used but `withAlpha` is sometimes preferred for integer alpha. |

## Network Images
| Deprecated | Modern Replacement |
| :--- | :--- |
| `Image.network` (basic) | `CachedNetworkImage` (package) is recommended for production apps to handle caching and offline states. |

## Buttons
Older button classes are long deprecated but worth noting if found in legacy code.

| Deprecated | Modern Replacement |
| :--- | :--- |
| `RaisedButton` | `ElevatedButton` |
| `FlatButton` | `TextButton` |
| `OutlineButton` | `OutlinedButton` |
| Deprecated | Modern Replacement |
| :--- | :--- |
| `myColor.withOpacity(0.5)` (when precise integer alpha is desired) | `myColor.withAlpha((0.5 * 255).round())` |
 