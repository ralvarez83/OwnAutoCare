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

class VehicleListScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final ServiceRecordRepository serviceRecordRepository;
  final GoogleDriveProvider googleDriveProvider;

  const VehicleListScreen({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
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
    setState(() {
      _currentUser = user;
    });
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

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 4,
        title: const Text(
          'My Vehicles',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Email display
          if (_currentUser?.email != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  _currentUser!.email!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          // Logout button
          TextButton.icon(
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _vehicles.length,
        itemBuilder: (context, index) {
          final vehicle = _vehicles[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(vehicle.name),
              subtitle: Text('${vehicle.make} ${vehicle.model} ${vehicle.year}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ServiceRecordListScreen(
                      serviceRecordRepository: widget.serviceRecordRepository,
                      vehicleId: vehicle.id.value,
                      vehicleName: vehicle.name,
                    ),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        final updatedVehicle = await Navigator.of(context).push<Vehicle>(
                          MaterialPageRoute(
                            builder: (context) => EditVehicleScreen(
                              vehicleRepository: widget.vehicleRepository, 
                              vehicle: vehicle
                            ),
                          ),
                        );
                        if (!mounted) return;
                        
                        if (updatedVehicle != null) {
                          setState(() {
                            final index = _vehicles.indexWhere((v) => v.id == updatedVehicle.id);
                            if (index != -1) {
                              _vehicles[index] = updatedVehicle;
                            }
                          });
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error editing vehicle: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Vehicle'),
                          content: Text('Are you sure you want to delete ${vehicle.name}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true && mounted) {
                        setState(() {
                          _isLoading = true;
                        });
                        
                        try {
                          await _deleteVehicle(vehicle.id);
                          await _loadVehicles();
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${vehicle.name} deleted successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error deleting vehicle: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: _isLoading ? null : FloatingActionButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          try {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddVehicleScreen(vehicleRepository: widget.vehicleRepository),
              ),
            );
            // Always reload vehicles when returning from add screen
            if (mounted) {
              await _loadVehicles();
            }
          } catch (e) {
            if (mounted) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding vehicle: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } finally {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          }
        },
        child: const Icon(Icons.add),
      ),
      ),
    );
  }
}