import 'package:flutter/material.dart';

class SizePageRoute extends PageRouteBuilder {
  final Widget page;

  /*
    + Reference: https://medium.com/flutter-community/everything-you-need-to-know-about-flutter-page-route-transition-9ef5c1b32823
  */

  SizePageRoute({this.page})
      : assert(page != null),
        super(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return Align(
                child: SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
              );
            });
}