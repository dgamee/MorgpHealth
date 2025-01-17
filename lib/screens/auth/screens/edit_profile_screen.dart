import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';

// ignore: unused_import
import 'package:kivicare_flutter/app_theme.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/custom_image_picker.dart';
import 'package:kivicare_flutter/components/gender_selection_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/qualification_model.dart';
import 'package:kivicare_flutter/model/static_data_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/screens/auth/components/qualification_widget.dart';
import 'package:kivicare_flutter/screens/receptionist/components/multi_select_specialization.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/date_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/enums.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:signature/signature.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  UniqueKey genderKey = UniqueKey();

  TextEditingController firstNameCont =
      TextEditingController(text: cachedUserData?.firstName ?? '');
  TextEditingController lastNameCont =
      TextEditingController(text: cachedUserData?.lastName ?? '');
  TextEditingController emailCont =
      TextEditingController(text: cachedUserData?.userEmail ?? '');
  TextEditingController contactNumberCont =
      TextEditingController(text: cachedUserData?.mobileNumber ?? '');
  TextEditingController dobCont =
      TextEditingController(text: cachedUserData?.dob ?? '');
  TextEditingController genderCont =
      TextEditingController(text: cachedUserData?.gender ?? '');
  TextEditingController addressCont =
      TextEditingController(text: cachedUserData?.address ?? '');
  TextEditingController cityCont =
      TextEditingController(text: cachedUserData?.city ?? '');
  TextEditingController postalCodeCont =
      TextEditingController(text: cachedUserData?.postalCode ?? '');
  TextEditingController countryCont =
      TextEditingController(text: cachedUserData?.country ?? '');
  TextEditingController experienceCont =
      TextEditingController(text: cachedUserData?.noOfExperience ?? '');
  TextEditingController signatureCont =
      TextEditingController(text: cachedUserData?.signatureImg ?? '');

  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dobFocus = FocusNode();
  FocusNode genderFocus = FocusNode();
  FocusNode specializationFocus = FocusNode();
  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();
  FocusNode experienceFocus = FocusNode();

  DateTime selectedBirthDate = DateTime.now();

  File? selectedProfileImage;

  List<StaticData> specializationList = [];
  List<Qualification> qualificationList = [];

  bool isFirstTime = true;

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    strokeJoin: StrokeJoin.round,
    strokeCap: StrokeCap.butt,
    exportBackgroundColor: signatureBackgroundColor.withOpacity(0.2),
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(true);
    getSingleUserDetailAPI(userStore.userId).then((value) {
      appStore.setLoading(false);
      setUserData(value);
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
      appStore.setLoading(false);
      throw e;
    });
  }

  void setUserData(UserModel userData) {
    firstNameCont.text = userData.firstName.validate();
    lastNameCont.text = userData.lastName.validate();
    emailCont.text = userData.userEmail.validate();
    contactNumberCont.text = userData.mobileNumber.validate();
    if (userData.dob.validate().isNotEmpty) {
      selectedBirthDate =
          DateFormat(SAVE_DATE_FORMAT).parse(userData.dob.validate());
      dobCont.text = selectedBirthDate.getFormattedDate(SAVE_DATE_FORMAT);
    }
    genderCont.text = userData.gender.validate();
    addressCont.text = userData.address.validate();
    cityCont.text = userData.city.validate();
    postalCodeCont.text = userData.postalCode.validate();
    countryCont.text = userData.country.validate();
    experienceCont.text = userData.noOfExperience.validate();
    signatureCont.text = userData.signatureImg.validate();
    if (isDoctor()) {
      multiSelectStore.clearStaticList();
      specializationList.clear();
      if (userData.specialties.validate().isNotEmpty) {
        userData.specialties.validate().forEach((element) {
          specializationList
              .add(StaticData(id: element.id, label: element.label));
        });
        specializationList.validate().forEach((element) {
          multiSelectStore.addSingleStaticItem(element, isClear: false);
          element.isSelected = true;
        });
      }
      if (userData.qualifications.validate().isNotEmpty) {
        qualificationList.clear();
        qualificationList.addAll(userData.qualifications.validate());
      }
    }
  }

  Future<void> _onProfileChange() async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      title: Text(locale.lblChooseAction, style: boldTextStyle()),
      builder: (p0) {
        return FilePickerDialog(isSelected: (false));
      },
    ).then((file) async {
      if (file != null) {
        if (file == GalleryFileTypes.CAMERA) {
          await getCameraImage().then((value) {
            selectedProfileImage = value;
            setState(() {});
          });
        } else if (file == GalleryFileTypes.GALLERY) {
          await getCameraImage(isCamera: false).then((value) {
            selectedProfileImage = value;
            setState(() {});
          });
        }
      }
    });
  }

  Future<void> saveUserDetails() async {
    if (appStore.isLoading) return;

    Map<String, dynamic> request = {
      "first_name": firstNameCont.text.toString(),
      "last_name": lastNameCont.text.toString(),
      "user_email": emailCont.text.toString(),
      "user_login": getStringAsync(USER_LOGIN),
      "mobile_number": contactNumberCont.text.toString(),
      "dob": dobCont.text.toString(),
      "gender": genderCont.text.toString(),
      "clinic_id": userStore.userClinicId.validate(),
      "address": addressCont.text.toString(),
      "country": countryCont.text.toString(),
      "city": cityCont.text.toString(),
      "postal_code": postalCodeCont.text,
    };
    request.putIfAbsent("ID", () => userStore.userId.validate());
    if (isDoctor()) {
      request.putIfAbsent(
          'specialties', () => jsonEncode(multiSelectStore.selectedStaticData));
      request.putIfAbsent('no_of_experience', () => experienceCont.text);
      request.putIfAbsent(
          'qualifications', () => jsonEncode(qualificationList));
    }

    File? doctorSignature = await getSignatureInFile(context,
        controller: _controller,
        fileName: "${firstNameCont.text}_doctor_signature");
    await updateProfileAPI(
            data: request,
            profileImage: selectedProfileImage,
            doctorSignature: doctorSignature)
        .then((value) {
      appStore.setLoading(false);
      init();
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Widgets

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblEditProfile,
        color: appPrimaryColor,
        elevation: 0,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        textColor: Colors.white,
      ),
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: AnimatedScrollView(
              listAnimationType: ListAnimationType.None,
              padding:
                  EdgeInsets.only(bottom: 60, left: 16, right: 16, top: 16),
              children: [
                Text(locale.lblBasicDetails,
                    style:
                        boldTextStyle(color: context.primaryColor, size: 18)),
                Divider(color: viewLineColor, height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        Container(
                          decoration: boxDecorationDefault(
                              color: appStore.isDarkModeOn
                                  ? cardDarkColor
                                  : context.scaffoldBackgroundColor,
                              shape: BoxShape.circle),
                          child: selectedProfileImage != null
                              ? Image.file(File(selectedProfileImage!.path),
                                      height: 126,
                                      width: 126,
                                      fit: BoxFit.cover,
                                      alignment: Alignment.center)
                                  .cornerRadiusWithClipRRect(180)
                              : CachedImageWidget(
                                  url: userStore.profileImage.validate(),
                                  height: 126,
                                  fit: BoxFit.cover,
                                  circle: true),
                        ),
                        Positioned(
                          bottom: -4,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: boxDecorationDefault(
                                color: appPrimaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: white, width: 3)),
                            child: ic_camera.iconImage(
                                size: 14, color: Colors.white),
                          ).onTap(() async {
                            _onProfileChange();
                          },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: radius()),
                        )
                      ],
                    ).center().paddingBottom(24),
                    Wrap(
                      runSpacing: 16,
                      children: [
                        Row(
                          children: [
                            AppTextField(
                              controller: firstNameCont,
                              focus: firstNameFocus,
                              nextFocus: lastNameFocus,
                              textFieldType: TextFieldType.NAME,
                              textInputAction: TextInputAction.next,
                              decoration: inputDecoration(
                                  context: context,
                                  labelText: locale.lblFirstName),
                            ).expand(),
                            10.width,
                            AppTextField(
                              controller: lastNameCont,
                              focus: lastNameFocus,
                              textInputAction: TextInputAction.next,
                              nextFocus: emailFocus,
                              textFieldType: TextFieldType.NAME,
                              decoration: inputDecoration(
                                  context: context,
                                  labelText: locale.lblLastName),
                            ).expand(),
                          ],
                        ),
                        AppTextField(
                          controller: emailCont,
                          focus: emailFocus,
                          textInputAction: TextInputAction.next,
                          nextFocus: contactNumberFocus,
                          textFieldType: TextFieldType.EMAIL,
                          decoration: inputDecoration(
                              context: context, labelText: locale.lblEmail),
                        ),
                        Row(
                          children: [
                            AppTextField(
                              controller: contactNumberCont,
                              focus: contactNumberFocus,
                              nextFocus: dobFocus,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10)
                              ],
                              textFieldType: TextFieldType.PHONE,
                              decoration: inputDecoration(
                                  context: context,
                                  labelText: locale.lblContactNumber),
                            ).expand(),
                            16.width,
                            // AppTextField(
                            //   controller: dobCont,
                            //   focus: dobFocus,
                            //   textInputAction: TextInputAction.next,
                            //   nextFocus: addressFocus,
                            //   textFieldType: TextFieldType.OTHER,
                            //   decoration: inputDecoration(context: context, labelText: locale.lblDOB),
                            //   keyboardAppearance: appStore.isDarkModeOn ? Brightness.dark : Brightness.light,
                            //   selectionControls: EmptyTextSelectionControls(),
                            //   onTap: () {
                            //     datePickerComponent(
                            //       context,
                            //       isAgeVerificationRequired: true,
                            //       helpText: locale.lblSelectBirthDate,
                            //       initialDate: selectedBirthDate,
                            //       onDateSelected: (birthDate) {
                            //         if (birthDate != null) {
                            //           selectedBirthDate = birthDate;
                            //           dobCont.text = selectedBirthDate.getFormattedDate(SAVE_DATE_FORMAT);
                            //         } else {
                            //           //
                            //         }
                            //       },
                            //     );
                            //   },
                            // ).expand(),
                          ],
                        ),
                        GenderSelectionComponent(
                          key: genderKey,
                          type: genderCont.text,
                          onTap: (value) {
                            genderCont.text = value;
                          },
                        ),
                        if (isDoctor())
                          GestureDetector(
                            onTap: () {
                              MultiSelectSpecialization(
                                      selectedServicesId: multiSelectStore
                                          .selectedStaticData
                                          .validate()
                                          .map((element) =>
                                              element!.id.validate())
                                          .toList())
                                  .launch(context);
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 16, 16, 16),
                              width: context.width(),
                              decoration: boxDecorationDefault(
                                  borderRadius: radius(),
                                  color: context.cardColor),
                              child: Observer(
                                builder: (_) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(locale.lblSpecialization,
                                          style: secondaryTextStyle()),
                                      if (multiSelectStore.selectedStaticData
                                          .validate()
                                          .isNotEmpty)
                                        16.height,
                                      Wrap(
                                        spacing: 16,
                                        runSpacing: 8,
                                        children: List.generate(
                                          multiSelectStore
                                              .selectedStaticData.length,
                                          (index) {
                                            StaticData data = multiSelectStore
                                                .selectedStaticData[index]!;
                                            return Chip(
                                              label: Text(data.label.validate(),
                                                  style: primaryTextStyle()),
                                              backgroundColor:
                                                  context.cardColor,
                                              deleteIcon:
                                                  Icon(Icons.clear, size: 18),
                                              deleteIconColor: Colors.red,
                                              onDeleted: () {
                                                multiSelectStore
                                                    .selectedStaticData
                                                    .remove(data);
                                              },
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          defaultRadius),
                                                  side: BorderSide(
                                                      color: viewLineColor)),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        if (isDoctor())
                          AppTextField(
                            controller: experienceCont,
                            focus: experienceFocus,
                            textFieldType: TextFieldType.OTHER,
                            keyboardType: TextInputType.number,
                            decoration: inputDecoration(
                                context: context,
                                labelText: locale.lblExperience),
                          )
                      ],
                    )
                  ],
                ).paddingBottom(24),
                Text(locale.lblAddressDetail,
                    style:
                        boldTextStyle(color: context.primaryColor, size: 18)),
                Divider(color: viewLineColor, height: 24),
                Wrap(
                  runSpacing: 16,
                  children: [
                    AppTextField(
                      controller: addressCont,
                      focus: addressFocus,
                      nextFocus: cityFocus,
                      isValidationRequired: false,
                      textFieldType: TextFieldType.MULTILINE,
                      minLines: 2,
                      maxLines: 4,
                      decoration: inputDecoration(
                              context: context, labelText: locale.lblAddress)
                          .copyWith(alignLabelWithHint: true),
                    ),
                    Row(
                      children: [
                        AppTextField(
                          controller: countryCont,
                          focus: countryFocus,
                          nextFocus: cityFocus,
                          textInputAction: TextInputAction.next,
                          textFieldType: TextFieldType.OTHER,
                          decoration: inputDecoration(
                              context: context, labelText: locale.lblCountry),
                        ).expand(),
                        16.width,
                        AppTextField(
                          controller: cityCont,
                          focus: cityFocus,
                          nextFocus: postalCodeFocus,
                          textInputAction: TextInputAction.next,
                          textFieldType: TextFieldType.OTHER,
                          decoration: inputDecoration(
                              context: context, labelText: locale.lblCity),
                        ).expand(),
                      ],
                    ),
                    AppTextField(
                      controller: postalCodeCont,
                      focus: postalCodeFocus,
                      inputFormatters: [
                        FilteringTextInputFormatter
                            .deny('')// Only allows digits
                      ],
                      textFieldType: TextFieldType.OTHER,
                      textInputAction: TextInputAction.done,
                      decoration: inputDecoration(
                          context: context, labelText: locale.lblPostalCode),
                    ),
                  ],
                ).paddingSymmetric(vertical: 16),
                if (isDoctor())
                  QualificationWidget(
                      qualificationList: qualificationList,
                      callBack: (newQualificationList) {
                        qualificationList = newQualificationList;
                        setState(() {});
                      }),
                if (isDoctor())
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    runSpacing: 16,
                    spacing: 16,
                    children: [
                      Text(locale.lblSignature,
                          style: boldTextStyle(
                              color: context.primaryColor, size: 18)),
                      if (signatureCont.text.validate().isNotEmpty)
                        Image.memory(getImageFromBase64(
                                signatureCont.text.validate())!)
                            .cornerRadiusWithClipRRect(defaultRadius),
                      if (signatureCont.text.validate().isEmpty)
                        Signature(
                          controller: _controller,
                          width: context.width(),
                          height: 150,
                          backgroundColor: signatureBackgroundColor,
                        ).cornerRadiusWithClipRRect(defaultRadius),
                      if (signatureCont.text.validate().isEmpty)
                        Row(
                          children: [
                            AppButton(
                              onTap: () {
                                _controller.undo();
                              },
                              text: locale.lblUndo,
                              color: appSecondaryColor,
                            ).expand(),
                            8.width,
                            AppButton(
                              onTap: () {
                                _controller.clear();
                              },
                              text: locale.lblClear,
                              color: primaryColor,
                            ).expand(),
                          ],
                        )
                      else
                        AppButton(
                          onTap: () {
                            signatureCont.clear();
                            setState(() {});
                          },
                          width: context.width(),
                          text: '${locale.lblChangeSignature}',
                          color: appSecondaryColor,
                        )
                    ],
                  ).paddingSymmetric(vertical: 16),
              ],
            ),
          ),
          Observer(
            builder: (context) =>
                LoaderWidget().visible(appStore.isLoading).center(),
          )
        ],
      ),
      bottomNavigationBar: AppButton(
        text: locale.lblSave,
        onTap: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            showConfirmDialogCustom(
              context,
              primaryColor: context.primaryColor,
              width: context.width() * 0.7,
              height: context.height() * 0.2,
              dialogType: DialogType.UPDATE,
              title: locale.lblDoYouWantToUpdateYourDetails,
              positiveText: locale.lblYes,
              negativeText: locale.lblCancel,
              onAccept: (p0) {
                ifNotTester(context, () {
                  saveUserDetails();
                });
              },
            );
          } else {
            isFirstTime = !isFirstTime;
            setState(() {});
          }
        },
      ).paddingAll(16),
    );
  }
}
