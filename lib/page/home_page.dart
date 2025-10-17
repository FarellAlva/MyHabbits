// page/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/model.dart';
import '../provider/provider.dart';
import 'add_edit_habit_page.dart';

/// Helper method untuk menampilkan SnackBar secara konsisten.
void _showSnackBar(BuildContext context, String message) {
  // Menghapus SnackBar yang mungkin sedang tampil agar tidak tumpang tindih.
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitListProvider);
    final progress = ref.watch(progressProvider);
    final completedCount = ref.watch(completedCountProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('MaHabits Tracker'), centerTitle: true),
      body: habitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (habits) {
          return Column(
            children: [
              // Header Progress
              Container(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progress Harian: ${(progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completedCount dari ${habits.length} kebiasaan selesai',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Daftar Habit
              Expanded(child: _buildHabitList(context, habits, progress)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Menunggu hasil (pesan) dari halaman AddEditHabitPage
          final result = await Navigator.push<String?>(
            context,
            MaterialPageRoute(builder: (context) => const AddEditHabitPage()),
          );

          // Jika ada pesan yang dikembalikan, tampilkan di SnackBar
          if (result != null && context.mounted) {
            _showSnackBar(context, result);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHabitList(
    BuildContext context,
    List<Habit> habits,
    double progress,
  ) {
    if (habits.isNotEmpty && progress == 1.0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/done.png', width: 200),
            const SizedBox(height: 24),
            Text(
              'Kerja Bagus! ✨',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const Text('Semua kebiasaan hari ini telah selesai.'),
          ],
        ),
      );
    }

    return habits.isEmpty
        ? const Center(child: Text('Belum ada kebiasaan.'))
        : ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              return HabitItem(habit: habits[index]);
            },
          );
  }
}

class HabitItem extends ConsumerWidget {
  final Habit habit;
  const HabitItem({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (value) {
            ref.read(habitListProvider.notifier).toggleHabit(habit.id);
          },
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
            color: habit.isCompleted ? Colors.grey[600] : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.blue.shade300),
              onPressed: () async {
                final result = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditHabitPage(habit: habit),
                  ),
                );

                if (result != null && context.mounted) {
                  _showSnackBar(context, result);
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: () =>
                  _showDeleteConfirmationDialog(context, ref, habit),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Kebiasaan'),
          content: Text('Apakah Anda yakin ingin menghapus "${habit.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                await ref
                    .read(habitListProvider.notifier)
                    .removeHabit(habit.id);

                if (context.mounted) {
                  _showSnackBar(
                    context,
                    'Habit "${habit.name}" telah dihapus.',
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
