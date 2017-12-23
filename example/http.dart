import 'package:jaguar/jaguar.dart';
import 'package:jaguar_rpc/jaguar_rpc.dart';
import 'package:jaguar_rpc/http.dart';
import 'package:jaguar_client/jaguar_client.dart';
import 'package:http/http.dart' as http;

import 'model/contact.dart';

final Contacts contacts = new Contacts();

main() async {
  int contactIdGen = 0;

  final endpoint = new RpcEndpoint()
    ..route('/get/version', (_) => response(body: {'major': '1', 'minor': '0'}))
    ..route('/add/todo', (RpcRequest req) {
      final newContact = new Contact.fromJson(req.body);
      newContact.id = contactIdGen++;
      contacts.contacts.add(newContact);
      return response(body: contacts.json);
    });

  final server = new Jaguar();
  server.addApi(rpcOnHttp(endpoint));

  await server.serve();

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
