
import 'package:equatable/equatable.dart';

class Currency extends Equatable {
  final String value;

  const Currency(this.value);

  @override
  List<Object?> get props => [value];
}
