import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:helping_hand/config/config.dart';
import 'package:helping_hand/models/requestItemBuild.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

final usersRef = Firestore.instance.collection('userRequests');
final auth = FirebaseAuth.instance;

bool showSpinner = true;

class requestDisplay extends StatefulWidget {
  @override
  _itemPageState createState() => _itemPageState();
}

class _itemPageState extends State<requestDisplay> {
  var tempList = List();
  var request_list = new List();

  Future<void> gather_requests() async {
    request_list.clear();

    final CollectionReference requests =
        Firestore.instance.collection('helpRequests');

    await for (var snapshot in requests.snapshots()) {
      for (var user in snapshot.documents) {
        final CollectionReference userPosts = Firestore.instance
            .collection('helpRequests/' + user.documentID + '/userPosts');
        await for (var snapshot in userPosts.snapshots()) {
          for (var userpost in snapshot.documents) {
            setState(() {
              tempList.add(userpost.data);
              request_list = tempList;
            });
          }
          break;
        }
      }
      break;
    }
    setState(() {
      showSpinner = false;
    });
    request_list = tempList;
    // tempList.clear();

    //print(request_list[0]['photUrl']);
  }

  @override
  void initState() {
    gather_requests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //this little code down here turns off auto rotation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.1,
          backgroundColor: primaryColor,
          title: Text(
            "Help Forum",
            style: requestTitleTextStyle,
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.list),
              onPressed: () {},
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async{
            setState(() async {
              gather_requests();
            });
          },
          child: Container(
            child: ListView.builder(
              itemCount: request_list.length,
              itemBuilder: (context, index) {
                return buildRequestItem(
                  //imgPath: request_list[index]['photUrl'],
                  title: request_list[index]['title'],
                  desc: request_list[index]['description'],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
