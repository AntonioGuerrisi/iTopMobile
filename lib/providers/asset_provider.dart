import 'package:flutter/foundation.dart';
import '../models/asset.dart';
import '../providers/auth_provider.dart';
import '../services/itop_api_service.dart';

/// Provider per la gestione degli asset
class AssetProvider with ChangeNotifier {
  ITopApiService? _apiService;

  List<Asset> _assets = [];
  List<Asset> _filteredAssets = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _classFilter = 'all';

  /// Classi di asset disponibili in iTop
  static const List<String> assetClasses = [
    'Server',
    'VirtualMachine',
    'PC',
    'Laptop',
    'Printer',
    'Phone',
    'MobilePhone',
    'Tablet',
    'NetworkDevice',
    'StorageSystem',
    'NAS',
    'Rack',
  ];

  List<Asset> get assets => _filteredAssets.isEmpty && _searchQuery.isEmpty && _classFilter == 'all'
      ? _assets
      : _filteredAssets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get classFilter => _classFilter;
  int get totalAssets => _assets.length;

  /// Aggiorna il riferimento all'autenticazione
  void updateAuth(AuthProvider auth) {
    _apiService = auth.apiService;
    if (!auth.isAuthenticated) {
      _assets = [];
      _filteredAssets = [];
    }
  }

  /// Carica tutti gli asset da iTop
  Future<void> loadAssets() async {
    if (_apiService == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _apiService!.getAssets();
      _assets = _parseAssets(result);
      _applyFilters();
    } on ITopApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento degli asset: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cerca asset
  Future<void> searchAssets(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _applyFilters();
      notifyListeners();
      return;
    }

    if (_apiService == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService!.searchAssets(query);
      _filteredAssets = _parseAssets(result);
    } catch (e) {
      _errorMessage = 'Errore nella ricerca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra per classe
  void filterByClass(String className) {
    _classFilter = className;
    _applyFilters();
    notifyListeners();
  }

  /// Applica i filtri correnti
  void _applyFilters() {
    if (_classFilter == 'all' && _searchQuery.isEmpty) {
      _filteredAssets = List.from(_assets);
    } else {
      _filteredAssets = _assets.where((asset) {
        final matchesClass = _classFilter == 'all' ||
            asset.className.toLowerCase() == _classFilter.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty ||
            asset.name.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesClass && matchesSearch;
      }).toList();
    }
  }

  /// Recupera il dettaglio di un asset
  Future<Asset?> getAssetDetail(String assetId, String className) async {
    if (_apiService == null) return null;

    try {
      final result = await _apiService!.getAssetDetail(assetId, className);
      final assets = _parseAssets(result);
      return assets.isNotEmpty ? assets.first : null;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento del dettaglio: $e';
      notifyListeners();
      return null;
    }
  }

  /// Parsa la risposta JSON e restituisce una lista di Asset
  List<Asset> _parseAssets(Map<String, dynamic> result) {
    final objects = result['objects'] as Map<String, dynamic>?;
    if (objects == null) return [];

    return objects.entries.map((entry) {
      final key = entry.key.toString();
      final id = key.contains('::') ? key.split('::').last : key;
      return Asset.fromJson(id, entry.value as Map<String, dynamic>);
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Reset del provider
  void reset() {
    _assets = [];
    _filteredAssets = [];
    _searchQuery = '';
    _classFilter = 'all';
    _errorMessage = null;
    notifyListeners();
  }
}
