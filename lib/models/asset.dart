/// Modello per un Asset (FunctionalCI) di iTop
class Asset {
  final String id;
  final String name;
  final String className;
  final String status;
  final String orgName;
  final String description;
  final String businessCriticity;
  final String serialNumber;
  final String assetNumber;
  final String brand;
  final String model;
  final String locationName;
  final String move2production;
  final Map<String, dynamic> rawFields;

  Asset({
    required this.id,
    required this.name,
    required this.className,
    this.status = '',
    this.orgName = '',
    this.description = '',
    this.businessCriticity = '',
    this.serialNumber = '',
    this.assetNumber = '',
    this.brand = '',
    this.model = '',
    this.locationName = '',
    this.move2production = '',
    this.rawFields = const {},
  });

  factory Asset.fromJson(String id, Map<String, dynamic> json) {
    final fields = json['fields'] as Map<String, dynamic>? ?? json;
    final className = _str(json['class'] ?? fields['finalclass'] ?? '');
    return Asset(
      id: id,
      name: _str(fields['name']),
      className: className,
      status: _str(fields['status']),
      orgName: _str(fields['org_id_friendlyname']),
      description: _str(fields['description']),
      businessCriticity: _str(fields['business_criticity']),
      serialNumber: _str(fields['serialnumber']),
      assetNumber: _str(fields['asset_number']),
      brand: _str(fields['brand_id_friendlyname']),
      model: _str(fields['model_id_friendlyname']),
      locationName: _str(fields['location_id_friendlyname']),
      move2production: _str(fields['move2production']),
      rawFields: fields,
    );
  }

  static String _str(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  /// Icona appropriata in base al tipo di asset
  String get friendlyClassName {
    switch (className) {
      case 'Server':
        return 'Server';
      case 'VirtualMachine':
        return 'Macchina Virtuale';
      case 'PC':
        return 'PC';
      case 'Laptop':
        return 'Laptop';
      case 'Printer':
        return 'Stampante';
      case 'Phone':
      case 'MobilePhone':
        return 'Telefono';
      case 'Tablet':
        return 'Tablet';
      case 'NetworkDevice':
        return 'Dispositivo di Rete';
      case 'StorageSystem':
        return 'Storage';
      case 'SANSwitch':
        return 'SAN Switch';
      case 'TapeLibrary':
        return 'Tape Library';
      case 'NAS':
        return 'NAS';
      case 'PowerSource':
        return 'Alimentazione';
      case 'PDU':
        return 'PDU';
      case 'Rack':
        return 'Rack';
      case 'Enclosure':
        return 'Enclosure';
      default:
        return className;
    }
  }

  /// Controlla se l'asset è in produzione
  bool get isInProduction =>
      status.toLowerCase() == 'production' ||
      status.toLowerCase() == 'produzione';
}
