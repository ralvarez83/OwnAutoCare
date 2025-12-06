import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class ServiceTimelineTile extends StatelessWidget {
  final ServiceRecord record;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ServiceTimelineTile({
    super.key,
    required this.record,
    required this.isFirst,
    required this.isLast,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  IconData _getIconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('oil')) return Icons.oil_barrel;
    if (t.contains('tire') || t.contains('wheel')) return Icons.tire_repair;
    if (t.contains('battery')) return Icons.battery_charging_full;
    if (t.contains('brake')) return Icons.build_circle;
    if (t.contains('inspection') || t.contains('itv')) return Icons.verified_user;
    return Icons.build;
  }

  Color _getColorForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('oil')) return Colors.amber;
    if (t.contains('tire')) return Colors.blueGrey;
    if (t.contains('battery')) return Colors.green;
    if (t.contains('brake')) return Colors.redAccent;
    return AppColors.primary;
  }

  String _formatCurrency(double amount, String currency) {
    return NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    ).format(amount);
  }

  String _getLocalizedServiceType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'oil_change':
        return l10n.serviceTypeOilChange;
      case 'inspection':
        return l10n.serviceTypeInspection;
      case 'brake_pads':
        return l10n.serviceTypeBrakePads;
      case 'tires':
        return l10n.serviceTypeTires;
      case 'coolant':
        return l10n.serviceTypeCoolant;
      case 'battery':
        return l10n.serviceTypeBattery;
      case 'itv':
        return l10n.serviceTypeItv;
      case 'other':
        return l10n.serviceTypeOther;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Determine display properties based on items
    // Determine display properties based on visit type
    String title;
    IconData displayIcon;
    Color displayColor;

    if (record.visitType == VisitType.itv) {
      title = '${l10n.visitTypeItv}: ${record.itvResult == ItvResult.favorable ? l10n.itvResultFavorable : l10n.itvResultUnfavorable}';
      displayIcon = record.itvResult == ItvResult.favorable ? Icons.check_circle : Icons.cancel;
      displayColor = record.itvResult == ItvResult.favorable ? Colors.green : Colors.red;
    } else {
      final primaryType = record.items.isNotEmpty ? record.items.first.type : 'other';
      final isMultiple = record.items.length > 1;
      
      displayIcon = isMultiple ? Icons.car_repair : _getIconForType(primaryType);
      displayColor = isMultiple ? AppColors.primary : _getColorForType(primaryType);
      
      title = record.items.map((i) => _getLocalizedServiceType(context, i.type)).join(', ');
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Column
          SizedBox(
            width: 50,
            child: Column(
              children: [
                // Top Line
                Expanded(
                  flex: 1,
                  child: Container(
                    width: 2,
                    color: isFirst ? Colors.transparent : AppColors.surface,
                  ),
                ),
                // Dot
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(
                      color: displayColor,
                      width: 3,
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                // Bottom Line
                Expanded(
                  flex: 5,
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppColors.surface,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: displayColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                displayIcon,
                                color: displayColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isEmpty ? l10n.serviceTypeOther : title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    DateFormat('MMM d, y').format(record.date),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                              onSelected: (value) {
                                if (value == 'edit') onEdit();
                                if (value == 'delete') onDelete();
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18),
                                      const SizedBox(width: 8),
                                      Text(l10n.edit),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, size: 18, color: AppColors.error),
                                      const SizedBox(width: 8),
                                      Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Details
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.speed, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${NumberFormat('#,###').format(record.mileageKm)} km',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            Text(
                              _formatCurrency(record.cost, record.currency),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      
                      if (record.notes != null && record.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            record.notes!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontStyle: FontStyle.italic,
                                ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
