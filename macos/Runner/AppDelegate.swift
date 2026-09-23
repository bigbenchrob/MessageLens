// See note in LinkPreviewPlugin.swift regarding SourceKit environments that
// lack the FlutterMacOS framework search paths.
#if canImport(FlutterMacOS)

  import Cocoa
  import FlutterMacOS
  import LinkPresentation
  import OSLog

  @main
  class AppDelegate: FlutterAppDelegate {
    private let unifiedLogger = Logger(
      subsystem: Bundle.main.bundleIdentifier ?? "com.bigbenchsoftware.MessageLens",
      category: "AppLogger"
    )
    private var optionLaunchResetRequested = false
    private var attachmentArchiveLocationBridge: AttachmentArchiveLocationBridge?

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }

    override func applicationWillFinishLaunching(_ notification: Notification) {
      optionLaunchResetRequested = CGEventSource.flagsState(.combinedSessionState).contains(
        .maskAlternate
      )
      super.applicationWillFinishLaunching(notification)
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
      // Register the LinkPreviewPlugin
      guard
        let controller =
          NSApplication.shared.windows.first?.contentViewController as? FlutterViewController
      else {
        // Native archive admission and duplicate-instance handling may
        // intentionally terminate before a Flutter controller is installed.
        return
      }
      let messenger = controller.engine.binaryMessenger

      attachmentArchiveLocationBridge = AttachmentArchiveLocationBridge(
        messenger: messenger
      )

      let linkChannel = FlutterMethodChannel(
        name: "com.remember_this_text/link_preview",
        binaryMessenger: messenger
      )
      linkChannel.setMethodCallHandler {
        (call: FlutterMethodCall, result: @escaping FlutterResult) in
        self.handleMethodCall(call, result: result)
      }

      let unifiedLogChannel = FlutterMethodChannel(
        name: "com.remember_this_text/unified_log",
        binaryMessenger: messenger
      )
      unifiedLogChannel.setMethodCallHandler {
        (call: FlutterMethodCall, result: @escaping FlutterResult) in
        self.handleUnifiedLogMethodCall(call, result: result)
      }

      let startupChannel = FlutterMethodChannel(
        name: "com.bigbenchsoftware.messagelens/startup",
        binaryMessenger: messenger
      )
      startupChannel.setMethodCallHandler {
        (call: FlutterMethodCall, result: @escaping FlutterResult) in
        self.handleStartupMethodCall(call, result: result)
      }

    }

    private func handleStartupMethodCall(
      _ call: FlutterMethodCall,
      result: @escaping FlutterResult
    ) {
      guard call.method == "getStartupFlags" else {
        result(FlutterMethodNotImplemented)
        return
      }

      result([
        "optionLaunchResetRequested": optionLaunchResetRequested
      ])
    }

    private func handleUnifiedLogMethodCall(
      _ call: FlutterMethodCall,
      result: @escaping FlutterResult
    ) {
      guard call.method == "log" else {
        result(FlutterMethodNotImplemented)
        return
      }

      guard let args = call.arguments as? [String: Any],
        let level = args["level"] as? String,
        let message = args["message"] as? String
      else {
        result(
          FlutterError(
            code: "INVALID_ARGUMENT",
            message: "level and message are required",
            details: nil
          ))
        return
      }

      let source = args["source"] as? String
      let renderedMessage: String
      if let source, !source.isEmpty {
        renderedMessage = "[\(source)] \(message)"
      } else {
        renderedMessage = message
      }

      switch level {
      case "error":
        unifiedLogger.error("\(renderedMessage, privacy: .public)")
      case "warn":
        unifiedLogger.warning("\(renderedMessage, privacy: .public)")
      default:
        unifiedLogger.info("\(renderedMessage, privacy: .public)")
      }

      result(nil)
    }

    private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
      switch call.method {
      case "fetchMetadata":
        guard let args = call.arguments as? [String: Any],
          let urlString = args["url"] as? String,
          let url = URL(string: urlString)
        else {
          result(
            FlutterError(
              code: "INVALID_ARGUMENT",
              message: "URL parameter is required",
              details: nil
            ))
          return
        }

        fetchMetadata(for: url, result: result)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    private func fetchMetadata(for url: URL, result: @escaping FlutterResult) {
      let provider = LPMetadataProvider()

      // Set timeout (LinkPresentation default is 30s, we'll use 10s to match our fallback)
      provider.timeout = 10.0

      provider.startFetchingMetadata(for: url) { metadata, error in
        DispatchQueue.main.async {
          if let error = error {
            result(
              FlutterError(
                code: "FETCH_FAILED",
                message: error.localizedDescription,
                details: nil
              ))
            return
          }

          guard let metadata = metadata else {
            result(
              FlutterError(
                code: "NO_METADATA",
                message: "No metadata returned",
                details: nil
              ))
            return
          }

          // Convert metadata to dictionary
          var dict: [String: Any?] = [
            "title": metadata.title,
            "url": metadata.url?.absoluteString ?? metadata.originalURL?.absoluteString,
          ]

          // Extract image if available
          if let imageProvider = metadata.imageProvider {
            // We'll convert to base64 for transport
            self.extractImage(from: imageProvider) { imageData in
              dict["imageData"] = imageData
              dict["iconData"] = nil  // Separate icon if needed

              // Clean up nil values
              let cleanDict = dict.compactMapValues { $0 }
              result(cleanDict)
            }
          } else if let iconProvider = metadata.iconProvider {
            // Fallback to icon if no image
            self.extractImage(from: iconProvider) { imageData in
              dict["imageData"] = nil
              dict["iconData"] = imageData

              let cleanDict = dict.compactMapValues { $0 }
              result(cleanDict)
            }
          } else {
            // No image at all
            let cleanDict = dict.compactMapValues { $0 }
            result(cleanDict)
          }
        }
      }
    }

    private func extractImage(
      from provider: NSItemProvider, completion: @escaping (String?) -> Void
    ) {
      // Try to load as NSImage
      if provider.canLoadObject(ofClass: NSImage.self) {
        provider.loadObject(ofClass: NSImage.self) { image, error in
          guard let nsImage = image as? NSImage,
            let tiffData = nsImage.tiffRepresentation,
            let bitmapImage = NSBitmapImageRep(data: tiffData),
            let pngData = bitmapImage.representation(using: .png, properties: [:])
          else {
            completion(nil)
            return
          }

          let base64String = pngData.base64EncodedString()
          completion(base64String)
        }
      } else {
        completion(nil)
      }
    }
  }

#endif
