import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_rpc/src/core/core.dart';

/// Convenient function to create [RpcOnHttp] from a [RpcEndpoint]
List<Route> rpcOnHttp(RpcEndpoint endpoint) => RpcOnHttp(endpoint).routes;

/// Convenient function to create [RpcToHttp] from a [RpcEndpoint]
List<Route> rpcToHttp(RpcEndpoint endpoint) => RpcToHttp(endpoint).routes;

/// Plain RPC on HTTP
class RpcOnHttp {
  /// Underlying RPC endpoint
  final RpcEndpoint endpoint;

  List<Route> routes = [];

  RpcOnHttp(this.endpoint) {
    for (final handler in endpoint.handlers) {
      routes.add(Route(handler.path, (ctx) => handleRequest(ctx, handler)));
    }
  }

  Future<Response> handleRequest(Context ctx, RpcRoute handler) async {
    final rpcRequest = await convertRequest(ctx);
    final rpcResponse = handler.handleRequest(rpcRequest);
    return convertResponse(rpcResponse);
  }

  /// Utility function to convert [Context] to [RpcRequest]
  static Future<RpcRequest> convertRequest(Context ctx) async {
    return new RpcRequest.decodeJsonMap(await ctx.bodyAsJsonMap());
  }

  /// Utility function to convert [RpcResponse] to [Response]
  static Response convertResponse(RpcResponse response) {
    if (response is! RpcResponse &&
        response.status == RpcStatus.notFound.value) {
      return null;
    }

    return Response.json(response.toMap);
  }
}

/// Interprets HTTP as RPC
class RpcToHttp {
  /// Underlying RPC endpoint
  final RpcEndpoint endpoint;

  List<Route> routes = [];

  RpcToHttp(this.endpoint) {
    for (final handler in endpoint.handlers) {
      routes.add(Route(handler.path, (ctx) => handleRequest(ctx, handler)));
    }
  }

  Future<Response> handleRequest(Context ctx, RpcRoute handler) async {
    final rpcRequest = await convertRequest(ctx);
    final rpcResponse = handler.handleRequest(rpcRequest);
    return convertResponse(rpcResponse);
  }

  /// Utility function to convert [Context] to [RpcRequest]
  static Future<RpcRequest> convertRequest(Context ctx) async {
    final params = <String, dynamic>{};
    params.addAll(ctx.query);
    // TODO add path params to params
    // TODO add headers to params

    return new RpcRequest(ctx.path,
        id: ctx.query['jrpcid'], body: await ctx.bodyAsJson(), params: params);
  }

  /// Utility function to convert [RpcResponse] to [Response]
  static Response convertResponse(RpcResponse response) {
    final Response ret = Response.json(response.body);
    if (response.id != null) ret.headers.add('jrpcid', response.id);
    ret.headers.add('jrpcstatus', response.status);
    return ret;
  }
}
