#!/bin/bash

# Test Push Notification Script for ExpressBasketball
# This script sends a test push notification via Supabase Edge Function

# Configuration
PROJECT_REF="scpluslhcastrobigkfb"
FUNCTION_NAME="send-push-notification"
SUPABASE_URL="https://${PROJECT_REF}.supabase.co"
EDGE_FUNCTION_URL="${SUPABASE_URL}/functions/v1/${FUNCTION_NAME}"

# Get Supabase anon key (you'll need to provide this)
echo "========================================="
echo "📱 ExpressBasketball Push Notification Test"
echo "========================================="
echo ""

# Check if device token is provided
if [ -z "$1" ]; then
    echo "❌ Error: Device token required"
    echo ""
    echo "Usage: ./test-push-notification.sh <device-token> [supabase-anon-key]"
    echo ""
    echo "Get your device token from:"
    echo "  1. Run ExpressUnited on a physical iPhone"
    echo "  2. Go to Settings → Developer Tools → Notification Testing"
    echo "  3. Copy the 'Device Token' value"
    echo ""
    echo "Get your Supabase anon key from:"
    echo "  https://supabase.com/dashboard/project/${PROJECT_REF}/settings/api"
    echo ""
    exit 1
fi

DEVICE_TOKEN="$1"
SUPABASE_ANON_KEY="${2:-}"

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: Supabase anon key required"
    echo ""
    echo "Usage: ./test-push-notification.sh <device-token> <supabase-anon-key>"
    echo ""
    echo "Get your anon key from:"
    echo "  https://supabase.com/dashboard/project/${PROJECT_REF}/settings/api"
    echo ""
    exit 1
fi

echo "Device Token: ${DEVICE_TOKEN:0:20}..."
echo "Sending to: $EDGE_FUNCTION_URL"
echo ""

# Test 1: Basic Game Reminder
echo "📤 Test 1: Sending Game Reminder..."
RESPONSE=$(curl -s -X POST "$EDGE_FUNCTION_URL" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"deviceTokens\": [\"$DEVICE_TOKEN\"],
    \"title\": \"Game Reminder\",
    \"body\": \"Game vs Warriors starts in 2 hours at Main Gym\",
    \"type\": \"game_reminder\",
    \"badge\": 1,
    \"sound\": \"default\"
  }")

echo "Response: $RESPONSE"
echo ""

# Wait a bit
sleep 2

# Test 2: Urgent Announcement
echo "📤 Test 2: Sending Urgent Announcement..."
RESPONSE=$(curl -s -X POST "$EDGE_FUNCTION_URL" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"deviceTokens\": [\"$DEVICE_TOKEN\"],
    \"title\": \"Important Team Update\",
    \"body\": \"Practice has been moved to Saturday at 3pm\",
    \"type\": \"announcement\",
    \"badge\": 2,
    \"sound\": \"default\"
  }")

echo "Response: $RESPONSE"
echo ""

# Wait a bit
sleep 2

# Test 3: Schedule Change
echo "📤 Test 3: Sending Schedule Change..."
RESPONSE=$(curl -s -X POST "$EDGE_FUNCTION_URL" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d "{
    \"deviceTokens\": [\"$DEVICE_TOKEN\"],
    \"title\": \"Schedule Change\",
    \"body\": \"Tomorrow's game has been moved to 6pm\",
    \"type\": \"schedule_change\",
    \"badge\": 3,
    \"sound\": \"default\",
    \"data\": {
      \"scheduleId\": \"test-123\"
    }
  }")

echo "Response: $RESPONSE"
echo ""

echo "========================================="
echo "✅ Test complete!"
echo ""
echo "Check your iPhone for notifications"
echo "========================================="
