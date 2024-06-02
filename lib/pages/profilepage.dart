import 'dart:typed_data';
import 'package:apneasense/components/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:apneasense/pages/upload_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  // ignore: use_super_parameters
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? currentUser = FirebaseAuth.instance.currentUser!;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .get();
  }

  Uint8List? _image;

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(15)),
          child: AppBar(
            backgroundColor: Colors.white,
            title: Center(
              child: Transform.translate(
                offset: const Offset(-25, -1),
                child: Text(
                  "P R O F I L E",
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                        color: Color(0xff64EBB6),
                        fontSize: 20,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            iconTheme: const IconThemeData(
              color: Color(0xff64EBB6),
            ),
          ),
        ),
      ),
      drawer: const CustomDrawer(),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: getUserDetails(),
              builder: (context, snapshot) {
                //during loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text("Error :${snapshot.error}"),
                  );
                } else if (snapshot.hasData) {
                  Map<String, dynamic>? user = snapshot.data!.data();
                  return SingleChildScrollView(
                    child: SizedBox(
                      height: MediaQuery.of(context)
                          .size
                          .height, // Set the height to match the screen height
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          InkWell(
                            onTap: selectImage,
                            child: _image != null
                                ? Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                      radius: 90,
                                      backgroundImage: MemoryImage(
                                        (_image!),
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                      radius: 90,
                                      foregroundImage: NetworkImage(
                                          '${user?['imageLink'] ?? "https://cdn.vectorstock.com/i/500p/08/19/gray-photo-placeholder-icon-design-ui-vector-35850819.jpg"}'
                                          //  "${user['imageLink']}"
                                          ),
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            user?['username'] ?? "username",
                            style: GoogleFonts.roboto(
                              textStyle: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Divider(
                            height: 20,
                            thickness: 1,
                            indent: 50,
                            endIndent: 50,
                            color: Colors.grey,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xff64EBB6)
                                          .withOpacity(0.8)),
                                  margin: const EdgeInsets.only(top: 25),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Name:", // Or format userDateOfBirth as desired
                                          style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 28,
                                        ),
                                        Text(
                                          user?['name'] ?? "null",
                                          style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ), // ------------------this is not in firebase right now
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xff64EBB6)
                                          .withOpacity(0.8)),
                                  margin: const EdgeInsets.only(top: 25),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          "DOB:", // Or format userDateOfBirth as desired
                                          style: GoogleFonts.roboto(
                                            textStyle: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 25),
                                        Expanded(
                                          child: Text(
                                            user?['dateofbirth'] ?? "null",
                                            style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xff64EBB6)
                                          .withOpacity(0.8)),
                                  margin: const EdgeInsets.only(top: 25),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          "Gender:", // Or format userDateOfBirth as desired
                                          style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 22),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 28),
                                        Expanded(
                                          child: Text(
                                            user?['gender'] ?? "null",
                                            style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: const Color(0xff64EBB6)
                                          .withOpacity(0.8)),
                                  margin: const EdgeInsets.only(top: 25),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Text(
                                          "Age:", // Or format userDateOfBirth as desired
                                          style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 22),
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 28),
                                        Expanded(
                                          child: Text(
                                            user?['age'] ?? "null",
                                            style: GoogleFonts.roboto(
                                              textStyle: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
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
                        ],
                      ),
                    ),
                  );
                } else {
                  return const Center(
                    child: Text("No Data Found"),
                  );
                }
              })),
    );
  }
}
