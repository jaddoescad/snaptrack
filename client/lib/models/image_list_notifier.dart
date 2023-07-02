import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin_image.dart';

class ImageListNotifier extends ChangeNotifier {
  Map<int, List<BinImage>> _imageMap = {};

  List<BinImage> getImagesForBin(int binId) => _imageMap[binId] ?? [];

  void setImagesForBin(int binId, List<BinImage> newImages) {
    _imageMap[binId] = newImages;
    notifyListeners();
  }

  void addImageToBin(int binId, BinImage image) {
    _imageMap[binId]?.add(image);
    notifyListeners();
  }

  void removeImageFromBin(int binId, String imageUrl) {
    _imageMap[binId]?.removeWhere((imageData) => imageData.imageUrl == imageUrl);
    notifyListeners();
  }
}
