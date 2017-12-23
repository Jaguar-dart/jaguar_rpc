import 'dart:io';
import 'dart:async';
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
