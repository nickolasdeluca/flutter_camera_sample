import 'dart:io' show File, Platform;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_camera_sample/components/camera/photo_preview.dart';
import 'package:flutter_camera_sample/components/dialogs/dialogs.dart';
import 'package:flutter_camera_sample/home/view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';

class CameraWidget extends StatefulWidget {
  const CameraWidget({super.key});

  @override
  State<CameraWidget> createState() => _CameraWidgetState();
}

class _CameraWidgetState extends State<CameraWidget> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  int _selectedCameraIdx = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    await Permission.camera.request();

    final permissionStatus = await Permission.camera.status;

    if (permissionStatus.isGranted) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![_selectedCameraIdx],
          ResolutionPreset.max,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.jpeg
              : ImageFormatGroup.bgra8888,
        );
        await _controller!.initialize();
      }
    } else {
      if (permissionStatus.isDenied) {
        if (!mounted) return;

        await Dialogs.confirm(context, "User denied access to camera",
            "You need to allow access to the camera in order to use this function!");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      } else if (permissionStatus.isPermanentlyDenied) {
        if (!mounted) return;

        await Dialogs.confirm(context, "User denied access to camera",
            "You'll have to manually give permission in the app's settings!");

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleCameraFlip() {
    setState(() {
      _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras!.length;
      _controller!.dispose();
      _controller = CameraController(
          _cameras![_selectedCameraIdx], ResolutionPreset.medium);
      _controller!.initialize().then((_) {
        if (mounted) {
          setState(() {});
        }
      });
    });
  }

  void _handleTakePicture() async {
    if (!_controller!.value.isInitialized) {
      return;
    }

    XFile image = await _controller!.takePicture();
    bool shouldSave = false;

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoPreview(image: image.path),
      ),
    ).then(
      (value) => (shouldSave = value ?? false),
    );

    if (shouldSave) {
      await GallerySaver.saveImage(image.path);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    }

    await File(image.path).delete();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: BackButton(
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            height: 100,
                            width: 100,
                          ),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: IconButton(
                              icon: const Icon(
                                Icons.circle_outlined,
                                size: 75,
                                color: Colors.white,
                              ),
                              onPressed: () => _handleTakePicture(),
                            ),
                          ),
                          SizedBox(
                            height: 100,
                            width: 100,
                            child: IconButton(
                              icon: const Icon(
                                Icons.sync_sharp,
                                size: 30,
                                color: Colors.white,
                              ),
                              onPressed: () => _handleCameraFlip(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
