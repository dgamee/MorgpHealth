import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/dashboard_repository.dart';
import 'package:kivicare_flutter/screens/patient/fragments/patient_insurance_fragment.dart';
import 'package:kivicare_flutter/screens/patient/screens/dashboard_fragment_doctor_service_component.dart';
import 'package:kivicare_flutter/screens/patient/components/dashboard_fragment_top_doctor_component.dart';
import 'package:kivicare_flutter/screens/patient/components/dashboard_fragment_upcoming_appointment_component.dart';
import 'package:kivicare_flutter/screens/patient/screens/patient_service_list_screen.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/patient_dashboard_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/model/dashboard_model.dart';

class PatientDashBoardFragment extends StatefulWidget {
  @override
  _PatientDashBoardFragmentState createState() =>
      _PatientDashBoardFragmentState();
}

class _PatientDashBoardFragmentState extends State<PatientDashBoardFragment> {
  Future<DashboardModel>? future;

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    appStore.setLoading(true);
    future = getUserDashBoardAPI().then((value) {
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InternetConnectivityWidget(
      retryCallback: () async {
        init();
        await 1.seconds.delay;
      },
      child: SnapHelperWidget<DashboardModel>(
        future: future,
        initialData: cachedDashboardModel,
        errorBuilder: (error) {
          return NoDataWidget(
            imageWidget:
                Image.asset(ic_somethingWentWrong, height: 180, width: 180),
            title: error.toString(),
          );
        },
        errorWidget: ErrorStateWidget(),
        loadingWidget: PatientDashboardShimmerScreen(),
        onSuccess: (snap) {
          return AnimatedScrollView(
            listAnimationType: listAnimationType,
            onSwipeRefresh: () async {
              init();
            },
            padding: EdgeInsets.only(bottom: 80),
            children: [
              DashboardFragmentDoctorServiceComponent(
                  service: getRemovedDuplicateServiceList(
                      snap.serviceList.validate())),
              if (snap.upcomingAppointment.validate().isNotEmpty)
                DashBoardFragmentUpcomingAppointmentComponent(
                    upcomingAppointment: snap.upcomingAppointment.validate()),
              16.height,
              // Padding(
              //   padding: const EdgeInsets.all(20.0),
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       shape: RoundedRectangleBorder(
              //           borderRadius: BorderRadius.circular(10.0)),
              //       backgroundColor: Color.fromRGBO(
              //           74, 97, 152, 1), // background (button) color
              //       foregroundColor: Colors.white, // foreground (text) color
              //     ),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(builder: (context) => InsurancePage()),
              //       );
              //     },
              //     child: const Text(
              //       'Insurance',
              //       style: TextStyle(fontSize: 16),
              //     ),
              //   ),
              // ),
              DashBoardFragmentTopDoctorComponent(
                  doctorList: snap.doctor.validate()),
              24.height,
            ],
          ).visible(!appStore.isLoading,
              defaultWidget:
                  PatientDashboardShimmerScreen().visible(appStore.isLoading));
        },
      ),
    );
  }
}
