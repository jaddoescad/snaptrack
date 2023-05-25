
import 'package:flutter/material.dart';

class FullSizeImagePage extends StatelessWidget {
  final String imageUrl;
  final String binTitle;

  FullSizeImagePage({Key? key, required this.imageUrl, required this.binTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(binTitle),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}