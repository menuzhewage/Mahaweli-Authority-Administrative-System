import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                NavigationPanel(),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            Expanded(child: TaskSlider()),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                children: [
                                  Expanded(child: TodayCard()),
                                  SizedBox(height: 10),
                                  Expanded(child: PlaceholderCard()),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            ImageSlider(),
                            WelcomeMessage(),
                            BottomNavigationBarCustom(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class NavigationPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: Colors.white,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(onPressed: () {}, child: Text('Dispatch Handler Dashboard')),
          ElevatedButton(onPressed: () {}, child: Text('Employee Profile View')),
          ElevatedButton(onPressed: () {}, child: Text('Notification Management')),
          ElevatedButton(onPressed: () {}, child: Text('Apply Leave')),
          Spacer(),
          Text('Chat'),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.chat)) ),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.chat)) ),
          TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.chat)) ),
          IconButton(onPressed: () {}, icon: Icon(Icons.add)),
        ],
      ),
    );
  }
}

class TaskSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange[100],
      child: Center(child: Text('Task Slider (Example Card)')),
    );
  }
}

class TodayCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[100],
      child: Center(child: Text('Today Card')),
    );
  }
}

class PlaceholderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green[100],
      child: Center(child: Text('Placeholder Card')),
    );
  }
}

class ImageSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.black,
      child: Center(child: Text('Image Slider', style: TextStyle(color: Colors.white))),
    );
  }
}

class WelcomeMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: const [
          Text('WELCOME', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('Need help? Discover what actions you can perform here!'),
        ],
      ),
    );
  }
}

class BottomNavigationBarCustom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Requests'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
