import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../models/ticket_log.dart';
import '../providers/auth_provider.dart';
import '../services/itop_api_service.dart';

/// Available ticket load periods
enum TicketPeriod {
  last3Months('Last 3 months', 90),
  last6Months('Last 6 months', 180),
  lastYear('Last year', 365),
  all('All', 0);

  final String label;
  final int days;
  const TicketPeriod(this.label, this.days);
}

/// Ticket sort order options
enum TicketSortOrder {
  openDateDesc('Open date ↓', 'start_date', false),
  openDateAsc('Open date ↑', 'start_date', true),
  lastUpdateDesc('Last update ↓', 'last_update', false),
  lastUpdateAsc('Last update ↑', 'last_update', true),
  priorityDesc('Priority ↓', 'priority', false),
  refDesc('Reference ↓', 'ref', false),
  refAsc('Reference ↑', 'ref', true);

  final String label;
  final String field;
  final bool ascending;
  const TicketSortOrder(this.label, this.field, this.ascending);
}

/// Provider for ticket management
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

  /// Updates the authentication reference
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

  /// Loads tickets from iTop based on the selected period
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
      _errorMessage = 'Error loading tickets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Changes the period and reloads
  Future<void> changePeriod(TicketPeriod period) async {
    if (period == _selectedPeriod) return;
    await loadTickets(period: period);
  }

  /// Toggles the "my tickets" filter
  void toggleMyTickets() {
    _myTicketsOnly = !_myTicketsOnly;
    _applyFilters();
    notifyListeners();
  }

  /// Searches tickets
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
      _errorMessage = 'Error searching tickets: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters tickets by status
  void filterByStatus(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  /// Applies the current filters
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

    // Recalculate counts based on active filters
    _statusCounts = {};
    final source = _myTicketsOnly ? _filteredTickets : _tickets;
    for (final ticket in source) {
      final status = ticket.status.toLowerCase();
      _statusCounts[status] = (_statusCounts[status] ?? 0) + 1;
    }
  }

  /// Retrieves the detail of a ticket
  Future<Ticket?> getTicketDetail(String ticketId) async {
    if (_apiService == null) return null;

    try {
      final result = await _apiService!.getTicketDetail(ticketId);
      final tickets = _parseTickets(result);
      return tickets.isNotEmpty ? tickets.first : null;
    } catch (e) {
      _errorMessage = 'Error loading ticket details: $e';
      notifyListeners();
      return null;
    }
  }

  /// Retrieves ticket logs (public, private, and activity)
  Future<List<TicketLog>> getTicketLogs(String ticketId) async {
    if (_apiService == null) return [];

    try {
      final logResult = await _apiService!.getTicketLog(ticketId);

      final logs = <TicketLog>[];

      // Parse public_log and private_log from the log result
      final logObjects = logResult['objects'] as Map<String, dynamic>?;
      if (logObjects != null && logObjects.isNotEmpty) {
        final first = logObjects.values.first as Map<String, dynamic>;
        final fields = first['fields'] as Map<String, dynamic>? ?? {};

        // Parse the public_log
        final publicLog = fields['public_log'];
        if (publicLog is Map<String, dynamic>) {
          final entries = publicLog['entries'] as List<dynamic>?;
          if (entries != null) {
            for (final entry in entries) {
              if (entry is Map<String, dynamic>) {
                logs.add(TicketLog.fromJson(entry, type: LogType.public));
              }
            }
          }
        }

        // Parse the private_log
        final privateLog = fields['private_log'];
        if (privateLog is Map<String, dynamic>) {
          final entries = privateLog['entries'] as List<dynamic>?;
          if (entries != null) {
            for (final entry in entries) {
              if (entry is Map<String, dynamic>) {
                logs.add(TicketLog.fromJson(entry, type: LogType.private_));
              }
            }
          }
        }
      }

      // Parse activities (CMDBChangeOp) — fault-tolerant
      try {
        final historyRecords = await _apiService!.getTicketHistory(ticketId);

        // Map attcode → iTop class to resolve IDs
        const attcodeToClass = <String, String>{
          'agent_id': 'Person',
          'caller_id': 'Person',
          'team_id': 'Team',
          'org_id': 'Organization',
          'service_id': 'Service',
          'servicesubcategory_id': 'ServiceSubcategory',
        };

        // Gather all IDs to resolve, grouped by class
        final idsToResolve = <String, Set<String>>{};
        for (final record in historyRecords) {
          if (record['class'] == 'CMDBChangeOpSetAttributeScalar') {
            final fields = record['fields'] as Map<String, dynamic>? ?? {};
            final attcode = fields['attcode']?.toString() ?? '';
            final targetClass = attcodeToClass[attcode];
            if (targetClass != null) {
              idsToResolve.putIfAbsent(targetClass, () => <String>{});
              final oldVal = fields['oldvalue']?.toString() ?? '';
              final newVal = fields['newvalue']?.toString() ?? '';
              if (oldVal.isNotEmpty && oldVal != '0') {
                idsToResolve[targetClass]!.add(oldVal);
              }
              if (newVal.isNotEmpty && newVal != '0') {
                idsToResolve[targetClass]!.add(newVal);
              }
            }
          }
        }

        // Resolve names in batch (one call per class)
        final resolvedNames = <String, String>{};
        final resolveFutures = idsToResolve.entries.map((e) async {
          final names = await _apiService!.resolveObjectNames(e.key, e.value);
          names.forEach((id, name) => resolvedNames[id] = name);
        });
        await Future.wait(resolveFutures);

        for (final record in historyRecords) {
          final changeClass = record['class'] as String? ?? '';
          final fields = record['fields'] as Map<String, dynamic>? ?? {};
          logs.add(TicketLog.fromChangeOp(changeClass, fields, resolvedNames));
        }
      } catch (_) {
        // If CMDBChangeOp is unavailable, ignore and show only logs
      }

      // Sort all logs by date descending
      logs.sort((a, b) => b.date.compareTo(a.date));

      return logs;
    } catch (e) {
      return [];
    }
  }

  /// Parses the JSON response and returns a list of tickets
  List<Ticket> _parseTickets(Map<String, dynamic> result) {
    final objects = result['objects'] as Map<String, dynamic>?;
    if (objects == null) return [];

    final tickets = objects.entries.map((entry) {
      final key = entry.key.toString();
      // Extract numeric id from the key (e.g. "UserRequest::123")
      final id = key.contains('::') ? key.split('::').last : key;
      return Ticket.fromJson(id, entry.value as Map<String, dynamic>);
    }).toList();
    _sortTickets(tickets);
    return tickets;
  }

  /// Sorts the ticket list by the selected criterion
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
          result =
              _priorityValue(a.priority).compareTo(_priorityValue(b.priority));
        case TicketSortOrder.refDesc:
        case TicketSortOrder.refAsc:
          result = a.ref.compareTo(b.ref);
      }
      return _sortOrder.ascending ? result : -result;
    });
  }

  /// Numeric value for priority sorting (1=critical, 4=low)
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

  /// Changes the sort order and reapplies it to the current tickets
  void changeSortOrder(TicketSortOrder order) {
    if (order == _sortOrder) return;
    _sortOrder = order;
    _sortTickets(_tickets);
    _applyFilters();
    notifyListeners();
  }

  // ==================== AZIONI TICKET ====================

  /// Adds a public log entry
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

  /// Adds a private log entry
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

  /// Applies a stimulus (state transition)
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

  /// Retrieves available services
  Future<List<Map<String, dynamic>>> getServices({String? orgId}) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getServices(orgId: orgId);
    } catch (_) {
      return [];
    }
  }

  /// Retrieves service subcategories
  Future<List<Map<String, dynamic>>> getServiceSubcategories(
      String serviceId) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getServiceSubcategories(serviceId);
    } catch (_) {
      return [];
    }
  }

  /// Retrieves the team list
  Future<List<Map<String, dynamic>>> getTeams() async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getTeams();
    } catch (_) {
      return [];
    }
  }

  /// Retrieves team members
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    if (_apiService == null) return [];
    try {
      return await _apiService!.getTeamMembers(teamId);
    } catch (_) {
      return [];
    }
  }

  /// Resets the provider
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
