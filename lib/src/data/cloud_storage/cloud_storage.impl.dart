part of "cloud_storage.dart";

class _CloudStorageImpl extends CloudStorage {
  _CloudStorageImpl(super._api) : super._();

  @override
  Future<(String? imageUrl, String? objectLink)> uploadImage(
    File image,
    User user,
    String imageType, {
    String bucketName = "clothing-app",
    bool deleteFile = true,
  }) async {
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

    final String signedUrl = generateSignedUrl(
      Credentials().googleServiceAccount,
      "clothing-app",
      objectLink.name!,
    );

    if (deleteFile) {
      image.delete();
    }

    return (signedUrl, objectLink.name);
  }

  @override
  String generateSignedUrl(
    Map<String, String> serviceAccount,
    String bucketName,
    String objectName, {
    String? subresource,
    int expiration = 604800,
    String httpMethod = "GET",
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
  }) {
    if (expiration > 604800) {
      return "";
    }

    // Encoding the object name
    final String escapedObjectName = Uri.encodeComponent(objectName);
    final String canonicalUri = "/$escapedObjectName";

    final DateTime dateTimeNow = DateTime.now().toUtc();
    final String requestTimestamp =
        DateFormat("yyyyMMdd'T'HHmmss'Z'").format(dateTimeNow);
    final String datestamp = DateFormat("yyyyMMdd").format(dateTimeNow);

    // Load your Google credentials and extract the client email
    final String? clientEmail =
        serviceAccount["client_email"]; // Extract from service account file
    final String credentialScope = "$datestamp/auto/storage/goog4_request";
    final String credential = "$clientEmail/$credentialScope";

    headers ??= <String, String>{};
    final String host = "$bucketName.storage.googleapis.com";
    headers["host"] = host;

    SplayTreeMap<String, dynamic> splayTreeMap = SplayTreeMap<String, dynamic>.from(
        headers); //this orders the headers alphabetically, important!
    headers = Map<String, String>.from(splayTreeMap);

    final String canonicalHeaders = headers.entries
        .map((MapEntry<String, String> entry) =>
            "${entry.key.toLowerCase()}:${entry.value.trim().toLowerCase()}\n")
        .join();
    final String signedHeaders =
        headers.keys.map((String k) => k.toLowerCase()).join(";");

    queryParameters ??= <String, String>{};
    queryParameters.addAll(<String, String>{
      "X-Goog-Algorithm": "GOOG4-RSA-SHA256",
      "X-Goog-Credential": credential,
      "X-Goog-Date": requestTimestamp,
      "X-Goog-Expires": expiration.toString(),
      "X-Goog-SignedHeaders": signedHeaders,
    });
    if (subresource != null) {
      queryParameters[subresource] = "";
    }

    final String canonicalQueryString = queryParameters.entries
        .map((MapEntry<String, String> entry) =>
            "${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}")
        .join("&");

    final String canonicalRequest = <String>[
      httpMethod,
      canonicalUri,
      canonicalQueryString,
      canonicalHeaders,
      signedHeaders,
      "UNSIGNED-PAYLOAD",
    ].join("\n");

    final String canonicalRequestHash =
        sha256.convert(utf8.encode(canonicalRequest)).toString();

    final String stringToSign = <String>[
      "GOOG4-RSA-SHA256",
      requestTimestamp,
      credentialScope,
      canonicalRequestHash,
    ].join("\n");

    String? pem = serviceAccount["private_key"];
    RSAPrivateKey rsaKey = keyFromString(pem!);
    RS256Signer signer = RS256Signer(rsaKey);

    List<int> stringToSignList = utf8.encode(stringToSign);
    List<int> signedRequestBytes = signer.sign(stringToSignList);
    String signature = HEX.encode(signedRequestBytes);

    final String schemeAndHost = "https://$host";
    final String signedUrl =
        "$schemeAndHost$canonicalUri?$canonicalQueryString&x-goog-signature=$signature";
    return signedUrl;
  }
}
