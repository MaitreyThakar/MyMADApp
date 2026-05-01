class AppointmentModel {
  final String appointmentId;
  final String userId;
  final String serviceName;
  final String providerName;
  final String date; // Format: yyyy-MM-dd
  final String timeSlot; // Format: 10:00 AM
  final String? slotId; // Firestore slot document id (optional)
  final String status; // pending | confirmed | cancelled
  final String notes;
  final String createdAt; // ISO 8601

  AppointmentModel({
    required this.appointmentId,
    required this.userId,
    required this.serviceName,
    required this.providerName,
    required this.date,
    required this.timeSlot,
    this.slotId,
    this.status = 'pending',
    this.notes = '',
    required this.createdAt,
  });

  factory AppointmentModel.fromMap(Map<String, dynamic> map, String id) {
    return AppointmentModel(
      appointmentId: id,
      userId: map['userId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      providerName: map['providerName'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      slotId: map['slotId'],
      status: map['status'] ?? 'pending',
      notes: map['notes'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'serviceName': serviceName,
        'providerName': providerName,
        'date': date,
        'timeSlot': timeSlot,
      'slotId': slotId,
        'status': status,
        'notes': notes,
        'createdAt': createdAt,
      };
}
