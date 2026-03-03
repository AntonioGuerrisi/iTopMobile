import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../models/ticket.dart';
import '../widgets/ticket_card.dart';
import '../widgets/status_filter_chips.dart';
import 'ticket_detail_screen.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TicketProvider>();
      if (provider.tickets.isEmpty) {
        provider.loadTickets();
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
                  hintText: 'Cerca ticket...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (value) {
                  context.read<TicketProvider>().searchTickets(value);
                },
              )
            : const Text('Ticket'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  context.read<TicketProvider>().searchTickets('');
                }
              });
            },
          ),
          // Filtro "I miei ticket"
          Consumer<TicketProvider>(
            builder: (context, provider, _) => IconButton(
              icon: Icon(
                provider.myTicketsOnly ? Icons.person : Icons.person_outline,
                color: provider.myTicketsOnly ? Colors.amber : null,
              ),
              tooltip: provider.myTicketsOnly
                  ? 'Mostra tutti i ticket'
                  : 'Solo i miei ticket',
              onPressed: () => provider.toggleMyTickets(),
            ),
          ),
          // Selettore periodo
          PopupMenuButton<TicketPeriod>(
            icon: const Icon(Icons.date_range),
            tooltip: 'Periodo',
            onSelected: (period) {
              context.read<TicketProvider>().changePeriod(period);
            },
            itemBuilder: (context) {
              final current = context.read<TicketProvider>().selectedPeriod;
              return TicketPeriod.values
                  .map((p) => PopupMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            if (p == current)
                              const Icon(Icons.check,
                                  size: 18, color: Colors.blue)
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(p.label),
                          ],
                        ),
                      ))
                  .toList();
            },
          ),
          // Selettore ordinamento
          PopupMenuButton<TicketSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: 'Ordinamento',
            onSelected: (order) {
              context.read<TicketProvider>().changeSortOrder(order);
            },
            itemBuilder: (context) {
              final current = context.read<TicketProvider>().sortOrder;
              return TicketSortOrder.values
                  .map((o) => PopupMenuItem(
                        value: o,
                        child: Row(
                          children: [
                            if (o == current)
                              const Icon(Icons.check,
                                  size: 18, color: Colors.blue)
                            else
                              const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(o.label),
                          ],
                        ),
                      ))
                  .toList();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TicketProvider>().loadTickets();
            },
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.tickets.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento ticket...'),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.tickets.isEmpty) {
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
                      onPressed: () => provider.loadTickets(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Filtri per stato
              StatusFilterChips(
                statusCounts: provider.statusCounts,
                selectedStatus: provider.statusFilter,
                onStatusSelected: (status) {
                  provider.filterByStatus(status);
                },
              ),

              // Periodo attivo + filtro attivo + conteggio risultati
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.date_range, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      provider.selectedPeriod.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    if (provider.myTicketsOnly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'I miei',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    Text(
                      '· ${provider.tickets.length} ticket',
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

              // Lista ticket
              Expanded(
                child: provider.tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Nessun ticket trovato',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadTickets(),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: provider.tickets.length,
                          itemBuilder: (context, index) {
                            final ticket = provider.tickets[index];
                            return TicketCard(
                              ticket: ticket,
                              onTap: () => _openTicketDetail(ticket),
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

  void _openTicketDetail(Ticket ticket) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TicketDetailScreen(ticket: ticket),
      ),
    );
  }
}
