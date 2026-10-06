import Cocoa
import Darwin
import FlutterMacOS
import Security

enum MessageLensArchiveEnvironment: String {
  case production
  case development
  case test
}

enum MessageLensArchiveBuildIdentity: String {
  case developmentDebug
  case developmentProfile
  case developmentRelease
  case fdaExperiment
  case productionRelease
  case testHarness

  var environment: MessageLensArchiveEnvironment {
    switch self {
    case .developmentDebug, .developmentProfile, .developmentRelease,
         .fdaExperiment:
      return .development
    case .productionRelease:
      return .production
    case .testHarness:
      return .test
    }
  }
}

struct MessageLensNativeArchiveClaim {
  let environment: MessageLensArchiveEnvironment
  let buildIdentity: MessageLensArchiveBuildIdentity
  let bundleIdentifier: String
  let productName: String
  let canonicalRootURL: URL
  let productionSignatureIsValid: Bool

  var channelPayload: [String: Any] {
    return [
      "environment": environment.rawValue,
      "buildIdentity": buildIdentity.rawValue,
      "bundleIdentifier": bundleIdentifier,
      "productName": productName,
      "canonicalRootPath": canonicalRootURL.path,
      "productionSignatureIsValid": productionSignatureIsValid,
    ]
  }
}

enum MessageLensNativeArchiveClaimError: Error, Equatable {
  case missingConfiguration(String)
  case invalidEnvironment(String)
  case invalidBuildIdentity(String)
  case buildEnvironmentMismatch
  case applicationIdentityMismatch
  case invalidProductionSignature
  case developmentRootOverrideNotPermitted
  case invalidDevelopmentRootOverride(String)
  case unavailableDevelopmentRootOverride(String)
}

extension MessageLensNativeArchiveClaimError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .missingConfiguration(let key):
      return "Required archive configuration is missing: \(key)."
    case .invalidEnvironment(let value):
      return "The archive environment is invalid: \(value)."
    case .invalidBuildIdentity(let value):
      return "The archive build identity is invalid: \(value)."
    case .buildEnvironmentMismatch:
      return "The build identity and archive environment do not agree."
    case .applicationIdentityMismatch:
      return "The application identity is not valid for this archive environment."
    case .invalidProductionSignature:
      return "The production archive requires the approved production signature."
    case .developmentRootOverrideNotPermitted:
      return "The development archive-root override cannot be used by this build."
    case .invalidDevelopmentRootOverride(let value):
      return "The development archive-root override is not an absolute path: \(value)"
    case .unavailableDevelopmentRootOverride(let value):
      return "The configured development archive root is unavailable or not writable: \(value)"
    }
  }
}

enum MessageLensArchiveStartupFailurePresenter {
  static func present(message: String) {
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = "MessageLens could not open its archive"
    alert.informativeText = message
    alert.addButton(withTitle: "Quit")
    alert.runModal()
  }
}

final class MessageLensCodeSignatureValidator {
  func hasCertificate(subjectSummary expectedSubjectSummary: String) -> Bool {
    var staticCode: SecStaticCode?
    guard SecStaticCodeCreateWithPath(
      Bundle.main.bundleURL as CFURL,
      [],
      &staticCode
    ) == errSecSuccess,
          let staticCode
    else {
      return false
    }

    var signingInformation: CFDictionary?
    let flags = SecCSFlags(rawValue: kSecCSSigningInformation)
    guard SecCodeCopySigningInformation(
      staticCode,
      flags,
      &signingInformation
    ) == errSecSuccess,
      let information = signingInformation as? [String: Any],
      let certificates = information[kSecCodeInfoCertificates as String]
        as? [SecCertificate]
    else {
      return false
    }

    return certificates.contains { certificate in
      SecCertificateCopySubjectSummary(certificate) as String?
        == expectedSubjectSummary
    }
  }
}

final class MessageLensNativeArchiveClaimResolver {
  private let bundleInfo: [String: Any]
  private let bundleIdentifier: String?
  private let applicationSupportURL: URL
  private let processEnvironment: [String: String]
  private let signatureValidator: (String) -> Bool

