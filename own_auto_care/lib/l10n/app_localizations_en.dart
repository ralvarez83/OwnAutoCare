// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OwnAutoCare';

  @override
  String get vehicleListTitle => 'My Vehicles';

  @override
  String get addVehicle => 'Add Vehicle';

  @override
  String get addRecord => 'Add Record';

  @override
  String get reminders => 'Reminders';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteVehicleConfirmTitle => 'Delete Vehicle';

  @override
  String get deleteVehicleConfirmContent =>
      'Are you sure you want to delete this vehicle? This action cannot be undone.';

  @override
  String get deleteRecordConfirmTitle => 'Delete Service Record';

  @override
  String get deleteRecordConfirmContent =>
      'Are you sure you want to delete this service record? This action cannot be undone.';

  @override
  String get noVehicles => 'No vehicles added yet';

  @override
  String get noRecords => 'No service records yet';

  @override
  String totalRecords(int count) {
    return '$count Records';
  }

  @override
  String totalCost(String cost) {
    return 'Total: $cost';
  }

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get exportData => 'Export Data';

  @override
  String get importData => 'Import Data';

  @override
  String get exportSuccess => 'Data exported successfully';

  @override
  String get importSuccess => 'Data imported successfully';

  @override
  String errorGeneric(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get addFirstCarPrompt => 'Add your first car to get started';

  @override
  String errorAddingVehicle(String error) {
    return 'Error adding vehicle: $error';
  }

  @override
  String errorEditingVehicle(String error) {
    return 'Error editing vehicle: $error';
  }

  @override
  String recordsCount(int count) {
    return '$count Records';
  }

  @override
  String get noServiceRecords => 'No service records yet';

  @override
  String get deleteServiceRecordTitle => 'Delete Service Record';

  @override
  String get deleteServiceRecordContent =>
      'Are you sure you want to delete this service record? This action cannot be undone.';

  @override
  String get serviceRecordDeleted => 'Service record deleted successfully';

  @override
  String errorLoadingRecords(String error) {
    return 'Error loading service records: $error';
  }

  @override
  String errorEditingRecord(String error) {
    return 'Error editing service record: $error';
  }

  @override
  String errorDeletingRecord(String error) {
    return 'Error deleting service record: $error';
  }

  @override
  String errorAddingRecord(String error) {
    return 'Error adding service record: $error';
  }

  @override
  String get addVehicleTitle => 'Add Vehicle';

  @override
  String get editVehicleTitle => 'Edit Vehicle';

  @override
  String get vehicleNameLabel => 'Vehicle Name';

  @override
  String get makeLabel => 'Make';

  @override
  String get modelLabel => 'Model';

  @override
  String get yearLabel => 'Year';

  @override
  String get vehicleNameRequired => 'Please enter a vehicle name';

  @override
  String get makeRequired => 'Please enter the make';

  @override
  String get modelRequired => 'Please enter the model';

  @override
  String get yearRequired => 'Please enter the year';

  @override
  String get saveVehicleButton => 'Save Vehicle';

  @override
  String get addServiceRecordTitle => 'Add Service Record';

  @override
  String get editServiceRecordTitle => 'Edit Service Record';

  @override
  String get dateLabel => 'Date';

  @override
  String get serviceTypeLabel => 'Service Type';

  @override
  String get mileageLabel => 'Mileage (km)';

  @override
  String get costLabel => 'Cost';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get notesLabel => 'Notes';

  @override
  String get mileageRequired => 'Please enter mileage';

  @override
  String get validNumberRequired => 'Please enter a valid number';

  @override
  String get costRequired => 'Please enter cost';

  @override
  String get saveServiceRecordButton => 'Save Service Record';

  @override
  String errorSavingServiceRecord(String error) {
    return 'Error saving service record: $error';
  }

  @override
  String get serviceTypeOilChange => 'Oil Change';

  @override
  String get serviceTypeInspection => 'Inspection';

  @override
  String get serviceTypeBrakePads => 'Brake Pads';

  @override
  String get serviceTypeTires => 'Tires';

  @override
  String get serviceTypeCoolant => 'Coolant';

  @override
  String get serviceTypeBattery => 'Battery';

  @override
  String get serviceTypeItv => 'ITV';

  @override
  String get serviceTypeOther => 'Other';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get exportDataTitle => 'Export Data';

  @override
  String get exportDataSubtitle => 'Save a backup of your data to a JSON file';

  @override
  String get importDataTitle => 'Import Data';

  @override
  String get importDataSubtitle => 'Restore data from a JSON backup';

  @override
  String get exportReadyMessage => 'Export ready';

  @override
  String exportFailedMessage(String error) {
    return 'Export failed: $error';
  }

  @override
  String get importSuccessfulMessage => 'Import successful';

  @override
  String importFailedMessage(String error) {
    return 'Import failed: $error';
  }

  @override
  String get remindersTitle => 'Reminders';

  @override
  String dueDateLabel(String date) {
    return 'Due Date: $date';
  }

  @override
  String dueMileageLabel(int mileage) {
    return 'Due Mileage: $mileage km';
  }

  @override
  String notesDisplayLabel(String notes) {
    return 'Notes: $notes';
  }

  @override
  String get deleteReminderTitle => 'Delete Reminder';

  @override
  String get deleteReminderContent =>
      'Are you sure you want to delete this reminder? This action cannot be undone.';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get deleteButton => 'Delete';

  @override
  String errorLoadingReminders(String error) {
    return 'Error loading reminders: $error';
  }

  @override
  String errorEditingReminder(String error) {
    return 'Error editing reminder: $error';
  }

  @override
  String get reminderDeletedMessage => 'Reminder deleted successfully';

  @override
  String errorDeletingReminder(String error) {
    return 'Error deleting reminder: $error';
  }

  @override
  String errorAddingReminder(String error) {
    return 'Error adding reminder: $error';
  }

  @override
  String get addReminderTitle => 'Add Reminder';

  @override
  String get editReminderTitle => 'Edit Reminder';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleRequired => 'Please enter a title';

  @override
  String get dueDateOrMileageRequired =>
      'Either Due Date or Due Mileage must be provided.';

  @override
  String get saveReminderButton => 'Save Reminder';

  @override
  String get notSet => 'Not set';

  @override
  String get welcomeScreenTitle => 'Welcome to OwnAutoCare';

  @override
  String get readyToAuthenticate => 'Ready to authenticate with Google Drive';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get dueDateFieldLabel => 'Due Date';

  @override
  String get specifyTypeLabel => 'Specify Type';

  @override
  String get addPhotoLabel => 'Add Photo';

  @override
  String get errorNoServicesAdded => 'Please add at least one service';

  @override
  String get visitTypeLabel => 'Visit Type';

  @override
  String get visitTypeMaintenance => 'Maintenance';

  @override
  String get visitTypeRepair => 'Repair';

  @override
  String get visitTypeItv => 'ITV';

  @override
  String get visitTypeOther => 'Other';

  @override
  String get itvResultLabel => 'Result';

  @override
  String get itvResultFavorable => 'Favorable';

  @override
  String get itvResultUnfavorable => 'Unfavorable';

  @override
  String get itvCostLabel => 'Inspection Cost';
}
