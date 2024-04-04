import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_document_reader_api/flutter_document_reader_api.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/featured/screen/extra/rfid_custom_ui.dart';
import 'package:instagram_clone/resources/firestore_methods.dart';
import 'package:instagram_clone/utils/utils.dart';

class MRZ_NFC extends StatefulWidget {
  final String uid;
  const MRZ_NFC({super.key, required this.uid});

  @override
  State<MRZ_NFC> createState() => _MRZ_NFCState();
}

class _MRZ_NFCState extends State<MRZ_NFC> {
  String expiryDate = "";
  String birthDate = "";
  String id_number = "";
  String gender = "";
  String nationlity = "";
  String age = "";
  String contentResults = '';
  String content = '';
  var _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    init();
  }

  var documentReader = DocumentReader.instance;

  var status = "Loading...";
  var portrait = Image.asset('assets/images/portrait.png');
  var docImage = Image.asset('assets/images/id.png');
  var selectedScenario = Scenario.MRZ;
  List<DocReaderScenario> scenarios = [];
  Object setStatus(String s) => {setState(() => status = s)};
  var doRfid = false;
  var isReadingRfid = false;
  var rfidCustomUiExample = RFIDCustomUI.empty();
  var rfidOption = RfidOption.Basic;

  var colorPrimary = Colors.blue;

  void init() async {
    super.initState();
    if (!await initializeReader()) return;
    setStatus("Ready");
    setState(() => scenarios = documentReader.availableScenarios);
  }

  void handleCompletion(
      DocReaderAction action, Results? results, DocReaderException? error) {
    if (error != null) print(error.message);
    if (action.stopped() && !shouldRfid(results))
      displayResults(results);
    else if (action.finished() && shouldRfid(results)) readRfid();
  }

  void displayResults(Results? results) async {
    isReadingRfid = false;
    clearResults();
    if (results == null) return;

    var name =
        await results.textFieldValueByType(FieldType.SURNAME_AND_GIVEN_NAMES);
    var expiry = await results.textFieldValueByType(FieldType.DATE_OF_EXPIRY);
    var birth = await results.textFieldValueByType(FieldType.DATE_OF_BIRTH);
    var id_no = await results.textFieldValueByType(FieldType.PERSONAL_NUMBER);
    var sex = await results.textFieldValueByType(FieldType.SEX);
    var nation = await results.textFieldValueByType(FieldType.NATIONALITY);
    var old = await results.textFieldValueByType(FieldType.AGE);
    var newDocImage =
        await results.graphicFieldImageByType(GraphicFieldType.DOCUMENT_IMAGE);
    var newPortrait =
        await results.graphicFieldImageByType(GraphicFieldType.PORTRAIT);

    setState(() {
      status = name ?? "Ready";
      expiryDate = expiry.toString();
      birthDate = birth.toString();
      id_number = id_no.toString();
      gender = sex.toString();
      nationlity = nation.toString();
      age = old.toString();
      print(expiryDate);
      if (newDocImage != null) docImage = Image.memory(newDocImage);
      if (newPortrait != null) portrait = Image.memory(newPortrait);
    });
  }

  void clearResults() {
    setState(() {
      status = "Ready";
      docImage = Image.asset('assets/images/id.png');
      portrait = Image.asset('assets/images/portrait.png');
    });
  }

  void readRfid() {
    isReadingRfid = true;
    if (rfidOption == RfidOption.Basic) basicRfid();
    if (rfidOption == RfidOption.Advanced) advancedRfid();
    if (rfidOption == RfidOption.Custom) rfidCustomUiExample.run();
  }

  void basicRfid() {
    documentReader.rfid(RFIDConfig(handleCompletion));
  }

  void advancedRfid() {
    var config = RFIDConfig(handleCompletion);

    config.onChipDetected = () => print("Chip detected, reading rfid.");
    config.onRetryReadChip = (error) async {
      var message = await error.code.getTranslation();
      print("Reading interrupted: $message. Retrying...");
    };

    documentReader.rfid(config);
  }

  bool shouldRfid(Results? results) =>
      doRfid && !isReadingRfid && results != null && results.chipPage != 0;

  Widget hasData() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.539,
      padding: EdgeInsets.all(20.0),
      child: Table(
        border: TableBorder.all(color: Colors.white),
        children: [
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'ID:',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${id_number}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'Nationlity:',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${nationlity}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'Date Of Birth:',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${birthDate}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'Date Of Expiry:',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${expiryDate}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'SEX',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${gender}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
          TableRow(children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              height: 30,
              child: Text(
                'Age:',
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                '${age}',
                textAlign: TextAlign.center,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget ui() {
    return Column(
      children: [
        documentImages(),
        expiryDate != '' && expiryDate != 'null'
            ? hasData()
            : scenarioSelector(),
        rfidCheckbox(),
        expiryDate != '' && expiryDate != 'null'
            ? saveInformation()
            : scanButtons()
      ],
    );
  }

  Widget documentImages() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          image("Portrait", 150, 150, portrait.image),
          image("Document image", 150, 200, docImage.image),
        ],
      ),
    );
  }

  Widget scenarioSelector() {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(5, 10, 10, 10),
        child: scenarios.length == 0
            ? SizedBox.shrink()
            : ListView.builder(
                itemCount: 1,
                itemBuilder: (_, int index) => radioButton(index),
              ),
      ),
    );
  }

  Widget rfidCheckbox() {
    var rfidCheckboxTitle = "Process rfid reading";
    if (!documentReader.isRFIDAvailableForUse)
      rfidCheckboxTitle += " (unavailable)";

    return CheckboxListTile(
      value: doRfid,
      title: Text(rfidCheckboxTitle),
      onChanged: (bool? value) {
        setState(() => doRfid = value! && documentReader.isRFIDAvailableForUse);
      },
    );
  }

  Widget saveInformation() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          button("Cancel", () {
            clearResults();
            showSnackBar('Clear Results Complete', context);
            Future.delayed(Duration(seconds: 3), () {
              setState(() {
                Navigator.of(context).pop();
              });
            });
          }),
          button("Save Information", () async {
            print(widget.uid);
            await FireStoreMethods()
                .ID_Number_Create(id_number.toString(), widget.uid);
            await Id_Number_User(widget.uid, id_number.toString());
            showSnackBar(content, context);
          })
        ],
      ),
    );
  }

  Widget scanButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          button("Scan document", () {
            clearResults();
            documentReader.scan(
              ScannerConfig.withScenario(selectedScenario),
              handleCompletion,
            );
          }),
          button("Scan image", () async {
            clearResults();
            documentReader.recognize(
              RecognizeConfig.withScenario(
                selectedScenario,
                RecognizeData.withImages(await getImages()),
              ),
              handleCompletion,
            );
          })
        ],
      ),
    );
  }

  Widget image(
    String title,
    double height,
    double width,
    ImageProvider image,
  ) {
    return Column(
      children: <Widget>[
        Text(title),
        Image(
          height: height,
          width: width,
          image: image,
        )
      ],
    );
  }

  Widget radioButton(int index) {
    Radio radio = Radio(
      value: scenarios[index].name,
      groupValue: selectedScenario.value,
      onChanged: (value) => setState(() {
        selectedScenario = Scenario.getByValue(value)!;
      }),
    );
    return Container(
      padding: const EdgeInsets.only(left: 40),
      child: ListTile(
        leading: radio,
        title: GestureDetector(
          onTap: () => radio.onChanged!(scenarios[index].name),
          child: Text(scenarios[index].caption),
        ),
      ),
    );
  }

  Widget button(String text, VoidCallback onPress) {
    return Container(
      width: 160,
      height: 40,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      transform: Matrix4.translationValues(0, -7.5, 0),
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all<Color>(colorPrimary),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black12),
        ),
        onPressed: onPress,
        child: Text(text),
      ),
    );
  }

  Future<bool> initializeReader() async {
    setStatus("Initializing...");

    // ByteData license = await rootBundle.load("assets/regula.license");
    var initConfig = InitConfig(await rootBundle.load("assets/regula.license"));
    initConfig.delayedNNLoad = true;
    var (success, error) = await documentReader.initializeReader(initConfig);

    if (!success) {
      setStatus(error!.message);
      printError(error);
    }
    rfidCustomUiExample = RFIDCustomUI(setState, setStatus, displayResults);
    return success;
  }

  void printError(DocReaderException error) =>
      print("Error: \n  code: ${error.code}\n  message: ${error.message}");

  Future<List<Uint8List>> getImages() async {
    setStatus("Processing image...");
    List<XFile> files = await ImagePicker().pickMultiImage();
    List<Uint8List> result = [];
    for (XFile file in files) {
      result.add(await file.readAsBytes());
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(right: 0),
          child: Text(status),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          rfidCustomUiExample.build(),
          Visibility(
            visible: !rfidCustomUiExample.isShowing,
            child: Expanded(
              child: ui(),
            ),
          )
        ],
      ),
    );
  }

  Future<String> Id_Number_User(String uid, String id_no) async {
    try {
      var snap = await _firestore.collection('users').doc(uid).get();
      String id_number = (snap.data()! as dynamic)['id_number'];
      if (id_number.contains(id_no)) {
        content = "ID already exits";
      }
      if (id_number.isNotEmpty) {
        content = "Already have data";
      } else {
        await _firestore.collection('users').doc(uid).update({
          'id_number': id_no,
        });
        content = "Add ID Number Complete";
      }
    } catch (err) {
      print(err.toString());
    }
    print(content);
    return content;
  }
}

enum RfidOption { Basic, Advanced, Custom }
