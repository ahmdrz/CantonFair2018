import 'package:flutter/material.dart';

import '../utils/ui.dart';

class SelectedPhaseRoute extends StatefulWidget {
  final String phase;
  SelectedPhaseRoute({this.phase});

  @override
  _SelectedPhaseRoute createState() => new _SelectedPhaseRoute();
}

class _SelectedPhaseRoute extends State<SelectedPhaseRoute> {
  String phase = '1';
  _SelectedPhaseRoute({this.phase});

  @override
  Widget build(BuildContext context) {    
    return scaffoldWrapper(
      context: context,      
      pageName: 'Phase $phase',
      childPage: true,
    );
  }
}
