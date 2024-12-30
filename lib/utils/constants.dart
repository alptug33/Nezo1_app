class Constants {
  static const Map<String, List<String>> batteryDevices = {
    '13': [
      'Bicore M 20',
      'Bicore M 30',
      'Bicore M 40',
      'Bicore M 80',
      'Bicore P 20',
      'Bicore P 30',
      'Mosaic P 40',
      'Mosaic P 80',
    ],
    '675': [
      'Bicore Hp 20',
      'Bicore Hp 30',
      'Bicore Hp 40',
      'Bicore Hp 80',
    ],
    '312': [
      'Bicore R312 20',
      'Bicore R312 30',
      'M-Core R312 40',
      'M-Core R312 80',
    ],
    '10': [
      'Sterling 10',
      'Sterling 20',
      'Sterling 30',
      'Sterling 40',
      'Sterling 80',
    ],
  };

  static List<String> get batteryTypes => batteryDevices.keys.toList();

  static List<String> getDevicesForBattery(String batteryType) {
    return batteryDevices[batteryType] ?? [];
  }
} 