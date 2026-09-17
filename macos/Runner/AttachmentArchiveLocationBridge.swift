import Cocoa
import FlutterMacOS

enum AttachmentArchiveBookmarkResolutionStatus: String {
  case available
  case readOnly = "read_only"
  case unavailable
  case permissionDenied = "permission_denied"
  case configuredDirectoryMissing = "configured_directory_missing"
  case invalidBookmark = "invalid_bookmark"
}

struct AttachmentArchiveBookmarkCreation {
  let bookmarkData: Data
  let resolvedURL: URL
  let volumeName: String?

  var channelPayload: [String: Any] {
    var payload: [String: Any] = [
      "bookmarkDataBase64": bookmarkData.base64EncodedString(),
      "resolvedPath": resolvedURL.path,
    ]
    if let volumeName {
      payload["volumeName"] = volumeName
    }
    return payload
  }
}

struct AttachmentArchiveBookmarkResolution {
  let status: AttachmentArchiveBookmarkResolutionStatus
  let resolvedURL: URL?
  let refreshedBookmarkData: Data?
  let volumeName: String?
  let issue: String?

  var channelPayload: [String: Any] {
    var payload: [String: Any] = ["status": status.rawValue]
    if status == .available || status == .readOnly,
      let resolvedURL
    {
      payload["resolvedPath"] = resolvedURL.path
    }
    if let refreshedBookmarkData {
      payload["refreshedBookmarkDataBase64"] =
        refreshedBookmarkData.base64EncodedString()
    }
    if let volumeName {
      payload["volumeName"] = volumeName
    }
    if let issue {
      payload["issue"] = issue
    }
    return payload
  }
}

enum AttachmentArchiveBookmarkError: Error {
  case invalidDirectoryPath
  case directoryMissing
  case notDirectory
  case symbolicLink
  case permissionDenied
}

enum AttachmentArchiveCapacityError: Error {
  case invalidDirectoryPath
  case capacityUnavailable
}

extension AttachmentArchiveCapacityError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidDirectoryPath:
      return "The capacity query path is not absolute."
    case .capacityUnavailable:
      return "Available capacity for important usage is unavailable."
    }
  }
}

extension AttachmentArchiveBookmarkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidDirectoryPath:
      return "The selected attachment archive path is not absolute."
    case .directoryMissing:
      return "The selected attachment archive directory does not exist."
    case .notDirectory:
      return "The selected attachment archive location is not a directory."
    case .symbolicLink:
      return "The attachment archive directory must not be a symbolic link."
    case .permissionDenied:
      return "The selected attachment archive directory is not readable."
    }
  }
}

final class FoundationAttachmentArchiveBookmarkService {
  private let fileManager: FileManager

  init(fileManager: FileManager = .default) {
    self.fileManager = fileManager
  }

  func createBookmark(directoryPath: String) throws
    -> AttachmentArchiveBookmarkCreation
  {
    guard (directoryPath as NSString).isAbsolutePath else {
      throw AttachmentArchiveBookmarkError.invalidDirectoryPath
    }
    let directoryURL = URL(
      fileURLWithPath: directoryPath,
      isDirectory: true
    ).standardizedFileURL
    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(
      atPath: directoryURL.path,
      isDirectory: &isDirectory
    ) else {
      throw AttachmentArchiveBookmarkError.directoryMissing
    }
    guard isDirectory.boolValue else {
      throw AttachmentArchiveBookmarkError.notDirectory
    }
    guard !isSymbolicLink(directoryURL) else {
      throw AttachmentArchiveBookmarkError.symbolicLink
    }
    guard fileManager.isReadableFile(atPath: directoryURL.path) else {
      throw AttachmentArchiveBookmarkError.permissionDenied
    }

    let bookmarkData = try directoryURL.bookmarkData(
      options: [],
      includingResourceValuesForKeys: [.volumeNameKey, .isDirectoryKey],
      relativeTo: nil
    )
    return AttachmentArchiveBookmarkCreation(
      bookmarkData: bookmarkData,
      resolvedURL: directoryURL,
      volumeName: volumeName(directoryURL)
    )
  }

