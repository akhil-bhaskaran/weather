import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Samp extends StatelessWidget {
  const Samp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              log(
                await Supabase.instance.client.auth.currentUser?.email ??
                    "No user logged in",
              );
              await Supabase.instance.client.from("sample").insert({
                "title": "Sample Name",
              });
            } catch (e) {
              log("Error inserting data: $e");
            }
          },
          child: Text(
            "Insert",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
