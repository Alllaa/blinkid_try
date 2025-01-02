import 'dart:convert';

import 'package:blinkid_flutter/microblink_scanner.dart';
import 'package:flutter/material.dart';

class ScanID extends StatefulWidget {
  const ScanID({Key? key}) : super(key: key);

  @override
  _ScanIDState createState() => _ScanIDState();
}

class _ScanIDState extends State<ScanID> {
  String? _resultString = "";
  String? _fullDocumentFrontImageBase64 = "";
  String? _faceImageBase64 = "";

  // This widget will display a complete image of the passport or national id that is scanned.
  @override
  Widget build(BuildContext context) {
    Widget fullDocumentFrontImage = Container();
    if (_fullDocumentFrontImageBase64 != null && _fullDocumentFrontImageBase64 != "") {
      fullDocumentFrontImage = Column(
        children: <Widget>[
          const Text("Document Front Image:"),
          Image.memory(
            const Base64Decoder().convert(_fullDocumentFrontImageBase64!),
            height: 180,
            width: 350,
          )
        ],
      );
    }
    //This widget will show the user image obtained from the passport or national id
    Widget faceImage = Container();
    if (_faceImageBase64 != null && _faceImageBase64 != "") {
      faceImage = Column(
        children: <Widget>[
          const Text("Face Image:"),
          Image.memory(
            const Base64Decoder().convert(_faceImageBase64!),
            height: 150,
            width: 100,
          )
        ],
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          title: const Text(
            "Scan ID for Visitor",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Padding(
                  child: ElevatedButton(
                    child: const Text("Scan ID"),
                    onPressed: () => scan(),
                  ),
                  padding: const EdgeInsets.only(bottom: 16.0)),
              Text(_resultString!),
              fullDocumentFrontImage,
              // fullDocumentBackImage,
              faceImage,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> scan() async {
    String license;
    // Set the license key depending on the target platform you are building for.
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      license = "sRwCABVjb20uZXhhbXBsZS5ibGlua2lUcnkBbGV5SkRjbVZoZEdWa1QyNGlPakUzTXpVM056QTVOekEyTXpZc0lrTnlaV0YwWldSR2IzSWlPaUprWVdReVltVXhOeTAzTTJNMExUUmlPVEV0WWpCbVppMWpNR0V3TnpFeFl6QTBZbVlpZlE9PY5nZfkvC7rQXlbZmvNhJ7lrndSCJ5d5F0MiiG3zcoYYinv0TqJLp9BtLohwlbyz34R5yB2MviSyOtG8uGC3DjwB7LCW3HLweDhyEvdDhUI+xHbfiTvKj2xKXM/yilYkTuNIjdrtfbxnhghxOgkHvdr69TvUycMF6w==";
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      license = "sRwCABZjb20uZXhhbXBsZS5ibGlua2lfdHJ5AGxleUpEY21WaGRHVmtUMjRpT2pFM016VTNOekE1TnpBM05USXNJa055WldGMFpXUkdiM0lpT2lKa1lXUXlZbVV4TnkwM00yTTBMVFJpT1RFdFlqQm1aaTFqTUdFd056RXhZekEwWW1ZaWZRPT2slhidStG0BF6+e9R2PQr/xbOyhSzInC53j/2exlG6LAjlZMEJ338Cm0Dywwfaw1iGKbdZhLX7tFNRyAkaRGX0oQdP6hH/SZNX1AdCMp+6M36HW509Ganx38gA71sQvYPD0O1vmJxtw0eS6MeiZNqcFtMjgFy4QQs=";
    } else {
      license = "sRwCABVjb20uZXhhbXBsZS5ibGlua2lUcnkBbGV5SkRjbVZoZEdWa1QyNGlPakUzTXpVM056QTVOekEyTXpZc0lrTnlaV0YwWldSR2IzSWlPaUprWVdReVltVXhOeTAzTTJNMExUUmlPVEV0WWpCbVppMWpNR0V3TnpFeFl6QTBZbVlpZlE9PY5nZfkvC7rQXlbZmvNhJ7lrndSCJ5d5F0MiiG3zcoYYinv0TqJLp9BtLohwlbyz34R5yB2MviSyOtG8uGC3DjwB7LCW3HLweDhyEvdDhUI+xHbfiTvKj2xKXM/yilYkTuNIjdrtfbxnhghxOgkHvdr69TvUycMF6w==";
    }

    var idRecognizer = BlinkIdMultiSideRecognizer();
    idRecognizer.returnFullDocumentImage = true;
    idRecognizer.returnFaceImage = true;

    BlinkIdOverlaySettings settings = BlinkIdOverlaySettings();

    var results = await MicroblinkScanner.scanWithCamera(RecognizerCollection([idRecognizer]), settings, license);

    if (!mounted) return;
    // When the scan is cancelled, the result is null therefore we return to the the main screen.
    if (results.isEmpty) return;
    //When the result is not null, we check if it is a passport then obtain the details using the `getPassportDetails` method and display them in the UI. If the document type is a national id, we get the details using the `getIdDetails` method and display them in the UI.
    for (var result in results) {
      if (result is BlinkIdMultiSideRecognizerResult) {
        if (result.mrzResult?.documentType == MrtdDocumentType.Passport) {
          _resultString = getPassportResultString(result);
        } else {
          _resultString = getIdResultString(result);
        }

        setState(() {
          _resultString = _resultString;
          _fullDocumentFrontImageBase64 = result.fullDocumentFrontImage ?? "";
          _faceImageBase64 = result.faceImage ?? "";
        });

        return;
      }
    }
  }

  //This method is used to obtain the specific user details from the national id from the scan result object.
  String getIdResultString(
    BlinkIdMultiSideRecognizerResult result,
  ) {
    // The information below will be otained from the natioal id if they are available.
    // In the case a field is not found, then it is skipped. For example, some national ids do not have the profession field.
    return buildResult(result.firstName?.latin, "First name") + buildResult(result.lastName?.latin, "Last name") + buildResult(result.fullName?.latin, "Full name") + buildResult(result.localizedName?.latin, "Localized name") + buildResult(result.additionalNameInformation?.latin, "Additional name info") + buildResult(result.address?.latin, "Address") + buildResult(result.additionalAddressInformation?.latin, "Additional address info") + buildResult(result.documentNumber?.latin, "Document number") + buildResult(result.documentAdditionalNumber?.latin, "Additional document number") + buildResult(result.sex?.latin, "Sex") + buildResult(result.issuingAuthority?.latin, "Issuing authority") + buildResult(result.nationality?.latin, "Nationality") + buildDateResult(result.dateOfBirth?.date, "Date of birth") + buildIntResult(result.age, "Age") + buildDateResult(result.dateOfIssue?.date, "Date of issue") + buildDateResult(result.dateOfExpiry?.date, "Date of expiry") + buildResult(result.dateOfExpiryPermanent.toString(), "Date of expiry permanent") + buildResult(result.maritalStatus?.latin, "Martial status") + buildResult(result.personalIdNumber?.latin, "Personal Id Number") + buildResult(result.profession?.latin, "Profession") + buildResult(result.race?.latin, "Race") + buildResult(result.religion?.latin, "Religion") + buildResult(result.residentialStatus?.latin, "Residential Status") + buildDriverLicenceResult(result.driverLicenseDetailedInfo);
  }

  String buildResult(String? result, String propertyName) {
    if (result == null || result.isEmpty) {
      return "";
    }

    return propertyName + ": " + result + "\n";
  }

  //This function creates a complete date based on the date obtained from the scanned document. For example, date of the document issue.
  String buildDateResult(Date? result, String propertyName) {
    if (result == null || result.year == 0) {
      return "";
    }

    return buildResult("${result.day}.${result.month}.${result.year}", propertyName);
  }

  String buildIntResult(int? result, String propertyName) {
    if (result == null || result < 0) {
      return "";
    }

    return buildResult(result.toString(), propertyName);
  }

  //This method obtained the
  String buildDriverLicenceResult(DriverLicenseDetailedInfo? result) {
    if (result == null) {
      return "";
    }

    return buildResult(result.restrictions?.latin, "Restrictions") + buildResult(result.endorsements?.latin, "Endorsements") + buildResult(result.vehicleClass?.latin, "Vehicle class") + buildResult(result.conditions?.latin, "Conditions");
  }

  String getPassportResultString(BlinkIdMultiSideRecognizerResult? result) {
    if (result == null) {
      return "";
    }

    var dateOfBirth = "";
    if (result.mrzResult?.dateOfBirth != null) {
      dateOfBirth = "Date of birth: ${result.mrzResult!.dateOfBirth?.day}."
          "${result.mrzResult!.dateOfBirth?.month}."
          "${result.mrzResult!.dateOfBirth?.year}\n";
    }

    var dateOfExpiry = "";
    if (result.mrzResult?.dateOfExpiry != null) {
      dateOfExpiry = "Date of expiry: ${result.mrzResult?.dateOfExpiry?.day}."
          "${result.mrzResult?.dateOfExpiry?.month}."
          "${result.mrzResult?.dateOfExpiry?.year}\n";
    }

    return "First name: ${result.mrzResult?.secondaryId}\n"
        "Last name: ${result.mrzResult?.primaryId}\n"
        "Document number: ${result.mrzResult?.documentNumber}\n"
        "Sex: ${result.mrzResult?.gender}\n"
        "$dateOfBirth"
        "$dateOfExpiry";
  }
// This widget will display a complete image of the scanned passport or national id.
}
