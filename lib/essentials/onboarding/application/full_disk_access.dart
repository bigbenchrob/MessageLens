enum MessagesSourceAccessResult { readable, accessDenied, unavailable }

abstract interface class FullDiskAccess {
  String get messagesDatabasePath;

  MessagesSourceAccessResult inspectMessagesSourceAccess();

  bool canReadMessagesDatabase();

  Future<void> openSettings();
}
