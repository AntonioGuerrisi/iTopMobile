import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../models/ticket_log.dart';
import '../providers/auth_provider.dart';
import '../services/itop_api_service.dart';

/// Periodi di caricamento disponibili
enum TicketPeriod {
  last3Months('Ultimi 3 mesi', 90),
  last6Months('Ultimi 6 mesi', 180),
  lastYear('Ultimo anno', 365),
  all('Tutti', 0);

  final String label;
  final int days;
  const TicketPeriod(this.label, this.days);
}

/// Opzioni di ordinamento dei ticket
enum TicketSortOrder {
  openDateDesc('Data apertura ↓', 'start_date', false),
  openDateAsc('Data apertura ↑', 'start_date', true),
  lastUpdateDesc('Ultima modifica ↓', 'last_update', false),
  lastUpdateAsc('Ultima modifica ↑', 'last_update', true),
  priorityDesc('Priorità ↓', 'priority', false),
  refDesc('Riferimento ↓', 'ref', false),
  refAsc('Riferimento ↑', 'ref', true);

  final String label;
  final String field;
  final bool ascending;
  const TicketSortOrder(this.label, this.field, this.ascending);
}

/// Provider per la gestione dei ticket
class TicketProvider with ChangeNotifier {
  ITopApiService? _apiService;

  List<Ticket> _tickets = [];
  List<Ticket> _filteredTickets = [];
  Map<String, int> _statusCounts = {};
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _statusFilter = 'all';
  TicketPeriod _selectedPeriod = TicketPeriod.last3Months;
  TicketSortOrder _sortOrder = TicketSortOrder.openDateDesc;
  bool _myTicketsOnly = false;
  String? _currentUserFriendlyName;

  List<Ticket> get tickets => _filteredTickets.isEmpty &&
          _searchQuery.isEmpty &&
          _statusFilter == 'all' &&
          !_myTicketsOnly
      ? _tickets
      : _filteredTickets;
  Map<String, int> get statusCounts => _statusCounts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;
  TicketPeriod get selectedPeriod => _selectedPeriod;
  TicketSortOrder get sortOrder => _sortOrder;
  bool get myTicketsOnly => _myTicketsOnly;
  int get totalTickets => _tickets.length;

  /// Aggiorna il riferimento all'autenticazione
  void updateAuth(AuthProvider auth) {
    _apiService = auth.apiService;
    if (auth.isAuthenticated && auth.currentUser != null) {
      _currentUserFriendlyName =
          auth.currentUser!['contactid_friendlyname']?.toString();
    }
    if (!auth.isAuthenticated) {
      _tickets = [];
      _filteredTickets = [];
      _statusCounts = {};
      _currentUserFriendlyName = null;
      _myTicketsOnly = false;
    }
  }

