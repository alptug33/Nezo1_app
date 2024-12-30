import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../providers/customer_provider.dart';
import '../utils/constants.dart';

class CustomerFormScreen extends StatefulWidget {
  final Customer? customer;

  const CustomerFormScreen({super.key, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedBatteryType = Constants.batteryTypes.first;
  String _selectedDevice = '';
  bool _isDoubleSided = false;
  DateTime? _batteryChangeDate;
  int? _batteryReminderMonths;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _firstNameController.text = widget.customer!.firstName;
      _lastNameController.text = widget.customer!.lastName;
      _phoneController.text = widget.customer!.phone;
      _notesController.text = widget.customer!.notes;
      _selectedBatteryType = widget.customer!.batteryType;
      _selectedDevice = widget.customer!.deviceName;
      _isDoubleSided = widget.customer!.isDoubleSided;
      _batteryChangeDate = widget.customer!.batteryChangeDate;
      _batteryReminderMonths = widget.customer!.batteryReminderMonths;
    } else {
      _selectedDevice = Constants.getDevicesForBattery(_selectedBatteryType).first;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lütfen telefon numarası giriniz';
    }
    
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length != 11) {
      return 'Telefon numarası 11 haneli olmalıdır';
    }
    
    if (!cleanPhone.startsWith('05')) {
      return 'Telefon numarası 05 ile başlamalıdır';
    }
    
    return null;
  }

  void _formatPhoneNumber(String value) {
    final cleanPhone = value.replaceAll(RegExp(r'\D'), '');
    if (cleanPhone.length <= 11) {
      String formatted = cleanPhone;
      if (formatted.length >= 1) {
        if (!formatted.startsWith('0')) {
          formatted = '0$formatted';
        }
        if (formatted.length >= 2 && !formatted.startsWith('05')) {
          formatted = '05${formatted.substring(2)}';
        }
      }
      
      String finalFormatted = '';
      for (int i = 0; i < formatted.length; i++) {
        if (i == 4 || i == 7 || i == 9) {
          finalFormatted += ' ';
        }
        finalFormatted += formatted[i];
      }

      if (finalFormatted != _phoneController.text) {
        _phoneController.value = TextEditingValue(
          text: finalFormatted,
          selection: TextSelection.collapsed(offset: finalFormatted.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Yeni Müşteri' : 'Müşteri Düzenle'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Ad',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen ad giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Soyad',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen soyad giriniz';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefon',
                border: OutlineInputBorder(),
                hintText: '0532 XXX XX XX',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 14,
              onChanged: _formatPhoneNumber,
              validator: _validatePhoneNumber,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBatteryType,
              decoration: const InputDecoration(
                labelText: 'Pil Tipi',
                border: OutlineInputBorder(),
              ),
              items: Constants.batteryTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text('$type numara pil'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedBatteryType = value;
                    _selectedDevice =
                        Constants.getDevicesForBattery(value).first;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDevice,
              decoration: const InputDecoration(
                labelText: 'Cihaz Modeli',
                border: OutlineInputBorder(),
              ),
              items: Constants.getDevicesForBattery(_selectedBatteryType)
                  .map((device) => DropdownMenuItem(
                        value: device,
                        child: Text(device),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDevice = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notlar',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Çift Taraflı Cihaz'),
              value: _isDoubleSided,
              onChanged: (value) {
                setState(() {
                  _isDoubleSided = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pil Değişim Hatırlatıcısı',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: widget.customer?.batteryReminderMonths,
                      decoration: const InputDecoration(
                        labelText: 'Hatırlatma Süresi',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: null,
                          child: Text('Hatırlatma yok'),
                        ),
                        DropdownMenuItem(
                          value: 3,
                          child: Text('3 ay'),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text('6 ay'),
                        ),
                        DropdownMenuItem(
                          value: 9,
                          child: Text('9 ay'),
                        ),
                        DropdownMenuItem(
                          value: 12,
                          child: Text('12 ay'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _batteryReminderMonths = value;
                          if (value != null && _batteryChangeDate == null) {
                            _batteryChangeDate = DateTime.now();
                          }
                        });
                      },
                    ),
                    if (_batteryReminderMonths != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Bir sonraki pil değişimi: ${DateFormat('dd/MM/yyyy').format(_batteryChangeDate?.add(Duration(days: _batteryReminderMonths! * 30)) ?? DateTime.now())}',
                        style: const TextStyle(color: Colors.blue),
                      ),
                      Text(
                        'Hatırlatma tarihi: ${DateFormat('dd/MM/yyyy').format(_batteryChangeDate?.add(Duration(days: _batteryReminderMonths! * 30 - 7)) ?? DateTime.now())}',
                        style: const TextStyle(color: Colors.orange),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveCustomer,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.customer == null ? 'Kaydet' : 'Güncelle',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text,
        batteryType: _selectedBatteryType,
        deviceName: _selectedDevice,
        notes: _notesController.text.trim(),
        isDoubleSided: _isDoubleSided,
        dateAdded: widget.customer?.dateAdded ?? DateTime.now(),
        batteryChangeDate: _batteryReminderMonths != null ? DateTime.now() : null,
        batteryReminderMonths: _batteryReminderMonths,
      );

      if (widget.customer == null) {
        context.read<CustomerProvider>().addCustomer(customer);
      } else {
        context.read<CustomerProvider>().updateCustomer(customer);
      }

      Navigator.pop(context);
    }
  }
} 