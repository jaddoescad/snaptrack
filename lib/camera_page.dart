import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);
  
  @override
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    final CameraDescription firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  // Main build method for Camera Page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: _buildCameraPreview,
      ),
    );
  }

  // Builder for camera preview or loading indicator.
  Widget _buildCameraPreview(BuildContext context, AsyncSnapshot<void> snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      return _buildCameraStack(context);
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  // Stack of widgets shown when camera is ready.
  Widget _buildCameraStack(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        _buildCameraPreviewBox(context),
        _buildProfileIconButton(),
        _buildReceiptIconButton(),
        _buildCameraButton(context),
      ],
    );
  }

  Widget _buildCameraPreviewBox(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: CameraPreview(_controller),
      ),
    );
  }

  Widget _buildProfileIconButton() {
    return Positioned(
      top: 60.0,
      left: 20.0,
      child: IconButton(
        iconSize: 40.0,
        icon: Icon(Icons.account_circle, color: Colors.white),
        onPressed: () {
          // TODO: Handle profile button press here.
        },
      ),
    );
  }

  Widget _buildReceiptIconButton() {
    return Positioned(
      top: 60.0,
      right: 20.0,
      child: IconButton(
        iconSize: 40.0,
        icon: Icon(Icons.receipt, color: Colors.white),
        onPressed: () {
          // TODO: Handle receipt button press here.
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
          child: _buildCameraIconButton(),
        ),
      ),
    );
  }

  Widget _buildCameraIconButton() {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: ShapeDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: CircleBorder(),
        ),
        child: Container(
          height: 80.0,
          width: 80.0,
          child: IconButton(
            icon: Icon(Icons.camera_alt, color: Colors.white),
            iconSize: 40.0,
            onPressed: () {
              // TODO: Handle camera button press here.
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}