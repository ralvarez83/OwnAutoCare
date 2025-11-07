
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

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      filename: json['filename'],
      mime: json['mime'],
      driveProvider: json['driveProvider'],
      drivePath: json['drivePath'],
      size: json['size'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'mime': mime,
      'driveProvider': driveProvider,
      'drivePath': drivePath,
      'size': size,
    };
  }
}
