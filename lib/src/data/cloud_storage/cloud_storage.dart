// ignore_for_file: implementation_imports

import "dart:collection";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:crypto/crypto.dart";
import "package:googleapis/storage/v1.dart";
import "package:googleapis_auth/src/crypto/pem.dart";
import "package:googleapis_auth/src/crypto/rsa.dart";
import "package:googleapis_auth/src/crypto/rsa_sign.dart";
import "package:hex/hex.dart";
import "package:intl/intl.dart";
import "package:shared/shared.dart";
import "package:uuid/uuid.dart";

import "../../../server.dart";

part "cloud_storage.impl.dart";

abstract class CloudStorage {
  const CloudStorage._(this._api);

  factory CloudStorage(StorageApi api) = _CloudStorageImpl;

  final StorageApi _api;

  Future<String?> uploadImage(
    File image,
    User user,
    String imageType, {
    String bucketName = "clothing-test",
    bool deleteFile = true,
  });
}
