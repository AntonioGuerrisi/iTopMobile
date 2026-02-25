import 'package:flutter/material.dart';
import '../models/asset.dart';
import '../theme/app_theme.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Icona tipo asset
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  _getAssetIcon(asset.className),
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),

              // Info principali
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Tipo
                    Row(
                      children: [
                        Text(
                          asset.friendlyClassName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (asset.orgName.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text('•',
                                style: TextStyle(color: Colors.grey[400])),
                          ),
                          Flexible(
                            child: Text(
                              asset.orgName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Marca e modello
                    if (asset.brand.isNotEmpty || asset.model.isNotEmpty)
                      Text(
                        [asset.brand, asset.model]
                            .where((s) => s.isNotEmpty)
                            .join(' - '),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Badge stato (solo se presente)
              const SizedBox(width: 8),
              if (asset.status.isNotEmpty)
                _buildStatusBadge(asset.status),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
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
      case 'implementation':
      case 'implementazione':
        color = AppTheme.primaryColor;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
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
