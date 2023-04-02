import 'package:flutter/material.dart';

Widget createToast(BuildContext context, String message, {Icon? icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[800]
          : Colors.grey[200],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon ?? const SizedBox(),
        icon != null ? const SizedBox(width: 12.0) : const SizedBox(),
        Text(message),
      ],
    ),
  );
}
