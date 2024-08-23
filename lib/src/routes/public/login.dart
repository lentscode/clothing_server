import "package:shared/shared.dart";
import "package:shelf/shelf.dart";

import "../../../server.dart";

/// Executes the login for a user.
///
/// It needs two fields to fulfill the request:
/// - email
/// - password
///
/// If one of these is not provided, a 400 response is sent.
///
/// If email and password are correct, a [User] object is returned,
/// with a sessionId that the user will use to remain authenticated.
///
/// If no user exists with the given email, or the password is incorrect,
/// a 401 response is sent.
Future<Response> login(Request req) async {
  try {
    final Map<String, dynamic> body = await RequestUtils(req).getBody();

    final String? email = body["email"];
    final String? password = body["password"];

    if (email == null || password == null) {
      return Response.badRequest(body: "Missing fields");
    }

    final (User user, String cookie) = await getIt.get<Auth>().login(email, password);

    return Response.ok(
      user.toJsonPublic(),
      headers: <String, Object>{
        "Set-Cookie": cookie,
      },
    );
  } on InvalidCredentialsException catch (e) {
    return Response.unauthorized(e.toString());
  } catch (e) {
    return Response.internalServerError(body: e.toString());
  }
}
