class Customer {
  final int? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String batteryType;
  final String deviceName;
  final String notes;
  final bool isDoubleSided;
  final DateTime dateAdded;
  final DateTime? batteryChangeDate;
  final int? batteryReminderMonths;

  String get fullName => '$firstName ${lastName.toUpperCase()}';

  DateTime? get nextBatteryChangeDate => batteryChangeDate?.add(
        Duration(days: (batteryReminderMonths ?? 0) * 30),
      );

  DateTime? get reminderDate => nextBatteryChangeDate?.subtract(
        const Duration(days: 7),
      );

  bool get isReminderDue => reminderDate != null && 
      DateTime.now().isAfter(reminderDate!) && 
      DateTime.now().isBefore(nextBatteryChangeDate!);

  Customer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.batteryType,
    required this.deviceName,
    required this.notes,
    required this.isDoubleSided,
    required this.dateAdded,
    this.batteryChangeDate,
    this.batteryReminderMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'batteryType': batteryType,
      'deviceName': deviceName,
      'notes': notes,
      'isDoubleSided': isDoubleSided ? 1 : 0,
      'dateAdded': dateAdded.toIso8601String(),
      'batteryChangeDate': batteryChangeDate?.toIso8601String(),
      'batteryReminderMonths': batteryReminderMonths,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      phone: map['phone'],
      batteryType: map['batteryType'],
      deviceName: map['deviceName'],
      notes: map['notes'],
      isDoubleSided: map['isDoubleSided'] == 1,
      dateAdded: DateTime.parse(map['dateAdded']),
      batteryChangeDate: map['batteryChangeDate'] != null 
          ? DateTime.parse(map['batteryChangeDate'])
          : null,
      batteryReminderMonths: map['batteryReminderMonths'],
    );
  }

  Customer copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? batteryType,
    String? deviceName,
    String? notes,
    bool? isDoubleSided,
    DateTime? dateAdded,
    DateTime? batteryChangeDate,
    int? batteryReminderMonths,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      batteryType: batteryType ?? this.batteryType,
      deviceName: deviceName ?? this.deviceName,
      notes: notes ?? this.notes,
      isDoubleSided: isDoubleSided ?? this.isDoubleSided,
      dateAdded: dateAdded ?? this.dateAdded,
      batteryChangeDate: batteryChangeDate ?? this.batteryChangeDate,
      batteryReminderMonths: batteryReminderMonths ?? this.batteryReminderMonths,
    );
  }
} 