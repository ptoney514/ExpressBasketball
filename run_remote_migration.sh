#!/bin/bash

# Express Basketball Remote Database Setup Script
# This script deploys the database schema to the remote Supabase project

echo "🏀 Express Basketball - Remote Database Setup"
echo "============================================"

# Configuration - using the linked Supabase project
PROJECT_REF="scpluslhcastrobigkfb"
MIGRATION_FILE="supabase/migrations/20250928225454_express_basketball_tables.sql"

echo ""
echo "📊 Database Connection Info:"
echo "   Project Ref: $PROJECT_REF"
echo "   Migration: $MIGRATION_FILE"
echo ""

# Check if migration file exists
if [ ! -f "$MIGRATION_FILE" ]; then
    echo "❌ Migration file not found: $MIGRATION_FILE"
    exit 1
fi

echo "⚡ Running migration on remote database..."
echo ""

# Use Supabase CLI to run the migration directly
# The --db-url flag uses the linked project's connection
cat "$MIGRATION_FILE" | supabase db query --project-ref "$PROJECT_REF"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Migration completed successfully!"
    echo ""
    echo "📝 Verifying tables were created..."
    supabase db query --project-ref "$PROJECT_REF" "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('teams', 'players', 'schedules', 'events', 'announcements');"
    
    echo ""
    echo "📋 Next steps:"
    echo "   1. Update Configuration.swift with production credentials"
    echo "   2. Test the connection from the iOS apps"
    echo "   3. Verify data sync between apps"
else
    echo ""
    echo "❌ Migration failed. Please check the error messages above."
    exit 1
fi