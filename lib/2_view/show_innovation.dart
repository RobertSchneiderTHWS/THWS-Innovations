import 'dart:typed_data';
import 'package:fhws_innovations/1_model/innovation.dart';
import 'package:fhws_innovations/1_model/innovations_object.dart';
import 'package:fhws_innovations/constants/text_constants.dart';
import 'package:flutter/material.dart';
import '../constants/rounded_alert.dart';
import 'innovations_overview.dart';
import 'login.dart';

class ShowInnovation extends StatefulWidget {
  final Innovation innovation;
  final String studentFirstName;

  const ShowInnovation(
      {Key? key, required this.innovation, required this.studentFirstName})
      : super(key: key);

  @override
  _ShowInnovationOverviewState createState() => _ShowInnovationOverviewState();
}

class _ShowInnovationOverviewState extends State<ShowInnovation> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    InnovationsObject ib = InnovationsObject();
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: Row(
                      children: [
                        const Text('Übersicht',
                            style:
                                TextStyle(color: Colors.white, fontSize: 18.0)),
                        IconButton(
                            onPressed: () async {
                              var student = await ib.getStudentFromSC();
                              var innos = await ib.getAllInnovations();
                              var isFinished =
                                  await ib.innovationProcessFinished();
                              var owner = await ib.getContractOwner();
                              bool isOwner = false;
                              if (owner == student.studentAddress) {
                                isOwner = true;
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => InnovationsOverview(
                                            student: student,
                                            studentFirstName:
                                                widget.studentFirstName,
                                            innovations: innos,
                                            isInnovationsProcessFinished:
                                                isFinished,
                                            isSmartContractOwner: isOwner,
                                          )));
                            },
                            icon: const Icon(Icons.home)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'Detailansicht',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontSize: 18.0),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.search, color: Colors.black)),
                    ],
                  ),
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
            _buildFeaturedItem(
                title: widget.innovation.title,
                innovationHash: widget.innovation.uniqueInnovationHash,
                voteCount: widget.innovation.votingCount.toString(),
                description: widget.innovation.description),
          ],
        )),
      ),
    );
  }

  Container _buildFeaturedItem(
      {required String title,
      required String description,
      required String voteCount,
      required Uint8List innovationHash}) {
    return Container(
      padding:
          const EdgeInsets.only(left: 16.0, top: 8.0, right: 16.0, bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        color: Colors.black.withOpacity(0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: fhwsGreen,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            Text(description,
                style: const TextStyle(
                  color: Colors.white,
                )),
            const SizedBox(
              height: 5.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Anzahl an Stimmen: ',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Text(voteCount,
                    style: const TextStyle(
                      color: fhwsGreen,
                      fontWeight: FontWeight.bold,
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Ersteller: ',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Text(widget.innovation.creator.studentAddress.toString() + ' ',
                    style: const TextStyle(
                      color: fhwsGreen,
                      fontWeight: FontWeight.bold,
                    )),
                const Text(' (',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Text(widget.innovation.creator.kNumber,
                    style: const TextStyle(
                      color: fhwsGreen,
                      fontWeight: FontWeight.bold,
                    )),
                const Text(')',
                    style: TextStyle(
                      color: Colors.white,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
