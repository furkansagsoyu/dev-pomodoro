import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'detector.dart';
import 'l10n.dart';

class ScanFlowPage extends StatefulWidget {
  final DeskDetector detector;
  final double minScore;
  final L10n l;
  final void Function(bool hadDistraction) onScanned;
  const ScanFlowPage({
    super.key,
    required this.detector,
    required this.minScore,
    required this.l,
    required this.onScanned,
  });

  @override
  State<ScanFlowPage> createState() => _ScanFlowPageState();
}

class _ScanFlowPageState extends State<ScanFlowPage> {
  CameraController? _cam;
  ScanResult? _result;
  bool _busy = false;
  String? _error;

  L10n get l => widget.l;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    setState(() {
      _result = null;
      _error = null;
    });
    try {
      final cams = await availableCameras();
      final c = CameraController(cams.first, ResolutionPreset.medium,
          enableAudio: false);
      await c.initialize();
      if (!mounted) {
        await c.dispose();
        return;
      }
      setState(() => _cam = c);
    } catch (e) {
      if (mounted) setState(() => _error = '${l.cameraUnavailable}\n$e');
    }
  }

  Future<void> _capture() async {
    final c = _cam;
    if (c == null || _busy) return;
    setState(() => _busy = true);
    final shot = await c.takePicture();
    setState(() => _cam = null); // remove the preview first
    await WidgetsBinding.instance.endOfFrame;
    await c.dispose();
    final result =
        widget.detector.detect(File(shot.path), minScore: widget.minScore);
    if (!mounted) return;
    widget.onScanned(result.distractorLabels.isNotEmpty);
    setState(() {
      _result = result;
      _busy = false;
    });
  }

  @override
  void dispose() {
    _cam?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _resultView(context, _result!);
    if (_error != null) return _errorView(context);
    if (_cam != null && _cam!.value.isInitialized) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(children: [
          Positioned.fill(child: CameraPreview(_cam!)),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context, false),
              ),
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Column(children: [
              Text(l.showDesk, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt),
                label: Text(l.scanDesk),
              ),
            ]),
          ),
        ]),
      );
    }
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _errorView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(l.deskCheck)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(_error!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          FilledButton(onPressed: _initCamera, child: Text(l.tryAgain)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.startWithoutScan),
          ),
        ]),
      ),
    );
  }

  Widget _resultView(BuildContext context, ScanResult result) {
    final found = result.distractorLabels;
    final clean = found.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.deskCheck),
        backgroundColor: Colors.transparent,
      ),
      body: Column(children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: result.aspect,
              child: Stack(fit: StackFit.expand, children: [
                Image.memory(result.jpg, fit: BoxFit.fill),
                CustomPaint(painter: BoxPainter(result.detections, l.object)),
              ]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            clean
                ? l.deskClear
                : l.distractionsFound(found.map(l.object).join(', ')),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: clean ? Colors.green : Colors.redAccent,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (!clean)
              OutlinedButton(
                onPressed: _initCamera,
                child: Text(l.rescan),
              ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(clean ? l.startTimer : l.startAnyway),
            ),
          ]),
        ),
      ]),
    );
  }
}

class BoxPainter extends CustomPainter {
  final List<Detection> detections;
  final String Function(String) nameOf;
  BoxPainter(this.detections, this.nameOf);

  @override
  void paint(Canvas canvas, Size size) {
    for (final d in detections) {
      final color = d.isDistractor ? Colors.redAccent : Colors.green;
      final rect = Rect.fromLTRB(
        d.box.left * size.width,
        d.box.top * size.height,
        d.box.right * size.width,
        d.box.bottom * size.height,
      );
      canvas.drawRect(
        rect,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final tp = TextPainter(
        text: TextSpan(
          text: '${nameOf(d.label)} ${(d.score * 100).toStringAsFixed(0)}%',
          style: TextStyle(
              color: Colors.white, backgroundColor: color, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(rect.left, (rect.top - tp.height).clamp(0, size.height)));
    }
  }

  @override
  bool shouldRepaint(covariant BoxPainter old) => old.detections != detections;
}