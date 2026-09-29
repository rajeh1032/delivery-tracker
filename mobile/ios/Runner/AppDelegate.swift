import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let apiKey = loadGoogleMapsApiKey(), !apiKey.isEmpty {
      GMSServices.provideAPIKey(apiKey)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  private func loadGoogleMapsApiKey() -> String? {
    if let envKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"], !envKey.isEmpty {
      return envKey
    }
    let bundle = Bundle.main
    let candidatePaths = [
      bundle.path(forResource: ".env", ofType: nil, inDirectory: "Frameworks/App.framework/flutter_assets"),
      bundle.path(forResource: ".env", ofType: nil, inDirectory: "flutter_assets"),
      bundle.path(forResource: ".env", ofType: nil)
    ]
    for path in candidatePaths.compactMap({ $0 }) {
      if let content = try? String(contentsOfFile: path, encoding: .utf8) {
        for line in content.components(separatedBy: .newlines) {
          let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
          if trimmed.starts(with: "GOOGLE_MAPS_API_KEY=") {
            let key = String(trimmed.dropFirst("GOOGLE_MAPS_API_KEY=".count))
              .trimmingCharacters(in: CharacterSet(charactersIn: "\"\'"))
            if !key.isEmpty { return key }
          }
        }
      }
    }
    return nil
  }
}
