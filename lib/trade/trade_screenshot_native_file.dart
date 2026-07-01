import 'dart:io';

import 'package:flutter/widgets.dart';

Widget tradeScreenshotNativeFileImage({
  required String path,
  required VoidCallback onError,
  required Widget errorWidget,
}) {
  return Image.file(
    File(path),
    fit: BoxFit.cover,
    width: double.infinity,
    errorBuilder: (context, error, stack) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onError());
      return errorWidget;
    },
  );
}
