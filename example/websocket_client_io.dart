import 'package:jaguar/jaguar.dart';
import 'package:jaguar_rpc/jaguar_rpc.dart';
import 'package:jaguar_rpc/websocket.dart';

import 'model/contact.dart';

final Contacts contacts = new Contacts();

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
