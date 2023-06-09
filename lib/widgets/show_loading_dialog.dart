import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: Container(
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: CircularProgressIndicator(),
              ),
              Expanded(child: Text("Loading ...", textAlign: TextAlign.center,)),
              Spacer(),
            ],
          ),
        ),
      );
    },
  );
}