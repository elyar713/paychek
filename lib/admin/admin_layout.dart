import 'package:flutter/material.dart';

/// Breakpoints et helpers responsive pour la console admin Paychek.
abstract final class AdminLayout {
  AdminLayout._();

  static const double mobileBreakpoint = 768;
  static const double compactBreakpoint = 600;
  static const double sidebarWidth = 260;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compactBreakpoint;

  static EdgeInsets shellHeaderPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(16, 14, 16, 12);
    }
    return const EdgeInsets.fromLTRB(28, 22, 28, 18);
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.fromLTRB(12, 12, 12, 16);
    }
    return const EdgeInsets.fromLTRB(20, 20, 20, 24);
  }
}
