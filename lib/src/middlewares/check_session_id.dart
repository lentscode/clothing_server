part of "middlewares.dart";

/// A middleware that checks if a session ID inside the cookies is valid.
Middleware checkSessionId() => (Handler innerHandler) => (Request req) async {
      try {
        final String sessionId = RequestUtils(req).getSessionId();

        final User user = await getIt.get<Auth>().checkSessionId(sessionId);

        final Request newReq =
            req.change(context: <String, Object>{"user": user});

        return innerHandler(newReq);
      } on SessionIdNotValidException catch (e) {
        return Response.unauthorized(e.toString());
      } on CookieNotFoundException catch (e) {
        return Response.unauthorized(e.toString());
      } catch (e) {
        return Response.internalServerError(body: e.toString());
      }
    };
