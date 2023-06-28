import 'package:flutter/material.dart';
import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/supabase/auth.dart';

class BinListNotifier extends ChangeNotifier {
  final SupabaseInstance supabaseClient = SupabaseInstance();
  List<Bin> _bins = [];

  List<Bin> get bins => _bins;

  Future<void> fetchBins() async {
    final response = await supabaseClient.supabase.rpc('get_bins_and_image_count');
    _bins = (response as List).map((bin) => Bin.fromMap(bin)).toList();
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
