part of "../../routes.dart";

Future<Response> getClothingsOfUser(Request req) async {
  try {
    final User user = req.context["user"] as User;

    final List<Clothing> clothings =
        await getIt.get<ClothingDataSource>().getClothingsOfUser(user.id.oid);

    for (int i = 0; i < clothings.length; i++) {
      final Clothing clothing = clothings[i];

      if (clothing.objectLink == null) {
        continue;
      }

      if (clothing.imageUrl != null ||
          (clothing.imageExpiration != null ||
              clothing.imageExpiration!.isBefore(DateTime.now()))) {
        final String signedUrl = getIt.get<CloudStorage>().generateSignedUrl(
              Credentials().googleServiceAccount,
              "clothing-app",
              clothing.objectLink!,
            );

        clothings[i] = clothing.copyWith(
          imageUrl: signedUrl,
          imageExpiration: DateTime.now().add(const Duration(days: 7)),
        );
      }
    }

    return Response.ok(clothings.toJson());
  } catch (e, s) {
    getIt.get<Logger>().e(e, stackTrace: s);
    return Response.internalServerError(body: e.toString());
  }
}
