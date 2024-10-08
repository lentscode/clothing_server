part of "../routes.dart";

/// Registers the user on request.
///
/// It needs three fields to fulfill the request:
/// - email
/// - password
///
/// If one of these is not provided, a 400 response is returned.
///
/// If a user with the given email already exists, a 403 response is returned.
Future<Response> register(Request req) async {
  try {
    final Map<String, dynamic> body = await RequestUtils(req).getBody();

    final String? email = body["email"];
    final String? password = body["password"];

    if (email == null || password == null) {
      return Response.badRequest(body: "Missing fields");
    }

    final User user = await getIt.get<Auth>().register(email, password);

    return Response.ok(user.toJsonPublic());
  } on InvalidCredentialsException catch (e) {
    return Response.forbidden(e.toString());
  } catch (e, s) {
    getIt.get<Logger>().e(e, stackTrace: s);
    return Response.internalServerError(body: e.toString());
  }
}
