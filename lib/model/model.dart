class Habit {
  final String name;
  final bool isCompleted;

  Habit({
    required this.name,
    this.isCompleted = false,
  });

  Habit copyWith({
    String? name,
    bool? isCompleted,
  }) {
    return Habit(
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}