  init(
    bundleInfo: [String: Any] = Bundle.main.infoDictionary ?? [:],
    bundleIdentifier: String? = Bundle.main.bundleIdentifier,
    applicationSupportURL: URL? = nil,
    processEnvironment: [String: String] = ProcessInfo.processInfo.environment,
    signatureValidator: ((String) -> Bool)? = nil
  ) {
    self.bundleInfo = bundleInfo
    self.bundleIdentifier = bundleIdentifier
    self.applicationSupportURL = applicationSupportURL
      ?? FileManager.default.urls(
        for: .applicationSupportDirectory,
        in: .userDomainMask
      ).first!
    self.processEnvironment = processEnvironment
    self.signatureValidator = signatureValidator
      ?? MessageLensCodeSignatureValidator().hasCertificate
  }

  func resolve() throws -> MessageLensNativeArchiveClaim {
    let environmentValue = try requiredInfoValue(
      named: "MessageLensArchiveEnvironment"
    )
    guard let environment = MessageLensArchiveEnvironment(
      rawValue: environmentValue
    ) else {
      throw MessageLensNativeArchiveClaimError.invalidEnvironment(
        environmentValue
      )
    }

    let buildIdentityValue = try requiredInfoValue(
      named: "MessageLensArchiveBuildIdentity"
    )
    guard let buildIdentity = MessageLensArchiveBuildIdentity(
      rawValue: buildIdentityValue
    ) else {
      throw MessageLensNativeArchiveClaimError.invalidBuildIdentity(
        buildIdentityValue
      )
    }
    guard buildIdentity.environment == environment else {
      throw MessageLensNativeArchiveClaimError.buildEnvironmentMismatch
    }

    let bundleIdentifier = try requiredBundleIdentifier()
    let productName = try requiredInfoValue(named: "CFBundleDisplayName")
    let expectedIdentity = Self.expectedApplicationIdentity(
      for: buildIdentity
    )
    guard bundleIdentifier == expectedIdentity.bundleIdentifier,
          productName == expectedIdentity.productName
    else {
      throw MessageLensNativeArchiveClaimError.applicationIdentityMismatch
    }

    let expectedSigningIdentity = bundleInfo[
      "MessageLensExpectedSigningIdentity"
    ] as? String ?? ""
    let productionSignatureIsValid =
      environment != .production
      || (!expectedSigningIdentity.isEmpty
        && signatureValidator(expectedSigningIdentity))
    guard productionSignatureIsValid else {
      throw MessageLensNativeArchiveClaimError.invalidProductionSignature
    }

    let canonicalRootURL = try resolveCanonicalRoot(
      for: environment,
      buildIdentity: buildIdentity,
      bundleIdentifier: bundleIdentifier
    )

    return MessageLensNativeArchiveClaim(
      environment: environment,
      buildIdentity: buildIdentity,
      bundleIdentifier: bundleIdentifier,
      productName: productName,
      canonicalRootURL: canonicalRootURL,
      productionSignatureIsValid: productionSignatureIsValid
    )
  }

  private func resolveCanonicalRoot(
    for environment: MessageLensArchiveEnvironment,
    buildIdentity: MessageLensArchiveBuildIdentity,
    bundleIdentifier: String
  ) throws -> URL {
    let variableName = "MESSAGELENS_DEVELOPMENT_ARCHIVE_ROOT"
    let configuredValue = processEnvironment[variableName]?
      .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

    guard !configuredValue.isEmpty else {
      if buildIdentity == .fdaExperiment {
        throw MessageLensNativeArchiveClaimError.missingConfiguration(
          variableName
        )
      }
      return applicationSupportURL.appendingPathComponent(
        bundleIdentifier,
        isDirectory: true
      )
    }

    guard environment == .development else {
      throw MessageLensNativeArchiveClaimError
        .developmentRootOverrideNotPermitted
    }
    guard (configuredValue as NSString).isAbsolutePath else {
      throw MessageLensNativeArchiveClaimError
        .invalidDevelopmentRootOverride(configuredValue)
    }

    let configuredURL = URL(
      fileURLWithPath: configuredValue,
      isDirectory: true
    ).standardizedFileURL
    var isDirectory: ObjCBool = false
    guard FileManager.default.fileExists(
      atPath: configuredURL.path,
      isDirectory: &isDirectory
    ),
      isDirectory.boolValue,
      FileManager.default.isWritableFile(atPath: configuredURL.path)
    else {
      throw MessageLensNativeArchiveClaimError
        .unavailableDevelopmentRootOverride(configuredValue)
    }

    let canonicalPath = configuredURL.path.withCString { pathPointer in
      guard let resolvedPathPointer = Darwin.realpath(pathPointer, nil) else {
        return nil as String?
      }
      defer { Darwin.free(resolvedPathPointer) }
      return String(cString: resolvedPathPointer)
    }
    guard let canonicalPath else {
      throw MessageLensNativeArchiveClaimError
        .unavailableDevelopmentRootOverride(configuredValue)
    }

    // Keep the POSIX realpath spelling. Foundation's URL symlink resolution
    // rewrites macOS's /private/tmp result back to /tmp, while Dart's
    // resolveSymbolicLinksSync() retains the filesystem-canonical spelling.
    return URL(fileURLWithPath: canonicalPath, isDirectory: true)
  }

