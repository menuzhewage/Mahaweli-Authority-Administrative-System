import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/bottum_navigation_bar.dart';
import 'package:mahaweli_admin_system/screens/leavehandlerpage.dart';
import 'package:mahaweli_admin_system/screens/leaveapplypage.dart';
import 'package:mahaweli_admin_system/components/leave_application_form.dart'; // Import your leave application form

class Leavedetailspage extends StatefulWidget {
  const Leavedetailspage({super.key});

  @override
  State<Leavedetailspage> createState() => _LeavedetailspageState();
}

class _LeavedetailspageState extends State<Leavedetailspage> {
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
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Leavehandlerpage(),
                            ),
                          );
                        },
                        child: Container(
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
                          onPressed: () {},
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
                                builder: (context) => const Leaveapplypage(),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Search by Employee ID or Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 20),
                            DataTable(
                              columns: const [
                                DataColumn(label: Text('Employee ID')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Leave Type')),
                                DataColumn(label: Text('Start Date')),
                                DataColumn(label: Text('End Date')),
                              ],
                              rows: const [
                                DataRow(cells: [
                                  DataCell(Text('E001')),
                                  DataCell(Text('John Doe')),
                                  DataCell(Text('Annual Leave')),
                                  DataCell(Text('2025-05-01')),
                                  DataCell(Text('2025-05-10')),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('E002')),
                                  DataCell(Text('Jane Smith')),
                                  DataCell(Text('Sick Leave')),
                                  DataCell(Text('2025-05-05')),
                                  DataCell(Text('2025-05-07')),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width: double.maxFinite,
                                    child:
                                        const LeaveApplicationForm(), // Use your existing form
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.add),
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
