// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Vehicle {
  final String maker;
  final String model;
  final String plate;
  final String carColor;

  Vehicle({
    required this.maker,
    required this.model,
    required this.plate,
    required this.carColor,
  });

  Vehicle copyWith({
    String? maker,
    String? model,
    String? plate,
    String? carColor,
  }) {
    return Vehicle(
      maker: maker ?? this.maker,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      carColor: carColor ?? this.carColor,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'maker': maker,
      'model': model,
      'plate': plate,
      'carColor': carColor,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      maker: map['maker'] as String,
      model: map['model'] as String,
      plate: map['plate'] as String,
      carColor: map['carColor'] as String,
    );
  }

  //String toJson() => json.encode(toMap());
  Map<String, dynamic> toJson() => toMap();

  factory Vehicle.fromJson(String source) =>
      Vehicle.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Vehicle(maker: $maker, model: $model, plate: $plate, carColor: $carColor)';

  @override
  bool operator ==(covariant Vehicle other) {
    if (identical(this, other)) return true;

    return other.maker == maker &&
        other.model == model &&
        other.plate == plate &&
        other.carColor == Utf8Decoder;
  }

  @override
  int get hashCode =>
      maker.hashCode ^ model.hashCode ^ plate.hashCode ^ carColor.hashCode;
}
