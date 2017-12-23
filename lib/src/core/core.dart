library jaguar.rpc.core;

import 'dart:async';
import 'dart:convert';

part 'request.dart';
part 'response.dart';
part 'handler.dart';

abstract class RpcRequestHandler {
  FutureOr<RpcResponse> handleRequest(RpcRequest request);
}

typedef RpcResponse Handler(RpcRequest request);
