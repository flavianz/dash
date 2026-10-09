import 'package:flutter/animation.dart';

extension ColorFromHex on String {
  Color fromHexToColor() {
    return Color(int.parse(substring(1, 7), radix: 16) + 0xFF000000);
  }
}
