import 'dart:math';
import 'package:flutter/material.dart';

enum RepsType {
  single,
  range;


//extension RepsTypeExtension on RepsType {
  String get displayName {
    switch (this) {
      case RepsType.single:
        return 'seconds';
      case RepsType.range:
        return 'reps';
    }
  }

  String get fullName {
    switch (this) {
      case RepsType.single:
        return 'Seconds';
      case RepsType.range:
        return 'Repetitions';
    }
  }

  String toDbString() {
    switch (this) {
      case RepsType.single:
        return 'seconds';
      case RepsType.range:
        return 'reps';
    }
  }

  static RepsType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'reps':
        return RepsType.range;
      case 'seconds':
        return RepsType.single;
      default:
        return RepsType.single; // default value
    }
  }
}

