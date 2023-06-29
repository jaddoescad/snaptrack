import 'package:snaptrack/models/bin.dart';
import 'package:snaptrack/supabase/auth.dart';

class SupabaseService {
  final SupabaseInstance supabaseClient = SupabaseInstance();

  Future<List<Bin>> fetchBins() async {
    final response = await supabaseClient.supabase.rpc('get_bins_and_image_count');
    return (response as List).map((bin) => Bin.fromMap(bin)).toList();
  }

  Future<void> addBin(String title, String userId) async {
    await supabaseClient.supabase.from('bins').insert({
      'title': title,
      'user_id': userId,
    });
  }
}
