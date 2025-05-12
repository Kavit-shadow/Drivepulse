// lib/models/attendance_record.dart
class AttendanceRecord {
  final String? date;
  final String? trainerName;
  final String? vehicleName;
  final String? note;
  final String? displayDatetime; // Formatted date/time from API
  final String? markType; // If you add it back to API

  AttendanceRecord({
    this.date,
    this.trainerName,
    this.vehicleName,
    this.note,
    this.displayDatetime,
    this.markType,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: json['date'],
      trainerName: json['trainer_name'],
      vehicleName: json['vehicle_name'],
      note: json['note'],
      displayDatetime: json['display_datetime'],
      markType: json['mark_type'],
    );
  }
}