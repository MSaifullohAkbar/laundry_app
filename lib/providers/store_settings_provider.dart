import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../models/store_settings.dart';

class StoreSettingsProvider extends ChangeNotifier {
  StoreSettings _settings = const StoreSettings();
  bool _isLoading = false;

  StoreSettings get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await supabase
          .from('store_settings')
          .select()
          .limit(1)
          .maybeSingle();

      if (response != null) {
        _settings = StoreSettings.fromMap(response);
      }
    } catch (e) {
      debugPrint('Error fetching store settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(StoreSettings newSettings) async {
    try {
      // Upsert: update if exists, insert if not
      await supabase.from('store_settings').upsert({
        'id': 1, // single row settings
        ...newSettings.toMap(),
      });
      _settings = newSettings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving store settings: $e');
      rethrow;
    }
  }
}
