// provider/provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- IMPOR BARU
import '../model/model.dart';
import '../service/database_service.dart'; // <-- IMPOR BARU


final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

/// Provider untuk nama list, yang membaca dari SharedPreferences.
final habitListNameProvider = StateProvider<String>((ref) {
  // Amati provider SharedPreferences
  final prefsAsync = ref.watch(sharedPreferencesProvider);

  // Gunakan .when() untuk menangani state loading/error/data
  return prefsAsync.when(
    data: (prefs) {
      // Baca nama dari storage, jika tidak ada, gunakan default 'MaHabits Tracker'
      return prefs.getString('habitListName') ?? 'MaHabits Tracker';
    },
    loading: () => 'Memuat...', // Teks sementara saat loading
    error: (e, s) => 'Error',  // Teks jika gagal
  );
});


// --- PROVIDER HABIT (DIMODIFIKASI UNTUK SQLITE) ---

class AsyncHabitNotifier extends AsyncNotifier<List<Habit>> {
  
  // Dapatkan instance singleton DatabaseHelper
  final _db = DatabaseHelper.instance;

  @override
  Future<List<Habit>> build() async {
    // Ganti data mock dengan panggilan ke database lokal
    return _db.queryAllHabits();
  }

  /// Menambah habit baru ke DB
  Future<void> addHabit(String name) async {
    final newHabit = Habit(name: name);
    
    state = const AsyncValue.loading(); // Tampilkan loading
    
    await _db.insert(newHabit); // Simpan ke DB
    
    // Muat ulang data dari DB untuk memperbarui state
    state = AsyncValue.data(await _db.queryAllHabits());
  }

  /// Menghapus habit dari DB
  Future<void> removeHabit(String habitId) async {
    await _db.delete(habitId); // Hapus dari DB
    
    // Muat ulang data dari DB
    state = AsyncValue.data(await _db.queryAllHabits());
  }

  /// Mengedit habit di DB
  Future<void> editHabit(String habitId, String newName) async {
    // Kita perlu state saat ini untuk mendapatkan objek habit yang lama
    final currentState = state.value ?? [];
    final habitToEdit = currentState.firstWhere((h) => h.id == habitId);
    
    // Buat objek baru dengan nama baru tapi ID dan status isCompleted yang sama
    final updatedHabit = habitToEdit.copyWith(name: newName);

    state = const AsyncValue.loading();
    await _db.update(updatedHabit); // Update di DB
    
    // Muat ulang data dari DB
    state = AsyncValue.data(await _db.queryAllHabits());
  }

  /// Mengubah status selesai (toggle) di DB
  Future<void> toggleHabit(String habitId) async {
    // Dapatkan state saat ini
    final currentState = state.value ?? [];
    final habitToToggle = currentState.firstWhere((h) => h.id == habitId);

    // Buat objek baru dengan status isCompleted yang dibalik
    final updatedHabit = habitToToggle.copyWith(
      isCompleted: !habitToToggle.isCompleted,
    );
    
    await _db.update(updatedHabit); // Update di DB
    
    // Muat ulang data dari DB.
    // Ini memastikan data selalu sinkron dengan database.
    state = AsyncValue.data(await _db.queryAllHabits());
  }
}

/// Provider daftar habit (Definisi ini tidak berubah)
final habitListProvider =
    AsyncNotifierProvider<AsyncHabitNotifier, List<Habit>>(
        () => AsyncHabitNotifier());

/// Provider jumlah habit selesai (Tidak berubah)
final completedCountProvider = Provider<int>((ref) {
  final habits = ref.watch(habitListProvider).value ?? [];
  return habits.where((habit) => habit.isCompleted).length;
});

/// Provider menghitung progress (Tidak berubah)
final progressProvider = Provider<double>((ref) {
  final habits = ref.watch(habitListProvider).value ?? [];
  final totalHabits = habits.length;
  final completedHabits = ref.watch(completedCountProvider);

  if (totalHabits == 0) {
    return 0.0;
  }
  return completedHabits / totalHabits;
});