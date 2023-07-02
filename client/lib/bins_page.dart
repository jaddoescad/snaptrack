import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/supabase/service.dart';
import 'package:snaptrack/utilities/snackbar.dart';
import 'package:snaptrack/models/image_list_notifier.dart';
import 'package:provider/provider.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';

class BinsPage extends StatefulWidget {
  final File? imageFile;
  BinsPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _BinsPageState createState() => _BinsPageState();
}

class _BinsPageState extends State<BinsPage> {
  final SupabaseService supabaseService = SupabaseService();
  final SupabaseInstance supabaseClient = SupabaseInstance();

  @override
  void initState() {
    super.initState();

    try {
      supabaseService.fetchBins().then((bins) {
        Provider.of<BinListNotifier>(context, listen: false).bins = bins;
      });
    } catch (e) {
      context.showErrorSnackBar(message: 'Error fetching bins');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BinListNotifier>(
      builder: (context, binListNotifier, _) {
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
                      await supabaseService.addBin(
                          title, supabaseClient.supabase.auth.currentUser!.id);

                      // Fetch the updated list of bins and update the state
                      supabaseService.fetchBins().then((bins) {
                        Provider.of<BinListNotifier>(context, listen: false)
                            .bins = bins;
                      });
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
          body: ListView.builder(
            itemCount: binListNotifier.bins.length,
            itemBuilder: (context, index) {
              return Consumer<BinListNotifier>(
                builder: (context, binListNotifier, _) {
                  final bin = binListNotifier.bins[index];
                  return ListTile(
                    title: Text(
                      bin.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${bin.imageCount} images'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ImageGridPage(
                            bin: bin,
                            binIndex: index,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        );
      },
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
