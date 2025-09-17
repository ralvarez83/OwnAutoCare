import 'dart:convert';

typedef JsonMap = Map<String, dynamic>;

abstract class CloudStorageProvider {
  Future<void> ensureSetup();
  Future<JsonMap> readRootMetadata();
  Future<void> writeRootMetadata(JsonMap data);
  Future<List<CloudItem>> listRecords(String vehicleId);
  Future<JsonMap> readRecord(String path);
  Future<void> writeRecord(String path, JsonMap data);
  Future<void> deleteRecord(String path);
  Future<Uri> getAttachmentLink(String path);
}

class CloudItem {
  final String id;
  final String name;
  final String path;

  CloudItem({required this.id, required this.name, required this.path});
}