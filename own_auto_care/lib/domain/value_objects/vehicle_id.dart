
import 'package:equatable/equatable.dart';

class VehicleId extends Equatable {
  final String value;

  const VehicleId(this.value);

  @override
  List<Object?> get props => [value];
}
