// ignore_for_file: sort_child_properties_last

import 'package:crud/user_form.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:crud/models/users.dart';
import 'package:crud/models/config.dart';
import 'package:crud/login.dart';
import 'package:crud/user_info.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Users CRUD',
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/login': (context) => const Login(),
        '/userform': (context) => const UserForm()
      },
    );
  }
}

class Home extends StatefulWidget {
  static const routeName = '/';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();

  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

  List<Users> _userList = [];
  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, 'users');
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

  Widget showUsers() {
    return (ListView.builder(
      itemCount: _userList.length,
      itemBuilder: (context, index) {
        Users user = _userList[index];

        Future<void> removeUsers(user) async {
          //@remind
          var url = Uri.http(Configure.server, 'users/${user.id}');
          var resp = await http.delete(url);
          print(resp.body);
          return;
        }

        return Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.endToStart,
          child: Card(
            child: ListTile(
              title: Text('${user.fullname}'),
              subtitle: Text('${user.email}'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UserInfo(),
                        settings: RouteSettings(arguments: user)));
              },
              trailing: IconButton(
                onPressed: () async {
                  String result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserForm(),
                          settings: RouteSettings(arguments: user)));
                  if (result == 'refresh') {
                    getUsers();
                  }
                },
                icon: Icon(Icons.edit),
              ),
            ),
          ),
          onDismissed: (direction) {
            removeUsers(user);
          },
          background: Container(
            color: Colors.red,
            margin: EdgeInsets.symmetric(horizontal: 15),
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete, color: Colors.white),
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      drawer: const SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserForm(),
              ));
          if (result == 'refresh') {
            getUsers();
          }
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }
}

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    String accountName = "N/A";
    String accountEmail = "N/A";
    String accountUrl = '';
    Users user = Configure.login;
    print(user.fullname);
    if (user.id != null) {
      accountName = user.fullname!;
      accountEmail = user.email!;
      accountUrl =
          "https://i2-prod.mirror.co.uk/incoming/article30743486.ece/ALTERNATES/s338a/0_balltze_21372186_112904979403632_7407063490164162560_n.jpg";
    }
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          UserAccountsDrawerHeader(
              accountName: Text(accountName),
              accountEmail: Text(accountEmail),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(accountUrl),
                backgroundColor: Colors.white,
              )),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, Home.routeName);
            },
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Login'),
            onTap: () {
              if (accountEmail == 'N/A') {
                Navigator.pushNamed(context, Login.routeName);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You are already logged in')));
              }
            },
          )
        ],
      ),
    );
  }
}
