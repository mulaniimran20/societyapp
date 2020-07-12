import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:image/image.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nice_button/nice_button.dart';
import 'package:societyapp/pages/your_adevertisement_list_screen.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/get_network_data.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';

URLForApi urlForApi = URLForApi();
Future<File> file;
String status = '';
String base64Image;
String imagename;
File tmpFile;
String errMessage = 'Error Uploading Image';
String textOnButton = "Update Advertisement";
var userId;
var societyId;
BuildContext contextm;
var adidm;

var adnameold;
var addescriptionold;
var addurationold;
var adimage_url_old;
var adimagecostold;
var adcontactnumberold;
var adcontactemailold;
var imageurlwithoutlink;

GetNetworkData getNetworkData = GetNetworkData();

class EditYourAdvertisement extends StatelessWidget {
  const EditYourAdvertisement({
    Key key,
    @required this.userIdPassed,
    @required this.societyIdPassed,
    @required this.adid,
  }) : super(key: key);

  final int userIdPassed;
  final int societyIdPassed;
  final int adid;
  @override
  Widget build(BuildContext context) {
    userId = userIdPassed;
    societyId = societyIdPassed;
    adidm = adid;
    return SerializedForm();
  }
}

class SerializedFormBloc extends FormBloc<String, String> {
  TextFieldBloc ad_name = TextFieldBloc(
    name: 'ad_name',
    validators: [FieldBlocValidators.required],
    initialValue: adnameold,
  );

  final ad_contact_number = TextFieldBloc(
    name: 'ad_contact_number',
    validators: [FieldBlocValidators.required],
    initialValue: adcontactnumberold,
  );

  final ad_contact_emailid = TextFieldBloc(
    name: 'ad_contact_email_id',
    validators: [FieldBlocValidators.email],
    initialValue: adcontactemailold,
  );

  final ad_duration = SelectFieldBloc(
      name: 'ad_duration',
      items: ['3 Days', '7 Days', '15 Days', '30 Days'],
      validators: [FieldBlocValidators.required],
      initialValue: '$addurationold Days');

  final ad_description = TextFieldBloc(
    name: 'ad_description',
    validators: [FieldBlocValidators.required],
    initialValue: addescriptionold,
  );

  final costOfAdvertisement1 = TextFieldBloc(
    validators: [FieldBlocValidators.required],
    name: 'cost_of_advertisement',
    initialValue: "309",
  );

  final costOfAdvertisement2 = TextFieldBloc(
    validators: [FieldBlocValidators.required],
    name: 'cost_of_advertisement',
    initialValue: "721",
  );

  final costOfAdvertisement3 = TextFieldBloc(
    validators: [FieldBlocValidators.required],
    name: 'cost_of_advertisement',
    initialValue: "1545",
  );

  final costOfAdvertisement4 = TextFieldBloc(
    validators: [FieldBlocValidators.required],
    name: 'cost_of_advertisement',
    initialValue: "3100",
  );

  final showSecretField = BooleanFieldBloc();

  final secretField = TextFieldBloc(
    validators: [FieldBlocValidators.required],
  );

