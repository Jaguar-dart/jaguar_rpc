part of jaguar.rpc.core;

RpcRequest request(String path,
        {String id, Map<String, String> params, dynamic body}) =>
    new RpcRequest(path, id: id, params: params, body: body);

class RpcRequest {
  String what;

  String id;

  String path;

  Map<String, String> params;

  dynamic body;

  RpcRequest(this.path,
      {this.what: 'JRPCQ 1.0', this.id, this.params, this.body});

  RpcRequest.decodeJsonMap(Map<String, dynamic> map) {
    if (map['what'] != 'JRPCQ 1.0')
      throw new ArgumentError.value(map, 'map',
          'Not a valid Jaguar RPC request! "what" field has invalid value!');

    if (map['what'] is String) what = map['what'];
    if (map['id'] is String) id = map['id'];
    if (map['path'] is String) path = map['path'];
    if (map['params'] is Map<String, String>) params = map['params'];
    if (map['body'] is String) body = map['body'];
  }

  factory RpcRequest.decodeJson(String json) {
    final decoded = JSON.decode(json);

    if (json is! Map)
      throw new ArgumentError.value(
          json, 'json', 'Not a valid Jaguar RPC request!');

    return new RpcRequest.decodeJsonMap(decoded);
  }

  String encodeJson() {
    final map = <String, dynamic>{};

    map['what'] = what;
    if (id != null) map['id'] = id;
    if (path != null) map['path'] = path;
    if (params != null) map['params'] = params;
    if (body != null) map['body'] = body;

    return JSON.encode(map);
  }
}
