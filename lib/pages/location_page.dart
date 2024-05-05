import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:winj/firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:winj/pages/user_tile.dart';

var userLatitude = LatLng(0, 0);

//TEST DATA

final List marketZoneLong = [
  77.50087910864238,
  77.50016290416494,
  77.49625633429417,
  77.49663800048785,
  77.50015346311142,
  77.50295317151898,
  77.502553213174,
  77.50087920957293,
];

final List marketZoneLat = [
  28.479001798631614,
  28.47902632608158,
  28.484332297156897,
  28.484588805298614,
  28.484682637903518,
  28.481052707783377,
  28.479940812333822,
  28.479001889931723
];

List<String> userCreds = ['Click on Edit', 'Phone'];
bool marketPresence = false;

//CHECK FUNCTION
bool isInsideMarketZone(
    int nvert, List vertx, List verty, double testx, double testy) {
  int i, j;
  j = nvert - 1;
  bool c = false;
  for (i = 0; i < nvert; j = i++) {
    if (((verty[i] > testy) != (verty[j] > testy)) &&
        (testx <
            (vertx[j] - vertx[i]) * (testy - verty[i]) / (verty[j] - verty[i]) +
                vertx[i])) {
      c = !c;
    }
  }
  return c;
}

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String messageToFetch = 'Click on fetch';

  final FirestoreService firestoreService = FirestoreService();

  //INITIALISING LOCAL USER DATA

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  //SAVING LOCAL USER DATA FOR NEXT STARTUP

  void _saveData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/userCreds.txt');
      final data = json.encode(userCreds);
      await file.writeAsString(data);
    } catch (e) {
      // print('ERROR SAVING');
    }
  }

  //LOADING LOCAL USER DATA FOR NEXT STARTUP

  void _loadData() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/userCreds.txt');
      if (await file.exists()) {
        final data = await file.readAsString();
        setState(
          () {
            userCreds = List.from(json.decode(data));
          },
        );
      }
    } catch (e) {
      // print('ERROR LOADING');
    }
  }

  //UPDATING LOCATION DATA TO FIRESTORE DATABASE

  Future<Position> locationFetch() async {
    await Geolocator.checkPermission();
    await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    // print(position.toString());

    //NEW FUNCTION
    if (marketPresence == false) {
      if (isInsideMarketZone(marketZoneLat.length, marketZoneLat,
          marketZoneLong, position.latitude, position.longitude)) {
        marketPresence = true;
        firestoreService.addUser(userCreds, marketPresence);
        Fluttertoast.showToast(
          msg: 'You\'re in Jagat. Location updated!',
          backgroundColor: const Color.fromARGB(255, 29, 29, 29),
          textColor: const Color.fromARGB(255, 255, 255, 255),
        );
        // print(marketPresence);
        // print('Inside Jagat');
      } else {
        Fluttertoast.showToast(
          msg: 'You\'re not in Jagat.',
          backgroundColor: const Color.fromARGB(255, 29, 29, 29),
          textColor: const Color.fromARGB(255, 255, 255, 255),
        );
        marketPresence = false;
      }
    } else {
      Fluttertoast.showToast(
        msg: 'You\'ve updated your location already!',
        backgroundColor: const Color.fromARGB(255, 29, 29, 29),
        textColor: const Color.fromARGB(255, 255, 255, 255),
      );
      // print(marketPresence);
      // print('Not inside Jagat');
    }
    return position;
  }

  //POP-UP TO ENTER USER DATA (NAME, PHONE)

  final TextEditingController textEditingControllerForName =
      TextEditingController();
  final TextEditingController textEditingControllerForPhone =
      TextEditingController();

  void emptyDialog() {
    // showDialog(context: context,
    //  builder: (context) => const AlertDialog(
    //   content: SizedBox(
    //     height: 40,
    //     child: Text('Please enter valid credentials'),
    //   ),
    //  ),
    //  );
    Fluttertoast.showToast(
      msg: 'Please enter valid credentials.',
      backgroundColor: const Color.fromARGB(255, 29, 29, 29),
      textColor: const Color.fromARGB(255, 255, 255, 255),
    );
  }

  void nameDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SizedBox(
          height: 100,
          child: Column(
            children: [
              TextField(
                controller: textEditingControllerForName,
                decoration: const InputDecoration(hintText: 'Enter your name'),
              ),
              TextField(
                keyboardType: TextInputType.number,
                controller: textEditingControllerForPhone,
                decoration:
                    const InputDecoration(hintText: 'Enter your phone number'),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              (textEditingControllerForName.text.toString() == '')
                  ? emptyDialog()
                  : userCreds[0] = textEditingControllerForName.text.toString();
              (textEditingControllerForPhone.text.toString() == '')
                  ? emptyDialog()
                  : userCreds[1] =
                      textEditingControllerForPhone.text.toString();
              setState(() {
                _saveData();
                Navigator.pop(context);
              });
            },
            child: const Text('DONE'),
          ),
        ],
      ),
    );
  }

  //BUILD FUNCTION

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //APPBAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(52),
        child: AppBar(
          backgroundColor: const Color.fromARGB(34, 175, 126, 236),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(25),
            ),
          ),
          leading: GestureDetector(
            onTap: () {
              showAboutDialog(
                applicationName: 'Who is in Jagat',
                applicationVersion: 'v0.050524',
                context: context,
                children: [
                  const Text(
                    'This app is in early stages of development.\nAny entry in the list expires after 30 minutes of creation to prevent spam. \nSimilar Features may be added or updated when possible. \n\nPlease do not create random names, phone numbers, spam entries etc. and maintain a healthy ecosystem. Source code for nerds:\nhttps://github.com/ppkekw/',
                    textAlign: TextAlign.justify,
                  ),
                ],
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                color: Color.fromARGB(34, 175, 126, 236),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 18,
              ),
            ),
          ),
          title: const Text(
            'WinJ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  const CircularProgressIndicator.adaptive();
                });
              },
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(34, 175, 126, 236),
                  shape: BoxShape.circle,
                ),
                margin: const EdgeInsets.only(right: 16),
                child: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
                
              ),
            ),
          ],
        ),
      ),

      //APP BODY
      body: ListView(
        children: [
          //CONTAINER 1 TO DISPLAY USER DATA
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.person_pin_rounded,
                  size: 100,
                ),
                (userCreds[0] != 'Click on Edit')
                    ? Text('Hey! I\'m ${userCreds[0]}')
                    : const Text('Click on Edit'),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: locationFetch,
                      child: const Text('I\'m in Jagat'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: nameDialog,
                      child: const Text('Edit'),
                    ),
                  ],
                )
              ],
            ),
          ),

          //CONTAINER 2 TO DISPLAY JAGAT USERS
          Container(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: const Text(
              'Those in Jagat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 400,
                  child: StreamBuilder(
                    stream: firestoreService.getUserStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData == false) {
                        return const Text('No data');
                      } else {
                        List users = snapshot.data!.docs;

                        //DISPLAY AS A LIST
                        return GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3),
                          scrollDirection: Axis.vertical,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            //GET INDIVIDUAL FIRESTORE DOC
                            DocumentSnapshot document = users[index];

                            //FOR FUTURE UPDATES (IF ANY)
                            // String docID = document.id;

                            //GET USER DATA FOR EACH DOC
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;

                            String userName = data['name'].toString();
                            String userPhone = data['phone'].toString();
                            Timestamp userTimestamp =
                                data['timestamp'] as Timestamp;
                            DateTime now = DateTime.now();
                            String formattedDate =
                                '@ ${((now.millisecondsSinceEpoch - userTimestamp.millisecondsSinceEpoch) / 60000).toStringAsFixed(0)} mins ago';

                            //30 MINUTE UPDATE
                            if (now.millisecondsSinceEpoch -
                                    userTimestamp.millisecondsSinceEpoch <
                                1800000) {
                              return UserTile(
                                name: userName,
                                phone: userPhone,
                                timestamp: formattedDate,
                              );
                            }
                            return null;
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
