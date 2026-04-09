import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';

/// Screen showing available actions for a ticket
class TicketActionsScreen extends StatelessWidget {
  final Ticket ticket;

  const TicketActionsScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.actions} - ${ticket.ref}'),
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
                  Text(AppStrings.currentStatus,
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

          // --- Log section ---
          _buildSectionTitle(context, AppStrings.addToLog),
          const SizedBox(height: 8),
          _ActionTile(
            icon: Icons.chat,
            title: AppStrings.publicLogTitle,
            subtitle: AppStrings.visibleToRequester,
            color: Colors.blue,
            onTap: () => _showAddLogDialog(context, isPublic: true),
          ),
          _ActionTile(
            icon: Icons.lock,
            title: AppStrings.privateLogTitle,
            subtitle: AppStrings.visibleToInternalTeam,
            color: Colors.orange,
            onTap: () => _showAddLogDialog(context, isPublic: false),
          ),

          const SizedBox(height: 24),

          // --- Status section ---
          _buildSectionTitle(context, AppStrings.changeStatus),
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

  /// Builds state change actions based on the current ticket status
  List<Widget> _buildStatusActions(BuildContext context) {
    final status = ticket.status.toLowerCase();
    final actions = <Widget>[];

    // Transizioni standard iTop per UserRequest
    switch (status) {
      case 'new':
        actions.add(_ActionTile(
          icon: Icons.assignment_ind,
          title: AppStrings.assign,
          subtitle: '${AppStrings.assign} -> ${AppStrings.assignedStatus}',
          color: Colors.indigo,
          onTap: () => _showAssignDialog(context),
        ));
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: AppStrings.resolve,
          subtitle: 'Resolve the ticket directly',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
        break;
      case 'assigned':
        actions.add(_ActionTile(
          icon: Icons.pause_circle,
          title: AppStrings.pending,
          subtitle: 'Waiting for more information',
          color: Colors.amber,
          onTap: () => _showPendingDialog(context),
        ));
        actions.add(_ActionTile(
          icon: Icons.check_circle,
          title: AppStrings.resolve,
          subtitle: 'Select a service and resolution',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
        actions.add(_ActionTile(
          icon: Icons.redo,
          title: AppStrings.reassign,
          subtitle: 'Reassign to another team or agent',
          color: Colors.purple,
          onTap: () => _showAssignDialog(context, stimulus: 'ev_reassign'),
        ));
        break;
      case 'pending':
        actions.add(_ActionTile(
          icon: Icons.assignment_ind,
          title: AppStrings.assign,
          subtitle: 'Resume and assign the ticket',
          color: Colors.indigo,
          onTap: () => _showAssignDialog(context, stimulus: 'ev_assign'),
        ));
        break;
      case 'resolved':
        actions.add(_ActionTile(
          icon: Icons.done_all,
          title: AppStrings.close,
          subtitle: 'Close the ticket permanently',
          color: Colors.teal,
          onTap: () => _confirmStimulus(context, 'ev_close', AppStrings.close),
        ));
        actions.add(_ActionTile(
          icon: Icons.replay,
          title: AppStrings.reopen,
          subtitle: 'Return the ticket to assigned',
          color: Colors.deepOrange,
          onTap: () =>
              _confirmStimulus(context, 'ev_reopen', AppStrings.reopen),
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
                      'The ticket is closed. No further transitions are available.',
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
          title: AppStrings.resolve,
          subtitle: 'Enter the resolution',
          color: Colors.green,
          onTap: () => _showResolveDialog(context),
        ));
    }

    return actions;
  }

  /// Dialog to add a log entry
  void _showAddLogDialog(BuildContext context, {required bool isPublic}) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
            isPublic ? AppStrings.publicLogTitle : AppStrings.privateLogTitle),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppStrings.writeLogMessage,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final message = controller.text.trim();
              if (message.isEmpty) return;
              Navigator.pop(ctx);
              await _sendLog(context, message, isPublic);
            },
            child: const Text(AppStrings.addLog),
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
            content: Text('Log added successfully'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // return to detail with refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? AppStrings.error),
            backgroundColor: Colors.red),
      );
    }
  }

  /// Dialog to assign the ticket to a team/agent
  void _showAssignDialog(BuildContext context,
      {String stimulus = 'ev_assign'}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _AssignTicketScreen(ticket: ticket, stimulus: stimulus),
      ),
    ).then((result) {
      if (result == true && context.mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  /// Dialog for setting the ticket to pending (with reason)
  void _showPendingDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.pendingReasonTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.pendingReasonLabel),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: AppStrings.pendingReasonHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final reason = controller.text.trim();
              final fields = <String, dynamic>{};
              if (reason.isNotEmpty) {
                fields['pending_reason'] = reason;
                fields['public_log'] = {
                  'add_item': {
                    'message': reason,
                    'format': 'text',
                  },
                };
              }
              await _doStimulus(context, 'ev_pending', fields: fields);
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  /// Dialog to resolve the ticket
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

  /// Confirms a simple stimulus action (requires a comment)
  void _confirmStimulus(
      BuildContext context, String stimulus, String actionLabel) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${AppStrings.confirmActionTitle} $actionLabel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'Do you want to ${actionLabel.toLowerCase()} ticket ${ticket.ref}?'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: AppStrings.commentLabel,
                hintText: AppStrings.commentHint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () {
              final comment = controller.text.trim();
              if (comment.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(AppStrings.mandatoryComment),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _doStimulus(context, stimulus, fields: {
                'public_log': {
                  'add_item': {
                    'message': comment,
                    'format': 'text',
                  },
                },
              });
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
            content: Text('Status updated successfully'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // return to detail with refresh
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(provider.errorMessage ?? AppStrings.error),
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
// Ticket assignment screen
// ============================================================

class _AssignTicketScreen extends StatefulWidget {
  final Ticket ticket;
  final String stimulus;
  const _AssignTicketScreen(
      {required this.ticket, this.stimulus = 'ev_assign'});

  @override
  State<_AssignTicketScreen> createState() => _AssignTicketScreenState();
}

class _AssignTicketScreenState extends State<_AssignTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _teams = [];
  List<Map<String, dynamic>> _members = [];

  String? _selectedTeamId;
  String? _selectedMemberId;

  bool _isLoadingTeams = true;
  bool _isLoadingMembers = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // If the ticket already has a team, pre-select it
    if (widget.ticket.teamName.isNotEmpty) {
      // The team ID is not directly available and will be selected manually
    }
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    final provider = context.read<TicketProvider>();
    final teams = await provider.getTeams();
    if (mounted) {
      setState(() {
        _teams = teams;
        _isLoadingTeams = false;
      });
    }
  }

  Future<void> _loadMembers(String teamId) async {
    setState(() {
      _isLoadingMembers = true;
      _members = [];
      _selectedMemberId = null;
    });

    try {
      final provider = context.read<TicketProvider>();
      final members = await provider.getTeamMembers(teamId);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _members = [];
          _isLoadingMembers = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.stimulus == 'ev_reassign'
              ? '${AppStrings.reassign} ${widget.ticket.ref}'
              : '${AppStrings.assign} ${widget.ticket.ref}',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info
            Card(
              color: Colors.indigo.shade50,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.indigo),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Select the team and agent to assign the ticket.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Team ---
            Text('${AppStrings.team} *',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingTeams
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedTeamId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: AppStrings.selectTeam,
                    ),
                    items: _teams
                        .map((t) => DropdownMenuItem(
                              value: t['id'] as String,
                              child: Text(t['name'] as String),
                            ))
                        .toList(),
                    validator: (v) => v == null ? AppStrings.selectTeam : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedTeamId = value;
                      });
                      if (value != null) {
                        _loadMembers(value);
                      }
                    },
                  ),
            const SizedBox(height: 20),

            // --- Agent ---
            Text('${AppStrings.agent} *',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingMembers
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedMemberId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _members.isEmpty
                          ? AppStrings.selectTeamFirst
                          : AppStrings.selectAgent,
                    ),
                    items: _members
                        .map((m) => DropdownMenuItem(
                              value: m['id'] as String,
                              child: Text(m['name'] as String),
                            ))
                        .toList(),
                    validator: (v) => _members.isNotEmpty && v == null
                        ? AppStrings.selectAgent
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedMemberId = value;
                      });
                    },
                  ),
            const SizedBox(height: 32),

            // --- Button ---
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _assign,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.assignment_ind),
                label: Text(_isSaving
                    ? AppStrings.assigningTicket
                    : AppStrings.assignTicket),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assign() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<TicketProvider>();

    final fields = <String, dynamic>{
      'team_id': _selectedTeamId,
      'agent_id': _selectedMemberId,
    };

    final success = await provider.applyStimulus(
      widget.ticket.id,
      widget.stimulus,
      fields: fields,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.stimulus == 'ev_reassign'
              ? AppStrings.ticketReassignedSuccessfully
              : AppStrings.ticketAssignedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Assignment error'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
// Ticket resolution screen
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
    // If the ticket already has a valid service, pre-select it
    final sid = widget.ticket.serviceId;
    if (sid.isNotEmpty && sid != '0') {
      _selectedServiceId = sid;
    }
    _loadServices();
  }

  Future<void> _loadServices() async {
    final provider = context.read<TicketProvider>();
    final services = await provider.getServices();
    if (mounted) {
      // Verify that the pre-selected service exists in the list
      if (_selectedServiceId != null &&
          !services.any((s) => s['id'] == _selectedServiceId)) {
        _selectedServiceId = null;
      }
      setState(() {
        _services = services;
        _isLoadingServices = false;
      });
      // If there is a pre-selected service, load subcategories
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
        title: Text('${AppStrings.resolve} ${widget.ticket.ref}'),
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
                        'To resolve the ticket, you must select a service, a subcategory and describe the solution.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- Service ---
            Text(AppStrings.service,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingServices
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedServiceId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: AppStrings.selectService,
                    ),
                    items: _services
                        .map((s) => DropdownMenuItem(
                              value: s['id'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    validator: (v) =>
                        v == null ? AppStrings.selectService : null,
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

            // --- Subcategory ---
            Text(AppStrings.subcategory,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingSubcategories
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    value: _selectedSubcategoryId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _subcategories.isEmpty
                          ? AppStrings.noSubcategories
                          : AppStrings.selectSubcategory,
                    ),
                    items: _subcategories
                        .map((s) => DropdownMenuItem(
                              value: s['id'] as String,
                              child: Text(s['name'] as String),
                            ))
                        .toList(),
                    validator: (v) => _subcategories.isNotEmpty && v == null
                        ? AppStrings.selectSubcategory
                        : null,
                    onChanged: (value) {
                      setState(() {
                        _selectedSubcategoryId = value;
                      });
                    },
                  ),
            const SizedBox(height: 20),

            // --- Solution ---
            Text(AppStrings.solutionDescription,
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
                hintText: AppStrings.solutionHint,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? AppStrings.enterSolutionDescription
                  : null,
            ),
            const SizedBox(height: 32),

            // --- Button ---
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
                label: Text(
                    _isSaving ? AppStrings.saving : AppStrings.resolveTicket),
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

    // Prepare fields for resolution
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
          content: Text(AppStrings.ticketResolvedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(
          context, true); // returns to actions, which will return to detail
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Resolution error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
