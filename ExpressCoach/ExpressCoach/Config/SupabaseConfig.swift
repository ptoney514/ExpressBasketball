import Foundation
import Supabase

enum SupabaseConfig {
    // Remote Supabase instance
    static let url = URL(string: "https://scpluslhcastrobigkfb.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q"
    
    // Local Supabase instance (for development)
    // static let url = URL(string: "http://127.0.0.1:54321")!
    // static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey
    )
}