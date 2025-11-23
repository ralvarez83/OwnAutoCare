import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:own_auto_care/application/use_cases/delete_vehicle.dart';
import 'package:own_auto_care/application/use_cases/list_vehicles.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/repositories.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:own_auto_care/presentation/screens/add_vehicle/add_vehicle_screen.dart';
import 'package:own_auto_care/presentation/screens/edit_vehicle/edit_vehicle_screen.dart';
import 'package:own_auto_care/presentation/screens/service_record_list/service_record_list_screen.dart';
import 'package:own_auto_care/presentation/screens/reminder_list/reminder_list_screen.dart';
import 'package:own_auto_care/presentation/screens/settings/settings_screen.dart';
import 'package:own_auto_care/presentation/widgets/vehicle_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/presentation/screens/service_record_form/service_record_form_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final ServiceRecordRepository serviceRecordRepository;
  final ReminderRepository reminderRepository;
  final GoogleDriveProvider googleDriveProvider;

  const VehicleListScreen({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
    required this.googleDriveProvider,
  });

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  late final ListVehicles _listVehicles;
  late final DeleteVehicle _deleteVehicle;
  GoogleSignInAccount? _currentUser;
  List<Vehicle> _vehicles = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listVehicles = ListVehicles(widget.vehicleRepository);
    _deleteVehicle = DeleteVehicle(widget.vehicleRepository);
    _loadCurrentUser();
    _loadVehicles();
  }

  Future<void> _loadCurrentUser() async {
    final user = await widget.googleDriveProvider.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _loadVehicles() async {
    final vehicles = await _listVehicles();
    setState(() {
      _vehicles = vehicles;
    });
  }

  Future<void> _logout() async {
    setState(() => _isLoading = true);
    try {
      await widget.googleDriveProvider.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showVehicleForm({Vehicle? vehicle}) async {
    setState(() => _isLoading = true);
    try {
      final updatedVehicle = await Navigator.of(context).push<Vehicle>(
        MaterialPageRoute(
          builder: (context) => vehicle == null
              ? AddVehicleScreen(
                  vehicleRepository: widget.vehicleRepository,
                  googleDriveProvider: widget.googleDriveProvider,
                )
              : EditVehicleScreen(
                  vehicleRepository: widget.vehicleRepository,
                  googleDriveProvider: widget.googleDriveProvider,
                  vehicle: vehicle,
                ),
        ),
      );
      if (!mounted) return;

      if (updatedVehicle != null) {
        setState(() {
          final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
          if (index != -1) {
            _vehicles[index] = updatedVehicle;
          } else {
            _vehicles.add(updatedVehicle); // For new vehicle added
          }
        });
      }
      await _loadVehicles(); // Reload all vehicles to ensure order/completeness
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(vehicle == null
                ? AppLocalizations.of(context)!.errorAddingVehicle(e.toString())
                : AppLocalizations.of(context)!.errorEditingVehicle(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  l10n.vehicleListTitle,
                  style: GoogleFonts.outfit(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  tooltip: l10n.settings,
                  onSelected: (value) {
                    if (value == 'settings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            vehicleRepository: widget.vehicleRepository,
                            serviceRecordRepository: widget.serviceRecordRepository,
                            reminderRepository: widget.reminderRepository,
                          ),
                        ),
                      );
                    } else if (value == 'logout') {
                      _logout();
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings, size: 20, color: Theme.of(context).colorScheme.onSurface),
                          const SizedBox(width: 12),
                          Text(l10n.settings),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 20, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 12),
                          Text(l10n.logout, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _vehicles.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noVehicles,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              l10n.addFirstCarPrompt,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          final vehicle = _vehicles[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: VehicleCard(
                              vehicle: vehicle,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceRecordListScreen(
                                      serviceRecordRepository: widget.serviceRecordRepository,
                                      vehicleId: vehicle.id.value,
                                      vehicleName: (vehicle.name != null && vehicle.name!.isNotEmpty)
                                          ? vehicle.name!
                                          : '${vehicle.make} ${vehicle.model}',
                                      googleDriveProvider: widget.googleDriveProvider,
                                    ),
                                  ),
                                );
                              },
                              onAddRecord: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ServiceRecordFormScreen(
                                      serviceRecordRepository: widget.serviceRecordRepository,
                                      vehicleId: vehicle.id.value,
                                      googleDriveProvider: widget.googleDriveProvider,
                                    ),
                                  ),
                                );
                              },
                              onReminders: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ReminderListScreen(
                                      reminderRepository: widget.reminderRepository,
                                      vehicleId: vehicle.id.value,
                                      vehicleName: (vehicle.name != null && vehicle.name!.isNotEmpty)
                                          ? vehicle.name!
                                          : '${vehicle.make} ${vehicle.model}',
                                    ),
                                  ),
                                );
                              },
                              onEdit: () => _showVehicleForm(vehicle: vehicle),
                              onDelete: () async {
                                final shouldDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(l10n.deleteVehicleConfirmTitle),
                                    content: Text(l10n.deleteVehicleConfirmContent),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(false),
                                        child: Text(l10n.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true);
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                        child: Text(l10n.delete),
                                      ),
                                    ],
                                  ),
                                );

                                if (shouldDelete == true && mounted) {
                                  setState(() => _isLoading = true);
                                  try {
                                    await _deleteVehicle(vehicle.id);
                                    await _loadVehicles();
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Vehicle deleted successfully'), // Could be localized too but keeping simple for now
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setState(() => _isLoading = false);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.errorGeneric(e.toString())),
                                          backgroundColor: Theme.of(context).colorScheme.error,
                                        ),
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                          );
                        },
                        childCount: _vehicles.length,
                      ),
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showVehicleForm(),
          icon: const Icon(Icons.add),
          label: Text(l10n.addVehicle),
        ),
      ),
    );
  }
}