import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/list_reminders.dart';
import 'package:own_auto_care/application/use_cases/delete_reminder.dart';
import 'package:own_auto_care/domain/entities/reminder.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:intl/intl.dart';
import 'package:own_auto_care/presentation/screens/reminder_form/reminder_form_screen.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class ReminderListScreen extends StatefulWidget {
  final ReminderRepository reminderRepository;
  final String vehicleId;
  final String vehicleName;

  const ReminderListScreen({
    super.key,
    required this.reminderRepository,
    required this.vehicleId,
    required this.vehicleName,
  });

  @override
  State<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends State<ReminderListScreen> {
  late final ListReminders _listReminders;
  late final DeleteReminder _deleteReminder;
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _listReminders = ListReminders(widget.reminderRepository);
    _deleteReminder = DeleteReminder(widget.reminderRepository);
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() => _isLoading = true);
    try {
      final reminders = await _listReminders(widget.vehicleId);
      setState(() {
        _reminders = reminders;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.errorLoadingReminders(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM d, y').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${widget.vehicleName} - ${l10n.remindersTitle}'),
        ),
        body: ListView.builder(
          itemCount: _reminders.length,
          itemBuilder: (context, index) {
            final reminder = _reminders[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(reminder.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (reminder.dueDate != null)
                      Text(
                        l10n.dueDateLabel(_formatDate(reminder.dueDate)),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (reminder.dueMileageKm != null)
                      Text(
                        l10n.dueMileageLabel(reminder.dueMileageKm!),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    if (reminder.notes != null && reminder.notes!.isNotEmpty)
                      Text(
                        l10n.notesDisplayLabel(reminder.notes!),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        try {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ReminderFormScreen(
                                reminderRepository: widget.reminderRepository,
                                vehicleId: widget.vehicleId,
                                reminder: reminder,
                              ),
                            ),
                          );
                          await _loadReminders();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.errorEditingReminder(e.toString())),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _isLoading ? null : () async {
                        final delete = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(l10n.deleteReminderTitle),
                              content: Text(l10n.deleteReminderContent),
                              actions: <Widget>[
                                TextButton(
                                  child: Text(l10n.cancelButton),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text(l10n.deleteButton),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );

                        if (delete == true) {
                          setState(() => _isLoading = true);
                          try {
                            await _deleteReminder(reminder.id);
                            await _loadReminders();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.reminderDeletedMessage),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.errorDeletingReminder(e.toString())),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
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
        floatingActionButton: FloatingActionButton(
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            try {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReminderFormScreen(
                    reminderRepository: widget.reminderRepository,
                    vehicleId: widget.vehicleId,
                  ),
                ),
              );
              await _loadReminders();
            } catch (e) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.errorAddingReminder(e.toString())),
                  backgroundColor: Colors.red,
                ),
              );
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
