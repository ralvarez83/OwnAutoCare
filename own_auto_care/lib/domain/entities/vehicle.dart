
import 'package:equatable/equatable.dart';
import 'package:own_auto_care/domain/entities/tire_pressure_configuration.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';

class Vehicle extends Equatable {
  final VehicleId id;
  final String? name;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? plates;
  final String? photoUrl;
  final List<TirePressureConfiguration> tirePressures;

  const Vehicle({
    required this.id,
    this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.plates,
    this.photoUrl,
    this.tirePressures = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        make,
        model,
        year,
        vin,
        plates,
        photoUrl,
        tirePressures,
      ];

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    // Migration logic: Check for old flat fields
    List<TirePressureConfiguration> pressures = [];
    
    if (json['tirePressures'] != null) {
      pressures = (json['tirePressures'] as List)
          .map((e) => TirePressureConfiguration.fromJson(e))
          .toList();
    } else if (json['frontTirePressure'] != null || json['rearTirePressure'] != null) {
      // Migrate existing data to "Standard" configuration
      double? front = json['frontTirePressure'] != null
          ? (json['frontTirePressure'] as num).toDouble()
          : null;
      double? rear = json['rearTirePressure'] != null
          ? (json['rearTirePressure'] as num).toDouble()
          : null;
      
      if (front != null || rear != null) {
        pressures.add(TirePressureConfiguration(
          name: 'Standard', // Will be localized when displayed, but stored as key or we can update later
          front: front ?? 0.0,
          rear: rear ?? 0.0,
        ));
      }
    }

    return Vehicle(
      id: VehicleId(json['id']),
      name: json['name'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      vin: json['vin'],
      plates: json['plates'],
      photoUrl: json['photoUrl'],
      tirePressures: pressures,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'plates': plates,
      'photoUrl': photoUrl,
      'tirePressures': tirePressures.map((e) => e.toJson()).toList(),
    };
  }

  Vehicle copyWith({
    VehicleId? id,
    String? name,
    String? make,
    String? model,
    int? year,
    String? vin,
    String? plates,
    String? photoUrl,
    List<TirePressureConfiguration>? tirePressures,
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      plates: plates ?? this.plates,
      photoUrl: photoUrl ?? this.photoUrl,
      tirePressures: tirePressures ?? this.tirePressures,
    );
  }
}
