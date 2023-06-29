import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/supabase/auth.dart';

class BinListNotifier extends ChangeNotifier {
  List<Bin> _bins = [];

  List<Bin> get bins => _bins;

  set bins(List<Bin> newBins) {
    _bins = newBins;
    notifyListeners();
  }

  void addBin(Bin bin) {
    _bins.add(bin);
    notifyListeners();
  }

  void incrementImageCount(int binIndex) {
    _bins[binIndex].imageCount += 1;
    notifyListeners();
  }

  void decrementImageCount(int binIndex) {
    _bins[binIndex].imageCount -= 1;
    notifyListeners();
  }
}
