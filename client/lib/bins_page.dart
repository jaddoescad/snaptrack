import 'dart:io';

import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/image_grid_page.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase/supabase.dart';
import 'package:snaptrack/utilities/snackbar.dart';

class BinsPage extends StatefulWidget {
  final File? imageFile;
  BinsPage({Key? key, this.imageFile}) : super(key: key);

  @override
  _BinsPageState createState() => _BinsPageState();
}

class _BinsPageState extends State<BinsPage> {
  late Future<List<Bin>> binsFuture;
  final SupabaseInstance supabaseClient = SupabaseInstance();

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
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ImageGridPage(
                          bin: Bin(
                              id: bins[index].id,
                              title: bins[index].title,
                              imageCount: bins[index].imageCount),
                        ),
                      ),
                    );
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