  private func requiredInfoValue(named key: String) throws -> String {
    guard let value = bundleInfo[key] as? String, !value.isEmpty else {
      throw MessageLensNativeArchiveClaimError.missingConfiguration(key)
    }
    return value
  }

  private func requiredBundleIdentifier() throws -> String {
    guard let bundleIdentifier, !bundleIdentifier.isEmpty else {
      throw MessageLensNativeArchiveClaimError.missingConfiguration(
        "CFBundleIdentifier"
      )
    }
    return bundleIdentifier
  }

  private static func expectedApplicationIdentity(
    for buildIdentity: MessageLensArchiveBuildIdentity
  ) -> (bundleIdentifier: String, productName: String) {
    switch buildIdentity {
    case .productionRelease:
      return ("com.bigbenchsoftware.MessageLens", "MessageLens")
    case .developmentDebug, .developmentProfile, .developmentRelease:
      return (
        "com.bigbenchsoftware.MessageLens.development",
        "MessageLens Development"
      )
    case .fdaExperiment:
      return (
        "com.bigbenchsoftware.MessageLens.fdaexperiment",
        "MessageLens FDA Experiment"
      )
    case .testHarness:
      return (
        "com.bigbenchsoftware.MessageLens.tests",
        "MessageLens Tests"
      )
    }
  }
}

final class MessageLensProcessLock {
  private var descriptor: Int32 = -1

  deinit {
    release()
  }

  func acquire(at lockURL: URL) -> Bool {
    if descriptor >= 0 {
      return true
    }

    do {
      try FileManager.default.createDirectory(
        at: lockURL.deletingLastPathComponent(),
        withIntermediateDirectories: true
      )
    } catch {
      NSLog("MessageLens could not create its instance-lock directory: \(error)")
      return false
    }

    let openedDescriptor = Darwin.open(
      lockURL.path,
      O_CREAT | O_RDWR,
      S_IRUSR | S_IWUSR
    )
    guard openedDescriptor >= 0 else {
      NSLog("MessageLens could not open its instance lock at \(lockURL.path)")
      return false
    }

    guard flock(openedDescriptor, LOCK_EX | LOCK_NB) == 0 else {
      Darwin.close(openedDescriptor)
      return false
    }

    descriptor = openedDescriptor
    return true
  }

  func release() {
    guard descriptor >= 0 else {
      return
    }

    flock(descriptor, LOCK_UN)
    Darwin.close(descriptor)
    descriptor = -1
  }
}

enum MessageLensInstanceClaim {
  case primary
  case duplicate(existingApplication: NSRunningApplication?)
}

final class MessageLensSingleInstanceAuthority {
  private let processLock: MessageLensProcessLock
  private let lockURL: URL
  private let runningApplications: () -> [NSRunningApplication]

