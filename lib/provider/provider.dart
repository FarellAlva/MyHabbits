
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/model.dart';

// StateNotifier untuk mengelola daftar habit
class HabitListNotifier extends StateNotifier<List<Habit>> {
  HabitListNotifier()
      : super([
          Habit(name: 'Olahraga 30 Menit'),
          Habit(name: 'Baca Buku 15 Halaman', isCompleted: true),
          Habit(name: 'Minum 8 Gelas Air'),
        ]);

  void addHabit(String name) {
    state = [...state, Habit(name: name)];
  }

  void removeHabit(Habit habitToRemove) {
    state = state.where((habit) => habit != habitToRemove).toList();
  }

  void toggleHabit(Habit habitToToggle) {
    state = [
      for (final habit in state)
        if (habit == habitToToggle)
          habit.copyWith(isCompleted: !habit.isCompleted)
        else
          habit,
    ];
  }
}

/// Provider untuk daftar habit (StateNotifierProvider)
final habitListProvider = StateNotifierProvider<HabitListNotifier, List<Habit>>((ref) {
  return HabitListNotifier();
});

/// Provider untuk menghitung jumlah habit selesai (Derived State)
final completedCountProvider = Provider<int>((ref) {
  final habits = ref.watch(habitListProvider);
  return habits.where((habit) => habit.isCompleted).length;
});

/// Provider untuk menghitung progress (Derived State)
final progressProvider = Provider<double>((ref) {
  final totalHabits = ref.watch(habitListProvider).length;
  final completedHabits = ref.watch(completedCountProvider);

  if (totalHabits == 0) {
    return 0.0;
  }
  return completedHabits / totalHabits;
});

