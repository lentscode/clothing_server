import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:shelf/shelf.dart";

part "response_utils.impl.dart";

abstract class ResponseUtils {
  factory ResponseUtils() = _ResponseUtilsImpl;

  Future<Response> composeMultipartResponse(String boundary,
      {File? image, Map<String, dynamic>? data});
}
