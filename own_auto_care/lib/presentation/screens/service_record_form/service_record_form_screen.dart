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
import 'package:intl/intl.dart';

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
  State<ServiceRecordFormScreen> createState() =>
      _ServiceRecordFormScreenState();
}

class _ServiceRecordFormScreenState extends State<ServiceRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late DateTime _date;
  int? _mileageKm;
  late String _currency;
  String? _recordName; // NEW: Optional custom name for the record
  String? _notes;
  VisitType _visitType = VisitType.maintenance;
  ItvResult _itvResult = ItvResult.favorable;
  double _itvCost = 0.0;
  final List<ServiceItem> _items = [];
  final List<Attachment> _attachments = [];
  final List<XFile> _newAttachments = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAttachment() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newAttachments.add(image);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      _date = widget.record!.date;
      _mileageKm = widget.record!.mileageKm;
      _currency = widget.record!.currency;
      _recordName = widget.record!.name; // Load existing name
      _notes = widget.record!.notes;
      _visitType = widget.record!.visitType;
      _itvResult = widget.record!.itvResult ?? ItvResult.favorable;
      _items.addAll(widget.record!.items);
      
      // If ITV, initialize cost from the first item if exists, or record cost
      if (_visitType == VisitType.itv) {
        _itvCost = widget.record!.cost;
      }
      
      _attachments.addAll(widget.record!.attachments);
    } else {
      _date = DateTime.now();
      _mileageKm = null;
      _currency = 'EUR';
      _recordName = null; // Initialize as empty for new records
      _visitType = VisitType.maintenance;
    }
  }

  double get _totalCost => _items.fold(0, (sum, item) => sum + item.cost);

  String _formatCurrency(double amount) {
    return NumberFormat.currency(symbol: _currency, decimalDigits: 2)
        .format(amount);
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

  String _getLocalizedVisitType(BuildContext context, VisitType type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case VisitType.maintenance: return l10n.visitTypeMaintenance;
      case VisitType.repair: return l10n.visitTypeRepair;
      case VisitType.itv: return l10n.visitTypeItv;
      case VisitType.other: return l10n.visitTypeOther;
    }
  }

  String _getLocalizedItvResult(BuildContext context, ItvResult result) {
    final l10n = AppLocalizations.of(context)!;
    switch (result) {
      case ItvResult.favorable: return l10n.itvResultFavorable;
      case ItvResult.unfavorable: return l10n.itvResultUnfavorable;
    }
  }

  Future<void> _showServiceItemDialog({ServiceItem? item, int? index}) async {
    final result = await showDialog<ServiceItem>(
      context: context,
      builder: (context) => _ServiceItemDialog(
        initialItem: item,
        currency: _currency,
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _items[index] = result;
        } else {
          _items.add(result);
        }
      });
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorNoServicesAdded ?? 'Please add at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload new attachments
      for (final file in _newAttachments) {
        final url =
            await widget.googleDriveProvider.uploadFile(file, 'Attachments');
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
        visitType: _visitType,
        itvResult: _visitType == VisitType.itv ? _itvResult : null,
        items: _visitType == VisitType.itv 
            ? [ServiceItem(type: 'itv', cost: _itvCost, notes: 'Result: ${_itvResult.name}')] 
            : _items,
        cost: _visitType == VisitType.itv ? _itvCost : _totalCost,
        currency: _currency,
        name: _recordName, // NEW: Pass the custom name
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
          content: Text(AppLocalizations.of(context)!
              .errorSavingServiceRecord(e.toString())),
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
        title: Text(widget.record == null
            ? l10n.addServiceRecordTitle
            : l10n.editServiceRecordTitle),
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
                // Section: Visit Details
                Text(
                  'Visit Details', // TODO: Localize
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Visit Type Selection
                DropdownButtonFormField<VisitType>(
                  value: _visitType,
                  decoration: InputDecoration(labelText: l10n.visitTypeLabel),
                  items: VisitType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getLocalizedVisitType(context, type)),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _visitType = value;
                              // If switching to ITV, specific handling could be done here if needed
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),

                // Record Name (Optional)
                TextFormField(
                  initialValue: _recordName,
                  onChanged: (value) {
                    setState(() => _recordName = value.isEmpty ? null : value);
                  },
                  decoration: InputDecoration(
                    labelText: l10n.serviceRecordName,
                    hintText: l10n.serviceRecordNameHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  maxLength: 100,
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                    return Text(
                      '$currentLength/${maxLength ?? 0}',
                      style: Theme.of(context).textTheme.bodySmall,
                    );
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // ITV Specific Fields
                if (_visitType == VisitType.itv) ...[
                  DropdownButtonFormField<ItvResult>(
                    value: _itvResult,
                    decoration: InputDecoration(labelText: l10n.itvResultLabel),
                    items: ItvResult.values.map((result) {
                      return DropdownMenuItem(
                        value: result,
                        child: Text(_getLocalizedItvResult(context, result)),
                      );
                    }).toList(),
                    onChanged: _isLoading
                        ? null
                        : (value) {
                            if (value != null) setState(() => _itvResult = value);
                          },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _itvCost.toString(),
                    decoration: InputDecoration(
                      labelText: '${l10n.itvCostLabel} ($_currency)',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.costRequired;
                      }
                      if (double.tryParse(value) == null) {
                        return l10n.validNumberRequired;
                      }
                      return null;
                    },
                    onSaved: (value) => _itvCost = double.parse(value!),
                    enabled: !_isLoading,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.dateLabel),
                  subtitle:
                      Text(DateFormat.yMMMd().format(_date)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _isLoading
                      ? null
                      : () async {
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
                const SizedBox(height: 8),

                // Mileage
                TextFormField(
                  initialValue: _mileageKm?.toString() ?? '',
                  decoration: InputDecoration(
                    labelText: l10n.mileageLabel,
                    suffixText: 'km',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (int.tryParse(value) == null) {
                        return l10n.validNumberRequired;
                      }
                    }
                    return null;
                  },
                  onSaved: (value) => _mileageKm = value != null && value.isNotEmpty ? int.parse(value) : null,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),

                // Currency Selection (Global for the visit)
                DropdownButtonFormField<String>(
                  value: _currency,
                  decoration: InputDecoration(labelText: l10n.currencyLabel),
                  items: const [
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) setState(() => _currency = value);
                        },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  initialValue: _notes,
                  decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                    hintText: 'Shop name, location, or general notes', // TODO: Localize hint if possible
                  ),
                  maxLines: 3,
                  onSaved: (value) => _notes = value,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),


                // Section: Services (Hidden for ITV)
                if (_visitType != VisitType.itv) ...[
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Services', // TODO: Localize
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: _isLoading ? null : () => _showServiceItemDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Service'), // TODO: Localize
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_items.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: const Center(
                      child: Text('No services added yet'), // TODO: Localize
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(_getIconForServiceType(item.type)),
                          ),
                          title: Text(_getLocalizedServiceType(context, item.type)),
                          subtitle: Text(item.notes ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatCurrency(item.cost),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: _isLoading ? null : () => _showServiceItemDialog(item: item, index: index),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _items.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total Cost: ${_formatCurrency(_visitType == VisitType.itv ? _itvCost : _totalCost)}', // TODO: Localize
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

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

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _saveForm,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(l10n.saveServiceRecordButton),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForServiceType(String type) {
    if (type.contains('oil')) return Icons.oil_barrel;
    if (type.contains('tire')) return Icons.tire_repair;
    if (type.contains('brake')) return Icons.build_circle;
    return Icons.build;
  }
}

class _ServiceItemDialog extends StatefulWidget {
  final ServiceItem? initialItem;
  final String currency;

  const _ServiceItemDialog({this.initialItem, required this.currency});

  @override
  State<_ServiceItemDialog> createState() => _ServiceItemDialogState();
}

class _ServiceItemDialogState extends State<_ServiceItemDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late double _cost;
  String? _notes;
  String? _customType;

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
    if (widget.initialItem != null) {
      if (_serviceTypes.contains(widget.initialItem!.type)) {
        _type = widget.initialItem!.type;
      } else {
        _type = 'other';
        _customType = widget.initialItem!.type;
      }
      _cost = widget.initialItem!.cost;
      _notes = widget.initialItem!.notes;
    } else {
      _type = _serviceTypes.first;
      _cost = 0;
    }
  }
  
  String _getLocalizedServiceType(BuildContext context, String type) {
    // This duplicates logic but good enough for now. 
    // Ideally should be static or shared.
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'oil_change': return l10n.serviceTypeOilChange;
      case 'inspection': return l10n.serviceTypeInspection;
      case 'brake_pads': return l10n.serviceTypeBrakePads;
      case 'tires': return l10n.serviceTypeTires;
      case 'coolant': return l10n.serviceTypeCoolant;
      case 'battery': return l10n.serviceTypeBattery;
      case 'itv': return l10n.serviceTypeItv;
      case 'other': return l10n.serviceTypeOther;
      default: return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(widget.initialItem == null ? 'Add Service' : 'Edit Service'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type
               DropdownButtonFormField<String>(
                  value: _type,
                  decoration: InputDecoration(labelText: l10n.serviceTypeLabel),
                  items: _serviceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getLocalizedServiceType(context, type)),
                    );
                  }).toList(),
                  onChanged: (value) {
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
                        return 'Required';
                      }
                      return null;
                    },
                    onSaved: (value) => _customType = value,
                  ),
                ],
                const SizedBox(height: 16),
                
                // Cost
                 TextFormField(
                  initialValue: _cost.toString(),
                  decoration: InputDecoration(
                    labelText: '${l10n.costLabel} (${widget.currency})',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.costRequired;
                    if (double.tryParse(value) == null) return l10n.validNumberRequired;
                    return null;
                  },
                  onSaved: (value) => _cost = double.parse(value!),
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  initialValue: _notes,
                  decoration: InputDecoration(
                    labelText: l10n.notesLabel,
                  ),
                  maxLines: 2,
                  onSaved: (value) => _notes = value,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final item = ServiceItem(
                type: _type == 'other' ? (_customType ?? 'other') : _type,
                cost: _cost,
                notes: _notes,
                parts: [], // TODO: Add parts support in dialog later
                labor: null, // TODO: Add labor support in dialog later
              );
              Navigator.of(context).pop(item);
            }
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}