import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:gallery_saver_plus/files.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  XFile? _imageFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;
    _controller = CameraController(camera, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final image = await _controller!.takePicture();
    setState(() {
      _imageFile = image;
    });
  }

  Future<void> _savePicture() async {
    if (_imageFile == null) return;
    setState(() => _isSaving = true);
    await GallerySaver.saveImage(_imageFile!.path);
    setState(() => _isSaving = false);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Bild wurde gespeichert!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Kamera')),
      body:
          _imageFile == null
              ? Stack(
                children: [
                  CameraPreview(_controller!),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: FloatingActionButton(
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera_alt),
                      ),
                    ),
                  ),
                ],
              )
              : Column(
                children: [
                  Expanded(child: Image.file(File(_imageFile!.path))),
                  if (_isSaving) const LinearProgressIndicator(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Verwerfen'),
                        onPressed: () => setState(() => _imageFile = null),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Speichern'),
                        onPressed: _isSaving ? null : _savePicture,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
    );
  }
}
