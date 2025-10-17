// model/model.dart
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Habit {
  final String id;
  final String name;
  final bool isCompleted;

  Habit({
    required this.name,
    this.isCompleted = false,
    String? id,
  }) : id = id ?? uuid.v4();

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
}