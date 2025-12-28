import 'package:flutter/material.dart';

enum WeightType {
  kg,
  lbs;

  String get displayName {
    switch (this) {
      case WeightType.kg:
        return 'kg';
      case WeightType.lbs:
        return 'lbs';
    }
  }

  String get fullName {
    switch (this) {
      case WeightType.kg:
        return 'Kilograms';
      case WeightType.lbs:
        return 'Pounds';
    }
  }

  //  Konwersja z String (z bazy danych)
  static WeightType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'kg':
        return WeightType.kg;
      case 'lbs':
        return WeightType.lbs;
      default:
        return WeightType.kg; // domyślna wartość
    }
  }

  // Konwersja do String (do bazy danych)
  String toDbString() {
    switch (this) {
      case WeightType.kg:
        return 'kg';
      case WeightType.lbs:
        return 'lbs';
    }
  }
  //  Konwersja wartości między jednostkami
  double convertTo(double value, WeightType targetType) {
    if (this == targetType) return value;
    
    switch (this) {
      case WeightType.kg:
        return value * 2.20462; // kg to lbs
      case WeightType.lbs:
        return value / 2.20462; // lbs to kg
    }
  }

  //  Formatowanie wartości z jednostką
  String formatWeight(double weight, {int decimals = 1}) {
    return '${weight.toStringAsFixed(decimals)} $displayName';
  }
}

//  EXTENSION DLA ŁATWEJ KONWERSJI
extension WeightTypeExtension on WeightType {
  String toApiString() {
    switch (this) {
      case WeightType.kg:
        return "kg";
      case WeightType.lbs:
        return "lbs";
    }
  }
  
  static WeightType fromString(String value) {
    switch (value.toLowerCase()) {
      case "kg":
        return WeightType.kg;
      case "lbs":
        return WeightType.lbs;
      default:
        return WeightType.kg; // domyślnie
    }
  }
  
}