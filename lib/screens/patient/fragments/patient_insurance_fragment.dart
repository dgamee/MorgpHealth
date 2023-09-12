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
import 'package:kivicare_flutter/screens/patient/fragments/forms/employee_insurance.dart';
import 'package:kivicare_flutter/screens/patient/fragments/forms/family_insurance.dart';
import 'package:kivicare_flutter/screens/patient/fragments/forms/partner_insurance.dart';
import 'package:kivicare_flutter/screens/patient/fragments/forms/personal_insurance.dart';
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
  const Insurance({super.key});

  @override
  State<Insurance> createState() => _InsuranceState();
}

class _InsuranceState extends State<Insurance> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insurance',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InsurancePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class InsurancePage extends StatefulWidget {
  const InsurancePage({super.key});

  @override
  State<InsurancePage> createState() => _InsurancePageState();
}

class _InsurancePageState extends State<InsurancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Insurance'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[Colors.purple, Colors.blue])),
          )),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 20),
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Personal_insurance()),
                  );
                },
                icon: Icon(Icons.person_2_rounded,
                    color: Colors.white, size: 24.0),
                label: Text('I Need Health Insurance For Myself'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Partner_insurance()),
                  );
                },
                icon: Icon(Icons.people, color: Colors.white, size: 24.0),
                label: Text('I Need Cover For Myself And My Partner'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Family_insurance()),
                  );
                },
                icon: Icon(Icons.family_restroom,
                    color: Colors.white, size: 24.0),
                label: Text('I Need Cover For My Whole Family'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Employee_insurance()),
                  );
                },
                icon: Icon(Icons.business, color: Colors.white, size: 24.0),
                label: Text('I Need Health Insurance For My Employees'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
