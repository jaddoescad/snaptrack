import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';

class AddBinsPage extends StatefulWidget {
  final File? imageFile;
  AddBinsPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _BinsPageState createState() => _BinsPageState();
}

class _BinsPageState extends State<AddBinsPage> {
  late Future<List<Bin>> binsFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();
int loadingIndex = -1;  // Added
  @override
  void initState() {
    super.initState();

    try {
      binsFuture = _fetchBins();
    } catch (e) {
      context.showErrorSnackBar(message: 'Error fetching bins');
    }
  }

  Future<List<Bin>> _fetchBins() async {
    final response =
        await supabaseClient.supabase.rpc('get_bins_and_image_count');

    return (response as List).map((bin) => Bin.fromMap(bin)).toList();
  }

  Future<String> uploadImage(File imageFile, int binId) async {
    String fileName = "${binId}_${DateTime.now().millisecondsSinceEpoch}";
    if (imageFile.path.contains('.jpg')) {
      fileName += '.jpg';
    } else if (imageFile.path.contains('.png')) {
      fileName += '.png';
    } else {
      throw Exception('Invalid file type');
    }

    if (supabaseClient.supabase.auth.currentUser == null) {
      throw Exception('No user logged in');
    }

    final response = await supabaseClient.supabase.storage
        .from('snaptrack-images')
        .upload(
          'snaptrack-images/${supabaseClient.supabase.auth.currentUser?.id}/$binId/$fileName',
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    final String publicUrl = supabaseClient.supabase.storage
        .from('snaptrack-images')
        .getPublicUrl(
            'snaptrack-images/${supabaseClient.supabase.auth.currentUser?.id}/$binId/$fileName');

    //store image url in database
    await supabaseClient.supabase
        .from('bin_images')
        .insert({'img_url': publicUrl, 'bin_id': binId});

    return fileName;
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bins'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
      body: FutureBuilder<List<Bin>>(
        future: binsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final bins = snapshot.data!;
            return ListView.builder(
              itemCount: bins.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(bins[index].title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${bins[index].imageCount} images'),
                  trailing: loadingIndex == index  // Modified
                      ? CircularProgressIndicator()
                      : Icon(Icons.add_photo_alternate),
                  onTap: () async {
                    setState(() {
                      loadingIndex = index;
                    });
                    try {
                      await uploadImage(widget.imageFile!, bins[index].id);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageGridPage(bin: Bin(id: bins[index].id, title: bins[index].title, imageCount: bins[index].imageCount),),
                        ),
                      );
                    } catch (e) {
                      context.showErrorSnackBar(message: 'Error uploading image');
                    } finally {
                      setState(() {
                        loadingIndex = -1;
                      });
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}