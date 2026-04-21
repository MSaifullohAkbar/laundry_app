import 'package:flutter/foundation.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final List<Customer> _customers = List.from(dummyCustomers);
  Customer? _selectedCustomer;
  String _searchQuery = '';

  List<Customer> get customers => _customers;
  Customer? get selectedCustomer => _selectedCustomer;
  String get searchQuery => _searchQuery;

  List<Customer> get filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.phone.contains(_searchQuery);
    }).toList();
  }

  void setSelectedCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void clearSelection() {
    _selectedCustomer = null;
    notifyListeners();
  }
}
