import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/supabase_service.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;
  Customer? _selectedCustomer;
  String _searchQuery = '';

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Customer> get filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
    }).toList();
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('customers')
          .select()
          .order('name', ascending: true);

      _customers = response.map((data) => Customer.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching customers: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      final response = await supabase
          .from('customers')
          .insert(customer.toMap())
          .select()
          .single();

      _customers.add(Customer.fromMap(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding customer: $e');
      rethrow;
    }
  }

  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }
}
