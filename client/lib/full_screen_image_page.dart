import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:supabase/supabase.dart';
import 'package:provider/provider.dart' as provider;
import 'package:snaptrack/models/bin_list_notifier.dart';

class FullSizeImagePage extends StatefulWidget {
  final String imageUrl;
  final String binTitle;
  final SupabaseClient supabaseClient;
  final int binId;
  final int imgId;
  final int binIndex; // Add this if you know the bin index

  FullSizeImagePage({
    Key? key,
    required this.imageUrl,
    required this.binTitle,
    required this.supabaseClient,
    required this.binId,
    required this.imgId,
    required this.binIndex,
  }) : super(key: key);

  @override
  _FullSizeImagePageState createState() => _FullSizeImagePageState();
}

class _FullSizeImagePageState extends State<FullSizeImagePage> {
  late BuildContext dialogContext; // Store reference to the dialog context

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save reference to the dialog context
    dialogContext = context;
  }

  Future<void> deleteImage(int imageId) async {
    // Show loader
    showDialog(
      context: dialogContext, // Use the saved dialog context
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Delete image from the database
      await widget.supabaseClient.from('bin_images').delete().eq('id', imageId);

      // Delete from storage
      await widget.supabaseClient.storage
          .from('ImageDocuments')
          .remove(['path_to_image']);

      // // Update state
      final binListNotifier =
          provider.Provider.of<BinListNotifier>(context, listen: false);
      binListNotifier.decrementImageCount(widget.binIndex);

      // Close loader
      Navigator.of(dialogContext).pop();
      Navigator.of(dialogContext).pop();

    } catch (error) {
      // Handle error
      print('Error deleting image: $error');
      // Close loader
      Navigator.of(dialogContext).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.binTitle),
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
                                    Navigator.of(context)
                                        .pop(); // Close the confirmation dialog
                                    await deleteImage(
                                        widget.imgId); // Execute your delete function here
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
              widget.imageUrl,
            ),
          ),
        ),
      ),
    );
  }
}
