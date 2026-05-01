import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChartService {
  final _col = FirebaseFirestore.instance.collection('appointments');
  final _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<Map<int, int>> getAppointmentsByDay() async {
    final snap =
        await _col.where('userId', isEqualTo: _uid).get();
    final Map<int, int> dayCount = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};

    for (final doc in snap.docs) {
      final dateStr = doc.data()['date'] as String? ?? '';
      if (dateStr.isNotEmpty) {
        try {
          final dt = DateTime.parse(dateStr);
          // weekday: Mon=1 ... Sun=7  → index 0..6
          final idx = dt.weekday - 1;
          dayCount[idx] = (dayCount[idx] ?? 0) + 1;
        } catch (_) {}
      }
    }
    return dayCount;
  }

  Future<Map<String, int>> getAppointmentsByStatus() async {
    final snap =
        await _col.where('userId', isEqualTo: _uid).get();
    final Map<String, int> statusCount = {
      'confirmed': 0,
      'pending': 0,
      'cancelled': 0,
    };

    for (final doc in snap.docs) {
      final status = doc.data()['status'] as String? ?? 'pending';
      statusCount[status] = (statusCount[status] ?? 0) + 1;
    }
    return statusCount;
  }
}
