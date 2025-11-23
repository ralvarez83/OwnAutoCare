import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/save_service_record.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';
import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/domain/entities/attachment.dart';
import 'package:image_picker/image_picker.dart';

class ServiceRecordFormScreen extends StatefulWidget {
  final ServiceRecordRepository serviceRecordRepository;
  final GoogleDriveProvider googleDriveProvider;
  final String vehicleId;
  final ServiceRecord? record;

  const ServiceRecordFormScreen({
    super.key,
    required this.serviceRecordRepository,
    required this.googleDriveProvider,
    required this.vehicleId,
    this.record,
  });

  @override
  State<ServiceRecordFormScreen> createState() => _ServiceRecordFormScreenState();
}

class _ServiceRecordFormScreenState extends State<ServiceRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late DateTime _date;
  late String _type;
  late int _mileageKm;
  late double _cost;
  late String _currency;
  String? _notes;
  final List<Part> _parts = [];
  final List<Attachment> _attachments = [];
  final List<XFile> _newAttachments = [];
  Labor? _labor;
  String? _customType;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAttachment() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newAttachments.add(image);
      });
    }
  }

  static const List<String> _serviceTypes = [
    'oil_change',
    'inspection',
    'brake_pads',
    'tires',
    'coolant',
    'battery',
    'itv',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _date = widget.record!.date;
      if (_serviceTypes.contains(widget.record!.type)) {
        _type = widget.record!.type;
      } else {
        _type = 'other';
        _customType = widget.record!.type;
      }
      _mileageKm = widget.record!.mileageKm;
      _cost = widget.record!.cost;
      _currency = widget.record!.currency;
      _notes = widget.record!.notes;
      _parts.addAll(widget.record!.parts);
      _attachments.addAll(widget.record!.attachments);
      _labor = widget.record!.labor;
    } else {
      _date = DateTime.now();
      _type = _serviceTypes.first;
      _mileageKm = 0;
      _cost = 0;
      _currency = 'EUR';
    }
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

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      // Upload new attachments
      for (final file in _newAttachments) {
        final url = await widget.googleDriveProvider.uploadFile(file, 'Attachments');
        if (url != null) {
          _attachments.add(Attachment(
            id: const Uuid().v4(),
            filename: file.name,
            mime: file.mimeType ?? 'application/octet-stream',
            driveProvider: 'google_drive',
            drivePath: url,
            size: await file.length(),
          ));
        }
      }

      final saveServiceRecord = SaveServiceRecord(widget.serviceRecordRepository);
      final record = ServiceRecord(
        id: widget.record?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        date: _date,
        mileageKm: _mileageKm,
        type: _type == 'other' ? (_customType ?? 'other') : _type,
        parts: _parts,
        labor: _labor,
        cost: _cost,
        currency: _currency,
        notes: _notes,
        attachments: _attachments,
      );
      await saveServiceRecord(record);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorSavingServiceRecord(e.toString())),
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
        title: Text(widget.record == null ? l10n.addServiceRecordTitle : l10n.editServiceRecordTitle),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date picker
                ListTile(
                  title: Text(l10n.dateLabel),
                  subtitle: Text(_date.toString().split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _isLoading ? null : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _date = date);
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Service type dropdown
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(labelText: l10n.serviceTypeLabel),
                  items: _serviceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getLocalizedServiceType(context, type)),
                    );
                  }).toList(),
                  onChanged: _isLoading ? null : (value) {
                    if (value != null) setState(() => _type = value);
                  },
                ),
                if (_type == 'other') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _customType,
                    decoration: InputDecoration(
                      labelText: l10n.specifyTypeLabel,
                    ),
                    validator: (value) {
                      if (_type == 'other' && (value == null || value.isEmpty)) {
                        return l10n.vehicleNameRequired; // Reusing "Required" message or generic
                      }
                      return null;
                    },
                    onSaved: (value) => _customType = value,
                    enabled: !_isLoading,
                  ),
                ],
                const SizedBox(height: 16),

                // Mileage
                TextFormField(
                  initialValue: _mileageKm.toString(),
                  decoration: InputDecoration(
                    labelText: l10n.mileageLabel,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.mileageRequired;
                    if (int.tryParse(value) == null) return l10n.validNumberRequired;
                    return null;
                  },
                  onSaved: (value) => _mileageKm = int.parse(value!),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Cost
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: _cost.toString(),
                        decoration: InputDecoration(
                          labelText: l10n.costLabel,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n.costRequired;
                          if (double.tryParse(value) == null) return l10n.validNumberRequired;
                          return null;
                        },
                        onSaved: (value) => _cost = double.parse(value!),
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: InputDecoration(labelText: l10n.currencyLabel),
                        items: const [
                          DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                          DropdownMenuItem(value: 'USD', child: Text('USD')),
                          DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                        ],
                        onChanged: _isLoading ? null : (value) {
                          if (value != null) setState(() => _currency = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  initialValue: _notes,
                  decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                  ),
                  maxLines: 3,
                  onSaved: (value) => _notes = value,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Attachments
                Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._attachments.map((a) => Chip(
                      label: Text(a.filename),
                      onDeleted: () => setState(() => _attachments.remove(a)),
                    )),
                    ..._newAttachments.map((f) => Chip(
                      label: Text(f.name),
                      onDeleted: () => setState(() => _newAttachments.remove(f)),
                      avatar: const Icon(Icons.upload, size: 16),
                    )),
                    ActionChip(
                      avatar: const Icon(Icons.add),
                      label: const Text('Add Photo'),
                      onPressed: _pickAttachment,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm,
                  child: Text(l10n.saveServiceRecordButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}