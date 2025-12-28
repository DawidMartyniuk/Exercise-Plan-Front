
enum RepsType {
  single,
  range;

  String get displayName {
    switch (this) {
      case RepsType.single:
        return 'single';
      case RepsType.range:
        return 'range';
    }
  }

  String get fullName {
    switch (this) {
      case RepsType.single:
        return 'Single';
      case RepsType.range:
        return 'Range';
    }
  }

  String toDbString() {
    switch (this) {
      case RepsType.single:
        return 'single';
      case RepsType.range:
        return 'range';
    }
  }

  static RepsType fromString(String value) {
    switch (value.toLowerCase().trim()) {
      case 'single':
        return RepsType.single;
      case 'range':
        return RepsType.range;
      default:
        return RepsType.range;
    }
  }
}