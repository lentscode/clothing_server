part of "request_utils.dart";

class _RequestUtilsImpl extends RequestUtils {
  _RequestUtilsImpl(super.req): super._();

  @override
  Future<Map<String, dynamic>> getBody() async {
    final String payload = await req.readAsString();

    return jsonDecode(payload);
  }
}
