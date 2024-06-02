import 'package:apneasense/components/drawer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:apneasense/components/resources.dart';
import 'package:apneasense/components/alertmessage.dart';
import 'package:apneasense/pages/upload_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:instagram_clone/helper/resources.dart';
// import 'package:instagram_clone/pages/upload_image.dart';

// Other necessary imports for image picker, storage, network, etc.

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Variables to store profile data from state management
  // String profileImagePath = "";
  String dateofbirth = "";
  String name = "";
  String gender = "";
  String age = "";
  String username = "";
  bool isAnyFieldEmpty() {
    if (name.isEmpty ||
        age.isEmpty ||
        gender.isEmpty ||
        username.isEmpty ||
        dateofbirth.isEmpty ||
        _image == null) {
      displayMessageToUser("Fields cannot be empty.", context);
      return true;
    } else {
      return false;
    }
  }

  void saveProfile() async {
    if (isAnyFieldEmpty()) {
      return;
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: AlertDialog(
              actions: [
                Center(child: CircularProgressIndicator()),
              ],
              title: Center(child: Text("Saving..")),
            ),
          );
        },
      );
      await storeData().saveData(
        name: name,
        file: _image!,
        age: age,
        username: username,
        gender: gender,
        dateofbirth: dateofbirth,
      );

      Navigator.pop(context);
    }
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
                  "D E T A I L S",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        : const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircleAvatar(
                              radius: 90,
                              foregroundImage: NetworkImage(
                                'https://cdn.vectorstock.com/i/500p/08/19/gray-photo-placeholder-icon-design-ui-vector-35850819.jpg',
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 5),
              Center(
                child: Text(
                  "Edit Picture",
                  style: GoogleFonts.roboto(
                    textStyle: const TextStyle(
                        color: Color(0xff64EBB6),
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Text fields for name, username, live, about, and pronouns
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xff64EBB6), width: 2.0)),
                    labelStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) => setState(() => name = value.trim()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'UserName',
                    hintText: 'UserName',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xff64EBB6), width: 2.0)),
                    labelStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) => setState(() => username = value.trim()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Age',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xff64EBB6), width: 2.0)),
                    labelStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) => setState(() => age = value.trim()),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    hintText: 'DD/MM/YYYY',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Color(0xff64EBB6), width: 2.0)),
                    labelStyle: const TextStyle(color: Colors.grey)),
                onChanged: (value) =>
                    setState(() => dateofbirth = value.trim()),
              ),
              Row(
                children: [
                  Text(
                    "Gender", // Or format userDateOfBirth as desired
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Color(0xff64EBB6),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Radio buttons for common options
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Male',
                        groupValue: gender,
                        onChanged: (value) => setState(() => gender = value!),
                        activeColor: Colors.grey,
                      ),
                      Text(
                        "Male", // Or format userDateOfBirth as desired
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Color(0xff64EBB6),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 1),
                      Radio<String>(
                        value: 'Female',
                        groupValue: gender,
                        onChanged: (value) => setState(() => gender = value!),
                        activeColor: Colors.grey,
                      ),
                      Text(
                        "Female", // Or format userDateOfBirth as desired
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                              color: Color(0xff64EBB6),
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  // Additional option for custom gender
                  Radio<String>(
                    value: 'Other',
                    groupValue: gender,
                    onChanged: (value) => setState(() => gender = value!),
                    activeColor: Colors.grey,
                  ),
                  Text(
                    "Other", // Or format userDateOfBirth as desired
                    style: GoogleFonts.roboto(
                      textStyle: const TextStyle(
                          color: Color(0xff64EBB6),
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: saveProfile,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          12), // Adjust the value as needed
                    ),
                    backgroundColor: const Color(0xff64EBB6),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      'Save',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
