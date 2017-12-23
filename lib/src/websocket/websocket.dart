import 'dart:io';
import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar_rpc/jaguar_rpc.dart';

/// Jaguar RPC on top of web socket
RouteFunc rpcOnWebSocket(RpcEndpoint endpoint, {void onConnect(WebSocket ws)}) {
  return (Context ctx) async {
    final WebSocket websocket = await ctx.req.upgradeToWebSocket;
    websocket.listen((data) async {
      final req = new RpcRequest.decodeJson(data);
      final resp = await endpoint.handleRequest(req);
      if (resp is! RpcResponse) {
        websocket.add(new RpcResponse.notFound(id: req.id).json);
      } else {
        websocket.add(resp.json);
      }
    });
  };
}

class RpcWebSocketClient {
  final WebSocket _socket;

  StreamSubscription _listenSub;

  int _genId = 0;

  final _event = <String, OneTimeEvent<RpcResponse>>{};

  final Duration timeout;

  RpcWebSocketClient._(this._socket,
      {this.timeout: const Duration(seconds: 30)}) {
    _listenSub = _socket.listen((d) {
      if (d is String) {
        try {
          final RpcResponse resp = new RpcResponse.decodeJson(d);
          final OneTimeEvent<RpcResponse> event = _event.remove(resp.id);

          if (event != null && !event.isDone) event.done(resp);
        } finally {}
      } else {
        // TODO handle this
      }
    });
  }

  Future close([int code, String reason]) async {
    await _listenSub.cancel();
    await _socket.close(code, reason);
  }

  Future<RpcResponse> send(RpcRequest req) async {
    final String newId = (_genId++).toString();
    req.id = newId;

    final event = new OneTimeEvent<RpcResponse>(timeout);
    _event[newId] = event;
    _socket.add(req.json);

    return event.onDone;
  }

  static Future<RpcWebSocketClient> connect(String url,
      {Iterable<String> protocols,
      Map<String, dynamic> headers,
      CompressionOptions compression: CompressionOptions.DEFAULT}) async {
    final WebSocket socket = await WebSocket.connect(url,
        protocols: protocols, headers: headers, compression: compression);
    return new RpcWebSocketClient._(socket);
  }
}

class OneTimeEvent<T> {
  final StreamController<T> _controller;

  bool _done = false;

  bool _timedOut = false;

  Timer timeoutTimer;

  OneTimeEvent(Duration timeout) : _controller = new StreamController<T>() {
    if (timeout != null) {
      timeoutTimer = new Timer(timeout, () async {
        if (_done) return;
        _done = true;
        _timedOut = true;
        _controller.addError('Timed out!');
        await _controller.close();
      });
    }
  }

  Future done([T val]) async {
    if (_done) throw new Exception('Already done!');

    if (timeoutTimer != null) {
      if (!timeoutTimer.isActive) return;
      timeoutTimer.cancel();
    }

    _done = true;
    _controller.add(val);
    await _controller.close();
  }

  Future error(Object error, [StackTrace trace]) async {
    if (_done) throw new Exception('Already done!');

    if (timeoutTimer != null) {
      if (!timeoutTimer.isActive) return;
      timeoutTimer.cancel();
    }

    _done = true;
    _controller.addError(error, trace);
    await _controller.close();
  }

  Future<T> get onDone => _controller.stream.first;

  bool get hasTimedOut => _timedOut;

  bool get isDone => _done;
}
