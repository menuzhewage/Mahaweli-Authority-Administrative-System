import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/annual_task_card.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/components/build_media_section_card.dart';
import 'package:mahaweli_admin_system/screens/leavedetailspage.dart';
import 'package:mahaweli_admin_system/screens/leaveapplypage.dart';

import '../classes/task.dart';

class Leavehandlerpage extends StatefulWidget {
  const Leavehandlerpage({super.key});

  @override
  State<Leavehandlerpage> createState() => _LeavehandlerpageState();
}

class _LeavehandlerpageState extends State<Leavehandlerpage> {
  final List<Task> tasks = [
    Task(
      name: 'Task 1',
      description: 'Description for Task 1',
      dueDate: '2025-03-01',
      createdDate: '2025-02-15',
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97',
    ),
    Task(
      name: 'Task 2',
      description: 'Description for Task 2',
      dueDate: '2025-03-05',
      createdDate: '2025-02-16',
      imageUrl: 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d',
    ),
    Task(
      name: 'Task 3',
      description: 'Description for Task 3',
      dueDate: '2025-03-10',
      createdDate: '2025-02-17',
      imageUrl: 'https://images.unsplash.com/photo-1494172961521-33799ddd43a5',
    ),
    Task(
      name: 'Task 4',
      description: 'Description for Task 4',
      dueDate: '2025-03-15',
      createdDate: '2025-02-18',
      imageUrl: 'https://images.unsplash.com/photo-1550745165-9bc0b252726f',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  top: 50,
                  right: 30,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        child: Card(
                          color: const Color.fromARGB(255, 228, 228, 228),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                'Leave Handler Dashboard',
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 103, 21, 158),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Leavedetailspage(),
                              ),
                            );
                          },
                          child: const Text('Leave Details',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 103, 21, 158),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ))),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Leaveapplypage(
                                  dashboardTitle: 'Leave Handler Dashboard',
                                  firstButtonText: 'Leave Details',
                                  secondButtonText: 'Apply leaves',
                                ),
                              ),
                            );
                          },
                          child: const Text('Apply leaves',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              )),
                        ),
                      ),
                      const Divider(),
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.5,
                        margin: const EdgeInsets.only(
                          top: 30,
                        ),
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Chat',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: 2,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 210, 210, 210)),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 260.0,
                          enlargeCenterPage: true,
                          autoPlay: true,
                          aspectRatio: 16 / 9,
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: true,
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          viewportFraction: 0.8,
                        ),
                        items: tasks
                            .map((task) => AnnualTaskCard.buildCard(task))
                            .toList(),
                      ),
                      const Divider(),
                      BuildMediaSectionCard(),
                      const Spacer(),
                      const Center(
                        child: Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Need help? Discover what actions you can perform here!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * 0.2,
                        height: 60,
                        child: Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Personal File Handling'),
                                Text('Request Management')
                              ],
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        height: 60,
                        child: CustomBottomNavigationBar(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: MediaQuery.sizeOf(context).height,
                width: 2,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 210, 210, 210)),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.2,
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          child: Card(
                            color: const Color.fromARGB(255, 106, 10, 157),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Todo',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Container(
                        height: MediaQuery.sizeOf(context).height * 0.45,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width,
                          height: MediaQuery.sizeOf(context).height,
                          child: Card(
                            color: const Color.fromARGB(255, 114, 20, 173),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: [],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
