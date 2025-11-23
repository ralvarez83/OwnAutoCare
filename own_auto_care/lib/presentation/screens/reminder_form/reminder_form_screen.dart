import 'package:flutter/material.dart';
import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/application/use_cases/create_reminder.dart';
import 'package:own_auto_care/application/use_cases/update_reminder.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class ReminderFormScreen extends StatefulWidget {
  final ReminderRepository reminderRepository;
  final String vehicleId;
  final Reminder? reminder;

  const ReminderFormScreen({
    super.key,
    required this.reminderRepository,
    required this.vehicleId,
    this.reminder,
  });

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _title;
  DateTime? _dueDate;
  int? _dueMileageKm;
  String? _notes;

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _title = widget.reminder!.title;
      _dueDate = widget.reminder!.dueDate;
      _dueMileageKm = widget.reminder!.dueMileageKm;
      _notes = widget.reminder!.notes;
    } else {
      _title = '';
    }
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final l10n = AppLocalizations.of(context)!;

    if (_dueDate == null && _dueMileageKm == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.dueDateOrMileageRequired),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reminderToSave = Reminder(
        id: widget.reminder?.id ?? const Uuid().v4(),
        vehicleId: widget.vehicleId,
        title: _title,
        dueDate: _dueDate,
        dueMileageKm: _dueMileageKm,
        notes: _notes,
      );

      await widget.reminderRepository.saveReminder(reminderToSave);

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorAddingReminder(e.toString())),
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
        title: Text(widget.reminder == null ? l10n.addReminderTitle : l10n.editReminderTitle),
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
                TextFormField(
                  initialValue: _title,
                  decoration: InputDecoration(labelText: l10n.titleLabel),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.titleRequired;
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value!,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(l10n.dueDateFieldLabel),
                  subtitle: Text(_dueDate == null ? l10n.notSet : DateFormat('MMM d, y').format(_dueDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _isLoading ? null : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() => _dueDate = date);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _dueMileageKm?.toString(),
                  decoration: InputDecoration(labelText: l10n.mileageLabel),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    if (value != null && value.isNotEmpty) {
                      _dueMileageKm = int.tryParse(value);
                    } else {
                      _dueMileageKm = null;
                    }
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: _notes,
                  decoration: InputDecoration(labelText: l10n.notesLabel),
                  maxLines: 3,
                  onSaved: (value) => _notes = value,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveForm,
                  child: Text(l10n.saveReminderButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
