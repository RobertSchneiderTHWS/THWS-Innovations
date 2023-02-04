import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:web3dart/credentials.dart';
import '../constants/text_constants.dart';

class StudentFromFhwsFetch {
  String kNumber;
  String firstName;

  StudentFromFhwsFetch(this.kNumber, this.firstName);
}

class Student {
  Student();

  late String kNumber;
  late EthereumAddress studentAddress;
  late bool voted;
  late Uint8List votedInnovationHash;

  Student.fromSmartContract(
      this.kNumber, this.studentAddress, this.voted, this.votedInnovationHash);

  static Future<StudentFromFhwsFetch> fetchStudentInformation(
      String kNumber, String password) async {
    String credentials = '$kNumber:$password';
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);

    final response = await http.get(
      Uri.parse(fhwsApi),
      // Send authorization headers to the fhws backend.
      headers: {
        HttpHeaders.authorizationHeader: 'Basic $encoded',
      },
    );
    Map<String, dynamic> json = jsonDecode(response.body);
    return StudentFromFhwsFetch(json['cn'], json['firstName']);
  }

  @override
  String toString() {
    return 'Student{kNumber: $kNumber, studentAddress: $studentAddress, voted: $voted, votedInnovationHash: $votedInnovationHash}';
  }
}