  func resolveBookmark(base64: String) -> AttachmentArchiveBookmarkResolution {
    guard let bookmarkData = Data(base64Encoded: base64),
      !bookmarkData.isEmpty
    else {
      return failure(
        .invalidBookmark,
        issue: "The attachment archive bookmark data is invalid."
      )
    }

    var isStale = false
    let resolvedURL: URL
    do {
      resolvedURL = try URL(
        resolvingBookmarkData: bookmarkData,
        options: [.withoutUI],
        relativeTo: nil,
        bookmarkDataIsStale: &isStale
      ).standardizedFileURL
    } catch {
      let status = isPermissionError(error)
        ? AttachmentArchiveBookmarkResolutionStatus.permissionDenied
        : AttachmentArchiveBookmarkResolutionStatus.unavailable
      return failure(status, issue: error.localizedDescription)
    }

    var isDirectory: ObjCBool = false
    guard fileManager.fileExists(
      atPath: resolvedURL.path,
      isDirectory: &isDirectory
    ) else {
      let status = absentVolumeRoot(for: resolvedURL)
        ? AttachmentArchiveBookmarkResolutionStatus.unavailable
        : AttachmentArchiveBookmarkResolutionStatus.configuredDirectoryMissing
      return failure(status, issue: "The bookmarked directory is unavailable.")
    }
    guard isDirectory.boolValue else {
      return failure(
        .configuredDirectoryMissing,
        issue: "The bookmarked location is not a directory."
      )
    }
    guard !isSymbolicLink(resolvedURL) else {
      return failure(
        .invalidBookmark,
        issue: "The bookmarked directory must not be a symbolic link."
      )
    }
    guard fileManager.isReadableFile(atPath: resolvedURL.path) else {
      return failure(
        .permissionDenied,
        issue: "The bookmarked directory is not readable."
      )
    }

    let refreshedBookmarkData: Data?
    if isStale {
      refreshedBookmarkData = try? resolvedURL.bookmarkData(
        options: [],
        includingResourceValuesForKeys: [.volumeNameKey, .isDirectoryKey],
        relativeTo: nil
      )
    } else {
      refreshedBookmarkData = nil
    }
    let status: AttachmentArchiveBookmarkResolutionStatus =
      fileManager.isWritableFile(atPath: resolvedURL.path)
      ? .available
      : .readOnly
    return AttachmentArchiveBookmarkResolution(
      status: status,
      resolvedURL: resolvedURL,
      refreshedBookmarkData: refreshedBookmarkData,
      volumeName: volumeName(resolvedURL),
      issue: status == .readOnly
        ? "The bookmarked attachment archive is read-only."
        : nil
    )
  }

  func availableCapacityForImportantUsage(directoryPath: String) throws
    -> Int64
  {
    guard (directoryPath as NSString).isAbsolutePath else {
      throw AttachmentArchiveCapacityError.invalidDirectoryPath
    }
    let directoryURL = URL(
      fileURLWithPath: directoryPath,
      isDirectory: true
    ).standardizedFileURL
    let values = try directoryURL.resourceValues(
      forKeys: [.volumeAvailableCapacityForImportantUsageKey]
    )
    guard let capacity = values.volumeAvailableCapacityForImportantUsage,
      capacity >= 0
    else {
      throw AttachmentArchiveCapacityError.capacityUnavailable
    }
    return capacity
  }

  private func failure(
    _ status: AttachmentArchiveBookmarkResolutionStatus,
    issue: String
  ) -> AttachmentArchiveBookmarkResolution {
    return AttachmentArchiveBookmarkResolution(
      status: status,
      resolvedURL: nil,
      refreshedBookmarkData: nil,
      volumeName: nil,
      issue: issue
    )
  }

  private func isSymbolicLink(_ url: URL) -> Bool {
    guard
      let attributes = try? fileManager.attributesOfItem(atPath: url.path),
      let fileType = attributes[.type] as? FileAttributeType
    else {
      return false
    }
    return fileType == .typeSymbolicLink
  }

  private func volumeName(_ url: URL) -> String? {
    return try? url.resourceValues(forKeys: [.volumeNameKey]).volumeName
  }

