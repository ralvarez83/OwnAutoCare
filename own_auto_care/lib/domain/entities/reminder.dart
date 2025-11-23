
import 'package:equatable/equatable.dart';

class Reminder extends Equatable {
  final String id;
  final String vehicleId;
  final DateTime? dueDate;
  final int? dueMileageKm;
  final String title;
  final String? notes;

  const Reminder({
    required this.id,
    required this.vehicleId,
    this.dueDate,
    this.dueMileageKm,
    required this.title,
    this.notes,
  }) : assert(dueDate != null || dueMileageKm != null,
            'Either dueDate or dueMileageKm must be provided.');

  @override
  List<Object?> get props => [id, vehicleId, dueDate, dueMileageKm, title, notes];

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'],
      vehicleId: json['vehicleId'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      dueMileageKm: json['dueMileageKm'],
      title: json['title'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'dueDate': dueDate?.toIso8601String(),
      'dueMileageKm': dueMileageKm,
      'title': title,
      'notes': notes,
    };
  }

  Reminder copyWith({
    String? id,
    String? vehicleId,
    DateTime? dueDate,
    int? dueMileageKm,
    String? title,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      dueDate: dueDate ?? this.dueDate,
      dueMileageKm: dueMileageKm ?? this.dueMileageKm,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }
}
