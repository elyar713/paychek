import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Rasterise une icône Material/Lucide en PNG pour l’embarquer dans un PDF.
Future<Uint8List?> rasterizeIconForPdf({
  required IconData icon,
  required Color color,
  double logicalSize = 18,
  double pixelRatio = 3,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final repaintBoundary = RenderRepaintBoundary();
  final view = ui.PlatformDispatcher.instance.views.isNotEmpty
      ? ui.PlatformDispatcher.instance.views.first
      : null;
  if (view == null) return null;

  final physicalSize = logicalSize * pixelRatio;
  final renderView = RenderView(
    view: view,
    child: RenderPositionedBox(
      alignment: Alignment.center,
      child: repaintBoundary,
    ),
    configuration: ViewConfiguration(
      physicalConstraints:
          BoxConstraints.tight(Size(physicalSize, physicalSize)),
      logicalConstraints: BoxConstraints.tight(Size(logicalSize, logicalSize)),
      devicePixelRatio: pixelRatio,
    ),
  );

  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());
  pipelineOwner.rootNode = renderView;
  renderView.prepareInitialFrame();

  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: repaintBoundary,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: MediaQuery(
        data: const MediaQueryData(),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Icon(icon, size: logicalSize, color: color),
          ),
        ),
      ),
    ),
  ).attachToRenderTree(buildOwner);

  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();

  final image = await repaintBoundary.toImage(pixelRatio: pixelRatio);
  final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
