import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget adaptiveAction({
  required final BuildContext context,
  required final VoidCallback onPressed,
  required final Widget child,
  final bool isDefaultAction = false,
  final bool isDestructiveAction = false,
}) {
  final ThemeData theme = Theme.of(context);
  switch (theme.platform) {
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
    case TargetPlatform.linux:
    case TargetPlatform.windows:
      return TextButton(onPressed: onPressed, child: child);
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDefaultAction: isDefaultAction,
        isDestructiveAction: isDefaultAction,
        child: child,
      );
  }
}
