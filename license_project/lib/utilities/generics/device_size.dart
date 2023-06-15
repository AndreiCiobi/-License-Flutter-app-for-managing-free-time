import 'package:flutter/material.dart';

extension GetSize on BuildContext {
  Size getSize() {
    return MediaQuery.of(this).size;
  }

  double getWidth() {
    return MediaQuery.of(this).size.width;
  }

  double getHeight() {
    return MediaQuery.of(this).size.height;
  }
}
