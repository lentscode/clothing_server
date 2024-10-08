import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:shelf/shelf.dart";
import "package:shelf_multipart/shelf_multipart.dart";

import "../../../../server.dart";

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

  /// Returns the session ID from the [Request].
  String getSessionId();

  Future<(Map<String, dynamic> data, File? image)> parseFormData();
}
