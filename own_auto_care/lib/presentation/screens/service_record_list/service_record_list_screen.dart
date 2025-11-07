import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/list_service_records.dart';
import 'package:own_auto_care/domain/entities/service_record.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/presentation/screens/service_record_form/service_record_form_screen.dart';
import 'package:intl/intl.dart';

class ServiceRecordListScreen extends StatefulWidget {
  final ServiceRecordRepository serviceRecordRepository;
  final String vehicleId;
  final String vehicleName;

  const ServiceRecordListScreen({
    super.key,
    required this.serviceRecordRepository,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<ServiceRecordListScreen> createState() => _ServiceRecordListScreenState();
}

class _ServiceRecordListScreenState extends State<ServiceRecordListScreen> {
  late final ListServiceRecords _listServiceRecords;
  List<ServiceRecord> _records = [];

  @override
  void initState() {
    super.initState();
    _listServiceRecords = ListServiceRecords(widget.serviceRecordRepository);
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await _listServiceRecords(widget.vehicleId);
    setState(() {
      _records = records;
    });
  }

  String _formatCurrency(double amount, String currency) {
    return NumberFormat.currency(
      symbol: currency,
      decimalDigits: 2,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.vehicleName} - Service Records'),
      ),
      body: ListView.builder(
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(record.type),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM d, y').format(record.date),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    '${record.mileageKm} km • ${_formatCurrency(record.cost, record.currency)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ServiceRecordFormScreen(
                            serviceRecordRepository: widget.serviceRecordRepository,
                            vehicleId: widget.vehicleId,
                            record: record,
                          ),
                        ),
                      );
                      _loadRecords();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final delete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Service Record'),
                            content: const Text('Are you sure you want to delete this service record? This action cannot be undone.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(false),
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () => Navigator.of(context).pop(true),
                              ),
                            ],
                          );
                        },
                      );

                      if (delete == true) {
                        await widget.serviceRecordRepository.deleteServiceRecord(record.id);
                        _loadRecords();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ServiceRecordFormScreen(
                serviceRecordRepository: widget.serviceRecordRepository,
                vehicleId: widget.vehicleId,
              ),
            ),
          );
          _loadRecords();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}