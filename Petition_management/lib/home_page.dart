import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'results_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController petitionController = TextEditingController();

  File? selectedFile;
  bool isLoading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> submitPetition(BuildContext context) async {
    String name = nameController.text.trim();
    String age = ageController.text.trim();
    String email = emailController.text.trim();
    String phone = phoneController.text.trim();
    String petitionText = petitionController.text.trim();

    if (name.isEmpty || age.isEmpty || email.isEmpty || phone.isEmpty || (petitionText.isEmpty && selectedFile == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields or upload a PDF")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    var uri = Uri.parse("https://1648-2402-3a80-479-f517-54f9-d3e8-2954-d7be.ngrok-free.app/analyze_petition"); // Flask server IP

    var request = http.MultipartRequest("POST", uri);
    request.fields["name"] = name;
    request.fields["age"] = age;
    request.fields["email"] = email;
    request.fields["phone"] = phone;
    request.fields["text"] = petitionText;

    if (selectedFile != null) {
      request.files.add(await http.MultipartFile.fromPath("file", selectedFile!.path));
    }

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = jsonDecode(responseData);

      setState(() {
        isLoading = false;
      });

      if (jsonResponse.containsKey("classification")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              name: jsonResponse["name"] ?? "N/A",
              age: jsonResponse["age"] ?? "N/A",
              email: jsonResponse["email"] ?? "N/A",
              phone: jsonResponse["phone"] ?? "N/A",
              petitionText: jsonResponse["petition_text"] ?? "N/A",
              department: jsonResponse["classification"]["department"] ?? "Unknown",
              urgency: jsonResponse["classification"]["urgency"] ?? "Unknown",
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${jsonResponse["error"] ?? "Unknown error"}")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petition Submission')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: petitionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Enter Petition',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: pickFile,
                child: const Text("Upload PDF"),
              ),
              if (selectedFile != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Selected File: ${selectedFile!.path}"),
                ),
              const SizedBox(height: 20),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: () => submitPetition(context),
                      child: const Text("Submit"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
