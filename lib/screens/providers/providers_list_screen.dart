import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../services/provider_service.dart';
import '../../models/provider_model.dart';
import '../../config/theme.dart';

class ProvidersListScreen extends StatelessWidget {
  const ProvidersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const Scaffold(body: Center(child: Text('Not available')));
    final svc = ProviderService();
    return Scaffold(
      appBar: AppBar(title: const Text('Providers')),
      body: StreamBuilder<List<ProviderModel>>(
        stream: svc.getAllProviders(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final list = snap.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final p = list[i];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(p.location),
                trailing: Text('${p.slotDurationMinutes}m'),
                onTap: () => Navigator.pushNamed(context, '/providers/edit', arguments: p.providerId),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/providers/edit'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
