import "dart:io";
import "dart:typed_data";

import "package:googleapis/storage/v1.dart";
import "package:shared/shared.dart";
import "package:uuid/uuid.dart";

part "cloud_storage.impl.dart";

abstract class CloudStorage {
  const CloudStorage._(this._api);

  factory CloudStorage(StorageApi api) = _CloudStorageImpl;

  final StorageApi _api;

  Future<String?> uploadImage(File image, User user, String imageType);
}
