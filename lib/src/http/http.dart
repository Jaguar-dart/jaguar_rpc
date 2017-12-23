import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_rpc/jaguar_rpc.dart';

RpcOnHttp rpcOnHttp(RpcEndpoint endpoint) => new RpcOnHttp(endpoint);

RpcToHttp rpcToHttp(RpcEndpoint endpoint) => new RpcToHttp(endpoint);

/// Plain RPC on HTTP
class RpcOnHttp implements RequestHandler {
  final RpcEndpoint endpoint;

  RpcOnHttp(this.endpoint);

  Future<Response> handleRequest(Context ctx, {String prefix}) async {
    final RpcRequest rpcReq = await convertRequest(ctx);

    final RpcResponse rpcResp = await endpoint.handleRequest(rpcReq);

    return convertResponse(rpcResp);
  }

  static Future<RpcRequest> convertRequest(Context ctx) async {
    return new RpcRequest.decodeJsonMap(await ctx.req.bodyAsJsonMap());
  }

  static Response convertResponse(RpcResponse response) {
    if (response is! RpcResponse &&
        response.status == RpcStatus.notFound.value) {
      return null;
    }

    return Response.json(response.toMap);
  }
}

/// Interprets HTTP as RPC
class RpcToHttp implements RequestHandler {
  final RpcEndpoint endpoint;

  RpcToHttp(this.endpoint);

  Future<Response> handleRequest(Context ctx, {String prefix}) async {
    final RpcRequest rpcReq = await convertRequest(ctx);

    final RpcResponse rpcResp = await endpoint.handleRequest(rpcReq);

    return convertResponse(rpcResp);
  }

  static Future<RpcRequest> convertRequest(Context ctx) async {
    final params = <String, dynamic>{};
    params.addAll(ctx.queryParams);
    // TODO add path params to params
    // TODO add headers to params

    return new RpcRequest(ctx.path,
        id: ctx.queryParams['jrpcid'],
        body: await ctx.req.bodyAsJson(),
        params: params);
  }

  static Response convertResponse(RpcResponse response) {
    final Response ret = Response.json(response.body);
    if (response.id != null) ret.headers.add('jrpcid', response.id);
    ret.headers.add('jrpcstatus', response.status);
    return ret;
  }
}
