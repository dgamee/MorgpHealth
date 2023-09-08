import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/appointment/components/appointment_widget.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/appointment_fragment.dart';
import 'package:kivicare_flutter/components/appointment_fragment_status_compoent.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/appointment_fragment_shimmer.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

Future<void> fetchFormData() async {
  final response = await http.get(Uri.parse(
      'https://morgphealth.com/wp-json/forminator/v1/[forminator_form id="38813"]/'));

  if (response.statusCode == 200) {
    // Parse the response and handle the data
  } else {
    throw Exception('Failed to load form data');
  }
}

class Insurance extends StatefulWidget {
  @override
  State<Insurance> createState() => _InsuranceState();
}

class _InsuranceState extends State<Insurance> {
  @override
  Widget build(BuildContext context) {
    const title = 'Insurance';
    return MaterialApp(
        title: title,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(title),
          ),
          body: GridView.count(
            crossAxisCount: 2,
            primary: false,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children:<Widget> [
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.teal[100],
                child: const Text("Family Insurance"),
              )
            ],
            ),
        )
        );
  }
}

class FamilyInsurance extends StatefulWidget {
  const FamilyInsurance({super.key});

  @override
  State<FamilyInsurance> createState() => _FamilyInsuranceState();
}

class _FamilyInsuranceState extends State<FamilyInsurance> {
  TextEditingController dateinput = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Insurance')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
                'Hi I`m Brian, I`m here to help you with Your MorgpHealth Insurance Quote'),
            TextFormField(decoration: InputDecoration(labelText: 'First Name')),
            TextFormField(
                decoration: InputDecoration(labelText: 'Email Address')),
            TextFormField(
                controller: dateinput,
                decoration: InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    labelText: 'Date of Birth')),
          ],
        ),
      ),
    );
  }
}
