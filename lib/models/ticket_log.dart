/// Type of log entry
enum LogType {
  public('Public'),
  private_('Private'),
  activity('Activity');

  final String label;
  const LogType(this.label);
}

/// Ticket log entry (caselog)
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

  /// Attcodes that are foreign keys (IDs resolved to names)
  static const _fkAttcodes = {
    'agent_id',
    'caller_id',
    'team_id',
    'org_id',
    'service_id',
    'servicesubcategory_id',
  };

  /// Creates a log entry from a CMDBChangeOp record (activity/history)
  factory TicketLog.fromChangeOp(
    String changeClass,
    Map<String, dynamic> fields,
    Map<String, String> resolvedNames,
  ) {
    final date = fields['date']?.toString() ?? '';
    final userLogin = fields['userinfo']?.toString() ?? '';

    String message;

    if (changeClass == 'CMDBChangeOpCreate') {
      message = 'Ticket created';
    } else if (changeClass == 'CMDBChangeOpSetAttributeScalar') {
      final attcode = fields['attcode']?.toString() ?? '';
      final oldValue = fields['oldvalue']?.toString() ?? '';
      final newValue = fields['newvalue']?.toString() ?? '';
      final attLabel = _attcodeLabels[attcode] ?? attcode;

      // Resolve IDs to readable names for foreign keys
      final displayOld = _fkAttcodes.contains(attcode)
          ? _resolveValue(oldValue, resolvedNames)
          : oldValue;
      final displayNew = _fkAttcodes.contains(attcode)
          ? _resolveValue(newValue, resolvedNames)
          : newValue;

      if (displayOld.isEmpty || oldValue == '0') {
        message = '$attLabel set to "$displayNew"';
      } else {
        message = '$attLabel: "$displayOld" → "$displayNew"';
      }
    } else if (changeClass == 'CMDBChangeOpSetAttributeHTML' ||
        changeClass == 'CMDBChangeOpSetAttributeText' ||
        changeClass == 'CMDBChangeOpSetAttributeLongText') {
      final attcode = fields['attcode']?.toString() ?? '';
      final attLabel = _attcodeLabels[attcode] ?? attcode;
      message = '$attLabel updated';
    } else if (changeClass == 'CMDBChangeOpSetAttributeBlob') {
      final filename = fields['filename']?.toString() ?? '';
      final attcode = fields['attcode']?.toString() ?? '';
      if (filename.isNotEmpty) {
        message = 'Attachment added: "$filename"';
      } else {
        final attLabel = _attcodeLabels[attcode] ?? attcode;
        message = '$attLabel updated';
      }
    } else if (changeClass == 'CMDBChangeOpPlugin') {
      final desc = fields['description']?.toString() ?? '';
      if (desc.isNotEmpty) {
        message = _stripHtml(desc);
      } else {
        message = 'Plugin action executed';
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

  /// Resolves an ID value to a readable name, if available
  static String _resolveValue(String value, Map<String, String> resolvedNames) {
    if (value.isEmpty || value == '0') return '';
    return resolvedNames[value] ?? value;
  }

  /// Maps iTop attcodes to readable labels
  static const _attcodeLabels = <String, String>{
    'status': 'Status',
    'agent_id': 'Agent',
    'team_id': 'Team',
    'priority': 'Priority',
    'urgency': 'Urgency',
    'impact': 'Impact',
    'caller_id': 'Requester',
    'org_id': 'Organization',
    'service_id': 'Service',
    'servicesubcategory_id': 'Subcategory',
    'title': 'Title',
    'assignment_date': 'Assignment date',
    'resolution_date': 'Resolution date',
    'close_date': 'Closure date',
    'start_date': 'Opening date',
    'last_update': 'Last update',
    'tto_escalation_deadline': 'TTO deadline',
    'ttr_escalation_deadline': 'TTR deadline',
    'origin': 'Origin',
    'description': 'Description',
    'solution': 'Solution',
    'user_satisfaction': 'User satisfaction',
    'parent_request_id': 'Parent request',
    'parent_incident_id': 'Parent incident',
    'resolution_code': 'Resolution code',
  };

  /// Removes HTML tags from the message
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
