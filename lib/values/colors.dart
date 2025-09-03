import 'package:flutter/material.dart';

Color backgroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Colors.grey[600]!
      : Colors.grey[900]!;
}

Color foregroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Colors.grey[400]!
      : Colors.grey[700]!;
}
