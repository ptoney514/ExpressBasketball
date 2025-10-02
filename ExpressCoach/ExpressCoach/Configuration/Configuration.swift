//
//  Configuration.swift
//  ExpressCoach
//
//  Environment configuration for Supabase and other services
//

import Foundation

enum AppEnvironment {
    case development
    case staging
    case production
    
    static var current: AppEnvironment {
        #if DEBUG
        // For debug builds, check if we want to test against production
        if ProcessInfo.processInfo.environment["USE_PRODUCTION"] == "true" {
            return .production
        }
        return .development
        #else
        // Release builds always use production
        return .production
        #endif
    }
    
    var supabaseURL: URL {
        switch self {
        case .development:
            return URL(string: "http://127.0.0.1:54321")!
        case .staging:
            // TODO: Add your staging URL when available
            return URL(string: "https://staging-project.supabase.co")!
        case .production:
            // Express Basketball Production Supabase URL
            return URL(string: "https://scpluslhcastrobigkfb.supabase.co")!
        }
    }
    
    var supabaseAnonKey: String {
        switch self {
        case .development:
            // Local development anon key
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
        case .staging:
            // TODO: Add your staging anon key
            return "your-staging-anon-key"
        case .production:
            // Express Basketball Production anon key (public key - safe to include)
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q"
        }
    }
    
    var deepLinkScheme: String {
        switch self {
        case .development:
            return "expresscoach-dev"
        case .staging:
            return "expresscoach-staging"
        case .production:
            return "expresscoach"
        }
    }
    
    var pushNotificationServerURL: URL? {
        switch self {
        case .development:
            // Local push notification server for testing
            return URL(string: "http://localhost:3000")
        case .staging:
            // TODO: Add your staging push server URL
            return nil
        case .production:
            // TODO: Add your production push server URL
            return nil
        }
    }
    
    var isDebugMode: Bool {
        switch self {
        case .development, .staging:
            return true
        case .production:
            return false
        }
    }
    
    var logLevel: LogLevel {
        switch self {
        case .development:
            return .verbose
        case .staging:
            return .debug
        case .production:
            return .warning
        }
    }
}

enum LogLevel: Int {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    
    var emoji: String {
        switch self {
        case .verbose: return "🔍"
        case .debug: return "🐛"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

// MARK: - Configuration Manager
class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    let environment: AppEnvironment
    
    private init() {
        self.environment = AppEnvironment.current
        
        #if DEBUG
        print("🚀 ExpressCoach Configuration")
        print("📍 Environment: \(environment)")
        print("🔗 Supabase URL: \(environment.supabaseURL)")
        print("🔑 Deep Link Scheme: \(environment.deepLinkScheme)")
        print("📊 Log Level: \(environment.logLevel)")
        #endif
    }
    
    // Helper to log based on environment
    func log(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        guard level.rawValue >= environment.logLevel.rawValue else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        print("\(timestamp) \(level.emoji) [\(fileName):\(line)] \(function) - \(message)")
    }
}

// MARK: - Environment File Loader
// This allows loading secrets from a .env file that's not checked into git
struct EnvironmentFileLoader {
    static func loadIfExists() {
        #if DEBUG
        // Only attempt to load .env file in debug builds
        let fileManager = FileManager.default
        
        guard let projectPath = ProcessInfo.processInfo.environment["PROJECT_DIR"] else {
            return
        }
        
        let envPath = "\(projectPath)/.env.local"
        
        guard fileManager.fileExists(atPath: envPath),
              let envContent = try? String(contentsOfFile: envPath, encoding: .utf8) else {
            return
        }
        
        // Parse .env file
        let lines = envContent.components(separatedBy: .newlines)
        for line in lines {
            let parts = line.components(separatedBy: "=")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                setenv(key, value, 1)
            }
        }
        
        print("✅ Loaded environment variables from .env.local")
        #endif
    }
}

// MARK: - Convenience Extensions
extension ConfigurationManager {
    var supabaseURL: URL {
        environment.supabaseURL
    }
    
    var supabaseAnonKey: String {
        environment.supabaseAnonKey
    }
    
    var deepLinkURL: URL {
        URL(string: "\(environment.deepLinkScheme)://")!
    }
    
    var magicLinkRedirectURL: URL {
        URL(string: "\(environment.deepLinkScheme)://login-callback")!
    }
}