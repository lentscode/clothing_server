import "dart:convert";

import "package:server/server.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

void main() {
  group("RequestUtils", () {
    group("getBody()", () {
      test("Success: should return body request", () async {
        final Request req = Request(
          "POST",
          Uri.parse("http://localhost/"),
          body: jsonEncode(<String, String>{
            "key": "value",
          }),
        );

        final Map<String, dynamic> body = await RequestUtils(req).getBody();

        expect(body["key"], "value");
      });
    });

    group("getSessionId", () {
      test("Success: should return a sessionId from a cookie", () {
        final String cookie =
            "sessionId=1234; HttpOnly; Secure; SameSite=Strict";

        final Request req = Request(
          "GET",
          Uri.parse("http://localhost/"),
          headers: <String, String>{
            "Cookie": cookie,
          },
        );

        final String sessionId = RequestUtils(req).getSessionId();

        expect(sessionId, "1234");
      });

      test(
          "Failure: if cookie is not present in request, should throw an Exception",
          () {
        final Request req = Request(
          "GET",
          Uri.parse("http://localhost/"),
        );

        expect(() => RequestUtils(req).getSessionId(),
            throwsA(isA<CookieNotFoundException>()));
      });
    });
  });
}
