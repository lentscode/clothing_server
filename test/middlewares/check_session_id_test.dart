import "package:mongo_dart/mongo_dart.dart";
import "package:server/server.dart";
import "package:shared/shared.dart";
import "package:shelf/shelf.dart";
import "package:test/test.dart";

import "../utils.dart";

void main() {
  late Handler handler;
  const String url = "http://localhost:8080/";
  const String sessionId = "sessionId";
  late Db db;

  setUpAll(() async {
    await config(true);
  });

  setUp(() async {
    handler = const Pipeline()
        .addMiddleware(checkSessionId())
        .addHandler((Request req) => Response.ok("OK", context: req.context));

    db = await Db.create(Credentials().mongoUriTest);

    await db.open();

    await db.collection("users").insertOne(<String, dynamic>{
      "_id": ObjectId(),
      "email": "email@example.com",
      "hashPassword": "hashPassword",
      "salt": "salt",
      "sessionId": sessionId,
    });
  });

  tearDown(() async {
    await closeTestDb(db, delete: <String>["users"]);
  });

  group("checkSessionId()", () {
    test("Success: should return return a 200 response", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        headers: <String, Object>{
          "Cookie": "sessionId=$sessionId",
        },
      );

      final Response res = await handler(req);

      expect(res.statusCode, 200);
      expect(res.context["user"], isA<User>());
    });

    test("Failure: wrong sessionId should return 401 response", () async {
      final Request req = Request(
        "POST",
        Uri.parse(url),
        headers: <String, Object>{
          "Cookie": "sessionId=1234",
        },
      );

      final Response res = await handler(req);

      expect(res.statusCode, 401);
    });

    test("Failure: missing cookie should return 401 response", () async {
      final Request req = Request("POST", Uri.parse(url));

      final Response res = await handler(req);

      expect(res.statusCode, 401);
    });
  });
}
