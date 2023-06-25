import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/full_screen_image_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snaptrack/utilities/uploadImage.dart';

class ImageGridPage extends StatefulWidget {
  final Bin bin;

  ImageGridPage({Key? key, required this.bin}) : super(key: key);

  @override
  _ImageGridPageState createState() => _ImageGridPageState();
}

class _ImageGridPageState extends State<ImageGridPage> {
  late Future<Map<String, List<SignedUrl>>> imagesFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();

  @override
  void initState() {
    super.initState();

    try {
      imagesFuture = _fetchImages();
    } catch (e) {
      context.showErrorSnackBar(message: 'Error fetching images');
    }
  }

  Future<void> _addImageToBin(String imagePath, int binId) async {
    try {
      await supabaseClient.supabase.from('bin_images').insert({
        'bin_id': binId,
        'img_url': imagePath,
        // 'thumbnail_url': <Add your thumbnail URL here>
      });
    } catch (e) {
      print('Error while adding image to bin: $e');
    }
  }

  // Future<List<String>> _fetchImages() async {
  //   final response = await supabaseClient.supabase
  //       .from('bin_images')
  //       .select()
  //       .eq('bin_id', widget.bin.id);

  //   return (response as List).map((image) => image['img_url'] as String).toList();
  // }

  Future<Map<String, List<SignedUrl>>> _fetchImages() async {
    final queries = await supabaseClient.supabase
        .from('bin_images')
        .select()
        .eq('bin_id', widget.bin.id);

    List<String> thumbnailPaths = [];
    List<String> imagePaths = [];

    for (var query in queries) {
      if (query['img_url'] != null && query['thumbnail_url'] != null) {
        thumbnailPaths.add(query['thumbnail_url']);
        imagePaths.add(query['img_url']); // added this line to fill imagePaths
      }
    }

    Map<String, List<SignedUrl>> resultMap = {}; // Initialize the result map

    // Create signed URLs for all image paths
    if (thumbnailPaths.isNotEmpty && imagePaths.isNotEmpty) {
      final signedThumbnailUrls = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrls(thumbnailPaths, 3600);

      final signedImageUrls = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrls(imagePaths, 3600);

      // Fill the result map
      resultMap['signedThumbnailUrls'] = signedThumbnailUrls;
      resultMap['signedImageUrls'] = signedImageUrls;

      return resultMap; // Return the map containing both lists
    } else {
      return {
        'signedThumbnailUrls': [],
        'signedImageUrls': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Text(widget.bin.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(
          widget.bin.title,
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey,
            height: 1.0,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext bc) {
                  return SafeArea(
                    child: Container(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text('Photo Library'),
                              onTap: () async {
                                final pickedFile = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);
                                final file = File(pickedFile!.path);
                                if (pickedFile != null) {
                                  final imagePath = await uploadImage(
                                      supabaseClient.supabase,
                                      file!,
                                      widget.bin.id);
                                  if (imagePath.isNotEmpty) {
                                    await _addImageToBin(
                                        imagePath, widget.bin.id);
                                    setState(() {
                                      imagesFuture =
                                          _fetchImages(); // Refresh the images
                                    });
                                  }
                                }
                                Navigator.of(context).pop();
                              }),
                          ListTile(
                              leading: Icon(Icons.photo_camera),
                              title: Text('Camera'),
                              onTap: () async {
                                final pickedFile = await ImagePicker()
                                    .pickImage(source: ImageSource.camera);
                                final file = File(pickedFile!.path);
                                if (pickedFile != null) {
                                  final imagePath = await uploadImage(
                                      supabaseClient.supabase,
                                      file!,
                                      widget.bin.id);
                                  if (imagePath.isNotEmpty) {
                                    await _addImageToBin(
                                        imagePath, widget.bin.id);
                                    setState(() {
                                      imagesFuture =
                                          _fetchImages(); // Refresh the images
                                    });
                                  }
                                }
                                Navigator.of(context).pop();
                              }),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, List<SignedUrl>>>(
        future: imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final images = snapshot.data!['signedImageUrls']!;
            if (images.isEmpty) {
              return Center(child: Text('No images to display'));
            } else {
              return GridView.builder(
                itemCount: images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullSizeImagePage(
                            imageUrl: images[index].signedUrl.toString(),
                            binTitle: widget.bin.title,
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: images[index].signedUrl.toString(),
                      cacheKey: images[index].path.toString(),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class ImageData {
  final String thumbnailUrl;
  final String imgUrl;

  ImageData({required this.thumbnailUrl, required this.imgUrl});
}
