import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:snaptrack/add_bins_page.dart';
import 'package:snaptrack/bins_page.dart';
import 'package:snaptrack/profile_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  // Define a variable to store the last picture taken
  XFile? _lastPicture;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.yuv420);

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  // Main build method for Camera Page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (_lastPicture == null)
                  CameraPreview(_controller),
                if (_lastPicture != null)
                  Image.file(
                    File(_lastPicture!.path),
                    fit: BoxFit.cover,
                  ),
                _buildCameraButton(context),
                _buildClearButton(context),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return Positioned(
      bottom: 40.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.5),
                shape: CircleBorder(),
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                iconSize: 40.0,
                onPressed: _onCapturePressed,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton(BuildContext context) {
    return Positioned(
      top: 40.0,
      right: 20.0,
      child: IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: _onClearPressed,
      ),
    );
  }

  void _onCapturePressed() async {
    try {
      final image = await _controller.takePicture();

      // Update the state to show the picture
      setState(() {
        _lastPicture = image;
      });
    } catch (e) {
      print(e);
    }
  }

  void _onClearPressed() {
    // Clear the picture
    setState(() {
      _lastPicture = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