  void getAllAdvertisementDetails() async {
    var clickedAdvertisementDetailsUrl =
        urlForApi.clickedAdvertisementDetailsUrl;
    Map mapAdvertisementClickId = {"clickedAdId": adidm};
    HttpClientResponse httpClientResponseForAdvertisementDetails =
        await getNetworkData.getNetworkDataUsingPostMethod(
            clickedAdvertisementDetailsUrl, mapAdvertisementClickId);

    if (httpClientResponseForAdvertisementDetails.statusCode == 200) {
      String replyForAllAdvertisementList =
          await httpClientResponseForAdvertisementDetails
              .transform(utf8.decoder)
              .join();
      var responseForAdvertisementDetails =
          jsonDecode(replyForAllAdvertisementList);

      if (responseForAdvertisementDetails['msg'] == "success") {
        var society_wise_advertisement_image_url = urlForApi.baseUrlForImages +
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_image_url'];
        imageurlwithoutlink = responseForAdvertisementDetails['data']
            ['society_wise_advertisement_image_url'];
        adimage_url_old = society_wise_advertisement_image_url;

        var society_wise_advertisement_name =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_name'];
        adnameold = society_wise_advertisement_name;
        ad_name.updateInitialValue(adnameold);

        var society_wise_advertisement_description =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_description'];
        addescriptionold = society_wise_advertisement_description;
        ad_description.updateInitialValue(addescriptionold);

        var society_wise_advertisement_contact_details =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_details'];
        adcontactnumberold = society_wise_advertisement_contact_details;
        ad_contact_number.updateInitialValue(adcontactnumberold);

        var society_wise_advertisement_contact_email_id =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_email_id'];
        adcontactemailold = society_wise_advertisement_contact_email_id;
        ad_contact_emailid.updateInitialValue(adcontactemailold);

        var society_wise_advertisement_running_duration_in_days =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_running_duration_in_days'];
        addurationold = society_wise_advertisement_running_duration_in_days;
        ad_duration.updateInitialValue(addurationold + " Days");

        var society_wise_advertisement_running_cost =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_cost'];

        var adcostdisp = society_wise_advertisement_running_cost;
        costOfAdvertisement1.updateInitialValue(adcostdisp);

        removeFieldBlocs(
          fieldBlocs: [
            costOfAdvertisement1,
            costOfAdvertisement2,
            costOfAdvertisement3,
            costOfAdvertisement4,
            showSecretField,
            secretField,
          ],
        );
      } else {
        Toast.show(
          "Request failed with status: ${httpClientResponseForAdvertisementDetails.statusCode}, please try again after some time",
          contextm,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      }
    }
  }

  SerializedFormBloc() {
    //getAllAdvertisementDetails();

    addFieldBlocs(
      fieldBlocs: [
        ad_name,
        ad_duration,
        ad_contact_number,
        ad_contact_emailid,
        ad_description,
        costOfAdvertisement1
      ],
    );

    showSecretField.onValueChanges(
      onData: (previous, current) async* {
        if (current.value) {
          addFieldBlocs(fieldBlocs: [secretField]);
        } else {
          removeFieldBlocs(fieldBlocs: [secretField]);
        }
      },
    );

    ad_duration.onValueChanges(
      onData: (previous, current) async* {
        removeFieldBlocs(
          fieldBlocs: [
            costOfAdvertisement1,
            costOfAdvertisement2,
            costOfAdvertisement3,
            costOfAdvertisement4,
            showSecretField,
            secretField,
          ],
        );

        if (current.value == '3 Days') {
          addFieldBlocs(fieldBlocs: [
            costOfAdvertisement1,
          ]);
        } else if (current.value == '7 Days') {
          addFieldBlocs(fieldBlocs: [
            costOfAdvertisement2,
          ]);
        } else if (current.value == '15 Days') {
          addFieldBlocs(fieldBlocs: [
            costOfAdvertisement3,
          ]);
        } else if (current.value == '30 Days') {
          addFieldBlocs(fieldBlocs: [
            costOfAdvertisement4,
          ]);
        }
      },
    );
  }

  @override
  void onSubmitting() async {
    emitSuccess(
      canSubmitAgain: true,
      successResponse: "Data uploaded Successfully",
    );

    var adname = ad_name.value;
    var addescription = ad_description.value;
    var adcontactnumber = ad_contact_number.value;
    var ademailid = ad_contact_emailid.value;

    var imgchanged = "not changed";

    if (tmpFile != null) {
      imagename = tmpFile.path.split('/').last;
      imgchanged = "changed";
    } else {
      imagename = imageurlwithoutlink;
      base64Image = imageurlwithoutlink;
      imgchanged = "not changed";
    }

    var updateAdvertiseUrl = urlForApi.updateAdvertiseUrl;
    http.post(updateAdvertiseUrl, body: {
      "advertiseid": adidm.toString(),
      "name": imagename,
      "image": base64Image,
      "adname": adname,
      "addescription": addescription,
      "ademailid": ademailid,
      "adcontactnumber": adcontactnumber,
      "imgchanged": imgchanged,
    }).then((result) {
      String r = result.body;
      var responseTest = jsonDecode(r);
      Navigator.pop(contextm);
    }).catchError((error) {
      print(error);
    });
  }
}

class SerializedForm extends StatefulWidget {
  @override
  _SerializedFormState createState() => _SerializedFormState();
}

class _SerializedFormState extends State<SerializedForm> {
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  chooseImage() {
    if (mounted) {
      setState(() {
        file = ImagePicker.pickImage(source: ImageSource.gallery);
      });
    }
    setStatus('');
  }

