import 'package:flutter/foundation.dart';
import '../models/service.dart';

class ServiceProvider extends ChangeNotifier {
  final List<ServiceType> _services = List.from(dummyServices);
  String _searchQuery = '';

  List<ServiceType> get services => _services;

  List<ServiceType> get filteredServices {
    if (_searchQuery.isEmpty) return _services;
    return _services.where((s) {
      return s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<ServiceType> get kiloanServices =>
      filteredServices.where((s) => s.category == 'kiloan').toList();

  List<ServiceType> get satuanServices =>
      filteredServices.where((s) => s.category == 'satuan').toList();

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addService(ServiceType service) {
    _services.add(service);
    notifyListeners();
  }
}
