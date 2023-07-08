import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:snaptrack/supabase/auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snaptrack/utilities/uploadImage.dart';

class UploadNotifier with ChangeNotifier {
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  Future<void> uploadImageToSupbase(int binId, File? imageFile) async {
    final SupabaseInstance supabaseClient = SupabaseInstance();

    setUploading(true);
    try {
      await uploadImage(supabaseClient.supabase, imageFile!, binId);
      setUploading(false);
    } catch (e) {
      setUploading(false);
      throw e;
    }
  }
}
