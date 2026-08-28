import 'package:flutter/material.dart';

/// Dismisses the soft keyboard and unfocuses active text inputs if currently open.
/// Returns `true` if the keyboard was open or a text field was focused and has been dismissed.
bool dismissKeyboardIfOpen(BuildContext context) {
  final bottomInset = MediaQuery.maybeOf(context)?.viewInsets.bottom ?? 0.0;
  final isKeyboardVisible = bottomInset > 0.0;

  final primaryFocus = FocusManager.instance.primaryFocus;
  final isTextFocused = primaryFocus != null &&
      primaryFocus is! FocusScopeNode &&
      (primaryFocus.context?.widget is EditableText ||
          primaryFocus.context?.findAncestorWidgetOfExactType<EditableText>() != null);

  if (isKeyboardVisible || isTextFocused) {
    FocusScope.of(context).unfocus();
    primaryFocus?.unfocus();
    return true;
  }
  return false;
}
