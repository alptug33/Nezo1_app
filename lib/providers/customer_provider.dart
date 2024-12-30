import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/database_helper.dart';

class CustomerProvider with ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  String? _error;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCustomers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _customers = await DatabaseHelper.instance.readAllCustomers();
    } catch (e) {
      print('Error loading customers: $e');
      _error = 'Müşteriler yüklenirken hata oluştu';
      _customers = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCustomer(Customer customer) async {
    _error = null;
    try {
      await DatabaseHelper.instance.create(customer);
      await loadCustomers();
    } catch (e) {
      print('Error adding customer: $e');
      _error = 'Müşteri eklenirken hata oluştu';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    _error = null;
    try {
      final result = await DatabaseHelper.instance.update(customer);
      if (result > 0) {
        await loadCustomers();
      } else {
        _error = 'Müşteri güncellenemedi';
        notifyListeners();
      }
    } catch (e) {
      print('Error updating customer: $e');
      _error = 'Müşteri güncellenirken hata oluştu';
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> deleteCustomer(int id) async {
    _error = null;
    try {
      // Önce müşteriyi bul
      final customerToDelete = _customers.firstWhere((c) => c.id == id);
      
      // Veritabanından sil
      final result = await DatabaseHelper.instance.delete(id);
      
      if (result > 0) {
        // Başarılı silme işleminden sonra listeyi güncelle
        _customers.removeWhere((c) => c.id == id);
        notifyListeners();
        return true;
      } else {
        _error = 'Müşteri silinemedi';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('Error deleting customer: $e');
      _error = 'Müşteri silinirken hata oluştu';
      notifyListeners();
      return false;
    }
  }

  Future<void> resetDatabase() async {
    _error = null;
    try {
      await DatabaseHelper.instance.deleteDatabase();
      _customers = [];
      notifyListeners();
    } catch (e) {
      print('Error resetting database: $e');
      _error = 'Veritabanı sıfırlanırken hata oluştu';
      notifyListeners();
    }
  }
} 