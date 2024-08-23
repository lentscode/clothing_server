import "dart:io";

import "package:args/args.dart";
import "package:server/server.dart";
import "package:shelf/shelf.dart";
import "package:shelf/shelf_io.dart";
import "package:shelf_router/shelf_router.dart";

// Configure routes.
final Router _publicRouter = Router()
  ..post("/login", login)
  ..post("/register", register);

final Router _privateRouter = Router()
  ..post("/clothing", createClothing)
  ..delete("/clothing", deleteClothing);

final Handler _privateHandler = const Pipeline()
    .addMiddleware(checkCookie())
    .addHandler(_privateRouter.call);

final Router _router = Router()
  ..mount("/public", _publicRouter.call)
  ..mount("/protected", _privateHandler);

void main(List<String> args) async {
  final ArgParser parser = ArgParser()..addFlag("test", negatable: false);
  final ArgResults results = parser.parse(args);

  await config(results["test"] ?? false);
  // Use any available host or container IP (usually `0.0.0.0`).
  final InternetAddress ip = InternetAddress.anyIPv4;

  // Configure a pipeline that logs requests.
  final Handler handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(_router.call);

  // For running in containers, we respect the PORT environment variable.
  final int port = int.parse(Platform.environment["PORT"] ?? "8080");
  final HttpServer server = await serve(handler, ip, port);
  print("Server listening on port ${server.port}");
}
