# jaguar_rpc

A simple JSON based RPC protocol

# Example

## HTTP

```dart
main() async {
  int contactIdGen = 0;

  // RPC endpoint
  final endpoint = new RpcEndpoint()
    ..route('/get/version', (_) => response(body: {'major': '1', 'minor': '0'}))
    ..route('/add/todo', (RpcRequest req) {
      final newContact = new Contact.fromJson(req.body);
      newContact.id = contactIdGen++;
      contacts.contacts.add(newContact);
      return response(body: contacts.json);
    });

  // Serve the endpoint with Jaguar http server
  final server = new Jaguar();
  server.addApi(rpcOnHttp(endpoint));
  await server.serve();
}
```

Client:

```dart
main() async {
  final client =
      new JsonClient(new http.IOClient(), basePath: 'http://localhost:8080/');
  {
    final resp =
        await client.post('/get/version', body: request('/get/version').toMap);
    final rpcResp = new RpcResponse.decodeJson(resp.bodyStr);
    print(rpcResp.status);
    print(rpcResp.body);
  }
  {
    final resp = await client.post('/add/todo',
        body: request('/add/todo',
                body: new Contact(name: 'teja', email: 'tejainece@gmail.com')
                    .json)
            .toMap);
    final rpcResp = new RpcResponse.decodeJson(resp.bodyStr);
    print(rpcResp.status);
    print(rpcResp.body);
  }
}
```

## Websocket server

```dart
main() async {
  int contactIdGen = 0;

  // RPC endpoint
  final endpoint = new RpcEndpoint()
    ..route('/get/version', (_) => response(body: {'major': '1', 'minor': '0'}))
    ..route('/add/todo', (RpcRequest req) {
      final newContact = new Contact.fromJson(req.body);
      newContact.id = contactIdGen++;
      contacts.contacts.add(newContact);
      return response(body: contacts.json);
    });

  // Serve the endpoint with Jaguar http server
  final server = new Jaguar();
  server.get('/ws', rpcOnWebSocket(endpoint));
  await server.serve();
}
```

Client:

```dart
main() async {
  // Client
  final WebSocket socket = await WebSocket.connect('ws://localhost:8080/ws');
  final Stream<RpcResponse> data =
      socket.asBroadcastStream().map((d) => new RpcResponse.decodeJson(d));
  {
    socket.add(request('/get/version').json);
    final RpcResponse rpcResp = await data.first;
    print(rpcResp.status);
    print(rpcResp.body);
  }
  {
    socket.add(request('/add/todo',
            body: new Contact(name: 'teja', email: 'tejainece@gmail.com').toMap)
        .json);
    final RpcResponse rpcResp = await data.first;
    print(rpcResp.status);
    print(rpcResp.body);
  }
}
```

## WebSocket IO client

```dart
main() async {
  // Client
  final RpcWebSocketClient socket =
      await RpcWebSocketClient.connect('ws://localhost:8080/ws');
  {
    final RpcResponse rpcResp = await socket.send(request('/get/version'));
    print(rpcResp.status);
    print(rpcResp.body);
  }
  {
    final RpcResponse rpcResp = await socket.send(request('/add/todo',
        body: new Contact(name: 'teja', email: 'tejainece@gmail.com').toMap));
    print(rpcResp.status);
    print(rpcResp.body);
  }
}
```

## Isolate

> TODO

## TCP

> TODO

## Plain

```dart
main() {
  int contactIdGen = 0;

  final server = new RpcEndpoint()
    ..route('/get/version', (_) => response(body: {'major': '1', 'minor': '0'}))
    ..route('/add/todo', (RpcRequest req) {
      final newContact = new Contact.fromJson(req.body);
      newContact.id = contactIdGen++;
      contacts.contacts.add(newContact);
      return response(body: contacts.json);
    });

  {
    final RpcResponse resp = server.handleRequest(request('/get/unknown'));
    print(resp.status);
  }

  {
    final RpcResponse resp = server.handleRequest(request('/add/todo',
        body: new Contact(name: 'teja', email: 'tejainece@gmail.com').json));
    print(resp.status);
    print(resp.body);
  }
}
```

# Native extension

> TODO

# TODO

+ [X] HTTP interface
+ [X] Websocket interface
+ [ ] TCP interface
+ [ ] Isolate interface