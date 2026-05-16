import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Non-zero [Rect] for [Share.shareXFiles] on iOS/iPadOS (share sheet popover).
Rect resolveSharePositionOrigin({BuildContext? context, Rect? explicit}) {
  if (explicit != null && explicit.width > 0 && explicit.height > 0) {
    return explicit;
  }
  if (context != null) {
    final ro = context.findRenderObject();
    if (ro is RenderBox && ro.hasSize) {
      final size = ro.size;
      if (size.width > 0 && size.height > 0) {
        return ro.localToGlobal(Offset.zero) & size;
      }
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 2,
      height: 2,
    );
  }
  final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
  if (view != null) {
    final size = view.physicalSize / view.devicePixelRatio;
    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 2,
      height: 2,
    );
  }
  return const Rect.fromLTWH(0, 0, 2, 2);
}
