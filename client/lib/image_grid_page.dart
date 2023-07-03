import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/full_screen_image_page.dart';
import 'package:snaptrack/models/bin_image.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snaptrack/utilities/uploadImage.dart';
import 'package:provider/provider.dart' as provider;
import 'package:snaptrack/models/image_list_notifier.dart';

class ImageGridPage extends StatefulWidget {
  final Bin bin;
  final int binIndex;

  ImageGridPage({Key? key, required this.bin, required this.binIndex})
      : super(key: key);

  @override
  _ImageGridPageState createState() => _ImageGridPageState();
}

class _ImageGridPageState extends State<ImageGridPage> {
  late Future<Map<String, dynamic>> imagesFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();
  bool isLoading = true;
  bool isUploading = false; // Add this line to track the uploading state

  @override
  void initState() {
    super.initState();
    try {
      _fetchImagesAndStoreInNotifier();
    } catch (e) {
      context.showErrorSnackBar(message: 'Error fetching images');
    }
  }

  Future<void> _fetchImagesAndStoreInNotifier() async {
    var result = await _fetchImages();

    List<BinImage> images = [];
    for (var i = 0; i < result['imageIds'].length; i++) {
      images.add(
        BinImage(
          id: result['imageIds'][i],
          imageUrl: result['signedImageUrls'][i].signedUrl.toString(),
          thumbnailUrl: result['signedThumbnailUrls'][i].signedUrl.toString(),
          imagePath: result['signedImageUrls'][i].path.toString(),
          thumbnailPath: result['signedThumbnailUrls'][i].path.toString(),
        ),
      );
    }

    provider.Provider.of<ImageListNotifier>(context, listen: false)
        .setImagesForBin(widget.bin.id, images);

    setState(() {
      isLoading = false; // changed
    });
  }

  Future<void> _addImageToBin(
      Map<String, dynamic> imagePaths, int binId) async {
    try {
      final imageId = imagePaths['id'];
      final imagepath = imagePaths["original"];
      final thumbnailpath = imagePaths["resized"];

      // Create signed URLs
      var signedImageUrl = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrl(imagepath, 3600);

      var signedThumbnailUrl = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrl(thumbnailpath, 3600);

      provider.Provider.of<ImageListNotifier>(context, listen: false)
          .addImageToBin(
              binId,
              BinImage(
                id: imageId,
                imageUrl: signedImageUrl, // use the created signed URL
                thumbnailUrl: signedThumbnailUrl, // use the created signed URL
                imagePath: imagepath,
                thumbnailPath: thumbnailpath,
              ));

      provider.Provider.of<BinListNotifier>(context, listen: false)
          .incrementImageCount(widget.binIndex); // Increment image count
    } catch (e) {
      print('Error while adding image to bin: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchImages() async {
    final queries = await supabaseClient.supabase
        .from('bin_images')
        .select()
        .eq('bin_id', widget.bin.id);

    List<String> thumbnailPaths = [];
    List<String> imagePaths = [];
    List<int> imageIds = [];

    for (var query in queries) {
      if (query['img_url'] != null && query['thumbnail_url'] != null) {
        thumbnailPaths.add(query['thumbnail_url']);
        imagePaths.add(query['img_url']);
        imageIds.add(query['id']);
      }
    }

    Map<String, dynamic> resultMap = {};

    if (thumbnailPaths.isNotEmpty && imagePaths.isNotEmpty) {
      final signedThumbnailUrls = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrls(thumbnailPaths, 3600);

      final signedImageUrls = await supabaseClient.supabase.storage
          .from('ImageDocuments')
          .createSignedUrls(imagePaths, 3600);

      resultMap['signedThumbnailUrls'] = signedThumbnailUrls;
      resultMap['signedImageUrls'] = signedImageUrls;
      resultMap['imageIds'] = imageIds;

      return resultMap;
    } else {
      return {
        'signedThumbnailUrls': [],
        'signedImageUrls': [],
        'imageIds': [],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
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
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                          child: Text('Photo Library'),
                          onPressed: () async {
                            Navigator.of(context)
                                .pop(); // Dismiss the action sheet

                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            final file = File(pickedFile!.path);
                            if (pickedFile != null) {
                              setState(() {
                                isUploading = true; // Set loading state
                              });
                              final imagePath = await uploadImage(
                                  supabaseClient.supabase,
                                  file,
                                  widget.bin.id);
                              if (imagePath.isNotEmpty) {
                                await _addImageToBin(
                                    imagePath, widget.bin.id);

                                // _fetchImagesAndStoreInNotifier();
                              }
                            }
                            setState(() {
                              isUploading = false; // Reset loading state
                            });
                          },
                        ),
                        CupertinoActionSheetAction(
                          child: Text('Camera'),
                          onPressed: () async {
                            Navigator.of(context)
                                .pop(); // Dismiss the action sheet
                            setState(() {
                              isUploading = true; // Set loading state
                            });
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            final file = File(pickedFile!.path);
                            if (pickedFile != null) {
                              final imagePath = await uploadImage(
                                  supabaseClient.supabase,
                                  file,
                                  widget.bin.id);
                              if (imagePath.isNotEmpty) {
                                await _addImageToBin(
                                    imagePath, widget.bin.id);
                                // _fetchImagesAndStoreInNotifier();
                              }
                            }
                            setState(() {
                              isUploading = false; // Reset loading state
                            });
                          },
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: provider.Consumer<ImageListNotifier>(
            builder: (context, imageListNotifier, child) {
              List<BinImage> images =
                  imageListNotifier.getImagesForBin(widget.bin.id);
              if (isLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (images.isEmpty) {
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
                              imageUrl: images[index].imageUrl,
                              binTitle: widget.bin.title,
                              imgId: images[index].id,
                              supabaseClient: supabaseClient.supabase,
                              binId: widget.bin.id,
                              binIndex: widget.binIndex,
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: images[index].thumbnailUrl,
                        cacheKey: images[index].thumbnailPath.toString(),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator()), // changed
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
        if (isUploading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
