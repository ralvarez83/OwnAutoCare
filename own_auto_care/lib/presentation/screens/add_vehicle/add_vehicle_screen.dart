import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/create_vehicle.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/domain/value_objects/vehicle_id.dart';
import 'package:uuid/uuid.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/presentation/widgets/tire_pressure_widget.dart';
import 'package:own_auto_care/domain/entities/tire_pressure_configuration.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class AddVehicleScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final GoogleDriveProvider googleDriveProvider;

  const AddVehicleScreen({
    super.key,
    required this.vehicleRepository,
    required this.googleDriveProvider,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _vehicleName = '';
  String _make = '';
  String _model = '';
  int _year = 0;

  List<TirePressureConfiguration> _tirePressures = [];
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addVehicleTitle),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile != null
                            ? DecorationImage(
                                image: kIsWeb
                                    ? NetworkImage(_imageFile!.path)
                                    : FileImage(File(_imageFile!.path)) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _imageFile == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                                const SizedBox(height: 8),
                                Text(l10n.addPhotoLabel ?? 'Add Photo', style: TextStyle(color: Colors.grey[600])),
                              ],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.vehicleNameLabel,
                    ),
                    // Name is optional now
                    validator: null,
                    onSaved: (value) {
                      _vehicleName = (value == null || value.isEmpty) ? '' : value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.makeLabel,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.makeRequired;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _make = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.modelLabel,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.modelRequired;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _model = value!;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: l10n.yearLabel,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.yearRequired;
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _year = int.parse(value!);
                    },
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 16),
                  TirePressureWidget(
                    initialConfigurations: const [], // Empty will trigger defaults in widget
                    onChanged: (configs) {
                      _tirePressures = configs;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        setState(() => _isLoading = true);
                          try {
                            String? photoUrl;
                            if (_imageFile != null) {
                              photoUrl = await widget.googleDriveProvider.uploadFile(_imageFile!, 'Photos');
                            }

                            final newVehicle = Vehicle(
                              id: VehicleId(const Uuid().v4()),
                              name: _vehicleName,
                              make: _make,
                              model: _model,
                              year: _year,
                              photoUrl: photoUrl,
                              tirePressures: _tirePressures,
                            );

                            final createVehicle = CreateVehicle(widget.vehicleRepository);
                            await createVehicle(newVehicle);
                            
                            if (!mounted) return;
                            
                            // Delay pop to avoid !_debugLocked error
                            await Future.delayed(Duration.zero);
                            if (!mounted) return;
                            Navigator.of(context).pop(newVehicle);
                        } catch (e) {
                          if (!mounted) return;
                          setState(() => _isLoading = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorAddingVehicle(e.toString())),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: Text(l10n.saveVehicleButton),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}