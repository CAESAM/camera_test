import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraApp());
}

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  /// Default Constructor
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  bool _showCameraPreview = false;
  XFile? _picture;

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Camera Overlay Test')),
        body: !_showCameraPreview
            ? ((_picture != null)
                ? Image.file(File(_picture!.path))
                : Container())
            : Stack(
                alignment: Alignment.center,
                children: [
                  CameraPreview(controller),
                  Image.asset(
                    'assets/images/overlay.png',
                    color: Colors.white,
                  ),
                  Transform.translate(
                    offset: const Offset(0.0, 230.0),
                    child: TextButton(
                        onPressed: () async {
                          _picture = await controller.takePicture();
                          controller.resumePreview();
                          _showCameraPreview = false;
                          setState(() {});
                        },
                        child: Transform.scale(
                            scale: 3,
                            child: const Icon(
                              Icons.camera,
                              color: Colors.white,
                            ))),
                  ),
                ],
              ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            _showCameraPreview = true;
            if (!controller.value.isInitialized) {
              controller.initialize();
            }
            setState(() {});
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}
