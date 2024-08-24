part of "../../routes.dart";

/// Deletes a clothing.
/// 
/// It needs the field:
/// - id (id of the clothing to delete, **required**)
/// 
/// If the fields are not provided, it will return a 400 status code.
/// 
/// If the clothing is not owned by the user, it will do nothing.
Future<Response> deleteClothing(Request req) async {
  final User user = req.context["user"] as User;

  final Map<String, dynamic> body = await RequestUtils(req).getBody();

  final String? id = body["id"];

  if (id == null) {
    return Response.badRequest(body: "Missing fields");
  }

  await getIt.get<ClothingDataSource>().deleteClothing(ObjectId.parse(id), user.oid);

  return Response.ok(null);
}
