# jaguar_rpc

A simple JSON based RPC protocol

# Example

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

# TODO

+ [ ] HTTP interface
+ [ ] Websocket interface
+ [ ] TCP interface