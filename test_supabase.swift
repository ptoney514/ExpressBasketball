#!/usr/bin/env swift

import Foundation

// Test Supabase connection
let url = URL(string: "http://127.0.0.1:54321/rest/v1/teams")!
let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

var request = URLRequest(url: url)
request.setValue(anonKey, forHTTPHeaderField: "apikey")
request.setValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")

let semaphore = DispatchSemaphore(value: 0)

URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
        print("Error: \(error)")
    } else if let data = data {
        print("Raw response: \(String(data: data, encoding: .utf8) ?? "Unable to decode")")

        // Try to decode
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                print("\nDecoded \(json.count) teams:")
                for team in json {
                    if let name = team["name"], let code = team["team_code"] {
                        print("  - \(name) (\(code))")
                    }
                }
            }
        } catch {
            print("Decode error: \(error)")
        }
    }
    semaphore.signal()
}.resume()

semaphore.wait()