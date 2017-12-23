import 'package:jaguar_rpc/jaguar_rpc.dart';

class Contact {
  int id;

  String name;

  String email;

  Contact({this.name, this.email});

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
  }

  Map<String, dynamic> get json => {
        'id': id,
        'name': name,
        'email': email,
      };
}

class Contacts {
  final contacts = <Contact>[];

  List<Map<String, dynamic>> get json =>
      contacts.map((contact) => contact.json).toList();
}

final Contacts contacts = new Contacts();

void printSeparator() => print('------------------------');

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

  printSeparator();

  {
    final RpcResponse resp = server.handleRequest(request('/add/todo',
        body: new Contact(name: 'teja', email: 'tejainece@gmail.com').json));
    print(resp.status);
    print(resp.body);
  }

  printSeparator();

  {
    final RpcResponse resp = server.handleRequest(request('/add/todo',
        body: new Contact(name: 'kleak', email: 'kleak@gmail.com').json));
    print(resp.status);
    print(resp.body);
  }
}
