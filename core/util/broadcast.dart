// import 'dart:io';

// /// Flutter
// import 'package:logger/logger.dart';
// final logger = Logger();

// /// Dart CLI
// import 'package:mason_logger/mason_logger.dart';
// final logger = Logger();

// /// (add a simple optional boolean [mute] parameter to toggle print, logger, or stdout
// /// so that the invoking code can choose to mute the broadcast without wrapping
// /// the whole invocation in a conditional)

// // ignore: avoid_positional_boolean_parameters
// void broadcast(String message, [bool mute = false]) {
//   if (mute) {
//     return;
//   }
//   //const toggle = 'print';
//   // const toggle = 'logger';
//   const toggle = 'stdout';

//   if (toggle == 'print') {
//     // ignore: avoid_print
//     print(message);
//   } else if (toggle == 'logger') {
//     logger.detail(message);
//   } else if (toggle == 'stdout') {
//     stdout.writeln(message);
//   }
// }