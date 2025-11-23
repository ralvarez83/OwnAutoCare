import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'OwnAutoCare'**
  String get appTitle;

  /// Title for the vehicle list screen
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get vehicleListTitle;

  /// Label for adding a new vehicle
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicle;

  /// Label for adding a service record
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addRecord;

  /// Label for reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// Label for edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Label for delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Label for cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Title for delete vehicle confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Vehicle'**
  String get deleteVehicleConfirmTitle;

  /// Content for delete vehicle confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this vehicle? This action cannot be undone.'**
  String get deleteVehicleConfirmContent;

  /// Title for delete record confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Service Record'**
  String get deleteRecordConfirmTitle;

  /// Content for delete record confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service record? This action cannot be undone.'**
  String get deleteRecordConfirmContent;

  /// Message shown when no vehicles exist
  ///
  /// In en, this message translates to:
  /// **'No vehicles added yet'**
  String get noVehicles;

  /// Message shown when no service records exist
  ///
  /// In en, this message translates to:
  /// **'No service records yet'**
  String get noRecords;

  /// Label for total records count
  ///
  /// In en, this message translates to:
  /// **'{count} Records'**
  String totalRecords(int count);

  /// Label for the total cost of service records
  ///
  /// In en, this message translates to:
  /// **'Total: {cost}'**
  String totalCost(String cost);

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Label for exporting data
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Label for importing data
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Message for successful export
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// Message for successful import
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get importSuccess;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String errorGeneric(String error);

  /// Prompt to add the first vehicle
  ///
  /// In en, this message translates to:
  /// **'Add your first car to get started'**
  String get addFirstCarPrompt;

  /// Error message when adding a vehicle fails
  ///
  /// In en, this message translates to:
  /// **'Error adding vehicle: {error}'**
  String errorAddingVehicle(String error);

  /// Error message when editing a vehicle fails
  ///
  /// In en, this message translates to:
  /// **'Error editing vehicle: {error}'**
  String errorEditingVehicle(String error);

  /// Label for the number of service records
  ///
  /// In en, this message translates to:
  /// **'{count} Records'**
  String recordsCount(int count);

  /// Message shown when there are no service records
  ///
  /// In en, this message translates to:
  /// **'No service records yet'**
  String get noServiceRecords;

  /// Title for the delete service record confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Service Record'**
  String get deleteServiceRecordTitle;

  /// Content for the delete service record confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this service record? This action cannot be undone.'**
  String get deleteServiceRecordContent;

  /// Message shown when a service record is deleted successfully
  ///
  /// In en, this message translates to:
  /// **'Service record deleted successfully'**
  String get serviceRecordDeleted;

  /// Error message when loading service records fails
  ///
  /// In en, this message translates to:
  /// **'Error loading service records: {error}'**
  String errorLoadingRecords(String error);

  /// Error message when editing a service record fails
  ///
  /// In en, this message translates to:
  /// **'Error editing service record: {error}'**
  String errorEditingRecord(String error);

  /// Error message when deleting a service record fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting service record: {error}'**
  String errorDeletingRecord(String error);

  /// Error message when adding a service record fails
  ///
  /// In en, this message translates to:
  /// **'Error adding service record: {error}'**
  String errorAddingRecord(String error);

  /// Title for the add vehicle screen
  ///
  /// In en, this message translates to:
  /// **'Add Vehicle'**
  String get addVehicleTitle;

  /// Title for the edit vehicle screen
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicleTitle;

  /// Label for the vehicle name input
  ///
  /// In en, this message translates to:
  /// **'Vehicle Name'**
  String get vehicleNameLabel;

  /// Label for the make input
  ///
  /// In en, this message translates to:
  /// **'Make'**
  String get makeLabel;

  /// Label for the model input
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get modelLabel;

  /// Label for the year input
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get yearLabel;

  /// Validation message for vehicle name
  ///
  /// In en, this message translates to:
  /// **'Please enter a vehicle name'**
  String get vehicleNameRequired;

  /// Validation message for make
  ///
  /// In en, this message translates to:
  /// **'Please enter the make'**
  String get makeRequired;

  /// Validation message for model
  ///
  /// In en, this message translates to:
  /// **'Please enter the model'**
  String get modelRequired;

  /// Validation message for year
  ///
  /// In en, this message translates to:
  /// **'Please enter the year'**
  String get yearRequired;

  /// Label for the save vehicle button
  ///
  /// In en, this message translates to:
  /// **'Save Vehicle'**
  String get saveVehicleButton;

  /// Title for the add service record screen
  ///
  /// In en, this message translates to:
  /// **'Add Service Record'**
  String get addServiceRecordTitle;

  /// Title for the edit service record screen
  ///
  /// In en, this message translates to:
  /// **'Edit Service Record'**
  String get editServiceRecordTitle;

  /// Label for the date input
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// Label for the service type input
  ///
  /// In en, this message translates to:
  /// **'Service Type'**
  String get serviceTypeLabel;

  /// Label for the mileage input
  ///
  /// In en, this message translates to:
  /// **'Mileage (km)'**
  String get mileageLabel;

  /// Label for the cost input
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get costLabel;

  /// Label for the currency input
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// Label for the notes input
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// Validation message for mileage
  ///
  /// In en, this message translates to:
  /// **'Please enter mileage'**
  String get mileageRequired;

  /// Validation message for valid number
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validNumberRequired;

  /// Validation message for cost
  ///
  /// In en, this message translates to:
  /// **'Please enter cost'**
  String get costRequired;

  /// Label for the save service record button
  ///
  /// In en, this message translates to:
  /// **'Save Service Record'**
  String get saveServiceRecordButton;

  /// Error message when saving a service record fails
  ///
  /// In en, this message translates to:
  /// **'Error saving service record: {error}'**
  String errorSavingServiceRecord(String error);

  /// No description provided for @serviceTypeOilChange.
  ///
  /// In en, this message translates to:
  /// **'Oil Change'**
  String get serviceTypeOilChange;

  /// No description provided for @serviceTypeInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get serviceTypeInspection;

  /// No description provided for @serviceTypeBrakePads.
  ///
  /// In en, this message translates to:
  /// **'Brake Pads'**
  String get serviceTypeBrakePads;

  /// No description provided for @serviceTypeTires.
  ///
  /// In en, this message translates to:
  /// **'Tires'**
  String get serviceTypeTires;

  /// No description provided for @serviceTypeCoolant.
  ///
  /// In en, this message translates to:
  /// **'Coolant'**
  String get serviceTypeCoolant;

  /// No description provided for @serviceTypeBattery.
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get serviceTypeBattery;

  /// No description provided for @serviceTypeItv.
  ///
  /// In en, this message translates to:
  /// **'ITV'**
  String get serviceTypeItv;

  /// No description provided for @serviceTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get serviceTypeOther;

  /// Title for the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Title for the export data option
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataTitle;

  /// Subtitle for the export data option
  ///
  /// In en, this message translates to:
  /// **'Save a backup of your data to a JSON file'**
  String get exportDataSubtitle;

  /// Title for the import data option
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importDataTitle;

  /// Subtitle for the import data option
  ///
  /// In en, this message translates to:
  /// **'Restore data from a JSON backup'**
  String get importDataSubtitle;

  /// Message when export is ready
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get exportReadyMessage;

  /// Message when export fails
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailedMessage(String error);

  /// Message when import is successful
  ///
  /// In en, this message translates to:
  /// **'Import successful'**
  String get importSuccessfulMessage;

  /// Message when import fails
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailedMessage(String error);

  /// Title for the reminders screen
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// Label for due date
  ///
  /// In en, this message translates to:
  /// **'Due Date: {date}'**
  String dueDateLabel(String date);

  /// Label for due mileage
  ///
  /// In en, this message translates to:
  /// **'Due Mileage: {mileage} km'**
  String dueMileageLabel(int mileage);

  /// Label for notes display
  ///
  /// In en, this message translates to:
  /// **'Notes: {notes}'**
  String notesDisplayLabel(String notes);

  /// Title for delete reminder dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder'**
  String get deleteReminderTitle;

  /// Content for delete reminder dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this reminder? This action cannot be undone.'**
  String get deleteReminderContent;

  /// Label for cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// Label for delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// Error message when loading reminders fails
  ///
  /// In en, this message translates to:
  /// **'Error loading reminders: {error}'**
  String errorLoadingReminders(String error);

  /// Error message when editing a reminder fails
  ///
  /// In en, this message translates to:
  /// **'Error editing reminder: {error}'**
  String errorEditingReminder(String error);

  /// Message when reminder is deleted
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted successfully'**
  String get reminderDeletedMessage;

  /// Error message when deleting a reminder fails
  ///
  /// In en, this message translates to:
  /// **'Error deleting reminder: {error}'**
  String errorDeletingReminder(String error);

  /// Error message when adding a reminder fails
  ///
  /// In en, this message translates to:
  /// **'Error adding reminder: {error}'**
  String errorAddingReminder(String error);

  /// Title for add reminder screen
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get addReminderTitle;

  /// Title for edit reminder screen
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get editReminderTitle;

  /// Label for title input
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// Validation message for title
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get titleRequired;

  /// Validation message for due date or mileage
  ///
  /// In en, this message translates to:
  /// **'Either Due Date or Due Mileage must be provided.'**
  String get dueDateOrMileageRequired;

  /// Label for save reminder button
  ///
  /// In en, this message translates to:
  /// **'Save Reminder'**
  String get saveReminderButton;

  /// Label for not set value
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Title for the welcome screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to OwnAutoCare'**
  String get welcomeScreenTitle;

  /// Status message when ready to authenticate
  ///
  /// In en, this message translates to:
  /// **'Ready to authenticate with Google Drive'**
  String get readyToAuthenticate;

  /// Label for sign in with Google button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// Label for due date field
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDateFieldLabel;

  /// Label for custom service type input
  ///
  /// In en, this message translates to:
  /// **'Specify Type'**
  String get specifyTypeLabel;

  /// Label for adding a photo
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhotoLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
