import 'dart:async';

import 'package:own_auto_care/infrastructure/providers/google_drive_provider.dart';
import 'package:own_auto_care/domain/repositories/cloud_storage_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Fake implementation that satisfies the public API of
/// `GoogleDriveProvider` for widget tests. Methods are no-ops and return
/// trivial values so tests don't perform network or platform operations.
class FakeGoogleDriveProvider implements GoogleDriveProvider {
  @override
  String get clientId => 'test-client';

  @override
  List<String> get scopes => const [];
  @override
  Future<void> authenticate() async {}

  @override
  Future<void> authenticateWithToken(String token) async {}

  @override
  Future<void> ensureSetup() async {}

  @override
  Future<Uri> getAttachmentLink(String path) async => Uri.parse('about:blank');

  @override
  Future<List<CloudItem>> listRecords(String vehicleId) async => [];

  @override
  Future<JsonMap> readRecord(String path) async => {};

  @override
  Future<JsonMap> readRootMetadata() async => {};

  @override
  Future<void> writeRecord(String path, JsonMap data) async {}

  @override
  Future<void> writeRootMetadata(JsonMap data) async {}

  @override
  Future<void> deleteRecord(String path) async {}

  @override
  Future<GoogleSignInAccount?> getCurrentUser() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<String?> uploadFile(dynamic file, String folderName) async => 'https://fake.url/image.jpg';
}

