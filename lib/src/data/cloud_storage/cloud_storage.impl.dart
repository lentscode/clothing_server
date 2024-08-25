part of "cloud_storage.dart";

class _CloudStorageImpl extends CloudStorage {
  _CloudStorageImpl(super._api) : super._();

  @override
  Future<String?> uploadImage(File image, User user, String imageType) async {
    final String path = "$imageType/${user.oid}/${const Uuid().v4()}";

    final Uint8List imageBytes = await image.readAsBytes();

    final Media media = Media(
      Stream<List<int>>.fromIterable(<List<int>>[imageBytes]),
      imageBytes.length,
    );

    final Object object = Object(name: path);

    final Object objectLink = await _api.objects.insert(
      object,
      "clothing-app",
      uploadMedia: media,
    );

    return objectLink.selfLink;
  }
}
