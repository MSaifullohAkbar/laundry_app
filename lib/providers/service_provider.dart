import 'package:flutter/foundation.dart';
import '../models/service.dart';
import '../services/supabase_service.dart';

class ServiceProvider extends ChangeNotifier {
  List<ServiceType> _services = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<ServiceType> get services => _services;
  bool get isLoading => _isLoading;

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

  Future<void> fetchServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('services')
          .select()
          .eq('is_active', true)
          .order('name', ascending: true);

      _services = response.map((data) => ServiceType.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error fetching services: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addService(ServiceType service) async {
    try {
      final response = await supabase.from('services').insert({
        'name': service.name,
        'category': service.category,
        'price': service.price,
        'unit': service.unit,
        'include_wash': service.includeWash,
        'include_dry': service.includeDry,
        'include_iron': service.includeIron,
        'image_url': service.imageUrl,
        'is_premium': service.isPremium,
        'is_express': service.isExpress,
        'duration_hours': service.durationHours,
        'description': service.description,
      }).select().single();

      _services.add(ServiceType.fromMap(response));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding service: $e');
      rethrow;
    }
  }

  Future<void> updateService(String id, ServiceType service) async {
    try {
      final response = await supabase.from('services').update({
        'name': service.name,
        'category': service.category,
        'price': service.price,
        'unit': service.unit,
        'include_wash': service.includeWash,
        'include_dry': service.includeDry,
        'include_iron': service.includeIron,
        'image_url': service.imageUrl,
        'is_premium': service.isPremium,
        'is_express': service.isExpress,
        'duration_hours': service.durationHours,
        'description': service.description,
      }).eq('id', id).select().single();

      final index = _services.indexWhere((s) => s.id == id);
      if (index != -1) {
        _services[index] = ServiceType.fromMap(response);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating service: $e');
      rethrow;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await supabase.from('services').update({'is_active': false}).eq('id', id);
      _services.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting service: $e');
      rethrow;
    }
  }
}
