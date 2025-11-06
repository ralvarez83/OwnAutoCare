import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/update_vehicle.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';

class EditVehicleScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final Vehicle vehicle;

  const EditVehicleScreen({
    super.key, 
    required this.vehicleRepository, 
    required this.vehicle
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  late String _vehicleName;
  late String _make;
  late String _model;
  late int _year;

  @override
  void initState() {
    super.initState();
    _vehicleName = widget.vehicle.name;
    _make = widget.vehicle.make;
    _model = widget.vehicle.model;
    _year = widget.vehicle.year;
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    
    try {
      final updatedVehicle = widget.vehicle.copyWith(
        name: _vehicleName,
        make: _make,
        model: _model,
        year: _year,
      );

      final updateVehicle = UpdateVehicle(widget.vehicleRepository);
      await updateVehicle(updatedVehicle);

      if (!mounted) return;
      Navigator.of(context).pop(updatedVehicle);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating vehicle: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vehicle'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _vehicleName,
                  decoration: const InputDecoration(
                    labelText: 'Vehicle Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a vehicle name';
                    }
                    return null;
                  },
                  onSaved: (value) => _vehicleName = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _make,
                  decoration: const InputDecoration(
                    labelText: 'Make',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the make';
                    }
                    return null;
                  },
                  onSaved: (value) => _make = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _model,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the model';
                    }
                    return null;
                  },
                  onSaved: (value) => _model = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _year.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Year',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the year';
                    }
                    return null;
                  },
                  onSaved: (value) => _year = int.parse(value!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveVehicle,
                  child: const Text('Save Vehicle'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
