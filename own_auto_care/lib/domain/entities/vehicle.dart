
import 'package:equatable/equatable.dart';

class Vehicle extends Equatable {
  final String id;
  final String make;
  final String model;
  final int year;
  final String? vin;
  final String? plates;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    this.vin,
    this.plates,
  });

  @override
  List<Object?> get props => [id, make, model, year, vin, plates];
}
