
import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String filename;
  final String mime;
  final String driveProvider;
  final String drivePath;
  final int? size;

  const Attachment({
    required this.id,
    required this.filename,
    required this.mime,
    required this.driveProvider,
    required this.drivePath,
    this.size,
  });

  @override
  List<Object?> get props => [id, filename, mime, driveProvider, drivePath, size];
}
