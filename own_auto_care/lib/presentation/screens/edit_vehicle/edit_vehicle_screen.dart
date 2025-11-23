import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/update_vehicle.dart';
import 'package:own_auto_care/domain/entities/vehicle.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class EditVehicleScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final GoogleDriveProvider googleDriveProvider;
  final Vehicle vehicle;

  const EditVehicleScreen({
    super.key, 
    required this.vehicleRepository, 
    required this.googleDriveProvider,
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
  String? _photoUrl;
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
  void initState() {
    super.initState();
    _vehicleName = widget.vehicle.name ?? '';
    _make = widget.vehicle.make;
    _model = widget.vehicle.model;
    _year = widget.vehicle.year;
    _photoUrl = widget.vehicle.photoUrl;
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isLoading = true);
    
    try {
      if (_imageFile != null) {
        _photoUrl = await widget.googleDriveProvider.uploadFile(_imageFile!, 'Photos');
      }

      final updatedVehicle = widget.vehicle.copyWith(
        name: _vehicleName,
        make: _make,
        model: _model,
        year: _year,
        photoUrl: _photoUrl,
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
          content: Text(AppLocalizations.of(context)!.errorEditingVehicle(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editVehicleTitle),
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
                          : _photoUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_photoUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                    ),
                    child: (_imageFile == null && _photoUrl == null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey[600]),
                              const SizedBox(height: 8),
                              Text(l10n.addPhotoLabel ?? 'Change Photo', style: TextStyle(color: Colors.grey[600])),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _vehicleName,
                  decoration: InputDecoration(
                    labelText: l10n.vehicleNameLabel,
                  ),
                  // Name is optional now
                  validator: null,
                  onSaved: (value) => _vehicleName = (value == null || value.isEmpty) ? '' : value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _make,
                  decoration: InputDecoration(
                    labelText: l10n.makeLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.makeRequired;
                    }
                    return null;
                  },
                  onSaved: (value) => _make = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _model,
                  decoration: InputDecoration(
                    labelText: l10n.modelLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.modelRequired;
                    }
                    return null;
                  },
                  onSaved: (value) => _model = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _year.toString(),
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
                  onSaved: (value) => _year = int.parse(value!),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveVehicle,
                  child: Text(l10n.saveVehicleButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
