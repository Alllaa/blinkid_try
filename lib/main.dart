import 'package:flutter/material.dart';

import 'scan_id.dart';

void main() {
  runApp(const MRZApp());
}

class MRZApp extends StatelessWidget {
  const MRZApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MRZ Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScanID(),
    );
  }
}
