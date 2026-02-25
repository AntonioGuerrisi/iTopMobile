import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';

/// Schermata con le azioni disponibili per un ticket
class TicketActionsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketActionsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Azioni - ${ticket.ref}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stato corrente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(AppTheme.getStatusIcon(ticket.status),
                      color: AppTheme.getStatusColor(ticket.status)),
                  const SizedBox(width: 12),
                  Text('Stato attuale: ',
                      style: TextStyle(color: Colors.grey[600])),
                  Text(
                    ticket.status,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // --- Sezione Log ---
          _buildSectionTitle(context, 'Aggiungi al Log'),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.chat,
            title: 'Log Pubblico',
            subtitle: 'Visibile al richiedente',
            color: Colors.blue,
            onTap: () => _showAddLogDialog(context, isPublic: true),
          ),
          _ActionTile(
            icon: Icons.lock,
            title: 'Log Privato',
            subtitle: 'Visibile solo al team interno',
            color: Colors.orange,
            onTap: () => _showAddLogDialog(context, isPublic: false),
          ),

          const SizedBox(height: 24),

          // --- Sezione Stato ---
          _buildSectionTitle(context, 'Cambia Stato'),
          const SizedBox(height: 8),
          ..._buildStatusActions(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
    );
  }

  /// Costruisce le azioni di cambio stato in base allo stato attuale
  List<Widget> _buildStatusActions(BuildContext context) {
    final status = ticket.status.toLowerCase();
    final actions = <Widget>[];

    // Transizioni standard iTop per UserRequest
    switch (status) {
      case 'new':
        actions.add(_ActionTile(
          icon: Icons.assignment_ind,
          title: 'Assegna',
          subtitle: 'Transizione a "Assegnato"',
          color: Colors.indigo,
          onTap: () => _confirmStimulus(context, 'ev_assign', 'Assegna'),
        ));
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: 'Risolvi',
          subtitle: 'Risolvi direttamente il ticket',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
        break;
      case 'assigned':
        actions.add(_ActionTile(
          icon: Icons.pause_circle,
          title: 'Metti in Attesa',
          subtitle: 'In attesa di informazioni',
          color: Colors.amber,
          onTap: () => _showPendingDialog(context),
        ));
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: 'Risolvi',
          subtitle: 'Inserisci servizio e soluzione',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
        actions.add(_ActionTile(
          icon: Icons.redo,
          title: 'Riassegna',
          subtitle: 'Riassegna ad altro team/agente',
          color: Colors.purple,
          onTap: () => _confirmStimulus(context, 'ev_reassign', 'Riassegna'),
        ));
        break;
      case 'pending':
        actions.add(_ActionTile(
          icon: Icons.assignment_ind,
          title: 'Riassegna',
          subtitle: 'Torna ad "Assegnato"',
          color: Colors.indigo,
          onTap: () => _confirmStimulus(context, 'ev_reassign', 'Riassegna'),
        ));
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: 'Risolvi',
          subtitle: 'Inserisci servizio e soluzione',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
        break;
      case 'resolved':
        actions.add(_ActionTile(
          icon: Icons.done_all,
          title: 'Chiudi',
          subtitle: 'Chiudi definitivamente il ticket',
          color: Colors.teal,
          onTap: () => _confirmStimulus(context, 'ev_close', 'Chiudi'),
        ));
        actions.add(_ActionTile(
          icon: Icons.replay,
          title: 'Riapri',
          subtitle: 'Riporta il ticket ad assegnato',
          color: Colors.deepOrange,
          onTap: () => _confirmStimulus(context, 'ev_reopen', 'Riapri'),
        ));
        break;
      case 'closed':
        actions.add(
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Il ticket è chiuso. Non sono disponibili ulteriori transizioni.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        break;
      default:
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: 'Risolvi',
          subtitle: 'Inserisci la soluzione',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
    }

    return actions;
  }

  /// Dialog per aggiungere una entry al log
  void _showAddLogDialog(BuildContext context, {required bool isPublic}) {
    final controller = TextEditingController();
    final logType = isPublic ? 'pubblico' : 'privato';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Log ${isPublic ? "Pubblico" : "Privato"}'),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Scrivi un messaggio nel log $logType...',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              final message = controller.text.trim();
              if (message.isEmpty) return;
              Navigator.pop(ctx);
              await _sendLog(context, message, isPublic);
            },
            child: const Text('Invia'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendLog(
      BuildContext context, String message, bool isPublic) async {
    _showLoadingDialog(context);
    final provider = context.read<TicketProvider>();
    final success = isPublic
        ? await provider.addPublicLog(ticket.id, message)
        : await provider.addPrivateLog(ticket.id, message);

    if (!context.mounted) return;
    Navigator.pop(context); // chiude loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Log aggiunto con successo'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // torna al detail con refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? 'Errore'),
            backgroundColor: Colors.red),
      );
    }
  }

  /// Dialog per mettere il ticket in attesa (con motivo)
  void _showPendingDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Metti in Attesa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Indica il motivo dell\'attesa:'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Motivo...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final reason = controller.text.trim();
              final fields = <String, dynamic>{};
              if (reason.isNotEmpty) {
                fields['pending_reason'] = reason;
              }
              await _doStimulus(context, 'ev_pending', fields: fields);
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  /// Dialog per risolvere il ticket
  void _showResolveDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResolveTicketScreen(ticket: ticket),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  /// Conferma un'azione di stimulus semplice
  void _confirmStimulus(
      BuildContext context, String stimulus, String actionLabel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Conferma: $actionLabel'),
        content:
            Text('Vuoi ${actionLabel.toLowerCase()} il ticket ${ticket.ref}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _doStimulus(context, stimulus);
            },
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _doStimulus(BuildContext context, String stimulus,
      {Map<String, dynamic>? fields}) async {
    _showLoadingDialog(context);
    final provider = context.read<TicketProvider>();
    final success = await provider.applyStimulus(
      ticket.id,
      stimulus,
      fields: fields,
    );

    if (!context.mounted) return;
    Navigator.pop(context); // chiude loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Stato aggiornato con successo'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // torna al detail con refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? 'Errore'),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}

// ============================================================
// Tile per le azioni
// ============================================================

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================
// Schermata Risoluzione Ticket
// ============================================================

class _ResolveTicketScreen extends StatefulWidget {
  final Ticket ticket;
  const _ResolveTicketScreen({required this.ticket});

  @override
  State<_ResolveTicketScreen> createState() => _ResolveTicketScreenState();
}

class _ResolveTicketScreenState extends State<_ResolveTicketScreen> {
  final _solutionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _subcategories = [];

  String? _selectedServiceId;
  String? _selectedSubcategoryId;

  bool _isLoadingServices = true;
  bool _isLoadingSubcategories = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Se il ticket ha già un servizio, pre-selezionalo
    if (widget.ticket.serviceId.isNotEmpty) {
      _selectedServiceId = widget.ticket.serviceId;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    final provider = context.read<TicketProvider>();
    final services = await provider.getServices();
    if (mounted) {
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
      // Se c'è un servizio pre-selezionato, carica le sottocategorie
      if (_selectedServiceId != null) {
        _loadSubcategories(_selectedServiceId!);
      }
    }
  }

  Future<void> _loadSubcategories(String serviceId) async {
    setState(() {
      _isLoadingSubcategories = true;
      _subcategories = [];
      _selectedSubcategoryId = null;
    });

    final provider = context.read<TicketProvider>();
    final subs = await provider.getServiceSubcategories(serviceId);
    if (mounted) {
      setState(() {
        _subcategories = subs;
        _isLoadingSubcategories = false;
      });
    }
  }

  @override
  void dispose() {
    _solutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Risolvi ${widget.ticket.ref}'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info
            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.green),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Per risolvere il ticket è necessario indicare '
                        'il servizio, la sottocategoria e la descrizione '
                        'della soluzione.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Servizio ---
            Text('Servizio *',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingServices
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    initialValue: _selectedServiceId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Seleziona un servizio',
                    ),
                    items: _services
                        .map((s) => DropdownMenuItem(
                              value: s['id'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    validator: (v) =>
                        v == null ? 'Seleziona un servizio' : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedServiceId = value;
                      });
                      if (value != null) {
                        _loadSubcategories(value);
                      }
                    },
                  ),
            const SizedBox(height: 20),

            // --- Sottocategoria ---
            Text('Sottocategoria Servizio *',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingSubcategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    initialValue: _selectedSubcategoryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _subcategories.isEmpty
                          ? 'Nessuna sottocategoria'
                          : 'Seleziona sottocategoria',
                    ),
                    items: _subcategories
                        .map((s) => DropdownMenuItem(
                              value: s['id'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    validator: (v) => _subcategories.isNotEmpty && v == null
                        ? 'Seleziona una sottocategoria'
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubcategoryId = value;
                      });
                    },
                  ),
            const SizedBox(height: 20),

            // --- Soluzione ---
            Text('Descrizione Soluzione *',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _solutionController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Descrivi la soluzione applicata...',
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Inserisci la descrizione della soluzione'
                  : null,
            ),
            const SizedBox(height: 32),

            // --- Bottone ---
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _resolve,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_circle),
                label: Text(_isSaving ? 'Salvataggio...' : 'Risolvi Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resolve() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TicketProvider>();

    // Prepara i campi per la risoluzione
    final fields = <String, dynamic>{
      'solution': _solutionController.text.trim(),
      'service_id': _selectedServiceId,
    };
    if (_selectedSubcategoryId != null) {
      fields['servicesubcategory_id'] = _selectedSubcategoryId;
    }

    final success = await provider.applyStimulus(
      widget.ticket.id,
      'ev_resolve',
      fields: fields,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket risolto con successo!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // torna ad actions, che tornerà al detail
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Errore nella risoluzione'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
