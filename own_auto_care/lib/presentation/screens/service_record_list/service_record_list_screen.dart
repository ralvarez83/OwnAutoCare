import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/list_service_records.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/presentation/screens/service_record_form/service_record_form_screen.dart';
import 'package:intl/intl.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/presentation/widgets/service_timeline_tile.dart';
import 'package:own_auto_care/presentation/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_auto_care/presentation/widgets/tire_pressure_widget.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/presentation/screens/edit_vehicle/edit_vehicle_screen.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';

class ServiceRecordListScreen extends StatefulWidget {
  final ServiceRecordRepository serviceRecordRepository;
  final VehicleRepository vehicleRepository;
  final Vehicle vehicle;
  final GoogleDriveProvider googleDriveProvider;

  const ServiceRecordListScreen({
    super.key,
    required this.serviceRecordRepository,
    required this.vehicleRepository,
    required this.vehicle,
    required this.googleDriveProvider,
  });

  @override
  State<ServiceRecordListScreen> createState() => _ServiceRecordListScreenState();
}

class _ServiceRecordListScreenState extends State<ServiceRecordListScreen> {
  late final ListServiceRecords _listServiceRecords;
  List<ServiceRecord> _records = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listServiceRecords = ListServiceRecords(widget.serviceRecordRepository);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await _listServiceRecords(widget.vehicle.id.value);
      // Sort by date descending
      records.sort((a, b) => b.date.compareTo(a.date));
      setState(() {
        _records = records;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorLoadingRecords(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double amount, String currency) {
    return NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 100.0,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: l10n.editVehicleTitle,
                  onPressed: () async {
                    // Navigate to edit screen
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditVehicleScreen(
                          vehicleRepository: widget.vehicleRepository,
                          vehicle: widget.vehicle,
                          googleDriveProvider: widget.googleDriveProvider,
                        ),
                      ),
                    );
                    // Reload vehicle data after edit
                    _loadRecords();
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  (widget.vehicle.name != null && widget.vehicle.name!.isNotEmpty)
                      ? '${widget.vehicle.name} (${widget.vehicle.year})'
                      : '${widget.vehicle.make} ${widget.vehicle.model} (${widget.vehicle.year})',
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: false, // Start collapsed
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          title: Text(
                            l10n.vehicleSummaryTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                // Vehicle Details
                                if (widget.vehicle.plates != null) ...[
                                  _buildInfoRow(
                                    context,
                                    label: l10n.platesLabel,
                                    value: widget.vehicle.plates!,
                                  ),
                                ],
                                if (widget.vehicle.vin != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(
                                    context,
                                    label: l10n.vinLabel,
                                    value: widget.vehicle.vin!,
                                  ),
                                ],
                                const SizedBox(height: 12),
                                const Divider(),
                                const SizedBox(height: 8),
                                // Mileage and Cost Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.latestMileageLabel,
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _records.isNotEmpty
                                              ? '${_records.first.mileageKm} km'
                                              : l10n.noMileageRecorded,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Tire Pressure Visual
                                if (widget.vehicle.tirePressures.isNotEmpty)
                                  TirePressureWidget(
                                    initialConfigurations: widget.vehicle.tirePressures,
                                    onChanged: (val) {}, // Read-only
                                    isEditing: false,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.recordsCount(_records.length),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Calculate total cost
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.totalCost(_formatCurrency(_records.fold(0, (sum, item) => sum + item.cost), _records.isNotEmpty ? _records.first.currency : 'EUR')),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: _records.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noServiceRecords,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final record = _records[index];
                          return ServiceTimelineTile(
                            record: record,
                            isFirst: index == 0,
                            isLast: index == _records.length - 1,
                            onTap: () async {
                                // Edit on tap for now, or show details
                                setState(() => _isLoading = true);
                                try {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ServiceRecordFormScreen(
                                        serviceRecordRepository: widget.serviceRecordRepository,
                                        vehicleId: widget.vehicle.id.value,
                                        googleDriveProvider: widget.googleDriveProvider,
                                        record: record,
                                      ),
                                    ),
                                  );
                                  await _loadRecords();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.errorEditingRecord(e.toString())),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                            },
                            onEdit: () async {
                              setState(() => _isLoading = true);
                              try {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceRecordFormScreen(
                                      serviceRecordRepository: widget.serviceRecordRepository,
                                      vehicleId: widget.vehicle.id.value,
                                      googleDriveProvider: widget.googleDriveProvider,
                                      record: record,
                                    ),
                                  ),
                                );
                                await _loadRecords();
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.errorEditingRecord(e.toString())),
                                    backgroundColor: Theme.of(context).colorScheme.error,
                                  ),
                                );
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                            onDelete: () async {
                              final delete = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(l10n.deleteServiceRecordTitle),
                                    content: Text(l10n.deleteServiceRecordContent),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(l10n.cancel),
                                        onPressed: () => Navigator.of(context).pop(false),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (delete == true) {
                                setState(() => _isLoading = true);
                                try {
                                  await widget.serviceRecordRepository.deleteServiceRecord(record.id);
                                  await _loadRecords();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.serviceRecordDeleted),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.errorDeletingRecord(e.toString())),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _isLoading = false);
                                }
                              }
                            },
                          );
                        },
                        childCount: _records.length,
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            try {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ServiceRecordFormScreen(
                    serviceRecordRepository: widget.serviceRecordRepository,
                    vehicleId: widget.vehicle.id.value,
                    googleDriveProvider: widget.googleDriveProvider,
                  ),
                ),
              );
              await _loadRecords();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorAddingRecord(e.toString())),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          icon: const Icon(Icons.add),
          label: Text(l10n.addRecord),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}