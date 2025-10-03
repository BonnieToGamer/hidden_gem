import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

Future<Uint8List> svgToPng(
  String svgString,
  BuildContext context, {
  int targetWidth = 100,
  int targetHeight = 100,
}) async {
  final pictureInfo = await vg.loadPicture(SvgStringLoader(svgString), context);

  final svgWidth = pictureInfo.size.width;
  final svgHeight = pictureInfo.size.height;

  final recorder = PictureRecorder();
  final canvas = Canvas(recorder);

  final paint = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRect(
    Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
    paint,
  );

  final scale = min(targetWidth / svgWidth, targetHeight / svgHeight);

  final dx = (targetWidth - svgWidth * scale) / 2;
  final dy = (targetHeight - svgHeight * scale) / 2;

  canvas.translate(dx, dy);
  canvas.scale(scale);

  canvas.drawPicture(pictureInfo.picture);

  final picture = recorder.endRecording();
  final image = await picture.toImage(targetWidth, targetHeight);
  final byteData = await image.toByteData(format: ImageByteFormat.png);

  if (byteData == null) {
    throw Exception('Unable to convert SVG to PNG');
  }

  return byteData.buffer.asUint8List();
}

Future<File> uint8ListToFile(Uint8List data, String filename) async {
  final tempDir =
      await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
  final file = File('${tempDir.path}/$filename');
  await file.writeAsBytes(data);
  return file;
}
