enum FastingProtocolType {
  p12_12,
  p16_8,
  p18_6,
  custom,
}

extension FastingProtocolExtension on FastingProtocolType {
  String get title {
    switch (this) {
      case FastingProtocolType.p12_12:
        return '12:12 Iniciante';
      case FastingProtocolType.p16_8:
        return '16:8 Intermediário';
      case FastingProtocolType.p18_6:
        return '18:6 Avançado';
      case FastingProtocolType.custom:
        return 'Personalizado';
    }
  }

  String get subtitle {
    switch (this) {
      case FastingProtocolType.p12_12:
        return '12h Jejum / 12h Alimentação';
      case FastingProtocolType.p16_8:
        return '16h Jejum / 8h Alimentação';
      case FastingProtocolType.p18_6:
        return '18h Jejum / 6h Alimentação';
      case FastingProtocolType.custom:
        return 'Duração definida pelo usuário';
    }
  }

  Duration get defaultDuration {
    switch (this) {
      case FastingProtocolType.p12_12:
        return const Duration(hours: 12);
      case FastingProtocolType.p16_8:
        return const Duration(hours: 16);
      case FastingProtocolType.p18_6:
        return const Duration(hours: 18);
      case FastingProtocolType.custom:
        return const Duration(hours: 16);
    }
  }
}