  init(
    processLock: MessageLensProcessLock = MessageLensProcessLock(),
    lockURL: URL,
    runningApplications: (() -> [NSRunningApplication])? = nil
  ) {
    self.processLock = processLock
    self.lockURL = lockURL
    self.runningApplications = runningApplications ?? {
      guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return []
      }

      return NSRunningApplication.runningApplications(
        withBundleIdentifier: bundleIdentifier
      )
    }
  }

  func claim() -> MessageLensInstanceClaim {
    if let earlierApplication = earlierRunningApplication() {
      return .duplicate(existingApplication: earlierApplication)
    }

    guard processLock.acquire(at: lockURL) else {
      return .duplicate(existingApplication: otherRunningApplication())
    }

    return .primary
  }

  private func earlierRunningApplication() -> NSRunningApplication? {
    let current = NSRunningApplication.current
    return matchingRunningApplications()
      .filter { application in
        guard application.processIdentifier != current.processIdentifier else {
          return false
        }

        let applicationLaunchDate = application.launchDate ?? .distantPast
        let currentLaunchDate = current.launchDate ?? .distantFuture
        if applicationLaunchDate != currentLaunchDate {
          return applicationLaunchDate < currentLaunchDate
        }

        return application.processIdentifier < current.processIdentifier
      }
      .min { lhs, rhs in
        let lhsLaunchDate = lhs.launchDate ?? .distantPast
        let rhsLaunchDate = rhs.launchDate ?? .distantPast
        if lhsLaunchDate != rhsLaunchDate {
          return lhsLaunchDate < rhsLaunchDate
        }
        return lhs.processIdentifier < rhs.processIdentifier
      }
  }

  private func otherRunningApplication() -> NSRunningApplication? {
    let currentProcessIdentifier = NSRunningApplication.current.processIdentifier
    return matchingRunningApplications().first { application in
      application.processIdentifier != currentProcessIdentifier
    }
  }

  private func matchingRunningApplications() -> [NSRunningApplication] {
    runningApplications()
  }
}

class MainFlutterWindow: NSWindow {
  private static var instanceAuthority: MessageLensSingleInstanceAuthority?
  private static var nativeArchiveClaim: MessageLensNativeArchiveClaim?

  override func awakeFromNib() {
    let nativeArchiveClaim: MessageLensNativeArchiveClaim
    do {
      nativeArchiveClaim = try MessageLensNativeArchiveClaimResolver().resolve()
    } catch {
      NSLog("MessageLens archive identity admission failed: \(error)")
      super.awakeFromNib()
      orderOut(nil)
      DispatchQueue.main.async {
        MessageLensArchiveStartupFailurePresenter.present(
          message: error.localizedDescription
        )
        NSApplication.shared.terminate(nil)
      }
      return
    }

    let lockURL = nativeArchiveClaim.canonicalRootURL
      .appendingPathComponent("MessageLens.instance.lock")
    let instanceAuthority = MessageLensSingleInstanceAuthority(lockURL: lockURL)
    switch instanceAuthority.claim() {
    case .duplicate(let existingApplication):
      super.awakeFromNib()
      orderOut(nil)
      existingApplication?.activate(options: [.activateAllWindows])
      DispatchQueue.main.async {
        NSApplication.shared.terminate(nil)
      }
      return
    case .primary:
      Self.instanceAuthority = instanceAuthority
      Self.nativeArchiveClaim = nativeArchiveClaim
    }

    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let archiveIdentityChannel = FlutterMethodChannel(
      name: "com.bigbenchsoftware.MessageLens/archive_identity",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    archiveIdentityChannel.setMethodCallHandler { call, result in
      if call.method == "showArchiveAdmissionFailure" {
        let arguments = call.arguments as? [String: Any]
        let message = arguments?["message"] as? String
          ?? "Native and Dart archive admission did not agree."
        result(nil)
        DispatchQueue.main.async {
          MessageLensArchiveStartupFailurePresenter.present(message: message)
          NSApplication.shared.terminate(nil)
        }
        return
      }
      guard call.method == "getNativeArchiveClaim" else {
        result(FlutterMethodNotImplemented)
        return
      }
      guard let claim = Self.nativeArchiveClaim else {
        result(
          FlutterError(
            code: "archive_claim_unavailable",
            message: "Native archive claim is unavailable.",
            details: nil
          )
        )
        return
      }
      result(claim.channelPayload)
    }

    super.awakeFromNib()
  }
}
