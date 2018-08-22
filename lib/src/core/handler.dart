part of jaguar.rpc.core;

/// A pair of [path] and the corresponding [Handler] [handler]
class RpcRoute implements RpcRequestHandler {
  /// The route path
  final String path;

  /// The request handler
  final Handler handler;

  /// Constructs a [RpcRoute] from given [path] and [Handler] [handler]
  const RpcRoute(this.path, this.handler);

  /// Handles request
  FutureOr<RpcResponse> handleRequest(RpcRequest request) {
    if (path != request.path) // TODO match properly
      return null;
    return handler(request);
  }
}

/// An RPC endpoint. Encapsulates a list of routes and executes the appropriate
/// one based on the incoming request.
class RpcEndpoint {
  /// The list of composing [RpcRoute]s
  final List<RpcRoute> handlers = <RpcRoute>[];

  /// Adds a new [RpcRoute] to the endpoint
  void route(String path, Handler handler) =>
      handlers.add(new RpcRoute(path, handler));

  /// Executes an appropriate [Handler] and returns the response
  FutureOr<RpcResponse> handleRequest(RpcRequest request) async {
    for (RpcRoute route in handlers) {
      final RpcResponse resp = route.handleRequest(request);
      if (resp is RpcResponse && resp.status != RpcStatus.notFound.value) {
        if (resp.id == null) resp.id = request.id;
        return resp;
      }
    }
    return new RpcResponse.notFound(id: request.id);
  }
}
