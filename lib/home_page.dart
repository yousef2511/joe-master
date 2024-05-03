
import 'package:flutter/material.dart';
import 'Login_page.dart';
import 'newB.dart';

void main() async {

  runApp(MyApp());
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/pp2.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200),
              FindSection(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FlutterBlueApp(),
                    ),
                  );
                },
                child: Text('Connect Manually'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FindSection extends StatefulWidget {
  @override
  _FindSectionState createState() => _FindSectionState();
}

class _FindSectionState extends State<FindSection> {
  bool _showSquare = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              _showSquare = true;
            });
          },
          child: Text('Find'),
        ),
        SizedBox(height: 20),
        if (_showSquare)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter ID',
                    labelText: 'Enter ID',
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Add functionality to find the entered ID
                  },
                  child: Text('Find'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
