// page/add_edit_habit_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/model.dart';
import '../provider/provider.dart';

class AddEditHabitPage extends ConsumerStatefulWidget {
  final Habit? habit;
  const AddEditHabitPage({super.key, this.habit});

  @override
  ConsumerState<AddEditHabitPage> createState() => _AddEditHabitPageState();
}

class _AddEditHabitPageState extends ConsumerState<AddEditHabitPage> {
  final _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _textController.text = widget.habit!.name;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final habitName = _textController.text;
    if (habitName.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final successMessage = widget.habit == null
          ? 'Habit berhasil ditambahkan!'
          : 'Habit berhasil diperbarui!';

      if (widget.habit == null) {
        await ref.read(habitListProvider.notifier).addHabit(habitName);
      } else {
        await ref
            .read(habitListProvider.notifier)
            .editHabit(widget.habit!.id, habitName);
      }

      // Kirim pesan sukses saat menutup halaman
      if (mounted) Navigator.of(context).pop(successMessage);
    } catch (e) {
      final errorMessage = 'Gagal menyimpan: $e';
      // Kirim pesan error saat menutup halaman jika terjadi masalah
      if (mounted) Navigator.of(context).pop(errorMessage);
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
    final isEditing = widget.habit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Kebiasaan' : 'Tambah Kebiasaan Baru'),
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
              onSubmitted: (_) => _isLoading ? null : _submit(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
