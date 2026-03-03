/// Tipo di log entry
enum LogType {
  public('Pubblico'),
  private_('Privato'),
  activity('Attività');

  final String label;
  const LogType(this.label);
}

/// Log entry per il ticket (caselog)
class TicketLog {
  final String date;
  final String userLogin;
  final String message;
  final String messageHtml;
  final LogType type;

  TicketLog({
    required this.date,
    required this.userLogin,
    required this.message,
    this.messageHtml = '',
    this.type = LogType.public,
  });

  factory TicketLog.fromJson(Map<String, dynamic> json,
      {LogType type = LogType.public}) {
    return TicketLog(
      date: json['date']?.toString() ?? '',
      userLogin: json['user_login']?.toString() ?? '',
      message: _stripHtml(json['message']?.toString() ?? ''),
      messageHtml: json['message']?.toString() ?? '',
      type: type,
    );
  }

  /// Attcode che sono chiavi esterne (ID da risolvere in nomi)
  static const _fkAttcodes = {
    'agent_id',
    'caller_id',
    'team_id',
    'org_id',
    'service_id',
    'servicesubcategory_id',
  };

  /// Crea un log entry da un record CMDBChangeOp (attività / storia)
  factory TicketLog.fromChangeOp(
    String changeClass,
    Map<String, dynamic> fields,
    Map<String, String> resolvedNames,
  ) {
    final date = fields['date']?.toString() ?? '';
    final userLogin = fields['userinfo']?.toString() ?? '';

    String message;

    if (changeClass == 'CMDBChangeOpCreate') {
      message = 'Ticket creato';
    } else if (changeClass == 'CMDBChangeOpSetAttributeScalar') {
      final attcode = fields['attcode']?.toString() ?? '';
      final oldValue = fields['oldvalue']?.toString() ?? '';
      final newValue = fields['newvalue']?.toString() ?? '';
      final attLabel = _attcodeLabels[attcode] ?? attcode;

      // Risolve gli ID in nomi leggibili per le chiavi esterne
      final displayOld = _fkAttcodes.contains(attcode)
          ? _resolveValue(oldValue, resolvedNames)
          : oldValue;
      final displayNew = _fkAttcodes.contains(attcode)
          ? _resolveValue(newValue, resolvedNames)
          : newValue;

      if (displayOld.isEmpty || oldValue == '0') {
        message = '$attLabel impostato a "$displayNew"';
      } else {
        message = '$attLabel: "$displayOld" → "$displayNew"';
      }
    } else if (changeClass == 'CMDBChangeOpSetAttributeHTML' ||
        changeClass == 'CMDBChangeOpSetAttributeText' ||
        changeClass == 'CMDBChangeOpSetAttributeLongText') {
      final attcode = fields['attcode']?.toString() ?? '';
      final attLabel = _attcodeLabels[attcode] ?? attcode;
      message = '$attLabel modificato/a';
    } else if (changeClass == 'CMDBChangeOpSetAttributeBlob') {
      final filename = fields['filename']?.toString() ?? '';
      final attcode = fields['attcode']?.toString() ?? '';
      if (filename.isNotEmpty) {
        message = 'Allegato aggiunto: "$filename"';
      } else {
        final attLabel = _attcodeLabels[attcode] ?? attcode;
        message = '$attLabel modificato';
      }
    } else if (changeClass == 'CMDBChangeOpPlugin') {
      final desc = fields['description']?.toString() ?? '';
      if (desc.isNotEmpty) {
        message = _stripHtml(desc);
      } else {
        message = 'Azione plugin eseguita';
      }
    } else {
      message = changeClass.replaceAll('CMDBChangeOp', '');
    }

    return TicketLog(
      date: date,
      userLogin: userLogin,
      message: message,
      type: LogType.activity,
    );
  }

  /// Risolve un valore ID in nome leggibile, se disponibile
  static String _resolveValue(String value, Map<String, String> resolvedNames) {
    if (value.isEmpty || value == '0') return '';
    return resolvedNames[value] ?? value;
  }

  /// Mappa attcode iTop → etichette leggibili
  static const _attcodeLabels = <String, String>{
    'status': 'Stato',
    'agent_id': 'Agente',
    'team_id': 'Team',
    'priority': 'Priorità',
    'urgency': 'Urgenza',
    'impact': 'Impatto',
    'caller_id': 'Richiedente',
    'org_id': 'Organizzazione',
    'service_id': 'Servizio',
    'servicesubcategory_id': 'Sottocategoria',
    'title': 'Titolo',
    'assignment_date': 'Data assegnazione',
    'resolution_date': 'Data risoluzione',
    'close_date': 'Data chiusura',
    'start_date': 'Data apertura',
    'last_update': 'Ultimo aggiornamento',
    'tto_escalation_deadline': 'Scadenza TTO',
    'ttr_escalation_deadline': 'Scadenza TTR',
    'origin': 'Origine',
    'description': 'Descrizione',
    'solution': 'Soluzione',
    'user_satisfaction': 'Soddisfazione utente',
    'parent_request_id': 'Richiesta padre',
    'parent_incident_id': 'Incidente padre',
    'resolution_code': 'Codice risoluzione',
  };

  /// Rimuove i tag HTML dal messaggio
  static String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }
}
