import 'package:flutter/material.dart';

class Person {
  final String name;
  final String email;

  Person({required this.email, required this.name});
}

class PeopleProvider extends ChangeNotifier {
  List<Person> _people = [];
  List<Person> get people => _people;

  void addPerson(Person person) {
    _people.add(person);
    notifyListeners();
  }
}

class PersonnelDataSource {
  static List<Person> personnel = [
    Person(name: 'user 1', email: ''),
    Person(name: 'user 2', email: ''),
    Person(name: 'user 3', email: ''),
    Person(name: 'user 4', email: ''),
    Person(name: 'user 5', email: ''),
    Person(name: 'user 6', email: ''),
    Person(name: 'user 7', email: ''),
    Person(name: 'user 8', email: ''),
    Person(name: 'user 9', email: ''),
    Person(name: 'Operator', email: ''),
  ];
}

class User {
  final String username;
  final String password;
  User({required this.username, required this.password});
}

class UserDatabase {
  static List<User> _users = [
    User(username: 'user 1', password: 'password1'),
  ];

  static User? getUserByUsername(String username) {
    return _users.firstWhere(
      (user) => user.username == username,
       // Specify the return type as User?
    );
  }

  static bool verifyCredentials(String username, String password) {
    User? user = getUserByUsername(username);
    return user != null && user.password == password;
  }
}
