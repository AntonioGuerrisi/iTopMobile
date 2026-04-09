import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/asset.dart';
import '../providers/asset_provider.dart';
import '../theme/app_theme.dart';

class AssetDetailScreen extends StatefulWidget {
  final Asset asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  Asset? _detailedAsset;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final provider = context.read<AssetProvider>();
    final detail = await provider.getAssetDetail(
      widget.asset.id,
      widget.asset.className,
    );

    if (mounted) {
      setState(() {
        _detailedAsset = detail;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _detailedAsset ?? widget.asset;

    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con icona e nome
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: Icon(
                              _getAssetIcon(asset.className),
                              size: 32,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  asset.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  asset.friendlyClassName,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildStatusBadge(asset.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informazioni generali
                  _buildSection(AppStrings.generalInformation, [
                    _buildDetailRow(
                        Icons.business, AppStrings.organization, asset.orgName),
                    _buildDetailRow(Icons.category, AppStrings.type,
                        asset.friendlyClassName),
                    _buildDetailRow(
                        Icons.info_outline, AppStrings.status, asset.status),
                    _buildDetailRow(Icons.priority_high, AppStrings.criticality,
                        asset.businessCriticity),
                  ]),

                  const SizedBox(height: 16),

                  // Informazioni hardware
                  _buildSection(AppStrings.hardware, [
                    _buildDetailRow(Icons.branding_watermark, AppStrings.brand,
                        asset.brand),
                    _buildDetailRow(
                        Icons.devices, AppStrings.model, asset.model),
                    _buildDetailRow(
                        Icons.tag, AppStrings.serialNumber, asset.serialNumber),
                    _buildDetailRow(Icons.confirmation_number,
                        AppStrings.assetNumber, asset.assetNumber),
                  ]),

                  const SizedBox(height: 16),

                  // Posizione
                  _buildSection(AppStrings.location, [
                    _buildDetailRow(Icons.location_on, AppStrings.locationName,
                        asset.locationName),
                    _buildDetailRow(Icons.calendar_today,
                        AppStrings.inProductionSince, asset.move2production),
                  ]),

                  // Description
                  if (asset.description.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSection(AppStrings.description, []),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(asset.description),
                    ),
                  ],

                  // Additional raw fields
                  if (asset.rawFields.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildRawFieldsSection(asset),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'production':
      case 'produzione':
        color = AppTheme.successColor;
        break;
      case 'stock':
      case 'magazzino':
        color = AppTheme.warningColor;
        break;
      case 'obsolete':
      case 'obsoleto':
        color = Colors.grey;
        break;
      default:
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const Divider(),
        ...children,
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildRawFieldsSection(Asset asset) {
    // Show only fields that are not already displayed
    final excludeKeys = {
      'name',
      'status',
      'org_id_friendlyname',
      'description',
      'business_criticity',
      'serialnumber',
      'asset_number',
      'brand_id_friendlyname',
      'model_id_friendlyname',
      'location_id_friendlyname',
      'move2production',
      'finalclass',
    };

    final extraFields = asset.rawFields.entries
        .where((e) =>
            !excludeKeys.contains(e.key) &&
            e.value != null &&
            e.value.toString().isNotEmpty &&
            e.value.toString() != '0' &&
            e.value is! Map &&
            e.value is! List)
        .toList();

    if (extraFields.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.additionalDetails,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const Divider(),
        ...extraFields.map(
          (e) => _buildDetailRow(
            Icons.info_outline,
            _formatFieldName(e.key),
            e.value.toString(),
          ),
        ),
      ],
    );
  }

  String _formatFieldName(String key) {
    return key
        .replaceAll('_', ' ')
        .replaceAll('id friendlyname', '')
        .split(' ')
        .map(
            (w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }

  IconData _getAssetIcon(String className) {
    switch (className) {
      case 'Server':
        return Icons.dns;
      case 'VirtualMachine':
        return Icons.cloud;
      case 'PC':
        return Icons.computer;
      case 'Laptop':
        return Icons.laptop;
      case 'Printer':
        return Icons.print;
      case 'Phone':
      case 'MobilePhone':
        return Icons.phone_android;
      case 'Tablet':
        return Icons.tablet;
      case 'NetworkDevice':
        return Icons.router;
      case 'StorageSystem':
        return Icons.storage;
      case 'NAS':
        return Icons.folder_shared;
      case 'Rack':
        return Icons.view_column;
      default:
        return Icons.devices_other;
    }
  }
}
