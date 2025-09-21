# Technical Debt Register - Express Basketball

## Last Updated: 2025-09-20

This document tracks technical compromises, shortcuts taken, and future improvements needed across the Express Basketball workspace.

---

## High Priority (Address Soon) 🔴

### 1. No Error Handling Implementation
- **Issue**: Both apps lack proper error handling throughout views and services
- **Impact**: App crashes on unexpected inputs, poor user experience
- **Solution**: Implement comprehensive error boundaries and user-friendly error messages
- **Estimate**: 2-3 days
- **Affected**: ExpressCoach, ExpressUnited

### 2. Missing Unit Tests
- **Issue**: No test coverage for SwiftData models, views, or business logic
- **Impact**: Cannot verify functionality, risky deployments, regression potential
- **Solution**: Add XCTest unit tests for models, integration tests for views
- **Estimate**: 1 week
- **Affected**: Both apps

### 3. Bundle Identifier Placeholders
- **Issue**: Using `com.yourcompany.ExpressCoach` and `com.yourcompany.ExpressUnited`
- **Impact**: Cannot deploy to TestFlight or App Store
- **Solution**: Register proper bundle IDs in Apple Developer account
- **Estimate**: 30 minutes
- **Affected**: Both apps

---

## Medium Priority 🟡

### 4. Supabase Service Layer Not Abstracted
- **Issue**: Direct Supabase calls would be scattered throughout views
- **Impact**: Tight coupling, difficult to test, hard to switch providers
- **Solution**: Create repository pattern with protocols for data access
- **Estimate**: 2 days
- **Affected**: Future implementation

### 5. Hard-coded Values in Views
- **Issue**: Magic numbers, strings, and configuration values in SwiftUI views
- **Impact**: Difficult to maintain, no central configuration
- **Solution**: Extract to constants file or environment configuration
- **Estimate**: 1 day
- **Affected**: ExpressCoach views

### 6. No Logging Infrastructure
- **Issue**: No centralized logging for debugging or analytics
- **Impact**: Difficult to debug production issues
- **Solution**: Implement structured logging with levels (debug, info, error)
- **Estimate**: 1 day
- **Affected**: Both apps

### 7. SwiftData Migration Strategy Missing
- **Issue**: No plan for handling model changes and data migrations
- **Impact**: Data loss risk when updating models
- **Solution**: Implement versioned migrations and backup strategy
- **Estimate**: 2 days
- **Affected**: Both apps

---

## Low Priority 🟢

### 8. No CI/CD Pipeline
- **Issue**: Manual builds and deployments
- **Impact**: Time-consuming releases, human error risk
- **Solution**: Set up GitHub Actions for automated testing and deployment
- **Estimate**: 1 day
- **Affected**: Workspace level

### 9. Missing App Icons and Launch Screens
- **Issue**: Using default Xcode assets
- **Impact**: Unprofessional appearance
- **Solution**: Design and implement proper branding assets
- **Estimate**: 1 day with designer
- **Affected**: Both apps

### 10. No Performance Monitoring
- **Issue**: No visibility into app performance metrics
- **Impact**: Cannot identify bottlenecks or crashes
- **Solution**: Integrate analytics (Firebase, Sentry, or similar)
- **Estimate**: 1 day
- **Affected**: Both apps

---

## Accepted Debt ✅

### 11. No User Authentication Initially
- **Decision**: Using team codes instead of user accounts
- **Rationale**: Simplifies onboarding, reduces complexity for MVP
- **Trade-off**: Less personalization, no user-specific features
- **Revisit**: Phase 3 when adding coach profiles

### 12. Two Separate Apps Instead of Role-Based Single App
- **Decision**: Separate ExpressCoach and ExpressUnited apps
- **Rationale**: Eliminates role-switching complexity, clearer UX
- **Trade-off**: Duplicate code, two apps to maintain
- **Revisit**: Only if maintenance becomes overwhelming

### 13. Local-Only Demo Mode
- **Decision**: Demo data stored locally, not synced
- **Rationale**: Faster initial development, no backend complexity
- **Trade-off**: Demo changes don't persist across devices
- **Revisit**: Not needed unless demos require persistence

---

## Code Smells to Address 🔍

1. **Massive View Files**: Some SwiftUI views exceeding 200 lines
2. **Repeated Code**: Similar UI patterns not extracted to components
3. **No View Models**: Business logic mixed with view code
4. **Inconsistent Naming**: Mix of conventions across files
5. **Comments Missing**: Complex logic lacks documentation

---

## Security Debt 🔒

1. **No API Key Management**: Supabase keys would be hard-coded when configured
2. **No Certificate Pinning**: MITM attack vulnerability
3. **No Data Encryption**: Local SwiftData not encrypted
4. **No Input Validation**: Forms accept any input without validation

---

## Next Refactoring Session Priorities

1. ⭐ Fix bundle identifiers (blocking deployment)
2. ⭐ Add basic error handling to critical paths
3. ⭐ Extract hard-coded values to configuration
4. ⭐ Write tests for core Team and Player models

---

## Metrics

- **Total Debt Items**: 15+ identified issues
- **High Priority Items**: 3
- **Estimated Total Effort**: 3-4 weeks
- **Risk Level**: Medium (no production deployment yet)

---

*This register should be reviewed weekly and updated after each development session.*