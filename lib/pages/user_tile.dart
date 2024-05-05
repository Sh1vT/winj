import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String phone;
  final String timestamp;
  const UserTile(
      {super.key,
      required this.name,
      required this.phone,
      required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        launchUrlString("tel:$phone");
      },
      child: Container(
        height: 100,
        width: 200,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(left: 8, right: 8, bottom: 14),
        decoration: const BoxDecoration(
          color: Color.fromARGB(15, 187, 134, 252),
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        // padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const Icon(Icons.contact_phone_rounded, size: 40),
            Text(
              name,
              style: const TextStyle(
                color: Color.fromARGB(255, 216, 186, 255),
              ),
            ),
            Text(
              timestamp,
              style: const TextStyle(
                fontSize: 11,
                color: Color.fromARGB(255, 216, 186, 255),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
