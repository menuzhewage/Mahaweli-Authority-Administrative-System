import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/annual_task_card.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/components/build_media_section_card.dart';
import '../classes/task.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        top: 50,
                        right: 30,
                      ),
                      child: Column(
                        children: [
                          Card(
                            color: const Color.fromARGB(255, 228, 228, 228),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Dispatch Handler Dashboard',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSidebarButton('Notifications'),
                          const SizedBox(height: 20),
                          _buildSidebarButton('Apply leaves'),
                          const Divider(),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    width: 2,
                    height: screenHeight,
                    color: const Color.fromARGB(255, 210, 210, 210),
                  ),
                  // Main Content
                  // Expanded(
                  //   flex: 5,
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(30.0),
                  //     child: Column(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         CarouselSlider(
                  //           options: CarouselOptions(
                  //             height: 260.0,
                  //             enlargeCenterPage: true,
                  //             autoPlay: true,
                  //             aspectRatio: 16 / 9,
                  //             autoPlayCurve: Curves.fastOutSlowIn,
                  //             enableInfiniteScroll: true,
                  //             autoPlayAnimationDuration:
                  //                 const Duration(milliseconds: 800),
                  //             viewportFraction: 0.8,
                  //           ),
                  //           items: tasks
                  //               .map((task) => AnnualTaskCard.buildCard(task))
                  //               .toList(),
                  //         ),
                  //         const Divider(),
                  //         BuildMediaSectionCard(),
                  //         const Spacer(),
                  //         const Center(
                  //           child: Text(
                  //             'Welcome',
                  //             style: TextStyle(
                  //               fontSize: 20,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ),
                  //         const Center(
                  //           child: Text(
                  //             'Need help? Discover what actions you can perform here!',
                  //             style: TextStyle(
                  //               fontSize: 14,
                  //               color: Colors.black,
                  //             ),
                  //           ),
                  //         ),
                  //         SizedBox(
                  //           width: screenWidth * 0.2,
                  //           height: 60,
                  //           child: Card(
                  //             color: Colors.white,
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(10)),
                  //             child: const Center(
                  //               child: Column(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 crossAxisAlignment: CrossAxisAlignment.center,
                  //                 children: [
                  //                   Text('Personal File Handling'),
                  //                   Text('Request Management'),
                  //                 ],
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //         const Spacer(),
                  //         SizedBox(
                  //           height: 60,
                  //           child: CustomBottomNavigationBar(),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight),
                              child: IntrinsicHeight(
                                child: Column(
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
                                          .map((task) =>
                                              AnnualTaskCard.buildCard(task))
                                          .toList(),
                                    ),
                                    const Divider(),
                                    BuildMediaSectionCard(),
                                    const Spacer(),
                                    const Center(
                                      child: Text(
                                        'Welcome',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                    const Center(
                                      child: Text(
                                        'Need help? Discover what actions you can perform here!',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenWidth * 0.2,
                                      height: 60,
                                      child: Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text('Personal File Handling'),
                                              Text('Request Management'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      height: 60,
                                      child: CustomBottomNavigationBar(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    width: 2,
                    height: screenHeight,
                    color: const Color.fromARGB(255, 210, 210, 210),
                  ),
                  // Right Sidebar
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 20,
                        left: 20,
                        right: 20,
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Card(
                              color: const Color.fromARGB(255, 106, 10, 157),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Todo',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: Card(
                              color: const Color.fromARGB(255, 114, 20, 173),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [],
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
          );
        },
      ),
    );
  }

  Widget _buildSidebarButton(String text) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 103, 21, 158),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        onPressed: () {},
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
