class SlotModel {
  final String slotId;
  final String date; // yyyy-MM-dd
  final String time; // e.g., 09:00 AM
  final String? time24; // e.g., 09:00
  final String status; // available | booked
  final String? providerId;

  SlotModel({
    required this.slotId,
    required this.date,
    required this.time,
    this.time24,
    this.status = 'available',
    this.providerId,
  });

  factory SlotModel.fromMap(Map<String, dynamic> map, String id) {
    return SlotModel(
      slotId: id,
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      time24: map['time24'],
      status: map['status'] ?? 'available',
      providerId: map['providerId'],
    );
  }

  Map<String, dynamic> toMap() => {
        'date': date,
        'time': time,
        if (time24 != null) 'time24': time24,
        'status': status,
        if (providerId != null) 'providerId': providerId,
      };
}
