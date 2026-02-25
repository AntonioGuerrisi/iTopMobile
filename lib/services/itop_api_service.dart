import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servizio per comunicare con le REST API di iTop
class ITopApiService {
  final String baseUrl;
  final String username;
  final String password;

  /// Versione dell'API REST di iTop
  static const String apiVersion = '1.3';

  ITopApiService({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  /// Endpoint REST di iTop
  String get _restEndpoint => '$baseUrl/webservices/rest.php';

  /// Esegue una chiamata REST all'API di iTop
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
          'Errore HTTP ${response.statusCode}: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      final result = jsonDecode(response.body) as Map<String, dynamic>;

      if (result['code'] != null && result['code'] != 0) {
        throw ITopApiException(
          result['message']?.toString() ?? 'Errore sconosciuto dall\'API iTop',
          code: result['code'] as int?,
        );
      }

      return result;
    } on ITopApiException {
      rethrow;
    } catch (e) {
      throw ITopApiException('Errore di connessione: $e');
    }
  }

  /// Verifica le credenziali tentando una query leggera
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

  /// Recupera l'utente corrente (Person collegata all'utente)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final result = await _callApi(
        operation: 'core/get',
        data: {
          'class': 'UserLocal',
          'key': 'SELECT UserLocal WHERE login = "$username"',
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

  /// Recupera tutti i ticket (UserRequest)
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

  /// Recupera un singolo ticket con tutti i dettagli
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

  /// Recupera il log di un ticket (public_log / private_log)
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

  /// Cerca ticket per testo
  Future<Map<String, dynamic>> searchTickets(String searchText) async {
    final escapedText = searchText.replaceAll('"', '\\"');
    return getTickets(
      oqlFilter:
          'SELECT UserRequest WHERE title LIKE "%$escapedText%" OR ref LIKE "%$escapedText%" OR description LIKE "%$escapedText%"',
    );
  }

  /// Recupera ticket filtrati per stato
  Future<Map<String, dynamic>> getTicketsByStatus(String status) async {
    return getTickets(
      oqlFilter: 'SELECT UserRequest WHERE status = "$status"',
    );
  }

  /// Recupera il conteggio dei ticket per stato
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

  /// Aggiunge un'entry al log pubblico di un ticket
  Future<Map<String, dynamic>> addPublicLogEntry(
      String ticketId, String message) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
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

  /// Aggiunge un'entry al log privato di un ticket
  Future<Map<String, dynamic>> addPrivateLogEntry(
      String ticketId, String message) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
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

  /// Applica uno stimulus (transizione di stato) a un ticket
  Future<Map<String, dynamic>> applyStimulus(
    String ticketId,
    String stimulus, {
    Map<String, dynamic>? fields,
  }) async {
    final data = <String, dynamic>{
      'class': 'UserRequest',
      'key': ticketId,
      'stimulus': stimulus,
      'output_fields': 'ref,status',
    };
    if (fields != null && fields.isNotEmpty) {
      data['fields'] = fields;
    }
    return await _callApi(operation: 'core/apply_stimulus', data: data);
  }

  /// Aggiorna i campi di un ticket (core/update generico)
  Future<Map<String, dynamic>> updateTicket(
    String ticketId,
    Map<String, dynamic> fields,
  ) async {
    return await _callApi(
      operation: 'core/update',
      data: {
        'class': 'UserRequest',
        'key': ticketId,
        'output_fields': 'ref,status',
        'fields': fields,
      },
    );
  }

  /// Recupera la lista dei servizi disponibili
  Future<List<Map<String, dynamic>>> getServices({String? orgId}) async {
    String oql = 'SELECT Service';
    if (orgId != null && orgId.isNotEmpty) {
      oql = 'SELECT Service WHERE org_id = "$orgId"';
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

  /// Recupera le sottocategorie di un servizio
  Future<List<Map<String, dynamic>>> getServiceSubcategories(
      String serviceId) async {
    final result = await _callApi(
      operation: 'core/get',
      data: {
        'class': 'ServiceSubcategory',
        'key': 'SELECT ServiceSubcategory WHERE service_id = "$serviceId"',
        'output_fields': 'name',
      },
    );
    return _parseObjectList(result);
  }

  /// Parsa una risposta iTop in lista di {id, name}
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

  /// Recupera tutti gli Incident
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

  /// Campi comuni a tutti i FunctionalCI
  static const String _baseCIFields = 'name,org_id_friendlyname,description,'
      'business_criticity,move2production,finalclass';

  /// Campi aggiuntivi disponibili su PhysicalDevice e sottoclassi
  static const String _physicalDeviceFields =
      ',status,serialnumber,asset_number,'
      'brand_id_friendlyname,model_id_friendlyname,'
      'location_id_friendlyname';

  /// Classi che ereditano da PhysicalDevice e hanno il campo status
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

  /// Recupera tutti gli asset (FunctionalCI)
  Future<Map<String, dynamic>> getAssets({
    String? oqlFilter,
    String? className,
    String? outputFields,
  }) async {
    final cls = className ?? 'FunctionalCI';
    String oql = oqlFilter ?? 'SELECT $cls';

    // Usa i campi estesi solo per classi che li supportano
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

  /// Recupera un singolo asset con tutti i dettagli
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

  /// Cerca asset per testo
  Future<Map<String, dynamic>> searchAssets(String searchText) async {
    final escapedText = searchText.replaceAll('"', '\\"');
    return getAssets(
      oqlFilter:
          'SELECT FunctionalCI WHERE name LIKE "%$escapedText%" OR description LIKE "%$escapedText%"',
      outputFields: _baseCIFields,
    );
  }

  /// Recupera asset per classe specifica (Server, PC, ecc.)
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
