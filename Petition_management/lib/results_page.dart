import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final String name;
  final String age;
  final String email;
  final String phone;
  final String petitionText;
  final String department;
  final String urgency;

  const ResultsPage({
    required this.name,
    required this.age,
    required this.email,
    required this.phone,
    required this.petitionText,
    required this.department,
    required this.urgency,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Petition Results')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: $name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Age: $age", style: TextStyle(fontSize: 16)),
            Text("Email: $email", style: TextStyle(fontSize: 16)),
            Text("Phone: $phone", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Petition Text:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(petitionText, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Department Assigned: $department", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Urgency Level: $urgency", style: TextStyle(fontSize: 16, color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
