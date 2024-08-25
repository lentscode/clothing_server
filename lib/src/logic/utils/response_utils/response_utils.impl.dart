part of "response_utils.dart";

class _ResponseUtilsImpl implements ResponseUtils {
  @override
  Future<Response> composeMultipartResponse(String boundary,
      {File? image, Map<String, dynamic>? data}) async {
    final String totalBoundary = "----------$boundary";

    final String jsonBody = jsonEncode(data);

    final String fileName = image?.uri.pathSegments.last ?? "";
    final Uint8List? fileContent = await image?.readAsBytes();

    final String body = <String>[
      if (data != null) ...<String>[
        totalBoundary,
        "Content-Disposition: form-data; name=\"data\"",
        "Content-Type: application/json",
        "",
        jsonBody,
        totalBoundary,
      ],
      if (fileContent != null) ...<String>[
        "Content-Disposition: form-data; name=\"image\"; filename=\"$fileName\"",
        "Content-Type: ${_getMimeType(fileName)}",
        "Content-Transfer-Encoding: binary",
        "",
        base64Encode(fileContent),
        "$totalBoundary--",
      ],
    ].join("\r\n");

    final Map<String, String> headers = <String, String>{
      HttpHeaders.contentTypeHeader:
          "multipart/form-data; boundary=$totalBoundary",
    };

    image?.delete();

    return Response.ok(body, headers: headers);
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith(".png")) {
      return "image/png";
    } else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) {
      return "image/jpeg";
    } else if (fileName.endsWith(".gif")) {
      return "image/gif";
    }
    return "application/octet-stream";
  }
}
