import 'package:flutter/material.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onAddRecord;
  final VoidCallback onReminders;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onTap,
    required this.onAddRecord,
    required this.onReminders,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: vehicle.photoUrl != null
                ? DecorationImage(
                    image: NetworkImage(vehicle.photoUrl!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.6),
                      BlendMode.darken,
                    ),
                  )
                : null,
            gradient: vehicle.photoUrl == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.surface.withOpacity(0.8),
                    ],
                  )
                : null,
          ),
          child: Column(
            children: [
              // Header with vehicle info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.directions_car_filled,
                        size: 32,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Vehicle Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (vehicle.name != null && vehicle.name!.isNotEmpty)
                                ? vehicle.name!
                                : '${vehicle.make} ${vehicle.model}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.make} ${vehicle.model} ${vehicle.year}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          if (vehicle.plates != null) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                vehicle.plates!,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Menu Button
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                      onSelected: (value) {
                        if (value == 'edit') onEdit();
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 20),
                              const SizedBox(width: 12),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete, size: 20, color: AppColors.error),
                              const SizedBox(width: 12),
                              Text(l10n.delete, style: const TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Divider
              Divider(height: 1, color: AppColors.textSecondary.withOpacity(0.1)),
              // Quick Actions
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: onAddRecord,
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.addRecord,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.textSecondary.withOpacity(0.1),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: onReminders,
                      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 20, color: AppColors.secondary),
                            const SizedBox(width: 8),
                            Text(
                              l10n.reminders,
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
