import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:overlay_support/overlay_support.dart';

class AddBinsPage extends StatefulWidget {
  final File? imageFile;
  final void Function() clearImage;
  AddBinsPage({Key? key, this.imageFile, required this.clearImage})
      : super(key: key);

  @override
  _AddBinsPageState createState() => _AddBinsPageState();
}

class _AddBinsPageState extends State<AddBinsPage> {
  late Future<List<Bin>> binsFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();
  int loadingIndex = -1;
  bool isUploading = false; // <-- add this line

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

    final request = http.MultipartRequest('POST',
        Uri.parse('https://serverless-seven-gray.vercel.app/api/resize-image'));

    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization':
          'Bearer ${supabaseClient.supabase.auth.currentSession?.accessToken}'
    });

    request.fields['binId'] = binId.toString();

    request.files.add(await http.MultipartFile.fromPath('file', imageFile.path,
        contentType: MediaType('image', imageFile.path.split('.').last),
        filename: fileName));

    final response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload image');
    }

    final responseBody = await response.stream.bytesToString();

    return fileName;
  }

  void _onTapBin(BuildContext context, Bin bin, int index) async {
    if (widget.imageFile == null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ImageGridPage(
            bin: Bin(
              id: bin.id,
              title: bin.title,
              imageCount: bin.imageCount,
            ),
          ),
        ),
      );
    } else {
      setState(() {
        loadingIndex = index;
      });
      try {
        await uploadImage(widget.imageFile!, bin.id);
        widget.clearImage();
        setState(() {
          bin.imageCount += 1;
          loadingIndex = -1;
        });

        // Pop back to the Camera page after a successful upload.
        Navigator.of(context).pop();

        // Show a success notification.
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                    size: const Size(40, 40),
                    child: ClipOval(
                        child: Container(
                      color: Colors.green,
                    ))),
                title: Text('Success'),
                subtitle: Text('Image uploaded successfully'),
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 4000));
      } catch (e) {
        print(e);
        setState(() {
          loadingIndex = -1;
        });

        // Pop back to the Camera page after a failed upload.
        Navigator.of(context).pop();

        // Show a failure notification.
        showOverlayNotification((context) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: SafeArea(
              child: ListTile(
                leading: SizedBox.fromSize(
                    size: const Size(40, 40),
                    child: ClipOval(
                        child: Container(
                      color: Colors.red,
                    ))),
                title: Text('Error'),
                subtitle: Text('Error uploading image'),
                trailing: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      OverlaySupportEntry.of(context)?.dismiss();
                    }),
              ),
            ),
          );
        }, duration: Duration(milliseconds: 4000));
      }
    }
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
            onPressed: () async {
              final title = await _showDialogAndGetTitle(context);
              if (title != null && title.isNotEmpty) {
                try {
                  await _addBin(title);
                  binsFuture = _fetchBins(); // refresh the bin list
                  setState(() {}); // trigger a rebuild
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bin added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding bin'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
                return AbsorbPointer(
                  absorbing: isUploading,
                  child: ListTile(
                    title: Text(bins[index].title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${bins[index].imageCount} images'),
                    trailing: loadingIndex == index
                        ? CircularProgressIndicator()
                        : widget.imageFile != null
                            ? Icon(Icons.add_photo_alternate)
                            : Icon(Icons.arrow_forward_ios),
                    onTap: () => _onTapBin(context, bins[index], index),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _addBin(String title) async {
    final response = await supabaseClient.supabase.from('bins').insert({
      'title': title,
    });

    if (response.error != null) {
      throw Exception('Failed to add bin');
    }
  }

  Future<String?> _showDialogAndGetTitle(BuildContext context) async {
    String? title;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add a new bin'),
          content: TextField(
            onChanged: (value) {
              title = value;
            },
            decoration: InputDecoration(
              hintText: "Enter bin title",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    return title;
  }
}
