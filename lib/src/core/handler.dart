part of jaguar.rpc.core;

/// A pair of [path] and the corresponding [Handler] [handler]
class Route implements RpcRequestHandler {
  /// The route path
  final String path;

  /// The request handler
  final Handler handler;

  /// Constructs a [Route] from given [path] and [Handler] [handler]
  const Route(this.path, this.handler);

  /// Handles request
  FutureOr<RpcResponse> handleRequest(RpcRequest request) {
    if (path != request.path) // TODO match properly
      return null;
    return handler(request);
  }
}

/// An RPC endpoint. Encapsulates a list of routes and executes the appropriate
/// one based on the incoming request.
class RpcEndpoint implements RpcRequestHandler {
  /// The list of composing [Route]s
  final List<Route> _handlers = <Route>[];

  /// Adds a new [Route] to the endpoint
  void route(String path, Handler handler) =>
      _handlers.add(new Route(path, handler));

  /// Executes an appropriate [Handler] and returns the response
  FutureOr<RpcResponse> handleRequest(RpcRequest request) {
    for (Route route in _handlers) {
      final RpcResponse resp = route.handleRequest(request);
      if (resp is RpcResponse && resp.status != RpcStatus.notFound.value) {
        if (resp.id == null) resp.id = request.id;
        return resp;
      }
    }

    return new RpcResponse.notFound(id: request.id);
  }
}
