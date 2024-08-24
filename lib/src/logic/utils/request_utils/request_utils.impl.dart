part of "request_utils.dart";

class _RequestUtilsImpl extends RequestUtils {
  _RequestUtilsImpl(super.req) : super._();

  @override
  Future<Map<String, dynamic>> getBody() async {
    final String payload = await req.readAsString();

    return jsonDecode(payload);
  }

  @override
  String getSessionId() {
    final String? cookieHeader = req.headers["Cookie"];

    if (cookieHeader == null) {
      throw CookieNotFoundException();
    }

    final List<String> parts = cookieHeader.split(";");

    final String cookie = parts.firstWhere(
        (String part) => part.startsWith("sessionId="),
        orElse: () => "");

    return cookie.split("=").last;
  }

  @override
  Future<(Map<String, dynamic> data, File image)> parseFormData() async {
    final Map<String, dynamic> formData = await _getFormData();

    final Multipart imagePart = formData["image"] as Multipart;
    final Multipart dataPart = formData["data"] as Multipart;

    final Map<String, dynamic> data = jsonDecode(await dataPart.readString());

    final File image = await imagePart.readBytes().then(
        (Uint8List bytes) => File("${data["name"]}.jpg").writeAsBytes(bytes));

    return (data, image);
  }

  Future<Map<String, dynamic>> _getFormData() async {
    final FormDataRequest? request = req.formData();

    if (request == null) {
      throw Exception();
    }

    return <String, Multipart?>{
      await for (final FormData formData in request.formData)
        formData.name: formData.part,
    };
  }
}
