// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'OwnAutoCare';

  @override
  String get vehicleListTitle => 'Mis Vehículos';

  @override
  String get addVehicle => 'Añadir Vehículo';

  @override
  String get addRecord => 'Añadir Registro';

  @override
  String get reminders => 'Recordatorios';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteVehicleConfirmTitle => 'Eliminar Vehículo';

  @override
  String get deleteVehicleConfirmContent =>
      '¿Estás seguro de que quieres eliminar este vehículo? Esta acción no se puede deshacer.';

  @override
  String get deleteRecordConfirmTitle => 'Eliminar Registro';

  @override
  String get deleteRecordConfirmContent =>
      '¿Estás seguro de que quieres eliminar este registro? Esta acción no se puede deshacer.';

  @override
  String get noVehicles => 'Aún no hay vehículos';

  @override
  String get noRecords => 'Aún no hay registros';

  @override
  String totalRecords(int count) {
    return '$count Registros';
  }

  @override
  String totalCost(String cost) {
    return 'Total: $cost';
  }

  @override
  String get settings => 'Ajustes';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get exportData => 'Exportar Datos';

  @override
  String get importData => 'Importar Datos';

  @override
  String get exportSuccess => 'Datos exportados correctamente';

  @override
  String get importSuccess => 'Datos importados correctamente';

  @override
  String errorGeneric(String error) {
    return 'Ocurrió un error: $error';
  }

  @override
  String get addFirstCarPrompt => 'Añade tu primer coche para empezar';

  @override
  String errorAddingVehicle(String error) {
    return 'Error al añadir vehículo: $error';
  }

  @override
  String errorEditingVehicle(String error) {
    return 'Error al editar vehículo: $error';
  }

  @override
  String recordsCount(int count) {
    return '$count Registros';
  }

  @override
  String get noServiceRecords => 'Aún no hay registros de servicio';

  @override
  String get deleteServiceRecordTitle => 'Eliminar Registro de Servicio';

  @override
  String get deleteServiceRecordContent =>
      '¿Estás seguro de que quieres eliminar este registro de servicio? Esta acción no se puede deshacer.';

  @override
  String get serviceRecordDeleted =>
      'Registro de servicio eliminado correctamente';

  @override
  String errorLoadingRecords(String error) {
    return 'Error al cargar registros de servicio: $error';
  }

  @override
  String errorEditingRecord(String error) {
    return 'Error al editar registro de servicio: $error';
  }

  @override
  String errorDeletingRecord(String error) {
    return 'Error al eliminar registro de servicio: $error';
  }

  @override
  String errorAddingRecord(String error) {
    return 'Error al añadir registro de servicio: $error';
  }

  @override
  String get addVehicleTitle => 'Añadir Vehículo';

  @override
  String get editVehicleTitle => 'Editar Vehículo';

  @override
  String get vehicleNameLabel => 'Nombre del Vehículo';

  @override
  String get makeLabel => 'Marca';

  @override
  String get modelLabel => 'Modelo';

  @override
  String get yearLabel => 'Año';

  @override
  String get vehicleNameRequired =>
      'Por favor introduce un nombre para el vehículo';

  @override
  String get makeRequired => 'Por favor introduce la marca';

  @override
  String get modelRequired => 'Por favor introduce el modelo';

  @override
  String get yearRequired => 'Por favor introduce el año';

  @override
  String get saveVehicleButton => 'Guardar Vehículo';

  @override
  String get addServiceRecordTitle => 'Añadir Registro de Servicio';

  @override
  String get editServiceRecordTitle => 'Editar Registro de Servicio';

  @override
  String get dateLabel => 'Fecha';

  @override
  String get serviceTypeLabel => 'Tipo de Servicio';

  @override
  String get mileageLabel => 'Kilometraje (km)';

  @override
  String get costLabel => 'Coste';

  @override
  String get currencyLabel => 'Moneda';

  @override
  String get notesLabel => 'Notas';

  @override
  String get mileageRequired => 'Por favor introduce el kilometraje';

  @override
  String get validNumberRequired => 'Por favor introduce un número válido';

  @override
  String get costRequired => 'Por favor introduce el coste';

  @override
  String get saveServiceRecordButton => 'Guardar Registro';

  @override
  String errorSavingServiceRecord(String error) {
    return 'Error al guardar registro de servicio: $error';
  }

  @override
  String get serviceTypeOilChange => 'Cambio de Aceite';

  @override
  String get serviceTypeInspection => 'Inspección';

  @override
  String get serviceTypeBrakePads => 'Pastillas de Freno';

  @override
  String get serviceTypeTires => 'Neumáticos';

  @override
  String get serviceTypeCoolant => 'Refrigerante';

  @override
  String get serviceTypeBattery => 'Batería';

  @override
  String get serviceTypeItv => 'ITV';

  @override
  String get serviceTypeOther => 'Otro';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get exportDataTitle => 'Exportar Datos';

  @override
  String get exportDataSubtitle =>
      'Guardar una copia de seguridad de tus datos en un archivo JSON';

  @override
  String get importDataTitle => 'Importar Datos';

  @override
  String get importDataSubtitle =>
      'Restaurar datos desde una copia de seguridad JSON';

  @override
  String get exportReadyMessage => 'Exportación lista';

  @override
  String exportFailedMessage(String error) {
    return 'Error en la exportación: $error';
  }

  @override
  String get importSuccessfulMessage => 'Importación exitosa';

  @override
  String importFailedMessage(String error) {
    return 'Error en la importación: $error';
  }

  @override
  String get remindersTitle => 'Recordatorios';

  @override
  String dueDateLabel(String date) {
    return 'Fecha de Vencimiento: $date';
  }

  @override
  String dueMileageLabel(int mileage) {
    return 'Kilometraje de Vencimiento: $mileage km';
  }

  @override
  String notesDisplayLabel(String notes) {
    return 'Notas: $notes';
  }

  @override
  String get deleteReminderTitle => 'Eliminar Recordatorio';

  @override
  String get deleteReminderContent =>
      '¿Estás seguro de que quieres eliminar este recordatorio? Esta acción no se puede deshacer.';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get deleteButton => 'Eliminar';

  @override
  String errorLoadingReminders(String error) {
    return 'Error al cargar recordatorios: $error';
  }

  @override
  String errorEditingReminder(String error) {
    return 'Error al editar recordatorio: $error';
  }

  @override
  String get reminderDeletedMessage => 'Recordatorio eliminado con éxito';

  @override
  String errorDeletingReminder(String error) {
    return 'Error al eliminar recordatorio: $error';
  }

  @override
  String errorAddingReminder(String error) {
    return 'Error al añadir recordatorio: $error';
  }

  @override
  String get addReminderTitle => 'Añadir Recordatorio';

  @override
  String get editReminderTitle => 'Editar Recordatorio';

  @override
  String get titleLabel => 'Título';

  @override
  String get titleRequired => 'Por favor introduce un título';

  @override
  String get dueDateOrMileageRequired =>
      'Se debe proporcionar la Fecha de Vencimiento o el Kilometraje de Vencimiento.';

  @override
  String get saveReminderButton => 'Guardar Recordatorio';

  @override
  String get notSet => 'No establecido';

  @override
  String get welcomeScreenTitle => 'Bienvenido a OwnAutoCare';

  @override
  String get readyToAuthenticate => 'Listo para autenticar con Google Drive';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get dueDateFieldLabel => 'Fecha de Vencimiento';

  @override
  String get specifyTypeLabel => 'Especificar Tipo';

  @override
  String get addPhotoLabel => 'Añadir Foto';
}
