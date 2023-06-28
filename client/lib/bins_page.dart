import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:snaptrack/utilities/snackbar.dart';

import 'package:provider/provider.dart';
import 'package:snaptrack/models/bin_list_notifier.dart';

class BinsPage extends StatefulWidget {
  final File? imageFile;
  BinsPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _BinsPageState createState() => _BinsPageState();
}

class _BinsPageState extends State<BinsPage> {
  final SupabaseInstance supabaseClient = SupabaseInstance();

  @override
  void initState() {
    super.initState();

    try {
      Provider.of<BinListNotifier>(context, listen: false).fetchBins();
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
                      await _addBin(title);
                      binListNotifier.fetchBins(); // refresh the bin list
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
              return ListTile(
                title: Text(binListNotifier.bins[index].title,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle:
                    Text('${binListNotifier.bins[index].imageCount} images'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageGridPage(
                        bin: binListNotifier.bins[index],
                        binIndex: index,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _addBin(String title) async {
    await supabaseClient.supabase.from('bins').insert({
      'title': title,
      'user_id': supabaseClient.supabase.auth.currentUser!.id,
    });
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
