
import 'package:equatable/equatable.dart';

import 'attachment.dart';

enum VisitType { maintenance, repair, itv, other }
enum ItvResult { favorable, unfavorable }

class ServiceRecord extends Equatable {
  final String id;
  final String vehicleId;
  final DateTime date;
  final int? mileageKm;
  final VisitType visitType;
  final ItvResult? itvResult; // Only for VisitType.itv
  final List<ServiceItem> items;
  final double cost; // Total cost of the visit
  final String currency;
  final String? name; // Optional name for the record
  final String? notes; // General notes for the visit
  final List<Attachment> attachments;

  const ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    this.mileageKm,
    this.visitType = VisitType.maintenance,
    this.itvResult,
    required this.items,
    required this.cost,
    required this.currency,
    this.name,
    this.notes,
    required this.attachments,
  });

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        date,
        mileageKm,
        visitType,
        itvResult,
        items,
        cost,
        currency,
        name,
        notes,
        attachments,
      ];

  factory ServiceRecord.fromJson(Map<String, dynamic> json) {
    // Backward compatibility check
    List<ServiceItem> items = [];
    if (json.containsKey('items')) {
      items = (json['items'] as List<dynamic>?)
              ?.map((i) => ServiceItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [];
    } else if (json.containsKey('type')) {
      // Legacy format migration
      items.add(ServiceItem(
        type: json['type'],
        parts: (json['parts'] as List<dynamic>?)
                ?.map((p) => Part.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        labor: json['labor'] != null
            ? Labor.fromJson(json['labor'] as Map<String, dynamic>)
            : null,
        cost: (json['cost'] as num).toDouble(),
        notes: null,
      ));
    }

    // Infer VisitType if missing
    VisitType visitType;
    if (json.containsKey('visitType')) {
      visitType = VisitType.values.firstWhere(
        (e) => e.name == json['visitType'],
        orElse: () => VisitType.maintenance,
      );
    } else {
      // Migration logic: check items for 'itv'
      if (items.any((i) => i.type.toLowerCase().contains('itv'))) {
        visitType = VisitType.itv;
      } else {
        visitType = VisitType.maintenance;
      }
    }

    ItvResult? itvResult;
    if (json.containsKey('itvResult') && json['itvResult'] != null) {
      itvResult = ItvResult.values.firstWhere(
        (e) => e.name == json['itvResult'],
        orElse: () => ItvResult.favorable, // Default or null logic? Keeping null if not found logic is better but using defaults here. Actually let's use null if no match.
      );
      // Correction: firstWhere throws if not found without orElse.
      try {
         itvResult = ItvResult.values.byName(json['itvResult']);
      } catch (_) {
        itvResult = null;
      }
    }

    return ServiceRecord(
      id: json['id'],
      vehicleId: json['vehicleId'],
      date: DateTime.parse(json['date']),
      mileageKm: json['mileageKm'],
      visitType: visitType,
      itvResult: itvResult,
      items: items,
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'],
      name: json['name'],
      notes: json['notes'],
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'mileageKm': mileageKm,
      'visitType': visitType.name,
      'itvResult': itvResult?.name,
      'items': items.map((i) => i.toJson()).toList(),
      'cost': cost,
      'currency': currency,
      'name': name,
      'notes': notes,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  ServiceRecord copyWith({
    String? id,
    String? vehicleId,
    DateTime? date,
    int? mileageKm,
    VisitType? visitType,
    ItvResult? itvResult,
    List<ServiceItem>? items,
    double? cost,
    String? currency,
    String? name,
    String? notes,
    List<Attachment>? attachments,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      mileageKm: mileageKm ?? this.mileageKm,
      visitType: visitType ?? this.visitType,
      itvResult: itvResult ?? this.itvResult,
      items: items ?? this.items,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }
}

class ServiceItem extends Equatable {
  final String type;
  final List<Part> parts;
  final Labor? labor;
  final double cost;
  final String? notes;

  const ServiceItem({
    required this.type,
    this.parts = const [],
    this.labor,
    required this.cost,
    this.notes,
  });

  @override
  List<Object?> get props => [type, parts, labor, cost, notes];

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      type: json['type'],
      parts: (json['parts'] as List<dynamic>?)
              ?.map((p) => Part.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      labor: json['labor'] != null
          ? Labor.fromJson(json['labor'] as Map<String, dynamic>)
          : null,
      cost: (json['cost'] as num).toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'parts': parts.map((p) => p.toJson()).toList(),
      'labor': labor?.toJson(),
      'cost': cost,
      'notes': notes,
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
