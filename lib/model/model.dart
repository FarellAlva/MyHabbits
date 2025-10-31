// model/model.dart

import 'package:uuid/uuid.dart';

// Model untuk Habit
class Habit {
  final String id;
  final String name;
  final bool isCompleted;

  Habit({
    String? id,
    required this.name,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4(); // Generate ID unik jika tidak disediakan

  Habit copyWith({
    String? id,
    String? name,
    bool? isCompleted,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted ? 1 : 0, // SQLite tidak punya bool, simpan 1 (true) / 0 (false)
    };
  }

  /// Konversi Map dari DB kembali ke objek Habit.
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      name: map['name'] as String,
      isCompleted: map['isCompleted'] == 1, // Konversi 1/0 kembali ke true/false
    );
  }

  // --- AKHIR TAMBAHAN ---
}

class ThoughtEntry {
  final String id;
  final String thought;
  final DateTime timestamp;

  ThoughtEntry({
    String? id,
    required this.thought,
    required this.timestamp,
  }) : id = id ?? const Uuid().v4();

  // Konversi ke JSON untuk dikirim ke Supabase
  Map<String, dynamic> toJson() {
    return {
      'thought': thought,
      'created_at': timestamp.toIso8601String(),
    };
  }

  // Konversi dari JSON yang diterima dari Supabase
  factory ThoughtEntry.fromJson(Map<String, dynamic> json) {
    return ThoughtEntry(
      id: json['id']?.toString() ?? const Uuid().v4(),
      thought: json['thought'] as String,
      timestamp: DateTime.parse(json['created_at'] as String),
    );
  }
}