  private func absentVolumeRoot(for url: URL) -> Bool {
    let components = url.pathComponents
    guard components.count >= 3, components[1] == "Volumes" else {
      return false
    }
    let volumeRoot = URL(fileURLWithPath: "/Volumes", isDirectory: true)
      .appendingPathComponent(components[2], isDirectory: true)
    return !fileManager.fileExists(atPath: volumeRoot.path)
  }

  private func isPermissionError(_ error: Error) -> Bool {
    let cocoaError = error as NSError
    return cocoaError.domain == NSCocoaErrorDomain
      && (
        cocoaError.code == NSFileReadNoPermissionError
          || cocoaError.code == NSFileWriteNoPermissionError
      )
  }
}

final class AttachmentArchiveLocationBridge: NSObject, FlutterStreamHandler {
  private let bookmarkService: FoundationAttachmentArchiveBookmarkService
  private var eventSink: FlutterEventSink?
  private var observers: [(NotificationCenter, NSObjectProtocol)] = []

  init(
    messenger: FlutterBinaryMessenger,
    bookmarkService: FoundationAttachmentArchiveBookmarkService =
      FoundationAttachmentArchiveBookmarkService()
  ) {
    self.bookmarkService = bookmarkService
    super.init()

    let methodChannel = FlutterMethodChannel(
      name: "com.bigbenchsoftware.MessageLens/attachment_archive_location",
      binaryMessenger: messenger
    )
    let eventChannel = FlutterEventChannel(
      name: "com.bigbenchsoftware.MessageLens/attachment_archive_location_events",
      binaryMessenger: messenger
    )
    methodChannel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }
    eventChannel.setStreamHandler(self)
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    eventSink = events
    installObservers()
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    removeObservers()
    return nil
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let arguments = call.arguments as? [String: Any] else {
      result(invalidArgumentsError("Method arguments are required."))
      return
    }
    switch call.method {
    case "createBookmark":
      guard let directoryPath = arguments["directoryPath"] as? String else {
        result(invalidArgumentsError("directoryPath is required."))
        return
      }
      do {
        result(try bookmarkService.createBookmark(
          directoryPath: directoryPath
        ).channelPayload)
      } catch {
        result(
          FlutterError(
            code: "bookmark_creation_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    case "resolveBookmark":
      guard
        let bookmarkDataBase64 = arguments["bookmarkDataBase64"] as? String
      else {
        result(invalidArgumentsError("bookmarkDataBase64 is required."))
        return
      }
      result(bookmarkService.resolveBookmark(
        base64: bookmarkDataBase64
      ).channelPayload)
    case "availableCapacityForImportantUsage":
      guard let directoryPath = arguments["directoryPath"] as? String else {
        result(invalidArgumentsError("directoryPath is required."))
        return
      }
      do {
        result(try bookmarkService.availableCapacityForImportantUsage(
          directoryPath: directoryPath
        ))
      } catch {
        result(
          FlutterError(
            code: "capacity_lookup_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func installObservers() {
    guard observers.isEmpty else {
      return
    }
    let workspaceCenter = NSWorkspace.shared.notificationCenter
    observe(
      center: workspaceCenter,
      name: NSWorkspace.didMountNotification,
      event: "volume_mounted"
    )
    observe(
      center: workspaceCenter,
      name: NSWorkspace.didUnmountNotification,
      event: "volume_unmounted"
    )
    observe(
      center: workspaceCenter,
      name: NSWorkspace.didRenameVolumeNotification,
      event: "volume_renamed"
    )
    observe(
      center: NotificationCenter.default,
      name: NSApplication.didBecomeActiveNotification,
      event: "application_activated"
    )
  }

  private func observe(
    center: NotificationCenter,
    name: Notification.Name,
    event: String
  ) {
    let observer = center.addObserver(
      forName: name,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.eventSink?(event)
    }
    observers.append((center, observer))
  }

  private func removeObservers() {
    for (center, observer) in observers {
      center.removeObserver(observer)
    }
    observers.removeAll()
  }

  private func invalidArgumentsError(_ message: String) -> FlutterError {
    return FlutterError(
      code: "invalid_arguments",
      message: message,
      details: nil
    )
  }
}
