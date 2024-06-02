import 'package:apneasense/components/alertmessage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class ECGPage extends StatefulWidget {
  const ECGPage({Key? key}) : super(key: key);

  @override
  State<ECGPage> createState() => _ECGPageState();
}

class _ECGPageState extends State<ECGPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser!;
  late Timer _heartbeatTimer = Timer(const Duration(seconds: 0), () {});

  @override
  void initState() {
    super.initState();
    _startHeartbeat();
  }

  @override
  void dispose() {
    _stopHeartbeat();
    super.dispose();
  }

  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _sendHeartbeat();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer.cancel();
  }

  Future<void> _sendHeartbeat() async {
    try {
      final response = await http.post(
        Uri.parse('http://13.50.17.49:5000/heartbeat'),
      );

      if (response.statusCode == 200) {
        print('Heartbeat sent successfully');
      } else {
        print('Failed to send heartbeat: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error sending heartbeat: $e');
    }
  }

  bool isNonApnic = false;
  bool isApnic = false;
  bool isBlank = true;
  bool isAnalysis = false;

  bool isStartButtonEnabled = true;
  bool isTerminateButtonEnabled = false;
  bool isDataFetch = false;
  bool continuousCall = false;
  List<Map<String, dynamic>> ECGValues = [];
  int latestTimestamp = 0;

  Future<void> fetchLatestECGValuesFromUbidots() async {
    String apikey = "BBUS-llkCCBCGG4YJGJjsl12mywraAcfQkV";
    String url =
        'https://industrial.api.ubidots.com/api/v1.6/devices/apneasense/ecg/values/?page_size=1';
    Map<String, String> headers = {"X-Auth-Token": apikey};

    try {
      while (isDataFetch) {
        final response = await http.get(Uri.parse(url), headers: headers);
        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);
          if (data.containsKey("results") && data["results"].isNotEmpty) {
            final latestEntry = data["results"][0];
            if (latestEntry['timestamp'] != latestTimestamp) {
              setState(() {
                ECGValues.add({
                  'timestamp': DateTime.fromMillisecondsSinceEpoch(
                      latestEntry['timestamp']),
                  'value': latestEntry['value'],
                });
                latestTimestamp = latestEntry['timestamp'];
              });
            }
          }
        } else {
          throw Exception('Failed to fetch data');
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching SpO2 values: $e');
    }
  }

  Future<void> _termination() async {
    setState(() {
      isAnalysis = false;
      isBlank = true;
      isTerminateButtonEnabled = false;
      isStartButtonEnabled = true;
      isDataFetch = false;
      continuousCall = false;
      ECGValues.clear();
    });

    final response =
        await http.post(Uri.parse('http://13.50.17.49:5000/ecgterminate'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      String message = jsonData['message'];
      // ignore: avoid_print
      print('Message: $message');
    } else {
      // ignore: avoid_print
      print('Request failed with status: ${response.statusCode}');
    }
  }

  // Future<bool> _checkInternetConnection() async {
  //   try {
  //     final result = await InternetAddress.lookup('example.com');
  //     return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  //   } on SocketException catch (_) {
  //     return false;
  //   }
  // }

  Future<void> _handleStart() async {
    setState(() {
      continuousCall = true;
      isDataFetch = true; // Data In Graph Start Displaying
      isStartButtonEnabled = false; // Start Button becomes disabled
      isTerminateButtonEnabled = true; // Terminate Button becomes enabled
      isBlank = false; // Blank Image goes away
      isAnalysis = true; // Data Fetching Image shows up
    });

    while (continuousCall) {
      setState(() {
        isAnalysis = true;
      });
      final response =
          await http.get(Uri.parse('http://13.50.17.49:5000/ecgpredict'));

      if (response.statusCode == 200) {
        DateTime endTime = DateTime.now();
        final jsonData = jsonDecode(response.body);
        if (jsonData.containsKey('array')) {
          final List<dynamic> array = jsonData['array'];
          final int arrayValue = array[0][0];
          await _firestore.collection('Users').doc(user.email!).update({
            'ECG': FieldValue.arrayUnion(
              [arrayValue],
            ),
            'timestampECG': FieldValue.arrayUnion(
              [endTime],
            ),
          });

          print("Array Value :: $array");
          print(arrayValue);

          if (arrayValue == 0) {
            setState(() {
              isAnalysis = false;
              isNonApnic = true;
              isApnic = false;
              isBlank = false;
              ECGValues.clear();
            });
          } else if (arrayValue == 1) {
            setState(() {
              isAnalysis = false;
              isNonApnic = false;
              isApnic = true;
              isBlank = false;
              ECGValues.clear();
            });
          }
          await Future.delayed(const Duration(seconds: 3));
        } else if (jsonData.containsKey('message')) {
          String message = jsonData['message'];
          print('Message: $message');
        }
      } else {
        String errorMessage =
            'Request failed with status: ${response.statusCode.toString()}';
        displayMessageToUser(errorMessage, context);

        setState(() {
          isAnalysis = false;
          isTerminateButtonEnabled = false;
          isStartButtonEnabled = true;
          isDataFetch = false;
          isBlank = true;
          ECGValues.clear();
        });
        break;
      }

      setState(() {
        isBlank = false; // isBlank needs to be true to start the process again
        isNonApnic = false;
        isApnic = false; // Reset for the next iteration
        isAnalysis = false; // Ensure isAnalysis is reset
      });

      // Adding a small delay to allow state to properly reset
      await Future.delayed(const Duration(milliseconds: 2000));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 405,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 0,
                      top: 50,
                      right: 15.0,
                      bottom: 5,
                    ),
                    child: LineChartWidget(ECGValues: ECGValues),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                top: 15,
                right: 0,
              ),
              child: Container(
                width: double.infinity,
                height: 210,
                color: Colors.white,
                child: Center(
                  child: Stack(
                    children: [
                      if (isNonApnic)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Image.asset('assets/images/normalsleep.png',
                                width: 150, height: 150),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Normal Sleep',
                              style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    color: Colors.lightGreen,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      if (isApnic)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Image.asset('assets/images/apnea.png',
                                width: 150, height: 150),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Apnea Event',
                              style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      if (isBlank)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Image.asset('assets/images/blank.png',
                                width: 150, height: 150),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'No Event',
                              style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      if (isAnalysis)
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Image.asset('assets/images/analysis.png',
                                width: 150, height: 150),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Fetching Values..',
                              style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                      // if (isTerminate)
                      //   Column(
                      //     children: [
                      //       const SizedBox(
                      //         height: 10,
                      //       ),
                      //       Image.asset('assets/images/terminate.png',
                      //           width: 150, height: 150),
                      //       const SizedBox(
                      //         height: 10,
                      //       ),
                      //       Text(
                      //         'Terminating Process..',
                      //         style: GoogleFonts.roboto(
                      //           textStyle: const TextStyle(
                      //               color: Colors.red,
                      //               fontSize: 20,
                      //               fontWeight: FontWeight.w900),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 10, right: 10, bottom: 15),
              // ignore: sized_box_for_whitespace
              child: Container(
                width: double.infinity,
                height: 150,
                child: Column(
                  children: [
                    //---------------------handleStart button Logic ------------
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isStartButtonEnabled
                            ? () {
                                _handleStart();
                                fetchLatestECGValuesFromUbidots();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          backgroundColor: const Color(0xff64EBB6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Start',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    //--------------------Terminate Button Logic---------------
                    // ignore: sized_box_for_whitespace
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            isTerminateButtonEnabled ? _termination : null,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          foregroundColor:
                              const Color.fromARGB(255, 255, 255, 255),
                          backgroundColor: const Color(0xff64EBB6),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Terminate',
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//-------------------------- Line Chart ----------------------------------------
class LineChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> ECGValues;

  LineChartWidget({required this.ECGValues});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = [];
    for (var data in ECGValues) {
      spots.add(FlSpot(
        data['timestamp'].millisecondsSinceEpoch.toDouble(),
        data['value'].toDouble(),
      ));
    }

    return LineChart(
      LineChartData(
        // To set grid lines.
        gridData: const FlGridData(
          show: true,
        ),
        titlesData: FlTitlesData(
          show: true,
          // Right side titles of the graph
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          // Left side titles of the graph
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
            axisNameWidget: Text(
              'ECG',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: Color(0xff64EBB6),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            axisNameSize: 35,
          ),

          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(value.toInt());
                String formattedDate =
                    "${date.hour}:${date.minute}:${date.second}";
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10,
                  child: Transform.rotate(
                    angle: -90 * 3.1415927 / 180,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            axisNameWidget: Text(
              'Time Stamp',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                    color: Color(0xff64EBB6),
                    fontSize: 14,
                    fontWeight: FontWeight.w900),
              ),
            ),
            axisNameSize: 20,
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        minY: 0,
        maxY: 5,
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey, width: 2),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            color: const Color(0xff64EBB6),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(
              show: true,
              color: Colors.grey.withOpacity(0.3),
            ),
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}
