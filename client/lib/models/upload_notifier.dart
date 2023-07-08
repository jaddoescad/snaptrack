import 'package:flutter/foundation.dart';

class UploadNotifier extends ChangeNotifier {
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }
}
