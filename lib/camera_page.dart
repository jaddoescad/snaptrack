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
  CameraPageState createState() => CameraPageState();
}

class CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

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
        builder: _buildCameraPreview,
      ),
    );
  }

  // Builder for camera preview or loading indicator.
  Widget _buildCameraPreview(
      BuildContext context, AsyncSnapshot<void> snapshot) {
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
    var camera = _controller.value;
    // fetch screen size
    final size = MediaQuery.of(context).size;

    // calculate scale depending on screen and camera ratios
    // this is actually size.aspectRatio / (1 / camera.aspectRatio)
    // because camera preview size is received as landscape
    // but we're calculating for portrait orientation
    var scale = size.aspectRatio * camera.aspectRatio;

    // to prevent scaling down, invert the value
    if (scale < 1) scale = 1 / scale;

    return Transform.scale(
      scale: scale,
      child: Center(
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
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
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BinsPage(),
            ),
          );
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
            onPressed: () async {
              try {
                final XFile image = await _controller.takePicture();

                Navigator.of(context).push(
                  DisplayPictureOverlay(imagePath: image.path),
                );
              } catch (e) {
                print(e);
              }
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

class DisplayPictureOverlay extends ModalRoute<void> {
  final String imagePath;

  DisplayPictureOverlay({required this.imagePath});

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => '';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Material(
      type: MaterialType.transparency,
      child: _buildOverlayContent(context),
    );
  }

  Widget _buildOverlayContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AspectRatio(
            aspectRatio: _getAspectRatioForImage(File(imagePath)),
            child: Image.file(File(imagePath), fit: BoxFit.cover)),
        Positioned(
          top: 40.0,
          left: 20.0,
          child: IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          bottom: 40.0,
          right: 20.0,
          child: ElevatedButton(
            child: Text('Next'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddBinsPage(imageFile: File(imagePath)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  double _getAspectRatioForImage(File file) {
    final img.Image image = img.decodeImage(file.readAsBytesSync())!;
    return image.width / image.height;
  }
}
