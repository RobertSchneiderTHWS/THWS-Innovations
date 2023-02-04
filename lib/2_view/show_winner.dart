import 'dart:typed_data';
import 'package:fhws_innovations/1_model/innovation.dart';
import 'package:fhws_innovations/1_model/innovations_object.dart';
import 'package:fhws_innovations/constants/text_constants.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/credentials.dart';
import '../1_model/student_object.dart';
import '../constants/rounded_alert.dart';
import 'login.dart';

class ShowWinner extends StatefulWidget {
  final List<Innovation> innovations;
  final bool studentIsContractOwner;
  final Student studentFromLogin;
  final EthereumAddress smartContractOwner;

  const ShowWinner({
    required this.innovations,
    required this.studentIsContractOwner,
    required this.studentFromLogin,
    required this.smartContractOwner,
  });

  @override
  _ShowWinner createState() => _ShowWinner();
}

class _ShowWinner extends State<ShowWinner> {
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
            child: Column(children: <Widget>[
          SizedBox(height: size.height * 0.015),
          Center(
            child: SizedBox(
              width: size.width * 0.9,
              child: const Text(
                '🎉 Herzlichen Glückwunsch! 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(color: fhwsGreen, fontSize: 24.0),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.01),

          Center(
            child: SizedBox(
              width: size.width * 0.9,
              height: 80,
              child: const Text(
                'Der Abstimmungsprozess wurde beendet und die Innovation(en) mit den meisten Stimmen stehen fest!',
                textAlign: TextAlign.center,
                style: TextStyle(color: fhwsGreen, fontSize: 24.0),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.015),
          FutureBuilder<List<Innovation>>(
            future: getAllWinningInnovations(),
            builder: (context, AsyncSnapshot<List<Innovation>> snap) {
              if (snap.data == null) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: fhwsGreen,
                ));
              }
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.innovations.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildFeaturedItem(
                      title: widget.innovations.elementAt(index).title,
                      description: widget.innovations
                          .elementAt(index)
                          .description
                          .toString(),
                      creator: widget.innovations.elementAt(index).creator,
                      voteCount: widget.innovations
                          .elementAt(index)
                          .votingCount
                          .toString(),
                      innovationHash: Uint8List.fromList(widget.innovations
                          .elementAt(index)
                          .uniqueInnovationHash),
                    );
                  });
            },
          ),
          SizedBox(height: size.height * 0.03),
          widget.studentIsContractOwner
              ? TextButton(
                  onPressed: () async {
                    ib.restartInnovationProcess(context, size, '');
                  },
                  child: Container(
                      height: 50,
                      width: size.width * 0.35,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(32.0)),
                        color: fhwsGreen,
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 10),
                        child: Center(
                          child: Text(
                            'Neue Abstimmungsperiode starten',
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
              : const SizedBox(),
          SizedBox(height: size.height * 0.015),
          //});
        ])),
      ),
    );
  }

  Container _buildFeaturedItem(
      {required String title,
      required String description,
      required String voteCount,
      required Student creator,
      required Uint8List innovationHash}) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title,
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
                Text(creator.studentAddress.toString() + ' ',
                    style: const TextStyle(
                      color: fhwsGreen,
                      fontWeight: FontWeight.bold,
                    )),
                const Text(' (',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                Text(creator.kNumber,
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

  Future<List<Innovation>> getAllWinningInnovations() async {
    InnovationsObject object = InnovationsObject();
    var winningInnos = await object.getWinningInnovationsOfProcess();
    return winningInnos;
  }
}
