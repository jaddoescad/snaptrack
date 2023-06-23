import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/full_screen_image_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageGridPage extends StatefulWidget {
  final Bin bin;

  ImageGridPage({Key? key, required this.bin}) : super(key: key);

  @override
  _ImageGridPageState createState() => _ImageGridPageState();
}

class _ImageGridPageState extends State<ImageGridPage> {
  late Future<List<SignedUrl>> imagesFuture;
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

  // Future<List<String>> _fetchImages() async {
  //   final response = await supabaseClient.supabase
  //       .from('bin_images')
  //       .select()
  //       .eq('bin_id', widget.bin.id);

  //   return (response as List).map((image) => image['img_url'] as String).toList();
  // }

  Future<List<SignedUrl>> _fetchImages() async {
    final queries = await supabaseClient.supabase
        .from('bin_images')
        .select()
        .eq('bin_id', widget.bin.id);

    List<String> imagePaths = [];

    for (var query in queries) {
      if (query['img_url'] != null && query['img_url'] != '') {
        imagePaths.add(query['thumbnail_url']);
      }
    }
    // Create signed URLs for all image paths
    final signedUrls = await supabaseClient.supabase.storage
        .from('ImageDocuments')
        .createSignedUrls(
            imagePaths, 36000); // 3600 is the expiry time in seconds

    final test = signedUrls[1].signedUrl.toString();

    print(test);
    return signedUrls;
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
              // TODO: Implement your functionality for the '+' button
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SignedUrl>>(
        future: imagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final images = snapshot.data!;
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
                    cacheKey:images[index].path.toString(),
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
