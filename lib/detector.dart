import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// COCO labels we treat as desk distractions. Edit freely.
const kDistractors = {
  'cell phone', 'cup', 'bottle', 'wine glass', 'bowl', 'banana', 'apple',
  'sandwich', 'orange', 'donut', 'cake', 'pizza', 'hot dog', 'remote',
  'tv', 'cat', 'dog', 'teddy bear', 'sports ball',
};

class Detection {
  final String label;
  final double score;
  final Rect box; // normalized 0..1
  Detection(this.label, this.score, this.box);
  bool get isDistractor => kDistractors.contains(label);
}

class ScanResult {
  final Uint8List jpg;
  final double aspect; // width / height
  final List<Detection> detections;
  ScanResult(this.jpg, this.aspect, this.detections);

  Set<String> get distractorLabels =>
      detections.where((d) => d.isDistractor).map((d) => d.label).toSet();
}

class DeskDetector {
  static const inputSize = 300;
  static const labelOffset = 1; // labelmap.txt starts with "???"
  late Interpreter _interpreter;
  late List<String> _labels;

  Future<void> load() async {
    _interpreter = await Interpreter.fromAsset('assets/detect.tflite');
    final raw = await rootBundle.loadString('assets/labelmap.txt');
    _labels = raw.split('\n').map((e) => e.trim()).toList();
  }

  ScanResult detect(File file, {double minScore = 0.5}) {
    var image = img.decodeImage(file.readAsBytesSync())!;
    image = img.bakeOrientation(image); // fix rotated phone photos

    final resized = img.copyResize(image, width: inputSize, height: inputSize);
    final bytes = resized.getBytes(order: img.ChannelOrder.rgb);
    final input = bytes.reshape([1, inputSize, inputSize, 3]);

    final locs = List.filled(1 * 10 * 4, 0.0).reshape([1, 10, 4]);
    final classes = List.filled(10, 0.0).reshape([1, 10]);
    final scores = List.filled(10, 0.0).reshape([1, 10]);
    final count = List.filled(1, 0.0);

    _interpreter.runForMultipleInputs(
      [input],
      {0: locs, 1: classes, 2: scores, 3: count},
    );

    final detections = <Detection>[];
    final n = count[0].toInt().clamp(0, 10);
    for (var i = 0; i < n; i++) {
      final score = (scores[0][i] as num).toDouble();
      if (score < minScore) continue;

      final idx = (classes[0][i] as num).toInt() + labelOffset;
      if (idx < 0 || idx >= _labels.length) continue;

      final b = locs[0][i] as List; // [ymin, xmin, ymax, xmax]
      double c(num v) => v.toDouble().clamp(0.0, 1.0);
      detections.add(Detection(
        _labels[idx],
        score,
        Rect.fromLTRB(c(b[1]), c(b[0]), c(b[3]), c(b[2])),
      ));
    }

    return ScanResult(
      Uint8List.fromList(img.encodeJpg(image, quality: 85)),
      image.width / image.height,
      detections,
    );
  }
}