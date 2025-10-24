// service/thought_api_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/model.dart';

final String _baseUrl = dotenv.env['SUPABASE_URL'] ?? 'https://fallback-url.com'; 
final String _anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 'fallback_anon_key'; 


final String _supabaseUrl = '$_baseUrl/rest/v1/thought_entries'; 


class ThoughtApiService {

  // FUNGSI 1: POST (Mengirim data baru ke Supabase)
  Future<void> saveThought(ThoughtEntry entry) async {
    final uri = Uri.parse(_supabaseUrl);
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': _anonKey, // Kunci dari .env
        'Authorization': 'Bearer $_anonKey', // Kunci dari .env
        'Prefer': 'return=minimal', 
      },
      body: json.encode(entry.toJson()),
    );

    if (response.statusCode >= 400) {
      throw Exception('Gagal menyimpan pikiran (Status ${response.statusCode}): ${response.body}');
    }
  }

  // FUNGSI 2: GET (Mengambil data dari Supabase & Parsing JSON)
  Future<List<ThoughtEntry>> fetchThoughts() async {
    // Meminta Supabase mengurutkan berdasarkan created_at secara menurun (terbaru di atas)
    final uri = Uri.parse('$_supabaseUrl?order=created_at.desc');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'apikey': _anonKey, // Kunci dari .env
        'Authorization': 'Bearer $_anonKey', 
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      
      final List<ThoughtEntry> loadedThoughts = jsonList
          .map((json) => ThoughtEntry.fromJson(json))
          .toList();
      
      return loadedThoughts;
    } else {
      throw Exception('Gagal mengambil data pikiran (Status ${response.statusCode}).');
    }
  }
}

// Provider untuk Service dan State
final thoughtApiServiceProvider = Provider((ref) => ThoughtApiService());

final thoughtListProvider = FutureProvider<List<ThoughtEntry>>((ref) async {
  final apiService = ref.watch(thoughtApiServiceProvider);
  return apiService.fetchThoughts();
});