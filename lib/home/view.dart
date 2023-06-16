import 'package:flutter/material.dart';
import 'package:flutter_camera_sample/components/camera/camera.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraWidget(),
            ),
          ),
          child: const Text('Abrir câmera'),
        ),
      ),
    );
  }
}
