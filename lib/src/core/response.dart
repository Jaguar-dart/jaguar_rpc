part of jaguar.rpc.core;

RpcResponse response({String id, int status: 200, dynamic body}) =>
    new RpcResponse(id: id, status: status, body: body);

class RpcResponse {
  String what;

  String id;

  int status;

  dynamic body;

  RpcResponse({this.what: 'JRPCS 1.0', this.id, this.status: 200, this.body});

  RpcResponse.notFound({this.id}) : status = RpcStatus.notFound.value;

  RpcResponse.decodeJsonMap(Map<String, dynamic> map) {
    print(map);
    if (map['what'] != 'JRPCS 1.0')
      throw new ArgumentError.value(map, 'map[\'what\']',
          'Not a valid Jaguar RPC response! "what" field has invalid value');

    if (map['id'] is String) id = map['id'];
    if (map['status'] is int)
      status = map['status'];
    else
      map['status'] = RpcStatus.success.value;
    body = map['body'];
  }

  factory RpcResponse.decodeJson(String data) {
    final decoded = json.decode(data);

    if (decoded is! Map)
      throw new ArgumentError.value(
          data, 'json', 'Not a valid Jaguar RPC response!');

    return new RpcResponse.decodeJsonMap(decoded);
  }

  Map<String, dynamic> get toMap {
    final map = <String, dynamic>{};

    map['what'] = what;
    if (id != null) map['id'] = id;
    if (status != null) map['status'] = status;
    if (body != null) map['body'] = body;

    return map;
  }

  String get toJson => json.encode(toMap);
}

class RpcStatus {
  final int value;

  const RpcStatus(this.value);

  static const RpcStatus notFound = const RpcStatus(-404);

  static const RpcStatus success = const RpcStatus(200);
}
