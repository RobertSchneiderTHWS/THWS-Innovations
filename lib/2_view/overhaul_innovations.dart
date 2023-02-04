import 'package:fhws_innovations/1_model/innovation.dart';
import 'package:fhws_innovations/2_view/user_innovations.dart';
import 'package:fhws_innovations/constants/text_constants.dart';
import 'package:flutter/material.dart';
import '../1_model/innovations_object.dart';
import '../constants/rounded_alert.dart';
import 'innovations_overview.dart';
import 'login.dart';

class OverhaulInnovation extends StatefulWidget {
  final String studentFirstName;
  final Innovation userInnovation;

  int voteCount = 0;

  OverhaulInnovation({
    Key? key,
    required this.studentFirstName,
    required this.userInnovation,
  }) : super(key: key);

  @override
  _InnovationsDetailOverviewState createState() =>
      _InnovationsDetailOverviewState();
}

class _InnovationsDetailOverviewState extends State<OverhaulInnovation> {
  @override
  Widget build(BuildContext context) {
    InnovationsObject ib = InnovationsObject();
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const RoundedAlert("Achtung",
                "Innerhalb der App kann nur durch die Icons der Applikation navigiert werden.");
          },
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            '⚡️FHWS Innovations⚡️',
            style: TextStyle(fontSize: 18.0, color: Colors.white),
          ),
          backgroundColor: fhwsGreen,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Row(
                children: [
                  const Text('Übersicht',
                      style: TextStyle(color: Colors.white, fontSize: 18.0)),
                  IconButton(
                      onPressed: () async {
                        var student = await ib.getStudentFromSC();
                        var allInnovations = await ib.getAllInnovations();
                        var isInnovationsProcessFinished =
                            await ib.innovationProcessFinished();
                        var contractOwner = await ib.getContractOwner();
                        bool isOwner = false;
                        if (student.studentAddress == contractOwner) {
                          isOwner = true;
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InnovationsOverview(
                                      student: student,
                                      innovations: allInnovations,
                                      isInnovationsProcessFinished:
                                          isInnovationsProcessFinished,
                                      isSmartContractOwner: isOwner,
                                      studentFirstName: widget.studentFirstName,
                                    )));
                      },
                      icon: const Icon(Icons.home)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Row(
                children: [
                  Text('Innovationen bearbeiten',
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.7),
                          fontSize: 18.0)),
                  IconButton(
                      onPressed: () async {
                        var studentInnovations =
                            await ib.getInnovationsOfStudent();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserInnovations(
                                      userInnovations: studentInnovations,
                                      studentFirstName: widget.studentFirstName,
                                    )));
                      },
                      icon: const Icon(Icons.description, color: Colors.black)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'Willst du deine Innovation wirklich löschen?'),
                                actions: <Widget>[
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'Nein',
                                        style: TextStyle(color: Colors.black),
                                      )),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () async {
                                      ib.deleteInnovation(
                                          widget.userInnovation
                                              .uniqueInnovationHash,
                                          context,
                                          size,
                                          widget.studentFirstName);
                                    },
                                    child: const Text('Löschen',
                                        style: TextStyle(color: Colors.red)),
                                  )
                                ],
                              );
                            });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Login(
                                  fromStudentCheck: false,
                                )));
                  },
                  icon: const Icon(Icons.logout)),
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            SizedBox(height: size.height * 0.015),
            _overhaulInnovation(),
            TextButton(
              onPressed: () async {
                ib.editInnovation(
                    widget.userInnovation.uniqueInnovationHash,
                    widget.userInnovation.title,
                    widget.userInnovation.description,
                    context,
                    size,
                    widget.studentFirstName);
              },
              child: Container(
                  height: 50,
                  width: size.width * 0.35,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(32.0)),
                    color: fhwsGreen,
                  ),
                  child: const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                    child: Center(
                      child: Text(
                        'Eingaben Speichern',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  )),
            )
          ],
        )),
      ),
    );
  }

  Container _overhaulInnovation() {
    return Container(
      padding:
          const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            TextFormField(
              onChanged: (value) {
                String input = '';
                input = value;
                widget.userInnovation.title = input;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: widget.userInnovation.title,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: fhwsGreen, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
              ),
            ),
            TextFormField(
              onChanged: (value) {
                String input = '';
                input = value;
                widget.userInnovation.description = input;
              },
              minLines: 7,
              maxLines: 11,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: widget.userInnovation.description,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: fhwsGreen, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(0.0)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
