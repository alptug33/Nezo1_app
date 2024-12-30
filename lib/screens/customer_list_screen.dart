import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import '../providers/customer_provider.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<CustomerProvider>().loadCustomers(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Müşteri Listesi'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'backup':
                  try {
                    final backupPath = await DatabaseHelper.instance.backupDatabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Yedekleme başarılı: $backupPath'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Yedekleme hatası: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  break;
                case 'info':
                  final size = await DatabaseHelper.instance.getDatabaseSize();
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Veritabanı Bilgisi'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Veritabanı Boyutu: $size'),
                            Text('Müşteri Sayısı: ${context.read<CustomerProvider>().customers.length}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'backup',
                child: Row(
                  children: [
                    Icon(Icons.backup),
                    SizedBox(width: 8),
                    Text('Yedekle'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'info',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('Bilgi'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<CustomerProvider>(
        builder: (context, provider, child) {
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadCustomers(),
                    child: const Text('Yeniden Dene'),
                  ),
                ],
              ),
            );
          }

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.customers.isEmpty) {
            return const Center(
              child: Text('Henüz müşteri kaydı bulunmamaktadır.'),
            );
          }

          return ListView.builder(
            itemCount: provider.customers.length,
            itemBuilder: (context, index) {
              final customer = provider.customers[index];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CustomerFormScreen(
                              customer: customer,
                            ),
                          ),
                        );
                      },
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.edit,
                      label: 'Düzenle',
                    ),
                    SlidableAction(
                      onPressed: (context) {
                        _showDeleteDialog(context, customer);
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Sil',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(customer.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tel: ${customer.phone}'),
                      Text('Cihaz: ${customer.deviceName}'),
                      Text('Pil: ${customer.batteryType}'),
                      if (customer.notes.isNotEmpty)
                        Text('Not: ${customer.notes}'),
                      Text(
                        'Tarih: ${DateFormat('dd/MM/yyyy').format(customer.dateAdded)}',
                      ),
                      if (customer.batteryReminderMonths != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Sonraki Pil Değişimi: ${DateFormat('dd/MM/yyyy').format(customer.nextBatteryChangeDate!)}',
                          style: TextStyle(
                            color: customer.isReminderDue ? Colors.red : Colors.blue,
                            fontWeight: customer.isReminderDue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        customer.isDoubleSided ? Icons.hearing : Icons.hearing_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(context, customer),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerFormScreen(
                          customer: customer,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CustomerFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: Text('${customer.fullName} isimli müşteriyi silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await context.read<CustomerProvider>().deleteCustomer(customer.id!);
              
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${customer.fullName} silindi'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  final error = context.read<CustomerProvider>().error ?? 'Silme işlemi başarısız oldu';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
} 