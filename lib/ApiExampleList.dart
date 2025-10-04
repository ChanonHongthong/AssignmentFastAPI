import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiExampleList extends StatefulWidget {
  const ApiExampleList({super.key});
  @override
  State<ApiExampleList> createState() => _ApiExampleListState();
}

class _ApiExampleListState extends State<ApiExampleList> {

  @override
  void initState() {
    super.initState();
    fetchAllUser();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('APIExampleList'),
        backgroundColor: Colors.red,
        actions: [
          ElevatedButton(
            onPressed: () {
              fetchAllUser();
            }, 
            child: Icon(Icons.refresh)
          )
        ],
      ),
      body: ListView.separated(
        itemCount: listEmployee.length,
        itemBuilder: (BuildContext context, int index){
          return ListTile(
            leading: Text('${listEmployee[index].id}'),
            title: Text('${listEmployee[index].name}'),
            trailing: Text('${listEmployee[index].email}'),
            subtitle: Text('${listEmployee[index].phone}'),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Divider();
        }, 
      )
    );
  }

  UserEmployee? userEmployee;
  List<UserEmployee> listEmployee = [];

  void fetchAllUser() async {
    try {
      var response = await http
          .get(Uri.parse('https://jsonplaceholder.typicode.com/users/'));
          if (response.statusCode == 200) {
            List<dynamic> jsonList = jsonDecode(response.body);
            setState(() {
              listEmployee = jsonList.map((item) => UserEmployee.fromJson(item)).toList();
            });
            // var data = jsonDecode(response.body);
            // setState(() {
            //   userEmployee = UserEmployee.fromJson(data);
            // });
          }
    } catch (e) {
      print('Error: $e');
    }
  }
}

// Model Class
class UserEmployee {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  // Constructor
  UserEmployee(this.id, this.name, this.username, this.email, this.phone);
  // แปลง JSON เป็น Object
  UserEmployee.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        username = json['username'],
        email = json['email'],
        phone = json['phone'];
  // แปลง Object เป็น JSON Map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'username': username, 'email': email, 'phone': phone};
  }
}