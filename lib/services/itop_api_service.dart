import 'dart:convert';
import 'package:http/http.dart' as http;
import '../l10n/app_strings.dart';

/// Service for communicating with iTop REST APIs
class ITopApiService {
  final String baseUrl;
  final String username;
  final String password;

  /// iTop REST API version
  static const String apiVersion = '1.3';

  ITopApiService({
    required this.baseUrl,
    required this.username,
    required this.password,
  }) {
    if (!baseUrl.startsWith('https://')) {
      throw ArgumentError(
        AppStrings.insecureConnection,
      );
    }
  }

  /// iTop REST endpoint
  String get _restEndpoint => '$baseUrl/webservices/rest.php';

  /// Sanitizes a string for use in OQL queries (prevents OQL injection)
  static String _escapeOqlString(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll("'", "\\'")
        .replaceAll('\n', ' ')
        .replaceAll('\r', '');
  }

  /// Validates that a value is a valid numeric ID
  static String _validateNumericId(String id) {
    if (!RegExp(r'^\d+$').hasMatch(id)) {
      throw ArgumentError('Invalid ID: must be numeric.');
    }
    return id;
  }

  /// Validates that an iTop class name contains only alphanumeric characters
  static String _validateClassName(String className) {
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(className)) {
      throw ArgumentError('Invalid class name: $className');
    }
    return className;
  }

  /// Executes a REST call to the iTop API
  Future<Map<String, dynamic>> _callApi({
    required String operation,
    required Map<String, dynamic> data,
  }) async {
    final jsonData = {
      'operation': operation,
      ...data,
    };

    try {
      final response = await http.post(
        Uri.parse('$_restEndpoint?version=$apiVersion'),
        body: {
          'auth_user': username,
          'auth_pwd': password,
          'json_data': jsonEncode(jsonData),
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw ITopApiException(
          'HTTP error ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (result['code'] != null && result['code'] != 0) {
        throw ITopApiException(
          result['message']?.toString() ?? AppStrings.apiUnknownError,
          code: result['code'] as int?,
        );
      }

      return result;
    } on ITopApiException {
      rethrow;
    } catch (e) {
      throw ITopApiException('${AppStrings.connectionError} $e');
    }
  }

  /// Verifies credentials by executing a lightweight query
  Future<bool> testLogin() async {
    try {
      await _callApi(
        operation: 'core/get',
        data: {
          'class': 'Person',
          'key': 'SELECT Person WHERE email LIKE "%"',
          'output_fields': 'friendlyname',
          'limit': '1',
        },
      );
      return true;
    } on ITopApiException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Retrieves the current user (Person linked to the user)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final result = await _callApi(
        operation: 'core/get',
        data: {
          'class': 'UserLocal',
          'key':
              'SELECT UserLocal WHERE login = "${_escapeOqlString(username)}"',
          'output_fields': 'login,contactid,contactid_friendlyname',
        },
      );
      final objects = result['objects'] as Map<String, dynamic>?;
      if (objects != null && objects.isNotEmpty) {
        final first = objects.values.first as Map<String, dynamic>;
        return first['fields'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================== TICKET ====================

  /// Retrieves all tickets (UserRequest)
  Future<Map<String, dynamic>> getTickets({
    String? oqlFilter,
    String outputFields =
        'ref,title,description,status,priority,urgency,impact,'
            'caller_id_friendlyname,org_id_friendlyname,'
            'team_id_friendlyname,agent_id_friendlyname,'
            'service_id,service_id_friendlyname,'
            'servicesubcategory_id_friendlyname,'
            'start_date,last_update,close_date,origin',
    int? limit,
    int? page,
  }) async {
    String oql = oqlFilter ?? 'SELECT UserRequest';

    final data = <String, dynamic>{
      'class': 'UserRequest',
      'key': oql,
      'output_fields': outputFields,
    };

    if (limit != null) {
      data['limit'] = limit.toString();
    }
    if (page != null && limit != null) {
      data['page'] = page.toString();
    }

    return await _callApi(operation: 'core/get', data: data);
  }

  /// Retrieves a single ticket with full details
  Future<Map<String, dynamic>> getTicketDetail(String ticketId) async {
    return await _callApi(
      operation: 'core/get',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'output_fields': '*',
      },
    );
  }

  /// Retrieves a ticket log (public_log / private_log)
  Future<Map<String, dynamic>> getTicketLog(String ticketId) async {
    return await _callApi(
      operation: 'core/get',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'output_fields': 'public_log,private_log',
      },
    );
  }

  /// Retrieves the ticket activity history from CMDBChangeOp subclasses
  Future<List<Map<String, dynamic>>> getTicketHistory(String ticketId) async {
    final safeId = _validateNumericId(ticketId);
    final oqlWhere =
        'WHERE objclass = \'UserRequest\' AND objkey = \'$safeId\'';

    // Executes each query in a fault-tolerant way
    Future<Map<String, dynamic>> _safeCall(Map<String, dynamic> data) async {
      try {
        return await _callApi(operation: 'core/get', data: data);
      } catch (_) {
        return {'objects': null};
      }
    }

    // Queries subclasses that contain useful information
    final futures = <Future<Map<String, dynamic>>>[
      _safeCall({
        'class': 'CMDBChangeOpCreate',
        'key': 'SELECT CMDBChangeOpCreate $oqlWhere',
        'output_fields': 'date,userinfo',
      }),
      _safeCall({
        'class': 'CMDBChangeOpSetAttributeScalar',
        'key': 'SELECT CMDBChangeOpSetAttributeScalar $oqlWhere',
        'output_fields': 'date,userinfo,attcode,oldvalue,newvalue',
      }),
      _safeCall({
        'class': 'CMDBChangeOpSetAttributeHTML',
        'key': 'SELECT CMDBChangeOpSetAttributeHTML $oqlWhere',
        'output_fields': 'date,userinfo,attcode',
      }),
      _safeCall({
        'class': 'CMDBChangeOpSetAttributeText',
        'key': 'SELECT CMDBChangeOpSetAttributeText $oqlWhere',
        'output_fields': 'date,userinfo,attcode',
      }),
      _safeCall({
        'class': 'CMDBChangeOpSetAttributeLongText',
        'key': 'SELECT CMDBChangeOpSetAttributeLongText $oqlWhere',
        'output_fields': 'date,userinfo,attcode',
      }),
      _safeCall({
        'class': 'CMDBChangeOpSetAttributeBlob',
        'key': 'SELECT CMDBChangeOpSetAttributeBlob $oqlWhere',
        'output_fields': 'date,userinfo,attcode,filename',
      }),
      _safeCall({
        'class': 'CMDBChangeOpPlugin',
        'key': 'SELECT CMDBChangeOpPlugin $oqlWhere',
        'output_fields': 'date,userinfo,description',
      }),
    ];

    final results = await Future.wait(futures, eagerError: false);
    final allRecords = <Map<String, dynamic>>[];

    for (final result in results) {
      final objects = result['objects'] as Map<String, dynamic>?;
      if (objects != null) {
        for (final entry in objects.values) {
          final map = entry as Map<String, dynamic>;
          // Usa finalclass se disponibile, altrimenti class
          final cls = (map['fields'] as Map<String, dynamic>?)?['finalclass']
                  ?.toString() ??
              map['class']?.toString() ??
              '';
          allRecords.add({
            'class': cls,
            'fields': map['fields'] as Map<String, dynamic>? ?? {},
          });
        }
      }
    }

    return allRecords;
  }

  /// Resolves a list of IDs to readable names for a given iTop class
  Future<Map<String, String>> resolveObjectNames(
      String className, Set<String> ids) async {
    if (ids.isEmpty) return {};
    final safeClass = _validateClassName(className);
    // Filtra '0' e vuoti, validando che siano numerici
    final validIds = ids.where((id) => id.isNotEmpty && id != '0').toList();
    if (validIds.isEmpty) return {};
    for (final id in validIds) {
      _validateNumericId(id);
    }

    try {
      final idList = validIds.join(',');
      final result = await _callApi(
        operation: 'core/get',
        data: {
          'class': safeClass,
          'key': 'SELECT $safeClass WHERE id IN ($idList)',
          'output_fields': 'friendlyname',
        },
      );
      final objects = result['objects'] as Map<String, dynamic>?;
      if (objects == null) return {};

      final nameMap = <String, String>{};
      for (final entry in objects.entries) {
        final key = entry.key.toString();
        final id = key.contains('::') ? key.split('::').last : key;
        final fields = (entry.value as Map<String, dynamic>)['fields']
                as Map<String, dynamic>? ??
            {};
        nameMap[id] = fields['friendlyname']?.toString() ?? id;
      }
      return nameMap;
    } catch (_) {
      return {};
    }
  }

  /// Searches tickets by text
  Future<Map<String, dynamic>> searchTickets(String searchText) async {
    final escapedText = _escapeOqlString(searchText);
    return getTickets(
      oqlFilter:
          'SELECT UserRequest WHERE title LIKE "%$escapedText%" OR ref LIKE "%$escapedText%" OR description LIKE "%$escapedText%"',
    );
  }

  /// Retrieves tickets filtered by status
  Future<Map<String, dynamic>> getTicketsByStatus(String status) async {
    return getTickets(
      oqlFilter:
          'SELECT UserRequest WHERE status = "${_escapeOqlString(status)}"',
    );
  }

  /// Retrieves the ticket count by status
  Future<Map<String, int>> getTicketCountsByStatus() async {
    final statuses = ['new', 'assigned', 'pending', 'resolved', 'closed'];
    final counts = <String, int>{};

    for (final status in statuses) {
      try {
        final result = await getTicketsByStatus(status);
        final objects = result['objects'] as Map<String, dynamic>?;
        counts[status] = objects?.length ?? 0;
      } catch (_) {
        counts[status] = 0;
      }
    }

    return counts;
  }

  // ==================== INCIDENT ====================

  // ==================== TICKET UPDATE ====================

  /// Adds a public log entry for a ticket
  Future<Map<String, dynamic>> addPublicLogEntry(
      String ticketId, String message) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'comment': 'Log pubblico aggiunto da iTopMobile',
        'output_fields': 'ref,status,public_log',
        'fields': {
          'public_log': {
            'add_item': {
              'message': message,
              'format': 'text',
            },
          },
        },
      },
    );
  }

  /// Adds a private log entry for a ticket
  Future<Map<String, dynamic>> addPrivateLogEntry(
      String ticketId, String message) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'comment': 'Log privato aggiunto da iTopMobile',
        'output_fields': 'ref,status,private_log',
        'fields': {
          'private_log': {
            'add_item': {
              'message': message,
              'format': 'text',
            },
          },
        },
      },
    );
  }

  /// Applies a stimulus (state transition) to a ticket
  Future<Map<String, dynamic>> applyStimulus(
    String ticketId,
    String stimulus, {
    Map<String, dynamic>? fields,
  }) async {
    final data = <String, dynamic>{
      'class': 'UserRequest',
      'key': ticketId,
      'stimulus': stimulus,
      'comment': 'Transizione eseguita da iTopMobile',
      'output_fields': 'ref,status',
      'fields': fields ?? {},
    };
    return await _callApi(operation: 'core/apply_stimulus', data: data);
  }

  /// Updates ticket fields (generic core/update)
  Future<Map<String, dynamic>> updateTicket(
    String ticketId,
    Map<String, dynamic> fields,
  ) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'comment': 'Aggiornamento da iTopMobile',
        'output_fields': 'ref,status',
        'fields': fields,
      },
    );
  }

  /// Retrieves the list of available services
  Future<List<Map<String, dynamic>>> getServices({String? orgId}) async {
    String oql = 'SELECT Service';
    if (orgId != null && orgId.isNotEmpty) {
      final safeOrgId = _validateNumericId(orgId);
      oql = 'SELECT Service WHERE org_id = "$safeOrgId"';
    }
    final result = await _callApi(
      operation: 'core/get',
      data: {
        'class': 'Service',
        'key': oql,
        'output_fields': 'name',
      },
    );
    return _parseObjectList(result);
  }

  /// Retrieves service subcategories
  Future<List<Map<String, dynamic>>> getServiceSubcategories(
      String serviceId) async {
    final safeId = _validateNumericId(serviceId);
    final result = await _callApi(
      operation: 'core/get',
      data: {
        'class': 'ServiceSubcategory',
        'key': 'SELECT ServiceSubcategory WHERE service_id = "$safeId"',
        'output_fields': 'name',
      },
    );
    return _parseObjectList(result);
  }

  /// Retrieves the team list
  Future<List<Map<String, dynamic>>> getTeams() async {
    final result = await _callApi(
      operation: 'core/get',
      data: {
        'class': 'Team',
        'key': 'SELECT Team',
        'output_fields': 'name',
      },
    );
    return _parseObjectList(result);
  }

  /// Retrieves team members (Person) for a team
  Future<List<Map<String, dynamic>>> getTeamMembers(String teamId) async {
    final safeId = _validateNumericId(teamId);
    final result = await _callApi(
      operation: 'core/get',
      data: {
        'class': 'lnkPersonToTeam',
        'key': 'SELECT lnkPersonToTeam WHERE team_id = "$safeId"',
        'output_fields': 'person_id,person_id_friendlyname',
      },
    );
    final objects = result['objects'] as Map<String, dynamic>?;
    if (objects == null) return [];
    final members = <Map<String, dynamic>>[];
    final seenIds = <String>{};
    for (final e in objects.entries) {
      final fields = (e.value as Map<String, dynamic>)['fields']
              as Map<String, dynamic>? ??
          {};
      final personId = fields['person_id']?.toString() ?? '';
      final name = fields['person_id_friendlyname']?.toString() ?? '';
      if (personId.isNotEmpty && personId != '0' && seenIds.add(personId)) {
        members.add({'id': personId, 'name': name});
      }
    }
    members
        .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    return members;
  }

  /// Parses an iTop response into a list of {id, name}
  List<Map<String, dynamic>> _parseObjectList(Map<String, dynamic> result) {
    final objects = result['objects'] as Map<String, dynamic>?;
    if (objects == null) return [];
    return objects.entries.map((e) {
      final key = e.key.toString();
      final id = key.contains('::') ? key.split('::').last : key;
      final fields = (e.value as Map<String, dynamic>)['fields']
              as Map<String, dynamic>? ??
          {};
      return {'id': id, 'name': fields['name']?.toString() ?? ''};
    }).toList()
      ..sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
  }

  // ==================== INCIDENT ====================

  /// Retrieves all incidents
  Future<Map<String, dynamic>> getIncidents({
    String? oqlFilter,
    String outputFields =
        'ref,title,description,status,priority,urgency,impact,'
            'caller_id_friendlyname,org_id_friendlyname,'
            'team_id_friendlyname,agent_id_friendlyname,'
            'service_id,service_id_friendlyname,'
            'servicesubcategory_id_friendlyname,'
            'start_date,last_update,close_date,origin',
  }) async {
    String oql = oqlFilter ?? 'SELECT Incident';

    return await _callApi(
      operation: 'core/get',
      data: {
        'class': 'Incident',
        'key': oql,
        'output_fields': outputFields,
      },
    );
  }

  // ==================== ASSET ====================

  /// Common fields for all FunctionalCI objects
  static const String _baseCIFields = 'name,org_id_friendlyname,description,'
      'business_criticity,move2production,finalclass';

  /// Additional fields available for PhysicalDevice and subclasses
  static const String _physicalDeviceFields =
      ',status,serialnumber,asset_number,'
      'brand_id_friendlyname,model_id_friendlyname,'
      'location_id_friendlyname';

  /// Classes that inherit from PhysicalDevice and include the status field
  static const Set<String> physicalDeviceClasses = {
    'PhysicalDevice',
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
    'SANSwitch',
    'TapeLibrary',
    'Rack',
    'Enclosure',
    'PDU',
    'PowerSource',
  };

  /// Retrieves all assets (FunctionalCI)
  Future<Map<String, dynamic>> getAssets({
    String? oqlFilter,
    String? className,
    String? outputFields,
  }) async {
    final cls = _validateClassName(className ?? 'FunctionalCI');
    String oql = oqlFilter ?? 'SELECT $cls';

    // Use extended fields only for classes that support them
    final fields = outputFields ??
        (physicalDeviceClasses.contains(cls)
            ? '$_baseCIFields$_physicalDeviceFields'
            : _baseCIFields);

    return await _callApi(
      operation: 'core/get',
      data: {
        'class': cls,
        'key': oql,
        'output_fields': fields,
      },
    );
  }

  /// Retrieves a single asset with full details
  Future<Map<String, dynamic>> getAssetDetail(
      String assetId, String className) async {
    return await _callApi(
      operation: 'core/get',
      data: {
        'class': className,
        'key': assetId,
        'output_fields': '*',
      },
    );
  }

  /// Searches assets by text
  Future<Map<String, dynamic>> searchAssets(String searchText) async {
    final escapedText = _escapeOqlString(searchText);
    return getAssets(
      oqlFilter:
          'SELECT FunctionalCI WHERE name LIKE "%$escapedText%" OR description LIKE "%$escapedText%"',
      outputFields: _baseCIFields,
    );
  }

  /// Retrieves assets by class (Server, PC, etc.)
  Future<Map<String, dynamic>> getAssetsByClass(String className) async {
    return getAssets(className: className);
  }
}

/// Eccezione personalizzata per errori API iTop
class ITopApiException implements Exception {
  final String message;
  final int? statusCode;
  final int? code;

  ITopApiException(this.message, {this.statusCode, this.code});

  @override
  String toString() => 'ITopApiException: $message';
}
