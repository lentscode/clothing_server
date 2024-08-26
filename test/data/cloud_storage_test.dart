import "dart:io";

import "package:googleapis/storage/v1.dart";
import "package:googleapis_auth/auth_io.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:test/test.dart";

void main() {
  late StorageApi storageApi;
  late User user;
  late File image;

  setUp(() async {
    final ServiceAccountCredentials googleCredentials =
        ServiceAccountCredentials.fromJson(Credentials().googleServiceAccount);

    final AutoRefreshingAuthClient googleClient = await clientViaServiceAccount(
      googleCredentials,
      <String>[StorageApi.devstorageReadWriteScope],
    );

    storageApi = StorageApi(googleClient);

    user = User.create(
      email: "email@example.com",
      hashPassword: "hashPassword",
      salt: "salt",
    );

    image = File("${Directory.current.path}/test/test.jpg");
  });

  group("CloudStorage", () {
    group("uploadImage()", () {
      test("Success: should return a secureUrl to retrieve the image",
          () async {
        final CloudStorage cloudStorage = CloudStorage(storageApi);

        final String? url = await cloudStorage.uploadImage(
          image,
          user,
          "image",
          bucketName: "clothing-test",
          deleteFile: false,
        );

        expect(url, isNotNull);

        print(url);
      });
    });
  });
}
