/// Modello per un Ticket (UserRequest) di iTop
class Ticket {
  final String id;
  final String ref;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String urgency;
  final String impact;
  final String callerName;
  final String orgName;
  final String teamName;
  final String agentName;
  final String serviceId;
  final String serviceName;
  final String serviceSubcategoryName;
  final String startDate;
  final String lastUpdate;
  final String closeDate;
  final String resolution;
  final String origin;
  final Map<String, dynamic> rawFields;

  Ticket({
    required this.id,
    required this.ref,
    required this.title,
    this.description = '',
    this.status = '',
    this.priority = '',
    this.urgency = '',
    this.impact = '',
    this.callerName = '',
    this.orgName = '',
    this.teamName = '',
    this.agentName = '',
    this.serviceId = '',
    this.serviceName = '',
    this.serviceSubcategoryName = '',
    this.startDate = '',
    this.lastUpdate = '',
    this.closeDate = '',
    this.resolution = '',
    this.origin = '',
    this.rawFields = const {},
  });

  factory Ticket.fromJson(String id, Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>? ?? json;
    return Ticket(
      id: id,
      ref: _str(fields['ref']),
      title: _str(fields['title']),
      description: _str(fields['description']),
      status: _str(fields['status']),
      priority: _str(fields['priority']),
      urgency: _str(fields['urgency']),
      impact: _str(fields['impact']),
      callerName: _str(fields['caller_id_friendlyname']),
      orgName: _str(fields['org_id_friendlyname']),
      teamName: _str(fields['team_id_friendlyname']),
      agentName: _str(fields['agent_id_friendlyname']),
      serviceId: _str(fields['service_id']),
      serviceName: _str(fields['service_id_friendlyname']),
      serviceSubcategoryName: _str(fields['servicesubcategory_id_friendlyname']),
      startDate: _str(fields['start_date']),
      lastUpdate: _str(fields['last_update']),
      closeDate: _str(fields['close_date']),
      resolution: _str(fields['solution']),
      origin: _str(fields['origin']),
      rawFields: fields,
    );
  }

  static String _str(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Mostra il titolo abbreviato
  String get shortTitle {
    if (title.length <= 60) return title;
    return '${title.substring(0, 57)}...';
  }

  /// Controlla se il ticket è aperto
  bool get isOpen =>
      status.toLowerCase() != 'closed' && status.toLowerCase() != 'chiuso';
}
