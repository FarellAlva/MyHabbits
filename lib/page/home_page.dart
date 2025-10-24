// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/model.dart';
import '../provider/provider.dart';
import '../service/thought_api_service.dart'; // Wajib
import 'add_edit_habit_page.dart';

/// Helper method untuk menampilkan SnackBar secara konsisten.
void _showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();

  final backgroundColor = isError
      ? Colors.red.shade400
      : Theme.of(context).colorScheme.primary;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 2500),
    ),
  );
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
              const ThoughtInputSection(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/thoughts');
                    },
                    icon: const Icon(Icons.message_sharp, size: 18),
                    label: const Text('Lihat Pesan Global'),
                  ),
                ),
              ),
              const Divider(height: 1),

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
          final result = await Navigator.push<String?>(
            context,
            MaterialPageRoute(builder: (context) => const AddEditHabitPage()),
          );

          if (result != null && context.mounted) {
            final isError = result.startsWith('ERROR:');
            final displayMessage = isError ? result.substring(6) : result;

            _showSnackBar(context, displayMessage, isError: isError);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Helper untuk membangun daftar habit
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
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              'Kerja Bagus! ',
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
              return HabitItem(habit: habits[index], homePageContext: context);
            },
          );
  }
}

class HabitItem extends ConsumerWidget {
  final Habit habit;
  final BuildContext homePageContext;
  const HabitItem({
    super.key,
    required this.habit,
    required this.homePageContext,
  });

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
                  final isError = result.startsWith('ERROR:');
                  final displayMessage = isError ? result.substring(6) : result;

                  _showSnackBar(
                    homePageContext,
                    displayMessage,
                    isError: isError,
                  );
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
    final safeSnackBarContext = homePageContext;

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
                Navigator.of(dialogContext).pop();

                try {
                  await ref
                      .read(habitListProvider.notifier)
                      .removeHabit(habit.id);

                  _showSnackBar(
                    safeSnackBarContext,
                    'Habit "${habit.name}" telah dihapus.',
                  );
                } catch (e) {
                  _showSnackBar(
                    safeSnackBarContext,
                    'Gagal menghapus habit: $e',
                    isError: true,
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

class ThoughtInputSection extends ConsumerStatefulWidget {
  const ThoughtInputSection({super.key});

  @override
  ConsumerState<ThoughtInputSection> createState() =>
      _ThoughtInputSectionState();
}

class _ThoughtInputSectionState extends ConsumerState<ThoughtInputSection> {
  final TextEditingController _thoughtController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  Future<void> _submitThought() async {
    final thoughtText = _thoughtController.text.trim();
    if (thoughtText.isEmpty) {
      _showSnackBar(context, 'Post tidak boleh kosong.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final apiService = ref.read(thoughtApiServiceProvider);
    final newEntry = ThoughtEntry(
      thought: thoughtText,
      timestamp: DateTime.now(),
    );

    try {
      await apiService.saveThought(newEntry);
      _thoughtController.clear();

      // Memuat ulang riwayat pikiran di provider
      ref.invalidate(thoughtListProvider);

      if (mounted) {
        _showSnackBar(context, 'Postingan berhasil dikirim! ');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(context, 'Gagal terhubung ke API: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // ---------------------------------------------
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bagikan Pesan Unikmu Hari Ini',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _thoughtController,
                  decoration: InputDecoration(
                    labelText: 'Tuliskan pikiranmu...',
                    border: const OutlineInputBorder(),
                    isDense: true,

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                  ),
                  maxLines: 1,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitThought(),
                ),
              ),
              const SizedBox(width: 8),
              _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton(
                      onPressed: _submitThought,
                      child: const Text('Kirim'),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
