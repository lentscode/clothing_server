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

    final String cookie = parts.firstWhere((String part) => part.startsWith("sessionId="), orElse: () => "");

    return cookie.split("=").last;
  }
}
