import 'package:flutter/material.dart';
import 'package:nucleo_casa_decor_android/mobile/models/transaction.dart';
import 'package:intl/intl.dart';

class RecentActivityCard extends StatefulWidget {
  final PointTransaction transaction;
  final int index; // Novo parâmetro

  const RecentActivityCard({super.key, required this.transaction, required this.index});

  @override
  State<RecentActivityCard> createState() => _RecentActivityCardState();
}

class _RecentActivityCardState extends State<RecentActivityCard> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = widget.transaction.type == TransactionType.earned;

    // Alternar entre duas cores com base no índice
    final isEvenIndex = widget.index % 2 == 0;
    final iconColor = isEvenIndex ? theme.colorScheme.secondary : theme.colorScheme.error;
    final iconBackgroundColor = iconColor.withValues(alpha: 0.15);
    final tagBackgroundColor = iconColor.withValues(alpha: 0.1);

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showTransactionDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEarned ? Icons.store_rounded : Icons.remove_circle,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Compra em ',
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: widget.transaction.companyName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.business,
                              size: 14,
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.transaction.companyName,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: theme.colorScheme.onSurface.withAlpha(153),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(widget.transaction.date),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(153),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: tagBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${isEarned ? '+' : ''}${widget.transaction.valor.toStringAsFixed(2)} pts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thatDay = DateTime(date.year, date.month, date.day);

    final difference = today.difference(thatDay).inDays;

    if (difference == 0) return 'Hoje';
    if (difference == 1) return 'Ontem';
    if (difference < 7) return '${difference}d atrás';
    return DateFormat('dd/MM').format(date);
  }

  void _showTransactionDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isEarned = widget.transaction.type == TransactionType.earned;

    final isEvenIndex = widget.index % 2 == 0;
    final iconColor = isEvenIndex ? theme.colorScheme.secondary : theme.colorScheme.error;
    final iconBackgroundColor = iconColor.withValues(alpha: 0.15);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEarned ? Icons.add_circle : Icons.remove_circle,
                      color: iconColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEarned ? 'Pontos Ganhos' : 'Pontos Gastos',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                        Text(
                          '${isEarned ? '+' : ''}${widget.transaction.points.toStringAsFixed(2)} pontos',

                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _DetailRow(
                icon: Icons.description,
                label: 'Descrição',
                value: widget.transaction.description,
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.business,
                label: 'Empresa',
                value: widget.transaction.companyName,
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Data',
                value: DateFormat('dd/MM/yyyy - HH:mm').format(widget.transaction.date),
              ),
              const SizedBox(height: 16),
              _DetailRow(icon: Icons.tag, label: 'ID da Transação', value: widget.transaction.id),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha(153),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
