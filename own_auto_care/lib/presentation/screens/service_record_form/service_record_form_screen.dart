import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/save_service_record.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:uuid/uuid.dart';

class ServiceRecordFormScreen extends StatefulWidget {
  final ServiceRecordRepository serviceRecordRepository;
  final String vehicleId;
  final ServiceRecord? record;

  const ServiceRecordFormScreen({
    super.key,
    required this.serviceRecordRepository,
    required this.vehicleId,
    this.record,
  });

  @override
  State<ServiceRecordFormScreen> createState() => _ServiceRecordFormScreenState();
}

class _ServiceRecordFormScreenState extends State<ServiceRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late String _type;
  late int _mileageKm;
  late double _cost;
  late String _currency;
  String? _notes;
  final List<Part> _parts = [];
  Labor? _labor;

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
      _type = widget.record!.type;
      _mileageKm = widget.record!.mileageKm;
      _cost = widget.record!.cost;
      _currency = widget.record!.currency;
      _notes = widget.record!.notes;
      _parts.addAll(widget.record!.parts);
      _labor = widget.record!.labor;
    } else {
      _date = DateTime.now();
      _type = _serviceTypes.first;
      _mileageKm = 0;
      _cost = 0;
      _currency = 'EUR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.record == null ? 'Add Service Record' : 'Edit Service Record'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(_date.toString().split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
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
                decoration: const InputDecoration(labelText: 'Service Type'),
                items: _serviceTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.replaceAll('_', ' ').toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _type = value);
                },
              ),
              const SizedBox(height: 16),

              // Mileage
              TextFormField(
                initialValue: _mileageKm.toString(),
                decoration: const InputDecoration(
                  labelText: 'Mileage (km)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter mileage';
                  if (int.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
                onSaved: (value) => _mileageKm = int.parse(value!),
              ),
              const SizedBox(height: 16),

              // Cost
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: _cost.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter cost';
                        if (double.tryParse(value) == null) return 'Please enter a valid number';
                        return null;
                      },
                      onSaved: (value) => _cost = double.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(labelText: 'Currency'),
                      items: const [
                        DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                        DropdownMenuItem(value: 'USD', child: Text('USD')),
                        DropdownMenuItem(value: 'GBP', child: Text('GBP')),
                      ],
                      onChanged: (value) {
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
                decoration: const InputDecoration(
                  labelText: 'Notes',
                ),
                maxLines: 3,
                onSaved: (value) => _notes = value,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final saveServiceRecord = SaveServiceRecord(widget.serviceRecordRepository);
                    final record = ServiceRecord(
                      id: widget.record?.id ?? const Uuid().v4(),
                      vehicleId: widget.vehicleId,
                      date: _date,
                      mileageKm: _mileageKm,
                      type: _type,
                      parts: _parts,
                      labor: _labor,
                      cost: _cost,
                      currency: _currency,
                      notes: _notes,
                      attachments: widget.record?.attachments ?? [],
                    );
                    saveServiceRecord(record);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Service Record'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}