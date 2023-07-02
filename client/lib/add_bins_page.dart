import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/supabase/service.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:snaptrack/utilities/uploadImage.dart';
import 'package:provider/provider.dart' as provider;

class AddBinsPage extends StatefulWidget {
  final File? imageFile;
  final void Function() clearImage;
  AddBinsPage({Key? key, this.imageFile, required this.clearImage})
      : super(key: key);

  @override
  _AddBinsPageState createState() => _AddBinsPageState();
}

class _AddBinsPageState extends State<AddBinsPage> {
  final SupabaseInstance supabaseClient = SupabaseInstance();
  final SupabaseService _supabaseService = SupabaseService();

  int loadingIndex = -1;
  bool isUploading = false;

  void showCustomOverlay(BuildContext context, String message, Color color) {
    showSimpleNotification(
      Text(message, style: TextStyle(color: Colors.white)),
      background: color,
      autoDismiss: true,
      trailing: Builder(builder: (context) {
        return TextButton(
          child: Text('Dismiss', style: TextStyle(color: Colors.white)),
          onPressed: () {
            OverlaySupportEntry.of(context)!.dismiss();
          },
        );
      }),
      slideDismissDirection: DismissDirection.up,
      position: NotificationPosition.top,
      duration: Duration(seconds: 3),
    );
  }

  @override
  void initState() {
    super.initState();
    final binListNotifier =
        provider.Provider.of<BinListNotifier>(context, listen: false);
    _supabaseService.fetchBins().then((bins) {
      binListNotifier.bins = bins;
    }).catchError((error) {
      context.showErrorSnackBar(message: 'Error fetching bins');
    });
  }

  void _onTapBin(BuildContext context, Bin bin, int index) async {
    final binListNotifier = provider.Provider.of<BinListNotifier>(context, listen: false);
    setState(() {
      loadingIndex = index;
    });
    try {
      await uploadImage(supabaseClient.supabase, widget.imageFile!, bin.id);
      widget.clearImage();
      binListNotifier.incrementImageCount(index);
      setState(() {
        loadingIndex = -1;
      });
      Navigator.of(context).pop();
      showCustomOverlay(context, 'Image uploaded successfully', Colors.green);
    } catch (e) {
      print(e);
      setState(() {
        loadingIndex = -1;
      });
      Navigator.of(context).pop();
      showCustomOverlay(context, 'Error uploading image', Colors.red);
    }
  }

  Future<void> _addBin(String title) async {
    await _supabaseService.addBin(
        title, supabaseClient.supabase.auth.currentUser!.id);

    final binListNotifier =
        provider.Provider.of<BinListNotifier>(context, listen: false);
    _supabaseService.fetchBins().then((bins) {
      binListNotifier.bins = bins;
    }).catchError((error) {
      print(error);
    });
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Bin added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  print(e);
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
      body: provider.Consumer<BinListNotifier>(
        builder: (context, binListNotifier, child) {
          if (binListNotifier.bins.isEmpty) {
            return Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: binListNotifier.bins.length,
              itemBuilder: (context, index) {
                return AbsorbPointer(
                  absorbing: isUploading,
                  child: ListTile(
                    title: Text(binListNotifier.bins[index].title,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        '${binListNotifier.bins[index].imageCount} images'),
                    trailing: loadingIndex == index
                        ? CircularProgressIndicator()
                        : widget.imageFile != null
                            ? Icon(Icons.add_photo_alternate)
                            : Icon(Icons.arrow_forward_ios),
                    onTap: () =>
                        _onTapBin(context, binListNotifier.bins[index], index),
                  ),
                );
              },
            );
          }
        },
      ),
    );
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
