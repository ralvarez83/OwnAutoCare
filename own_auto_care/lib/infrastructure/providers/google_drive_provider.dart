import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/googleapis_auth.dart' as gauth;
import 'package:http/http.dart' as http;

import '../../domain/repositories/repositories.dart';

import 'package:own_auto_care/secrets.dart';

class GoogleDriveProvider implements CloudStorageProvider {
  late final GoogleSignIn _googleSignIn;
  http.Client? _client;
  final String clientId;
  final List<String> scopes;
  String? _appFolderId;
  static const String _appFolderName = 'OwnAutoCare';
  bool _initialized = false;

  GoogleDriveProvider({
    GoogleSignIn? googleSignIn,
    this.clientId = googleClientId,
    this.scopes = const ['https://www.googleapis.com/auth/drive.file'],
  }) {
    _googleSignIn = googleSignIn ?? GoogleSignIn.instance;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    await _googleSignIn.initialize(
      clientId: clientId,
    );
    _initialized = true;
  }

  Future<void> authenticate() async {
    if (_client != null) {
      return;
    }
    try {
      await _ensureInitialized();
      
      final googleUser = await _googleSignIn.attemptLightweightAuthentication();
      if (googleUser == null) {
        throw 'Sign in aborted by user';
      }
      
      // Get authorization with scopes
      final authorization = await _googleSignIn.authorizationClient.authorizeScopes(scopes);
      if (authorization == null || authorization.accessToken.isEmpty) {
        throw 'Failed to obtain access token';
      }

      final credentials = gauth.AccessCredentials(
        gauth.AccessToken(
          'Bearer',
          authorization.accessToken,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null,
        scopes,
      );

      _client = gauth.authenticatedClient(http.Client(), credentials);

    } catch (e) {
      rethrow;
    }
  }

  Future<void> authenticateWithToken(String token) async {
    if (_client != null) {
      return;
    }
    try {
      await _ensureInitialized();
      
      final credentials = gauth.AccessCredentials(
        gauth.AccessToken(
          'Bearer',
          token,
          DateTime.now().toUtc().add(const Duration(hours: 1)),
        ),
        null,
        scopes,
      );

      _client = gauth.authenticatedClient(http.Client(), credentials);

    } catch (e) {
      rethrow;
    }
  }

  Future<GoogleSignInAccount?> getCurrentUser() async {
    // On web, avoid calling google_sign_in methods that might trigger
    // the GSI One Tap / Auto-sign-in flow, as it conflicts with our
    // manual OAuth2 implementation and causes error popups.
    if (kIsWeb) {
      return null;
    }

    await _ensureInitialized();
    return await _googleSignIn.attemptLightweightAuthentication();
  }

  Future<void> logout() async {
    await _ensureInitialized();
    try {
      // Try to disconnect (may not work on web with OAuth2)
      await _googleSignIn.disconnect();
    } catch (e) {
      // Ignore disconnect errors on web
    }
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore signOut errors
    }
    // Always clear local state
    _client = null;
    _appFolderId = null;
    _initialized = false;
  }

  @override
  Future<void> ensureSetup() async {
    await authenticate();
    final driveApi = drive.DriveApi(_client!);
    
    final appFolder = await _findAppFolder(driveApi);
    if (appFolder != null) {
      _appFolderId = appFolder.id;
      return;
    }

    final folderMetadata = drive.File()
      ..name = _appFolderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = ['root'];
    
    final folder = await driveApi.files.create(folderMetadata);
    _appFolderId = folder.id;
    
    await writeRootMetadata({
      'vehicles': [],
      'settings': {
        'currency': 'EUR',
        'locale': 'es-ES',
      }
    });
  }

  Future<drive.File?> _findAppFolder(drive.DriveApi driveApi) async {
    final query = "name = '$_appFolderName' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final result = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );
    if (result.files?.isEmpty ?? true) {
      return null;
    }
    return result.files!.first;
  }

