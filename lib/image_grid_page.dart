import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/full_screen_image_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';

class ImageGridPage extends StatefulWidget {
  final Bin bin;

  ImageGridPage({Key? key, required this.bin}) : super(key: key);

  @override
  _ImageGridPageState createState() => _ImageGridPageState();
}

class _ImageGridPageState extends State<ImageGridPage> {
  late Future<List<String>> imagesFuture;
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

  Future<List<String>> _fetchImages() async {
    final response = await supabaseClient.supabase
        .from('bin_images')
        .select()
        .eq('bin_id', widget.bin.id);

    print(response);

    return (response as List).map((image) => image['img_url'] as String).toList();
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
      body: FutureBuilder<List<String>>(
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
                            imageUrl: images[index], binTitle: widget.bin.title),
                      ),
                    );
                  },
                  child: Image.network(images[index], fit: BoxFit.cover),
                );
              },
            );
          }
        },
      ),
    );
  }
}
