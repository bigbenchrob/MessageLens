// See note in LinkPreviewPlugin.swift regarding SourceKit environments that
// lack the FlutterMacOS framework search paths.
#if canImport(FlutterMacOS)

  import Cocoa
  import FlutterMacOS
  import LinkPresentation

  @main
  class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
      return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
      return true
    }

    override func applicationDidFinishLaunching(_ notification: Notification) {
      // Register the LinkPreviewPlugin
      let controller =
        NSApplication.shared.windows.first?.contentViewController as! FlutterViewController
      let channel = FlutterMethodChannel(
        name: "com.remember_this_text/link_preview",
        binaryMessenger: controller.engine.binaryMessenger
      )

      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        self.handleMethodCall(call, result: result)
      }
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
