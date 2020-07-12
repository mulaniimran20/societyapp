import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as br;
import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nice_button/nice_button.dart';
import 'package:societyapp/pages/your_adevertisement_list_screen.dart';
import 'package:societyapp/pojo_classes/constant.dart';
import 'package:societyapp/pojo_classes/url_for_api.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:toast/toast.dart';
import 'package:societyapp/pages/all_advertisement_list_page.dart';

URLForApi urlForApi = URLForApi();
Future<File> file;
String status = '';
String base64Image;
String imagename;
File tmpFile;
String errMessage = 'Error Uploading Image';
String textOnButton = "Pay and Upload";
var userId;
var societyId;
BuildContext contextm;
Razorpay _razorpay;

class GiveYourAddPage extends StatelessWidget {
  const GiveYourAddPage({
    Key key,
    @required this.userIdPassed,
    @required this.societyIdPassed,
  }) : super(key: key);

  final int userIdPassed;
  final int societyIdPassed;

  @override
  Widget build(BuildContext context) {
    userId = userIdPassed;
    societyId = societyIdPassed;
    return SerializedForm();
  }
}

class SerializedFormBloc extends FormBloc<String, String> {
  final ad_name = TextFieldBloc(
    name: 'ad_name',
    validators: [FieldBlocValidators.required],
  );

  final ad_contact_number = TextFieldBloc(
    name: 'ad_contact_number',
    validators: [FieldBlocValidators.required],
  );

  final ad_contact_emailid = TextFieldBloc(
    name: 'ad_contact_email_id',
    validators: [FieldBlocValidators.email],
  );

  final ad_duration = SelectFieldBloc(
      name: 'ad_duration',
      items: ['3 Days', '7 Days', '15 Days', '30 Days'],
      validators: [FieldBlocValidators.required],
      initialValue: '3 Days');

  final ad_description = TextFieldBloc(
    name: 'ad_description',
    validators: [FieldBlocValidators.required],
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

  SerializedFormBloc() {
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

  void _razoroaySuccessEventHandler(
      PaymentSuccessResponse paymentSuccessResponse) async {
    var paymentId = paymentSuccessResponse.paymentId;

    var adname = ad_name.value;
    var addescription = ad_description.value;
    var adduration = ad_duration.value;
    var adcontactnumber = ad_contact_number.value;
    var ademailid = ad_contact_emailid.value;
    var adcosting;

    if (adduration == '3 Days') {
      adcosting = costOfAdvertisement1.value;
    } else if (adduration == '7 Days') {
      adcosting = costOfAdvertisement2.value;
    } else if (adduration == '15 Days') {
      adcosting = costOfAdvertisement3.value;
    } else if (adduration == '30 Days') {
      adcosting = costOfAdvertisement4.value;
    }

    imagename = tmpFile.path.split('/').last;
    var advertiseUrl = urlForApi.advertiseUpload;
    http.post(advertiseUrl, body: {
      "name": imagename,
      "image": base64Image,
      "societyId": "$societyId",
      "userId": "$userId",
      "adname": adname,
      "addescription": addescription,
      "adduration": adduration,
      "adcosting": adcosting,
      "ademailid": ademailid,
      "adcontactnumber": adcontactnumber,
      "paymentid": paymentId,
      "adby": "1",
    }).then((result) {
      String r = result.body;
      var responseTest = jsonDecode(r);

      Navigator.pushReplacement(
        contextm,
        MaterialPageRoute(
            builder: (contextm) => YourAdvertisementsListScreen()),
      );
    }).catchError((error) {
      print(error);
    });
  }

  void _razoroayErrorEventHandler(
      PaymentFailureResponse paymentFailureResponse) {
    Toast.show("Error - " + paymentFailureResponse.message, contextm,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _razoroayExternalWalletEventHandler(
      ExternalWalletResponse externalWalletResponse) {
    Toast.show(
        "External Wallet - " + externalWalletResponse.walletName, contextm,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void openCheckout() async {
    var adcontactnumber = ad_contact_number.value;
    var ademailid = ad_contact_emailid.value;
    int adcosting;
    var adduration = ad_duration.value;

    if (adduration == '3 Days') {
      adcosting = int.parse(costOfAdvertisement1.value);
    } else if (adduration == '7 Days') {
      adcosting = int.parse(costOfAdvertisement2.value);
    } else if (adduration == '15 Days') {
      adcosting = int.parse(costOfAdvertisement3.value);
    } else if (adduration == '30 Days') {
      adcosting = int.parse(costOfAdvertisement4.value);
    }

    var options = {
      'key': 'rzp_live_iMJU2s4h0nl9gl',
      'amount': adcosting * 100,
      'name': 'Society Maintainance Payment',
      'description': 'Your society maintainance payment',
      'prefill': {'contact': adcontactnumber, 'email': ademailid},
      'external': {
        'wallet': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print(e);
    }
  }

  @override
  void onSubmitting() async {
    emitSuccess(
      canSubmitAgain: true,
      successResponse: "Data uploaded Successfully",
    );
    openCheckout();
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
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    file = null;
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
          return Image.asset(
            'assets/select.png',
            height: 180.0,
            width: double.infinity,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    contextm = context;
    _razorpay = Razorpay();

    context = this.context;
    String _character = "3";
    double i_width = MediaQuery.of(context).size.width * 0.75;

    return BlocProvider(
      create: (context) => SerializedFormBloc(),
      child: Builder(
        builder: (context) {
          final formBloc = context.bloc<SerializedFormBloc>();

          _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
              formBloc._razoroaySuccessEventHandler);
          _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
              formBloc._razoroayErrorEventHandler);
          _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
              formBloc._razoroayExternalWalletEventHandler);

          return Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            child: Scaffold(
              appBar: AppBar(
                title: Text("Society App"),
                centerTitle: true,
              ),
              resizeToAvoidBottomInset: false,
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
                              setState(() {
                                file = ImagePicker.pickImage(
                                    source: ImageSource.gallery);
                              });
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
