
import 'package:equatable/equatable.dart';

import 'attachment.dart';

class ServiceRecord extends Equatable {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int mileageKm;
  final String type;
  final List<Part> parts;
  final Labor? labor;
  final double cost;
  final String currency;
  final String? notes;
  final List<Attachment> attachments;

  const ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.mileageKm,
    required this.type,
    required this.parts,
    this.labor,
    required this.cost,
    required this.currency,
    this.notes,
    required this.attachments,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        date,
        mileageKm,
        type,
        parts,
        labor,
        cost,
        currency,
        notes,
        attachments,
      ];
}

class Part extends Equatable {
  final String name;
  final String brand;
  final int qty;
  final String unit;
  final double unitPrice;

  const Part({
    required this.name,
    required this.brand,
    required this.qty,
    required this.unit,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [name, brand, qty, unit, unitPrice];
}

class Labor extends Equatable {
  final double hours;
  final double rate;

  const Labor({
    required this.hours,
    required this.rate,
  });

  @override
  List<Object?> get props => [hours, rate];
}
