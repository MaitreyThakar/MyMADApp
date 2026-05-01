import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/slot_model.dart';
import '../services/slots_service.dart';

class SlotsProvider extends ChangeNotifier {
  final _service = SlotsService();
  List<SlotModel> _slots = [];
  bool _isLoading = false;
  StreamSubscription? _sub;

  List<SlotModel> get slots => _slots;
  bool get isLoading => _isLoading;

  void listenToDate(String date, {String? providerId}) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();
    final stream = (providerId != null && providerId.isNotEmpty)
        ? _service.getSlotsForDateAndProvider(date, providerId)
        : _service.getSlotsForDate(date);
    _sub = stream.listen((list) {
      _slots = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (_) {
      _slots = [];
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createSlot(SlotModel slot) => _service.createSlot(slot);

  Future<void> generateSlotsForDate({
    required String providerId,
    required String date,
    required String start,
    required String end,
    required int slotDurationMinutes,
  }) async {
    await _service.generateSlotsForDate(
        providerId: providerId, date: date, start: start, end: end, slotDurationMinutes: slotDurationMinutes);
  }

  Future<void> updateSlot(String id, Map<String, dynamic> data) =>
      _service.updateSlot(id, data);

  Future<void> disposeProvider() async {
    await _sub?.cancel();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
