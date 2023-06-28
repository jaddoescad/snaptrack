import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase/supabase.dart';
import 'package:provider/provider.dart' as provider;
import 'package:snaptrack/models/bin_list_notifier.dart';

class FullSizeImagePage extends StatelessWidget {
  final String imageUrl;
  final String binTitle;
  final SupabaseClient supabaseClient;
  final int binId;
  final int imgId;
  final int binIndex; // Add this if you know the bin index

  FullSizeImagePage(
      {Key? key,
      required this.imageUrl,
      required this.binTitle,
      required this.supabaseClient,
      required this.binId,
      required this.imgId,
      required this.binIndex}) // Add this if you know the bin index
      : super(key: key);

  Future<void> deleteImage(int imageId, BuildContext context) async {
    try {
      // Delete image from the database
      await supabaseClient
          .from('bin_images')
          .delete()
          .eq('id', imageId);

      // If deletion from the database was successful, delete from storage
      await supabaseClient.storage
          .from('ImageDocuments')
          .remove(['path_to_image']);

      // Update state
      final binListNotifier = provider.Provider.of<BinListNotifier>(context, listen: false);
      binListNotifier.decrementImageCount(binIndex);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(binTitle),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  actions: <Widget>[
                    CupertinoActionSheetAction(
                      child: Text('Delete'),
                      isDestructiveAction: true,
                      onPressed: () async {
                        Navigator.of(context)
                            .pop(); // Close the modal after clicking on an option
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text('Confirm Delete'),
                              content: Text(
                                  'Are you sure you want to delete this image?'),
                              actions: [
                                CupertinoDialogAction(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                CupertinoDialogAction(
                                  child: Text('Delete'),
                                  isDestructiveAction: true,
                                  onPressed: () async {
                                    try {
                                      await deleteImage(imgId, context); // Execute your delete function here
                                      Navigator.of(context)
                                          .pop(); // Close the confirmation dialog
                                      Navigator.of(context)
                                          .pop(); // Close the image page
                                    } catch (e) {
                                      // Handle any errors during the deletion
                                      print(e);
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        );
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
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: PhotoView(
            minScale: PhotoViewComputedScale.contained,
            imageProvider: NetworkImage(
              imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}
