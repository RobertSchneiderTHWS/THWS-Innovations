import 'package:fhws_innovations/constants/text_constants.dart';
import 'package:flutter/material.dart';

class RoundedAlert extends StatelessWidget {
  final String title;
  final String text;

  const RoundedAlert(this.title, this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.only(right: 16.0),
          width: size.width * 0.9,
          height: size.height * 0.2,
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text('❗️ ' + title + ' ❗️',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10.0),
                    Flexible(
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      height: 40,
                      width: 90,
                      decoration: const BoxDecoration(
                        color: fhwsGreen,
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      ),
                      child: TextButton(
                        child: const Text("OK",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            )),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