  @override
  Future<JsonMap> readRootMetadata() async {
    await authenticate();
    if (_appFolderId == null) {
      await ensureSetup();
    }

    final driveApi = drive.DriveApi(_client!);
    final metadataFile = await _getMetadataFile(driveApi);
    if (metadataFile == null) {
      final initialData = {
        'vehicles': [],
        'settings': {
          'currency': 'EUR',
          'locale': 'es-ES',
        }
      };
      await writeRootMetadata(initialData);
      return initialData;
    }

    try {
      final content = await driveApi.files.get(
        metadataFile.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;
      
      final jsonStr = await utf8.decodeStream(content.stream);
      return json.decode(jsonStr);
    } catch (e) {
      return {
        'vehicles': [],
        'settings': {
          'currency': 'EUR',
          'locale': 'es-ES',
        }
      };
    }
  }

  @override
  Future<void> writeRootMetadata(JsonMap data) async {
    await authenticate();
    if (_appFolderId == null) {
      await ensureSetup();
    }

    final driveApi = drive.DriveApi(_client!);
    final metadataFile = await _getMetadataFile(driveApi);
    final content = json.encode(data);
    final media = drive.Media(
      Stream.value(utf8.encode(content)),
      content.length,
      contentType: 'application/json',
    );

    if (metadataFile == null) {
      final newFile = drive.File()
        ..name = 'carcare.json'
        ..parents = [_appFolderId!]
        ..mimeType = 'application/json';
      await driveApi.files.create(newFile, uploadMedia: media);
    } else {
      await driveApi.files.update(
        drive.File(),
        metadataFile.id!,
        uploadMedia: media,
      );
    }
  }

  Future<drive.File?> _getMetadataFile(drive.DriveApi driveApi) async {
    if (_appFolderId == null) {
      await ensureSetup();
    }

    final query = "name = 'carcare.json' and '${_appFolderId!}' in parents and trashed = false";
    final files = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id, name)',
    );

    if (files.files?.isEmpty ?? true) {
      return null;
    }
    return files.files!.first;
  }

  @override
  Future<List<CloudItem>> listRecords(String vehicleId) async {
    await authenticate();
    throw UnimplementedError();
  }

  @override
  Future<JsonMap> readRecord(String path) async {
    await authenticate();
    throw UnimplementedError();
  }

  @override
  Future<void> writeRecord(String path, JsonMap data) async {
    await authenticate();
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRecord(String path) async {
    await authenticate();
    throw UnimplementedError();
  }

  Future<String?> uploadFile(XFile file, String folderName) async {
    await authenticate();
    if (_appFolderId == null) await ensureSetup();

    final driveApi = drive.DriveApi(_client!);
    
    // Find or create folder
    final folderId = await _findOrCreateFolder(driveApi, folderName, _appFolderId!);

    // Create file metadata
    final fileMetadata = drive.File()
      ..name = file.name
      ..parents = [folderId];
      // ..mimeType = file.mimeType; // mimeType might be null, Drive auto-detects

    // Upload
    final media = drive.Media(
      file.openRead(),
      await file.length(),
    );

    final uploadedFile = await driveApi.files.create(
      fileMetadata,
      uploadMedia: media,
      $fields: 'id, webContentLink, webViewLink',
    );
    
    // Make public to allow Image.network to work easily
    // In a production app with sensitive data, we should use authenticated image fetching instead.
    try {
      final permission = drive.Permission()
        ..role = 'reader'
        ..type = 'anyone';
      await driveApi.permissions.create(permission, uploadedFile.id!);
    } catch (e) {
      debugPrint('Error making file public: $e');
    }

    return uploadedFile.webContentLink;
  }

  Future<String> _findOrCreateFolder(drive.DriveApi driveApi, String name, String parentId) async {
    final query = "name = '$name' and '$parentId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false";
    final result = await driveApi.files.list(
      q: query,
      spaces: 'drive',
      $fields: 'files(id)',
    );

    if (result.files?.isNotEmpty ?? false) {
      return result.files!.first.id!;
    }

    final folderMetadata = drive.File()
      ..name = name
      ..parents = [parentId]
      ..mimeType = 'application/vnd.google-apps.folder';
    
    final folder = await driveApi.files.create(folderMetadata);
    return folder.id!;
  }

  @override
  Future<Uri> getAttachmentLink(String path) async {
    await authenticate();
    throw UnimplementedError();
  }
}
