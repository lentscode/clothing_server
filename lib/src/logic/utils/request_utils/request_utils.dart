import "dart:convert";

import "package:shelf/shelf.dart";

part "request_utils.impl.dart";

/// Utility class to parse [Request]s.
abstract class RequestUtils {
  const RequestUtils._(this.req);

  /// Returns a new instance of [RequestUtils]
  factory RequestUtils(Request req) = _RequestUtilsImpl;

  /// The request to parse.
  final Request req;

  /// Returns the body of the [Request].
  Future<Map<String, dynamic>> getBody();
}
