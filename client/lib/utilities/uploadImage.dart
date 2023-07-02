// upload_image.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase/supabase.dart';

Future<Map<String, dynamic>> uploadImage(
    SupabaseClient supabaseClient, File imageFile, int binId) async {
  String fileName = "${binId}_${DateTime.now().millisecondsSinceEpoch}";

  if (imageFile.path.contains('.jpg')) {
    fileName += '.jpg';
  } else if (imageFile.path.contains('.png')) {
    fileName += '.png';
  } else {
    throw Exception('Invalid file type');
  }

  if (supabaseClient.auth.currentUser == null) {
    throw Exception('No user logged in');
  }

  final request = http.MultipartRequest('POST',
      Uri.parse('https://serverless-seven-gray.vercel.app/api/resize-image'));

  request.headers.addAll({
    'Content-Type': 'multipart/form-data',
    'Authorization': 'Bearer ${supabaseClient.auth.currentSession?.accessToken}'
  });

  request.fields['binId'] = binId.toString();

  request.files.add(await http.MultipartFile.fromPath('file', imageFile.path,
      contentType: MediaType('image', imageFile.path.split('.').last),
      filename: fileName));

  final response = await request.send();

  print(response);

  if (response.statusCode != 200) {
    throw Exception('Failed to upload image');
  }

  final responseBody = await response.stream.bytesToString();
  final Map<String, dynamic> responseBodyJson = jsonDecode(responseBody);

  return responseBodyJson;
}
