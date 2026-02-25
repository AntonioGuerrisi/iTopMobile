import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';
import '../models/ticket_log.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';
import 'ticket_actions_screen.dart';

class TicketDetailScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Ticket? _detailedTicket;
  List<TicketLog> _logs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final provider = context.read<TicketProvider>();

    final results = await Future.wait([
      provider.getTicketDetail(widget.ticket.id),
      provider.getTicketLogs(widget.ticket.id),
    ]);

    if (mounted) {
      setState(() {
        _detailedTicket = results[0] as Ticket?;
        _logs = results[1] as List<TicketLog>;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _detailedTicket ?? widget.ticket;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(ticket.ref.isNotEmpty ? ticket.ref : 'Ticket #${ticket.id}'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Dettagli'),
            Tab(text: 'Descrizione'),
            Tab(text: 'Log'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(ticket),
                _buildDescriptionTab(ticket),
                _buildLogTab(),
              ],
            ),
      floatingActionButton: ticket.isOpen
          ? FloatingActionButton.extended(
              onPressed: () => _openActions(ticket),
              icon: const Icon(Icons.edit),
              label: const Text('Azioni'),
            )
          : null,
    );
  }

  void _openActions(Ticket ticket) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TicketActionsScreen(ticket: ticket),
      ),
    );
    if (result == true && mounted) {
      setState(() => _isLoading = true);
      await _loadDetails();
      // Ricarica anche la lista ticker in background
      if (mounted) {
        context.read<TicketProvider>().loadTickets();
      }
    }
  }

  Widget _buildDetailsTab(Ticket ticket) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          Text(
            ticket.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Stato e priorità
          Row(
            children: [
              _buildStatusChip(ticket.status),
              const SizedBox(width: 8),
              _buildPriorityChip(ticket.priority),
            ],
          ),
          const SizedBox(height: 24),

          // Informazioni principali
          _buildInfoSection('Informazioni Generali', [
            _buildInfoRow(Icons.business, 'Organizzazione', ticket.orgName),
            _buildInfoRow(
                Icons.person_outline, 'Richiedente', ticket.callerName),
            _buildInfoRow(Icons.group, 'Team', ticket.teamName),
            _buildInfoRow(Icons.person, 'Agente', ticket.agentName),
            _buildInfoRow(
                Icons.miscellaneous_services, 'Servizio', ticket.serviceName),
            _buildInfoRow(Icons.category, 'Sottocategoria',
                ticket.serviceSubcategoryName),
            _buildInfoRow(Icons.source, 'Origine', ticket.origin),
          ]),

          const SizedBox(height: 16),

          // Impatto e urgenza
          _buildInfoSection('Classificazione', [
            _buildInfoRow(Icons.priority_high, 'Priorità', ticket.priority),
            _buildInfoRow(Icons.speed, 'Urgenza', ticket.urgency),
            _buildInfoRow(Icons.flash_on, 'Impatto', ticket.impact),
          ]),

          const SizedBox(height: 16),

          // Date
          _buildInfoSection('Date', [
            _buildInfoRow(
                Icons.play_arrow, 'Apertura', _formatDate(ticket.startDate)),
            _buildInfoRow(Icons.update, 'Ultimo aggiornamento',
                _formatDate(ticket.lastUpdate)),
            if (ticket.closeDate.isNotEmpty)
              _buildInfoRow(Icons.check_circle, 'Chiusura',
                  _formatDate(ticket.closeDate)),
          ]),

          // Risoluzione
          if (ticket.resolution.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoSection('Risoluzione', []),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(ticket.resolution),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDescriptionTab(Ticket ticket) {
    if (ticket.description.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessuna descrizione disponibile',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _stripHtml(ticket.description),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildLogTab() {
    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Nessun log disponibile',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => const Divider(height: 24),
      itemBuilder: (context, index) {
        final log = _logs[index];
        return _buildLogEntry(log);
      },
    );
  }

  Widget _buildLogEntry(TicketLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.userLogin,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatDate(log.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SelectableText(log.message),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    return Chip(
      avatar: Icon(
        AppTheme.getStatusIcon(status),
        size: 18,
        color: Colors.white,
      ),
      label: Text(
        status,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: AppTheme.getStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildPriorityChip(String priority) {
    return Chip(
      label: Text(
        priority,
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      backgroundColor: AppTheme.getPriorityColor(priority),
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
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
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  String _stripHtml(String html) {
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
