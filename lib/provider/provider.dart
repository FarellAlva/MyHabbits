// provider/provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/model.dart';

class AsyncHabitNotifier extends AsyncNotifier<List<Habit>> {
  
  @override
  Future<List<Habit>> build() async {
   
    await Future.delayed(const Duration(seconds: 2));
    // Data awal
    return [
      Habit(name: 'Olahraga 30 Menit'),
      Habit(name: 'Baca Buku 15 Halaman', isCompleted: true),
      Habit(name: 'Minum 8 Gelas Air'),
    ];
  }

  
  Future<void> addHabit(String name) async {
    final currentState = await future; 
    state = const AsyncValue.loading(); 
    
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data([...currentState, Habit(name: name)]);
  }

  // Menghapus habit
  Future<void> removeHabit(String habitId) async {
    final currentState = await future;
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 300));
    state = AsyncValue.data(currentState.where((h) => h.id != habitId).toList());
  }
  
  // Mengedit habit
  Future<void> editHabit(String habitId, String newName) async {
    final currentState = await future;
    state = const AsyncValue.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    state = AsyncValue.data([
      for (final habit in currentState)
        if (habit.id == habitId) habit.copyWith(name: newName) else habit,
    ]);
  }

  // status selesai
  Future<void> toggleHabit(String habitId) async {
    final currentState = await future;
  
    state = AsyncValue.data([
      for (final habit in currentState)
        if (habit.id == habitId)
          habit.copyWith(isCompleted: !habit.isCompleted)
        else
          habit,
    ]);
  }
}

/// Provider  daftar habit
final habitListProvider =
    AsyncNotifierProvider<AsyncHabitNotifier, List<Habit>>(
        () => AsyncHabitNotifier());

/// Providerjumlah habit selesai (Derived State)
final completedCountProvider = Provider<int>((ref) {

  final habits = ref.watch(habitListProvider).value ?? [];
  return habits.where((habit) => habit.isCompleted).length;
});

/// Provider menghitung progress (Derived State)
final progressProvider = Provider<double>((ref) {
  final habits = ref.watch(habitListProvider).value ?? [];
  final totalHabits = habits.length;
  final completedHabits = ref.watch(completedCountProvider);

  if (totalHabits == 0) {
    return 0.0;
  }
  return completedHabits / totalHabits;
});