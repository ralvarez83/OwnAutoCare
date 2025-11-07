
import 'package:equatable/equatable.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';

class Vehicle extends Equatable {
  final VehicleId id;
  final String name;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? plates;

  const Vehicle({
    required this.id,
    required this.name,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.plates,
  });

  @override
  List<Object?> get props => [id, name, make, model, year, vin, plates];

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: VehicleId(json['id']),
      name: json['name'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      vin: json['vin'],
      plates: json['plates'],
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
  }) {
    return Vehicle(
      id: id ?? this.id,
      name: name ?? this.name,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      plates: plates ?? this.plates,
    );
  }
}
