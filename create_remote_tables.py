#!/usr/bin/env python3

import requests
import json

# Supabase credentials
url = "https://scpluslhcastrobigkfb.supabase.co"
anon_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMzNjE4OTEsImV4cCI6MjA2ODkzNzg5MX0.rJEXZH-Bnnc-B09ysG6c9Irjmvbol0UGjmU5vWiAG0Q"
service_role_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNjcGx1c2xoY2FzdHJvYmlna2ZiIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MzM2MTg5MSwiZXhwIjoyMDY4OTM3ODkxfQ.tIMxf5Nc7QwDNDd8kB3LTrlqRhyqhI6v40BPrRc2YvI"

headers = {
    "apikey": service_role_key,
    "Authorization": f"Bearer {service_role_key}",
    "Content-Type": "application/json"
}

# First, let's test if teams table exists
test_url = f"{url}/rest/v1/teams"
response = requests.get(test_url, headers=headers)

if response.status_code == 404 or "relation" in response.text:
    print("Teams table doesn't exist. Creating tables...")
    
    # Create the tables using RPC function
    # Note: We need to use the SQL editor endpoint which might not be available via API
    # Let's try creating via REST API with proper schema
    
    print("Tables need to be created via Supabase Dashboard SQL editor")
    print("Please go to: https://supabase.com/dashboard/project/scpluslhcastrobigkfb/sql/new")
    print("And run the SQL from: supabase/migrations/20250928225454_express_basketball_tables.sql")
else:
    print(f"Teams table exists! Response: {response.status_code}")
    teams = response.json()
    print(f"Found {len(teams)} teams")
    
    if len(teams) == 0:
        # Insert demo data
        demo_team = {
            "name": "Thunder Elite",
            "team_code": "THDR01",
            "organization": "Express Basketball Club",
            "age_group": "14U",
            "season": "2024-2025",
            "primary_color": "#007AFF",
            "secondary_color": "#FF3B30"
        }
        
        insert_response = requests.post(test_url, headers=headers, json=demo_team)
        if insert_response.status_code == 201:
            print("Demo team created successfully!")
        else:
            print(f"Error creating team: {insert_response.text}")