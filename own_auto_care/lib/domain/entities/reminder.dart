
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
}
