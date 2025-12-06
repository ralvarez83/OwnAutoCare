import 'package:equatable/equatable.dart';

class TirePressureConfiguration extends Equatable {
  final String name;
  final double front;
  final double rear;

  const TirePressureConfiguration({
    required this.name,
    required this.front,
    required this.rear,
  });

  factory TirePressureConfiguration.fromJson(Map<String, dynamic> json) {
    return TirePressureConfiguration(
      name: json['name'] as String,
      front: (json['front'] as num).toDouble(),
      rear: (json['rear'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'front': front,
      'rear': rear,
    };
  }

  TirePressureConfiguration copyWith({
    String? name,
    double? front,
    double? rear,
  }) {
    return TirePressureConfiguration(
      name: name ?? this.name,
      front: front ?? this.front,
      rear: rear ?? this.rear,
    );
  }

  @override
  List<Object?> get props => [name, front, rear];
}
