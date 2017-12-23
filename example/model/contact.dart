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