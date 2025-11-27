// import 'dart:io';

// //import 'package:get/instance_manager.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class PathsHelper {
//   late final String? _userStub;
//   late final String _applicationDocumentsPath;
//   late final String? _downloadsPath;
//   late final String _libraryPath;
//   late final String _temporaryPath;
//   static PathsHelper? _instance;

//   PathsHelper._privateConstructor(
//     this._userStub,
//     this._applicationDocumentsPath,
//     this._downloadsPath,
//     this._libraryPath,
//     this._temporaryPath,
//   );

//   // USE: final pathsHelper = await PathsHelper.asyncInstance;

//   static Future<PathsHelper> get asyncInstance async {
//     _instance ??= await _createInstance();
//     return _instance!;
//   }

//   static Future<PathsHelper> _createInstance() async {
//     final appDocsDirPath = await getPathProviderDirectoryPath('appDocs');
//     // print('appdocs: $appDocsDirPath');
//     final downloadsDirPath =
//         Platform.isIOS ? null : await getPathProviderDirectoryPath('downloads');
//     // print('downloadsDirPath: $downloadsDirPath');
//     final libDirPath = await getPathProviderDirectoryPath('library');
//     // print('libDirPath: $libDirPath');
//     final tempDirPath = await getPathProviderDirectoryPath('temp');
//     // print('tempDirPath: $tempDirPath');

//     final userStub =
//         downloadsDirPath?.split(context.separator).take(3).toList().join('/');

//     _instance = PathsHelper._privateConstructor(
//       userStub,
//       appDocsDirPath,
//       downloadsDirPath,
//       libDirPath,
//       tempDirPath,
//     );

//     return _instance!;
//   }

//   String get applicationDocumentsPath => _applicationDocumentsPath;
//   String? get downloadsPath => _downloadsPath;
//   String get libraryPath => _libraryPath;
//   String get temporaryPath => _temporaryPath;

//   static Future<String> getPathProviderDirectoryPath(
//       String directoryKey) async {
//     Directory? directory;
//     try {
//       switch (directoryKey) {
//         case 'downloads':
//           directory = await getDownloadsDirectory();
//           break;

//         case 'appDocs':
//           directory = await getApplicationDocumentsDirectory();
//           break;

//         case 'library':
//           directory = await getLibraryDirectory();
//           break;

//         case 'temp':
//           directory = await getTemporaryDirectory();

//           break;

//         default:
//           throw '$directoryKey is not a recognized key';
//       }

//       if (directory == null) {
//         throw 'path providfer path not found';
//       }
//     } catch (e) {
//       throw "PathsHelper initialization error, getPathProviderDirectoryPath(): unspecified error with key '$directoryKey'";
//     }
//     return directory.path;
//   }

//   String getUserName() {
//     if (Platform.isIOS) {
//       return 'ios';
//     } else {
//       return _userStub!.split(context.separator)[2];
//     }
//   }

//   String userGraft(String graft) {
//     if (Platform.isIOS) {
//       return graft;
//     } else {
//       return join(_userStub!, graft);
//     }
//   }

//   String get chatDBPath => userGraft('Library/Messages/chat.db');

//   String stripTilde(String path) {
//     if (path[0] != '~') {
//       return path;
//     }

//     final List graft = path.split(context.separator)..removeAt(0);

//     return userGraft(graft.join(context.separator));
//   }
// }
