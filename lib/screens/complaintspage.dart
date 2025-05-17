import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/complaint_form.dart'; // Import your complaint form
import 'package:mahaweli_admin_system/screens/leaveapplypage.dart';
import 'package:mahaweli_admin_system/screens/complaintsdetailspage.dart'; // Import the new complaint details page

class Complaintspage extends StatefulWidget {
  const Complaintspage({super.key});

  @override
  State<Complaintspage> createState() => _ComplaintspageState();
}

class _ComplaintspageState extends State<Complaintspage> {
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
                                'Complaint Handler Dashboard',
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
                          onPressed: () {},
                          child: const Text('Complaints',
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
                                  dashboardTitle: 'Complaint Handler Dashboard',
                                  firstButtonText: 'Complaints',
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
              Expanded(
                child: Container(
                  width: MediaQuery.sizeOf(context).width * 0.5,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            const TextField(
                              decoration: InputDecoration(
                                labelText: 'Search by Beneficiary ID',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: ListView.builder(
                                itemCount:
                                    10, // Replace with the actual number of complaints
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ComplaintDetailsPage(
                                            complaintId:
                                                'agri/land/001/n008', // Pass the complaint ID
                                          ),
                                        ),
                                      );
                                    },
                                    child: Card(
                                      child: ListTile(
                                        title: Text(
                                            'complaint_ID: agri/land/001/n008 10.00AM 2024'),
                                        // Add more details as needed
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: FloatingActionButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  content: Container(
                                    width: double.maxFinite,
                                    child:
                                        const ComplaintForm(), // Use your existing complaint form
                                  ),
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.add),
                        ),
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
