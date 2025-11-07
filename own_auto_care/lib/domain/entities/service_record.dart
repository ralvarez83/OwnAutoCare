
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

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    return ServiceRecord(
      id: json['id'],
      vehicleId: json['vehicleId'],
      date: DateTime.parse(json['date']),
      mileageKm: json['mileageKm'],
      type: json['type'],
      parts: (json['parts'] as List<dynamic>?)?.map((p) => Part.fromJson(p as Map<String, dynamic>)).toList() ?? [],
      labor: json['labor'] != null ? Labor.fromJson(json['labor'] as Map<String, dynamic>) : null,
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'],
      notes: json['notes'],
      attachments: (json['attachments'] as List<dynamic>?)?.map((a) => Attachment.fromJson(a as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'mileageKm': mileageKm,
      'type': type,
      'parts': parts.map((p) => p.toJson()).toList(),
      'labor': labor?.toJson(),
      'cost': cost,
      'currency': currency,
      'notes': notes,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }
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

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      name: json['name'],
      brand: json['brand'],
      qty: json['qty'],
      unit: json['unit'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'brand': brand,
      'qty': qty,
      'unit': unit,
      'unitPrice': unitPrice,
    };
  }
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

  factory Labor.fromJson(Map<String, dynamic> json) {
    return Labor(
      hours: (json['hours'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'rate': rate,
    };
  }
}
