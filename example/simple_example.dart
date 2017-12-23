import 'package:jaguar_rpc/jaguar_rpc.dart';

import 'model/contact.dart';

final Contacts contacts = new Contacts();

void printSeparator() => print('------------------------');

main() {
  int contactIdGen = 0;

  final endpoint = new RpcEndpoint()
    ..route('/get/version', (_) => response(body: {'major': '1', 'minor': '0'}))
    ..route('/add/todo', (RpcRequest req) {
      final newContact = new Contact.fromJson(req.body);
      newContact.id = contactIdGen++;
      contacts.contacts.add(newContact);
      return response(body: contacts.json);
    });

  {
    final RpcResponse resp = endpoint.handleRequest(request('/get/unknown'));
    print(resp.status);
  }

  printSeparator();

  {
    final RpcResponse resp = endpoint.handleRequest(request('/get/version'));
    print(resp.status);
    print(resp.body);
  }

  printSeparator();

  {
    final RpcResponse resp = endpoint.handleRequest(request('/add/todo',
        body: new Contact(name: 'teja', email: 'tejainece@gmail.com').toMap));
    print(resp.status);
    print(resp.body);
  }

  printSeparator();

  {
    final RpcResponse resp = endpoint.handleRequest(request('/add/todo',
        body: new Contact(name: 'kleak', email: 'kleak@gmail.com').toMap));
    print(resp.status);
    print(resp.body);
  }
}
