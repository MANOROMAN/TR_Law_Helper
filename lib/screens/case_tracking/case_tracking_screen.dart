import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class CaseTrackingScreen extends StatefulWidget {
  @override
  _CaseTrackingScreenState createState() => _CaseTrackingScreenState();
}

class _CaseTrackingScreenState extends State<CaseTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dava Takip'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Center(
        child: Text('Dava Takip Modülü'),
      ),
    );
  }
}
