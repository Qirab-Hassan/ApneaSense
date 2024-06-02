import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String? _selectedOption;
  final List<String> _options = ['ECG', 'SPO2'];
  List<int>? resultValues;
  bool _isLoading = false;
  List<Timestamp>? timestamps;
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
  }

  Future<void> fetchData(
      String attribute, Map<String, dynamic> userData) async {
    setState(() {
      _isLoading = true;
    });

    if (userData.containsKey(attribute)) {
      List<int> allValues = List<int>.from(userData[attribute]);
      List<Timestamp> allTimestamps =
          List<Timestamp>.from(userData['timestamp$attribute']);
      List<int> filteredValues = [];
      List<Timestamp> filteredTimestamps = [];

      for (int i = 0; i < allValues.length; i++) {
        if (allValues[i] == 1) {
          filteredValues.add(allValues[i]);
          filteredTimestamps.add(allTimestamps[i]);
        }
      }

      setState(() {
        resultValues = filteredValues;
        timestamps = filteredTimestamps;
        _isLoading = false;
      });
    } else {
      setState(() {
        resultValues = [];
        timestamps = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      'Patient History',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff64EBB6),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DropdownButton<String>(
                      hint: const Text('Select an option'),
                      value: _selectedOption,
                      items: _options.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue;
                          if (_selectedOption != null && user != null) {
                            fetchData(_selectedOption!, user);
                          }
                        });
                      },
                      isExpanded: true,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      underline: Container(
                        height: 2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (resultValues == null)
                    const Center(child: Text('No data'))
                  else if (resultValues!.isEmpty)
                    const Center(
                      child: Text('No data available for the selected option'),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height -
                            300, // Adjust as needed
                        child: ListView.builder(
                          itemCount: resultValues!.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: SizedBox(
                                height: 80.0,
                                child: ListTile(
                                  title: Text.rich(
                                    TextSpan(
                                      children: [
                                        const TextSpan(
                                            text: 'Apnea event cccured at'),
                                        const TextSpan(text: ' timestamp: '),
                                        TextSpan(
                                            text:
                                                '${timestamps![index].toDate()}'),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}
