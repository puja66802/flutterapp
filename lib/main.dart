import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _selectedChief = '';
  String _selectedSE = '';
  String _password = '';
  List<String> chiefs = [];
  List<String> ses = [];
  List<String> ees = [];

  @override
  void initState() {
    super.initState();
    fetchChiefs();
  }

  Future<void> fetchChiefs() async {
    print('----------------------------------');
    final response =
    await http.get(Uri.parse('http://117.250.2.226:6060/mobile/ce2'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['data'] != null) {
        setState(() {
          chiefs = List<String>.from(responseData['data']['listOfCe']);
        });
      } else {
        throw Exception('Failed to parse chiefs data');
      }
    } else {
      throw Exception('Failed to load chiefs: ${response.statusCode}');
    }
  }

  Future<void> fetchSEs(String chief) async {
    final response =
    await http.get(Uri.parse('http://117.250.2.226:6060/mobile/se/$chief'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['data'] != null) {
        List<String> tempList =
        List<String>.from(responseData['data']['listOfSe']);
        // Convert list to set to remove duplicates, then back to list
        setState(() {
          ses = tempList.toSet().toList(); // Remove duplicates
        });
      } else {
        throw Exception('Failed to parse SEs data');
      }
    } else {
      throw Exception('Failed to load SEs: ${response.statusCode}');
    }
  }

  Future<void> fetchEEs(String se) async {
    final response =
    await http.get(Uri.parse('http://117.250.2.226:6060/mobile/ee/$se'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData != null && responseData['data'] != null) {
        List<String> tempList =
        List<String>.from(responseData['data']['listOfEe']);
        setState(() {
          ees = tempList.toSet().toList();
        });
      } else {
        throw Exception('Failed to parse EEs data');
      }
    } else {
      throw Exception('Failed to load EEs: ${response.statusCode}');
    }
  }

  Future<void> login() async {
    print('Logging in...');
    final url = 'http://117.250.2.226:6060/mobile/login';
    final response = await http.post(
      Uri.parse(url),
      body: {
        'username': _selectedSE, // Use the selected SE as the username
        'password': _password,
      },
    );
    if (response.statusCode == 200) {
      // Successful authentication
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessfulAuthPage(),
        ),
      );
    } else if (response.statusCode == 401) {
      // Unsuccessful authentication
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UnsuccessfulAuthPage(),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Chief',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField(
              value: _selectedChief.isNotEmpty ? _selectedChief : null,
              items: chiefs.map((chief) {
                return DropdownMenuItem(
                  value: chief,
                  child: Text(chief),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedChief = value!;
                  fetchSEs(value);
                });
              },
              decoration: InputDecoration(
                labelText: 'Select Chief',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 20.0),
            Text(
              'Select SE',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField(
              value: null,
              items: ses.map((se) {
                return DropdownMenuItem(
                  value: se,
                  child: Text(se),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSE = value!;
                  fetchEEs(value);
                });
              },

              decoration: InputDecoration(
                labelText: 'Select SE',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Select EE',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            DropdownButtonFormField(
              value: null,
              items: ees.map((ee) {
                return DropdownMenuItem(
                  value: ee,
                  child: Text(ee),
                );
              }).toList(),
              onChanged: (value) {
                // Handle EE selection
              },
              decoration: InputDecoration(
                labelText: 'Select EE',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Enter Password',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              obscureText: true,
              onChanged: (value) {
                setState(() {
                  _password = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                login();
                // Add your submit logic here
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class SuccessfulAuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Successful Authentication'),
      ),
      body: Center(
        child: Text(
          'You have successfully authenticated!',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}

class UnsuccessfulAuthPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unsuccessful Authentication'),
      ),
      body: Center(
        child: Text(
          'Authentication failed. Please try again.',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
