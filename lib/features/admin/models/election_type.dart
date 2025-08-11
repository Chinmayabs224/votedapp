enum ElectionType {
  general,
  presidential,
  parliamentary,
  local,
  referendum,
  other;

  String get displayName {
    switch (this) {
      case ElectionType.general:
        return 'General Election';
      case ElectionType.presidential:
        return 'Presidential Election';
      case ElectionType.parliamentary:
        return 'Parliamentary Election';
      case ElectionType.local:
        return 'Local Election';
      case ElectionType.referendum:
        return 'Referendum';
      case ElectionType.other:
        return 'Other';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ElectionType fromString(String value) {
    return ElectionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => ElectionType.other,
    );
  }
}