  setStatus(String message) {
    if (mounted) {
      setState(() {
        status = message;
      });
    }
  }

/*
  startUpload() {
    setStatus('Uploading Image...');
    if (null == tmpFile) {
      setStatus(errMessage);
      return;
    }
    String fileName = tmpFile.path.split('/').last;
    upload(fileName);
  }
*/

/*  upload(String fileName) {
    String uploadEndPoint = urlForApi.uploadImage;


  }*/

  Widget showImage() {
    return FutureBuilder<File>(
      future: file,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            null != snapshot.data) {
          tmpFile = snapshot.data;
          base64Image = base64Encode(snapshot.data.readAsBytesSync());
          return Container(
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: Image.file(
                snapshot.data,
                fit: BoxFit.fill,
                height: 180.0,
                width: double.infinity,
              ),
            ),
          );
        } else if (null != snapshot.error) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          if (adimage_url_old == null) {
            return Image.asset(
              'assets/select.png',
              height: 180.0,
              width: double.infinity,
            );
          } else {
            return ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/loading1.gif',
                image: adimage_url_old,
                height: 200.0,
                width: double.infinity,
                fit: BoxFit.fill,
              ),
            );
          }
        }
      },
    );
  }

  Widget oldimagwidget;
  List<Widget> listofwidgets;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    adimage_url_old = null;
    file = null;
    getAllAdvertisementDetails();
  }

  Widget myWidget = Container(
    child: Center(
      child: Image.asset("assets/loading1.gif"),
    ),
  );

  bool loading = false;

  void getAllAdvertisementDetails() async {
    loading = true;
    var clickedAdvertisementDetailsUrl =
        urlForApi.clickedAdvertisementDetailsUrl;
    Map mapAdvertisementClickId = {"clickedAdId": adidm};
    HttpClientResponse httpClientResponseForAdvertisementDetails =
        await getNetworkData.getNetworkDataUsingPostMethod(
            clickedAdvertisementDetailsUrl, mapAdvertisementClickId);

    if (httpClientResponseForAdvertisementDetails.statusCode == 200) {
      String replyForAllAdvertisementList =
          await httpClientResponseForAdvertisementDetails
              .transform(utf8.decoder)
              .join();
      var responseForAdvertisementDetails =
          jsonDecode(replyForAllAdvertisementList);

      if (responseForAdvertisementDetails['msg'] == "success") {
        var society_wise_advertisement_image_url = urlForApi.baseUrlForImages +
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_image_url'];
        imageurlwithoutlink = responseForAdvertisementDetails['data']
            ['society_wise_advertisement_image_url'];

        var society_wise_advertisement_name =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_name'];
        adnameold = society_wise_advertisement_name;

        var society_wise_advertisement_description =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_description'];
        addescriptionold = society_wise_advertisement_description;

        var society_wise_advertisement_contact_details =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_details'];
        adcontactnumberold = society_wise_advertisement_contact_details;

        var society_wise_advertisement_contact_email_id =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_contact_email_id'];
        adcontactemailold = society_wise_advertisement_contact_email_id;

        var society_wise_advertisement_running_duration_in_days =
            responseForAdvertisementDetails['data']
                ['society_wise_advertisement_running_duration_in_days'];
        addurationold = society_wise_advertisement_running_duration_in_days;
        if (mounted) {
          setState(() {
            adimage_url_old = society_wise_advertisement_image_url;
            showImage();
            loading = false;
          });
        }
      } else {
        Toast.show(
          "Request failed with status: ${httpClientResponseForAdvertisementDetails.statusCode}, please try again after some time",
          contextm,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
        );
      }
    }
  }

  Widget body() {
    double i_width = MediaQuery.of(context).size.width * 0.75;
    return BlocProvider(
      create: (context) => SerializedFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = context.bloc<SerializedFormBloc>();

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text("Society App"),
                centerTitle: true,
              ),
              body: FormBlocListener<SerializedFormBloc, String, String>(
                onSuccess: (context, state) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(state.successResponse),
                    duration: Duration(seconds: 2),
                  ));
                },
                child: SingleChildScrollView(
                  physics: ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Color(0xFF716D6D),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    20.0) //                 <--- border radius here
                                ),
                          ),
                          child: Text("Select Advertisement Image"),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Color(0xFF716D6D),
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(
                                    20.0) //                 <--- border radius here
                                ),
                          ),
                          child: GestureDetector(
                            onTap: () async {
                              if (mounted) {
                                setState(() {
                                  file = ImagePicker.pickImage(
                                      source: ImageSource.gallery);
                                });
                              }
                            },
                            child: Container(
                              child: showImage(),
                            ),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.ad_name,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Advertisement Name',
                            prefixIcon: Icon(Icons.branding_watermark),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.ad_description,
                          keyboardType: TextInputType.text,
                          maxLength: 500,
                          maxLines: 10,
                          decoration: InputDecoration(
                            labelText: 'Advertisement Description',
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.ad_contact_number,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Contact Number',
                            prefixIcon: Icon(Icons.branding_watermark),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.ad_contact_emailid,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Contact Mail ID',
                            prefixIcon: Icon(Icons.branding_watermark),
                          ),
                        ),
                        RadioButtonGroupFieldBlocBuilder(
                          selectFieldBloc: formBloc.ad_duration,
                          itemBuilder: (context, value) => value,
                          decoration: InputDecoration(
                            labelText: 'Select Advertisement Duration',
                            prefixIcon: SizedBox(),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.costOfAdvertisement1,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          isEnabled: false,
                          decoration: InputDecoration(
                            labelText: 'Cost of Advertisement?',
                            prefixIcon: Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.costOfAdvertisement2,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          isEnabled: false,
                          decoration: InputDecoration(
                            labelText: 'Cost of Advertisement?',
                            prefixIcon: Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.costOfAdvertisement3,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          isEnabled: false,
                          decoration: InputDecoration(
                            labelText: 'Cost of Advertisement?',
                            prefixIcon: Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ),
                        TextFieldBlocBuilder(
                          textFieldBloc: formBloc.costOfAdvertisement4,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          isEnabled: false,
                          decoration: InputDecoration(
                            labelText: 'Cost of Advertisement?',
                            prefixIcon: Icon(Icons.sentiment_very_dissatisfied),
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        NiceButton(
                          width: i_width,
                          elevation: 8.0,
                          radius: 52.0,
                          text: textOnButton,
                          fontSize: 15.0,
                          background: reusableCardColor,
                          onPressed: formBloc.submit,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    contextm = context;

    return loading ? myWidget : body();
  }
}

class LoadingDialog extends StatelessWidget {
  static void show(BuildContext context, {Key key}) => showDialog<void>(
        context: context,
        useRootNavigator: false,
        barrierDismissible: false,
        builder: (_) => LoadingDialog(key: key),
      ).then((_) => FocusScope.of(context).requestFocus(FocusNode()));

  static void hide(BuildContext context) => Navigator.pop(context);

  LoadingDialog({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Center(
        child: Card(
          child: Container(
            width: 80,
            height: 80,
            padding: EdgeInsets.all(12.0),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  SuccessScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.tag_faces, size: 100),
            SizedBox(height: 10),
            Text(
              'Success',
              style: TextStyle(fontSize: 54, color: Colors.black),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            RaisedButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => SerializedForm())),
              icon: Icon(Icons.replay),
              label: Text('AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