  /// Carica i ticket da iTop in base al periodo selezionato
  Future<void> loadTickets({TicketPeriod? period}) async {
    if (_apiService == null) return;

    if (period != null) {
      _selectedPeriod = period;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? oqlFilter;
      if (_selectedPeriod != TicketPeriod.all) {
        final since =
            DateTime.now().subtract(Duration(days: _selectedPeriod.days));
        final sinceStr = DateFormat('yyyy-MM-dd').format(since);
        oqlFilter = 'SELECT UserRequest WHERE last_update >= "$sinceStr"';
      }

      final result = await _apiService!.getTickets(oqlFilter: oqlFilter);
      _tickets = _parseTickets(result);
      _applyFilters();

      // Conta per stato
      _statusCounts = {};
      for (final ticket in _tickets) {
        final status = ticket.status.toLowerCase();
        _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
      }
    } on ITopApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento dei ticket: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cambia il periodo e ricarica
  Future<void> changePeriod(TicketPeriod period) async {
    if (period == _selectedPeriod) return;
    await loadTickets(period: period);
  }

  /// Toggle filtro "I miei ticket"
  void toggleMyTickets() {
    _myTicketsOnly = !_myTicketsOnly;
    _applyFilters();
    notifyListeners();
  }

  /// Cerca ticket
  Future<void> searchTickets(String query) async {
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
      final result = await _apiService!.searchTickets(query);
      _filteredTickets = _parseTickets(result);
    } catch (e) {
      _errorMessage = 'Errore nella ricerca: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filtra per stato
  void filterByStatus(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// Applica i filtri correnti
  void _applyFilters() {
    if (_statusFilter == 'all' && _searchQuery.isEmpty && !_myTicketsOnly) {
      _filteredTickets = List.from(_tickets);
    } else {
      _filteredTickets = _tickets.where((ticket) {
        final matchesStatus = _statusFilter == 'all' ||
            ticket.status.toLowerCase() == _statusFilter.toLowerCase();
        final matchesSearch = _searchQuery.isEmpty ||
            ticket.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            ticket.ref.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesMine = !_myTicketsOnly ||
            (_currentUserFriendlyName != null &&
                ticket.agentName == _currentUserFriendlyName);
        return matchesStatus && matchesSearch && matchesMine;
      }).toList();
    }

    // Ricalcola i conteggi in base ai filtri attivi
    _statusCounts = {};
    final source = _myTicketsOnly ? _filteredTickets : _tickets;
    for (final ticket in source) {
      final status = ticket.status.toLowerCase();
      _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
    }
  }

  /// Recupera il dettaglio di un ticket
  Future<Ticket?> getTicketDetail(String ticketId) async {
    if (_apiService == null) return null;

    try {
      final result = await _apiService!.getTicketDetail(ticketId);
      final tickets = _parseTickets(result);
      return tickets.isNotEmpty ? tickets.first : null;
    } catch (e) {
      _errorMessage = 'Errore nel caricamento del dettaglio: $e';
      notifyListeners();
      return null;
    }
  }

  /// Recupera i log di un ticket
  Future<List<TicketLog>> getTicketLogs(String ticketId) async {
    if (_apiService == null) return [];

    try {
      final result = await _apiService!.getTicketLog(ticketId);
      final objects = result['objects'] as Map<String, dynamic>?;
      if (objects == null || objects.isEmpty) return [];

      final first = objects.values.first as Map<String, dynamic>;
      final fields = first['fields'] as Map<String, dynamic>? ?? {};

      final logs = <TicketLog>[];

      // Parsa il public_log
      final publicLog = fields['public_log'];
      if (publicLog is Map<String, dynamic>) {
        final entries = publicLog['entries'] as List<dynamic>?;
        if (entries != null) {
          for (final entry in entries) {
            if (entry is Map<String, dynamic>) {
              logs.add(TicketLog.fromJson(entry));
            }
          }
        }
      }

      return logs;
    } catch (e) {
      return [];
    }
  }

  /// Parsa la risposta JSON e restituisce una lista di Ticket
  List<Ticket> _parseTickets(Map<String, dynamic> result) {
    final objects = result['objects'] as Map<String, dynamic>?;
    if (objects == null) return [];

    final tickets = objects.entries.map((entry) {
      final key = entry.key.toString();
      // Estrai l'id numerico dalla chiave (es. "UserRequest::123")
      final id = key.contains('::') ? key.split('::').last : key;
      return Ticket.fromJson(id, entry.value as Map<String, dynamic>);
    }).toList();
    _sortTickets(tickets);
    return tickets;
  }

  /// Ordina la lista di ticket in base al criterio selezionato
  void _sortTickets(List<Ticket> list) {
    list.sort((a, b) {
      int result;
      switch (_sortOrder) {
        case TicketSortOrder.openDateDesc:
        case TicketSortOrder.openDateAsc:
          result = a.startDate.compareTo(b.startDate);
        case TicketSortOrder.lastUpdateDesc:
        case TicketSortOrder.lastUpdateAsc:
          result = a.lastUpdate.compareTo(b.lastUpdate);
        case TicketSortOrder.priorityDesc:
          result = _priorityValue(a.priority)
              .compareTo(_priorityValue(b.priority));
        case TicketSortOrder.refDesc:
        case TicketSortOrder.refAsc:
          result = a.ref.compareTo(b.ref);
      }
      return _sortOrder.ascending ? result : -result;
    });
  }

  /// Valore numerico per ordinamento priorità (1=critical, 4=low)
  static int _priorityValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical' || 'critica':
        return 1;
      case 'high' || 'alta':
        return 2;
      case 'medium' || 'media':
        return 3;
      case 'low' || 'bassa':
        return 4;
      default:
        return 5;
    }
  }

  /// Cambia l'ordinamento e riapplica ai ticket correnti
  void changeSortOrder(TicketSortOrder order) {
    if (order == _sortOrder) return;
    _sortOrder = order;
    _sortTickets(_tickets);
    _applyFilters();
    notifyListeners();
  }

  // ==================== AZIONI TICKET ====================

  /// Aggiunge una entry al log pubblico
  Future<bool> addPublicLog(String ticketId, String message) async {
    if (_apiService == null) return false;
    try {
      await _apiService!.addPublicLogEntry(ticketId, message);
      return true;
    } on ITopApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Aggiunge una entry al log privato
  Future<bool> addPrivateLog(String ticketId, String message) async {
    if (_apiService == null) return false;
    try {
      await _apiService!.addPrivateLogEntry(ticketId, message);
      return true;
    } on ITopApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Applica uno stimulus (transizione di stato)
  Future<bool> applyStimulus(
    String ticketId,
    String stimulus, {
    Map<String, dynamic>? fields,
  }) async {
    if (_apiService == null) return false;
    try {
      await _apiService!.applyStimulus(ticketId, stimulus, fields: fields);
      return true;
    } on ITopApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  /// Recupera i servizi disponibili
  Future<List<Map<String, dynamic>>> getServices({String? orgId}) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getServices(orgId: orgId);
    } catch (_) {
      return [];
    }
  }

  /// Recupera le sotto-categorie di un servizio
  Future<List<Map<String, dynamic>>> getServiceSubcategories(
      String serviceId) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getServiceSubcategories(serviceId);
    } catch (_) {
      return [];
    }
  }

  /// Recupera la lista dei team
  Future<List<Map<String, dynamic>>> getTeams() async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getTeams();
    } catch (_) {
      return [];
    }
  }

  /// Recupera i membri di un team
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getTeamMembers(teamId);
    } catch (_) {
      return [];
    }
  }

  /// Reset del provider
  void reset() {
    _tickets = [];
    _filteredTickets = [];
    _statusCounts = {};
    _searchQuery = '';
    _statusFilter = 'all';
    _sortOrder = TicketSortOrder.openDateDesc;
    _myTicketsOnly = false;
    _errorMessage = null;
    notifyListeners();
  }
}
