// page/thought_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../service/thought_api_service.dart';
import '../model/model.dart';

class ThoughtPage extends ConsumerWidget {
  const ThoughtPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thoughtsAsync = ref.watch(thoughtListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pikiran'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(thoughtListProvider); 
            },
          ),
        ],
      ),
      body: thoughtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: ${err.toString().contains("Exception") ? err.toString().split(":").last : err}'),
        ),
        data: (thoughts) {
          if (thoughts.isEmpty) {
            return const Center(
              child: Text('Belum ada pikiran yang tersimpan. Ayo mulai berbagi!'),
            );
          }

          return ListView.builder(
            itemCount: thoughts.length,
            itemBuilder: (context, index) {
              final thought = thoughts[index] as ThoughtEntry;
              final formattedDate = DateFormat('EEE, d MMM yyyy, HH:mm')
                  .format(thought.timestamp.toLocal()); 

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(thought.thought),
                  subtitle: Text(formattedDate),
                  leading: Icon(
                    Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  trailing: Text(
                 
                    thought.id.length > 4 ? thought.id.substring(0, 4) : thought.id, 
                    style: const TextStyle(color: Colors.grey)
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}