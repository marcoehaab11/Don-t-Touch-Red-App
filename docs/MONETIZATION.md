# Monetization Plan

The current game has only earned, in-game coins. No ads, real-money purchases, billing SDK, or tracking SDK is active.

## Planned AdMob

Introduce an `AdService` adapter with availability, consent, show, and verified reward callbacks. Reward coins only after the SDK confirms completion. Limit interstitials to natural breaks, never during active play. Add test IDs during development, privacy disclosures, age handling, and device QA before enabling production IDs. Keep IDs and account credentials out of Git.

## Planned Google Play Billing

Introduce a `PurchaseService` adapter for product catalog, purchase flow, server or Play verification, acknowledgment, restore, and duplicate-safe grants. Never grant items on an unverified client-side event. Use Play Console configuration and secrets outside the repo.

Neither provider is included in the current build. Update the store listing, privacy policy, consent flow, and release checklist before either integration ships.
