import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

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



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaHabits',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 10, 9, 93)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListProvider);
    final progress = ref.watch(progressProvider);
    final completedCount = ref.watch(completedCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MaHabits Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header Progress
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress Harian: ${(progress * 100).toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(5),
                ),
                const SizedBox(height: 8),
                Text('$completedCount dari ${habits.length} kebiasaan selesai'),
              ],
            ),
          ),
          const Divider(height: 1),
          // Daftar Habit
          Expanded(
            child: habits.isEmpty
                ? const Center(child: Text('Belum ada kebiasaan.'))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: habits.length,
                    itemBuilder: (context, index) {
                      return HabitItem(habit: habits[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddHabitPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Widget untuk satu item kebiasaan
class HabitItem extends ConsumerWidget {
  final Habit habit;
  const HabitItem({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (value) {
            ref.read(habitListProvider.notifier).toggleHabit(habit);
          },
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
            color: habit.isCompleted ? const Color.fromARGB(255, 117, 70, 70) : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: const Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            ref.read(habitListProvider.notifier).removeHabit(habit);
          },
        ),
      ),
    );
  }
}

/// Halaman untuk menambah kebiasaan baru
class AddHabitPage extends ConsumerWidget {
  AddHabitPage({super.key});

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kebiasaan Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nama Kebiasaan',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submit(context, ref),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () => _submit(context, ref),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(BuildContext context, WidgetRef ref) {
    final habitName = _textController.text;
    if (habitName.isNotEmpty) {
      ref.read(habitListProvider.notifier).addHabit(habitName);
      Navigator.of(context).pop();
    }
  }
}