import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',

      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor:
            const Color(0xFFF5F7FB),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.black,
        ),

        cardTheme: const CardThemeData(
        elevation: 4,
        ),
      ),

      home: const LoginScreen(),
    );
  }
}
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(
          "http://10.0.2.2:8000/api/accounts/login/",
        ),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "username": usernameController.text,
          "password": passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        String accessToken = data['access'];

        SharedPreferences prefs =
            await SharedPreferences.getInstance();

        await prefs.setString(
          'access_token',
          accessToken,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              token: accessToken, 
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to authenticate"),
          ),
        );
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {

  final String token;

  const TodoScreen({
    super.key,
    required this.token,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List todos = [];

  final TextEditingController titleController =
      TextEditingController();

  final String baseUrl =
      "http://10.0.2.2:8000/api/tasks/";

late String token;

@override
void initState() {
  super.initState();

  token = widget.token;

  fetchTodos();
}

  Future<void> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          todos = jsonDecode(response.body);
        });
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> addTodo() async {
    try {
      final response = await http.post(
        Uri.parse(
          "http://10.0.2.2:8000/api/tasks/add/",
        ),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "title": titleController.text,
        }),
      );

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        titleController.clear();
        fetchTodos();
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await http.delete(
        Uri.parse(
          "http://10.0.2.2:8000/api/tasks/delete/$id/",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 204 ||
          response.statusCode == 200) {
        fetchTodos();
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }
  Future<void> toggleTask(int id) async {

  try {

    final response = await http.patch(

      Uri.parse(
        "http://10.0.2.2:8000/api/tasks/toggle/$id/",
      ),

      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    print(response.statusCode);

    print(response.body);

    if (response.statusCode == 200) {

      await fetchTodos();

      setState(() {});
    }

  } catch (e) {

    print(e);
  }
}

  Future<void> logout() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('access_token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        "My Tasks",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 26,
        ),
      ),

      actions: [
        IconButton(
          onPressed: logout,
          icon: const Icon(Icons.logout),
        ),
      ],
    ),

    body: Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        children: [

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),

            child: TextField(
              controller: titleController,

              decoration: const InputDecoration(
                hintText: "Add a new task",
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.all(18),
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 55,

            child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF6C63FF),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
                ),
              ),

              onPressed: addTodo,

              child: const Text(
                "Add Task",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          Expanded(
            child: ListView.builder(
              itemCount: todos.length,

              itemBuilder: (context, index) {

                final todo = todos[index];

                return Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 14,
                  ),

                  child: Card(
                    child: ListTile(

                      contentPadding:
                          const EdgeInsets.all(14),

                      leading: Checkbox(

                        value: todo['completed'],

                        activeColor:
                            const Color(0xFF6C63FF),

                        onChanged: (value) {
                          toggleTask(todo['id']);
                        
                        },
        
                      ),

                    title: Text(

                      todo['title'],

                      style: TextStyle(

                        fontWeight: FontWeight.w600,

                        fontSize: 16,

                        decoration:
                            todo['completed']
                            ? TextDecoration.lineThrough
                            : null,
  ),
),

                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),

                        onPressed: () {
                          deleteTodo(
                            todo['id'],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}