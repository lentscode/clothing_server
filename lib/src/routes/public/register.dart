import "package:shared/shared.dart";
import "package:shelf/shelf.dart";

import "../../../server.dart";
import "../../logic/auth/auth.dart";
import "../../logic/utils/request_utils/request_utils.dart";

/// Registers the user on request.
///
/// It needs three fields to fulfill the request:
/// - email
/// - password
/// - name
/// 
/// If one of these is not provided, a 400 response is returned.
/// 
/// If a user with the given email already exists, a 403 response is returned.
Future<Response> register(Request req) async {
  try {
    final Map<String, dynamic> body = await RequestUtils(req).getBody();

    final String? email = body["email"];
    final String? password = body["password"];
    final String? name = body["name"];

    if (email == null || password == null || name == null) {
      return Response.badRequest(body: "Missing fields");
    }

    final User user = await getIt.get<Auth>().register(email, password, name);

    return Response.ok(user.toJsonPublic());
  } on UserWithEmailAlreadyExistingException catch (e) {
    return Response.forbidden(e.toString());
  } catch (e) {
    return Response.internalServerError(body: e.toString());
  }
}
