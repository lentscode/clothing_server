part of "../routes.dart";

Future<Response> handlerName(Request req) async {
  final User user = req.context["user"] as User;

  final Map<String, dynamic> body = await RequestUtils(req).getBody();

  final String? id = body["id"];

  if (id == null) {
    return Response.badRequest(body: "Missing fields");
  }

  await getIt.get<ClothingDataSource>().deleteClothing(ObjectId.parse(id), user.oid);

  return Response.ok(null);
}
