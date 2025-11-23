import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:own_auto_care/application/use_cases/export_data.dart';
import 'package:own_auto_care/application/use_cases/import_data.dart';
import 'package:own_auto_care/domain/repositories/reminder_repository.dart';
import 'package:own_auto_care/domain/repositories/service_record_repository.dart';
import 'package:own_auto_care/domain/repositories/vehicle_repository.dart';
import 'package:own_auto_care/presentation/widgets/loading_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:own_auto_care/l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final VehicleRepository vehicleRepository;
  final ServiceRecordRepository serviceRecordRepository;
  final ReminderRepository reminderRepository;

  const SettingsScreen({
    super.key,
    required this.vehicleRepository,
    required this.serviceRecordRepository,
    required this.reminderRepository,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final ExportData _exportData;
  late final ImportData _importData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _exportData = ExportData(
      vehicleRepository: widget.vehicleRepository,
      serviceRecordRepository: widget.serviceRecordRepository,
      reminderRepository: widget.reminderRepository,
    );
    _importData = ImportData(
      vehicleRepository: widget.vehicleRepository,
      serviceRecordRepository: widget.serviceRecordRepository,
      reminderRepository: widget.reminderRepository,
    );
  }

  Future<void> _handleExport() async {
    setState(() => _isLoading = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final jsonString = await _exportData();
      final fileName = 'own_auto_care_backup_${DateTime.now().toIso8601String().split('T')[0]}.json';

      if (kIsWeb) {
        // On Web, Share.shareXFiles with bytes might trigger download
        // Or we can use a simple Share.share if text is small, but for file download:
        // Share_plus on web supports shareXFiles.
        await Share.shareXFiles(
          [
            XFile.fromData(
              utf8.encode(jsonString),
              name: fileName,
              mimeType: 'application/json',
            ),
          ],
          subject: 'OwnAutoCare Backup',
        );
      } else {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(jsonString);

        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'OwnAutoCare Backup',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportReadyMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.exportFailedMessage(e.toString())), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleImport() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true, // Important for Web
      );

      if (result != null) {
        setState(() => _isLoading = true);
        final file = result.files.single;
        String jsonString;

        if (kIsWeb) {
          if (file.bytes != null) {
            jsonString = utf8.decode(file.bytes!);
          } else {
            throw Exception('No data in selected file');
          }
        } else {
          if (file.path != null) {
            jsonString = await File(file.path!).readAsString();
          } else {
            throw Exception('No path for selected file');
          }
        }

        await _importData(jsonString);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.importSuccessfulMessage), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.importFailedMessage(e.toString())), backgroundColor: Colors.red),
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
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.settingsTitle),
        ),
        body: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(l10n.exportDataTitle),
              subtitle: Text(l10n.exportDataSubtitle),
              onTap: _isLoading ? null : _handleExport,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.upload),
              title: Text(l10n.importDataTitle),
              subtitle: Text(l10n.importDataSubtitle),
              onTap: _isLoading ? null : _handleImport,
            ),
          ],
        ),
      ),
    );
  }
}
