// model/model.dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Habit {
  final String id;
  final String name;
  final bool isCompleted;

  Habit({required this.name, this.isCompleted = false, String? id})
    : id = id ?? uuid.v4();

  Habit copyWith({String? id, String? name, bool? isCompleted}) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ThoughtEntry {
  final String id;
  final String thought;
  final DateTime timestamp;

  ThoughtEntry({String? id, required this.thought, required this.timestamp})
    : id = id ?? uuid.v4();

  // Saat POST ke Supabase, kirim hanya data yang diperlukan.
  Map<String, dynamic> toJson() {
    return {
      'thought': thought,
      // HAPUS BARIS INI: 'timestamp': timestamp.toIso8601String(),
    };
  }

  // Saat GET dari Supabase, ambil created_at yang dikembalikan oleh DB.
  factory ThoughtEntry.fromJson(Map<String, dynamic> json) {
    return ThoughtEntry(
      id: json['id'] != null ? json['id'].toString() : uuid.v4(),
      thought: json['thought'] ?? 'No Thought',
      // MENGGUNAKAN 'created_at' DARI SUPABASE DULU
      timestamp:
          DateTime.tryParse(json['created_at'] ?? json['timestamp'] ?? '') ??
          DateTime.now(),
    );
  }
}
