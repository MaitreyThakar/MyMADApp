import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/slot_model.dart';

class SlotsService {
  final _col = FirebaseFirestore.instance.collection('slots');

  Stream<List<SlotModel>> getSlotsForDate(String date) => _col
      .where('date', isEqualTo: date)
      .snapshots()
      .map((snap) {
      final list = snap.docs
        .map((d) => SlotModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
      // Prefer 24h key for stable sort, fallback to display label.
      list.sort((a, b) => (a.time24 ?? a.time).compareTo(b.time24 ?? b.time));
      return list;
      });

  Stream<List<SlotModel>> getSlotsForDateAndProvider(String date, String providerId) => _col
      .where('date', isEqualTo: date)
      .where('providerId', isEqualTo: providerId)
      .snapshots()
      .map((snap) {
      final list = snap.docs
        .map((d) => SlotModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();
      list.sort((a, b) => (a.time24 ?? a.time).compareTo(b.time24 ?? b.time));
      return list;
      });

  Future<void> createSlot(SlotModel slot) async => await _col.add(slot.toMap());

  Future<void> updateSlot(String id, Map<String, dynamic> data) async =>
      await _col.doc(id).update(data);

  Future<void> deleteSlot(String id) async => await _col.doc(id).delete();

  /// Generate slots between start and end times for a provider on a given date.
  /// start/end format: "HH:mm" (24h), date format: yyyy-MM-dd
  Future<void> generateSlotsForDate({
    required String providerId,
    required String date,
    required String start,
    required String end,
    required int slotDurationMinutes,
  }) async {
    try {
      final startParts = start.split(':');
      final endParts = end.split(':');
      int sh = int.parse(startParts[0]);
      int sm = int.parse(startParts[1]);
      int eh = int.parse(endParts[0]);
      int em = int.parse(endParts[1]);

      DateTime cur = DateTime(2000, 1, 1, sh, sm);
      final DateTime endDt = DateTime(2000, 1, 1, eh, em);

      final batch = FirebaseFirestore.instance.batch();
      while (cur.isBefore(endDt)) {
        final next = cur.add(Duration(minutes: slotDurationMinutes));
        final timeLabel = '${cur.hour.toString().padLeft(2, '0')}:${cur.minute.toString().padLeft(2, '0')}';
        // Convert to 12h format with AM/PM for display
        final hour = cur.hour % 12 == 0 ? 12 : cur.hour % 12;
        final ampm = cur.hour >= 12 ? 'PM' : 'AM';
        final display = '${hour.toString().padLeft(2, '0')}:${cur.minute.toString().padLeft(2, '0')} $ampm';

        final doc = _col.doc();
        batch.set(doc, {
          'providerId': providerId,
          'date': date,
          'time': display,
          'time24': timeLabel,
          'status': 'available'
        });
        cur = next;
      }
      await batch.commit();
    } catch (_) {}
  }
}
