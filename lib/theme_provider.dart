import 'package:flutter/material.dart';

// Define a callback type for theme toggling
typedef ToggleThemeCallback = void Function();

class ThemeProvider extends InheritedWidget {
  final ToggleThemeCallback toggleTheme;

  const ThemeProvider({
    super.key,
    required this.toggleTheme,
    required super.child,
  });

  // Static method to get the nearest ThemeProvider instance from the context
  static ThemeProvider of(BuildContext context) {
    final ThemeProvider? result = context
        .dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(result != null, 'No ThemeProvider found in context');
    return result!;
  }

  // Static method to get the nearest ThemeProvider instance (nullable)
  static ThemeProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
  }

  // Determine if the widget needs to rebuild when the InheritedWidget updates
  @override
  bool updateShouldNotify(ThemeProvider oldWidget) {
    // If the callback itself changes, notify dependents.
    // In this simple case, it likely won't change after creation.
    return oldWidget.toggleTheme != toggleTheme;
  }
}
