import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../providers/asset_provider.dart';
import '../models/asset.dart';
import '../widgets/asset_card.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AssetProvider>();
      if (provider.assets.isEmpty) {
        provider.loadAssets();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: AppStrings.searchAssets,
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  context.read<AssetProvider>().searchAssets(value);
                },
              )
            : const Text(AppStrings.assets),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<AssetProvider>().searchAssets('');
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: AppStrings.filterByType,
            onSelected: (value) {
              context.read<AssetProvider>().filterByClass(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text(AppStrings.all),
              ),
              const PopupMenuDivider(),
              ...AssetProvider.assetClasses.map(
                (cls) => PopupMenuItem(
                  value: cls,
                  child: Row(
                    children: [
                      Icon(
                        _getAssetClassIcon(cls),
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(cls),
                    ],
                  ),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AssetProvider>().loadAssets();
            },
          ),
        ],
      ),
      body: Consumer<AssetProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.assets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(AppStrings.loading),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.assets.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.loadAssets(),
                      icon: const Icon(Icons.refresh),
                      label: const Text(AppStrings.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Filtro attivo
              if (provider.classFilter != 'all')
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Row(
                    children: [
                      Icon(
                        _getAssetClassIcon(provider.classFilter),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${AppStrings.selectedFilter} ${provider.classFilter}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => provider.filterByClass('all'),
                        child: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),

              // Conteggio
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${provider.assets.length}${AppStrings.assetsCountSuffix}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    if (provider.isLoading) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ],
                  ],
                ),
              ),

              // Lista asset
              Expanded(
                child: provider.assets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              AppStrings.noAssetsFound,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadAssets(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: provider.assets.length,
                          itemBuilder: (context, index) {
                            final asset = provider.assets[index];
                            return AssetCard(
                              asset: asset,
                              onTap: () => _openAssetDetail(asset),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openAssetDetail(Asset asset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(asset: asset),
      ),
    );
  }

  IconData _getAssetClassIcon(String className) {
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
