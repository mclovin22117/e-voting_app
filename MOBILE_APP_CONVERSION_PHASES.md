# Mobile App Conversion Plan

## Goal
Convert the existing Blockchain-e-voting web platform into a production-ready Flutter mobile app while preserving core smart-contract logic and improving security and UX for mobile users.

## Guiding Principles
- Keep one source of truth for election state on-chain.
- Reuse existing backend where it adds value (IPFS, registration metadata, API helpers).
- Avoid hardcoded secrets and addresses in app code.
- Build incrementally with testable milestones.

## Phase 0: Foundation and Alignment
### Objective
Lock architecture, environments, and baseline app structure before feature expansion.

### Scope
- Confirm target networks (Ganache local and Sepolia testnet).
- Define environment config strategy for Flutter (RPC URL, backend URL, contract address, chain IDs).
- Normalize contract ABI source and version.
- Set coding conventions and folder structure for screens, services, models, and state management.

### Deliverables
- Config model for environment-based app settings.
- Clean service boundaries for blockchain and backend APIs.
- Baseline navigation structure for auth, voter, and admin journeys.

### Exit Criteria
- App builds and runs with environment-driven config only.
- No private keys hardcoded in source.

## Phase 1: Blockchain Core Parity
### Objective
Bring Flutter contract integration to parity with the core Election contract behavior.

### Scope
- Implement read calls: owner, candidatesCount, getCandidate/candidates, registered, hasVoted, votes, voteHashes, votingStart, votingEnd, votingPeriodSet, paused.
- Implement write calls: castVote, registerVoter, addCandidate, setVotingPeriod, cancelVotingPeriod, pause, unpause.
- Add chain/network mismatch detection and user feedback.
- Add robust transaction lifecycle states (pending, success, failure).

### Deliverables
- Upgraded blockchain service with complete contract method coverage.
- Typed models for candidate and voting period data.
- Reusable transaction status UI components.

### Exit Criteria
- All critical contract methods can be called from mobile.
- User receives clear status and error messages for every transaction path.

## Phase 2: Wallet and Identity Flow
### Objective
Replace insecure direct signing with wallet-based authentication and transaction signing.

### Scope
- Integrate wallet connection flow suitable for mobile (WalletConnect-based flow).
- Build connect/disconnect state handling and session restore.
- Map connected account to role (admin or voter).
- Add guards for unregistered and unverified users.

### Deliverables
- Wallet connect screen and shared session management.
- Role-aware routing and access guards.
- Account/network diagnostics panel for troubleshooting.

### Exit Criteria
- Users can securely connect wallet and sign transactions from mobile.
- Role detection is reliable and reflected throughout UI.

## Phase 3: Voter Experience Parity
### Objective
Deliver complete voter-side mobile UX aligned with web app behavior.

### Scope
- Candidate list with live on-chain vote counts.
- Voting eligibility checks (registered, not already voted, period active, not paused).
- Vote submission flow with confirmations.
- Voting status banners (not set, upcoming, active, ended, paused).

### Deliverables
- Voter dashboard screen.
- Candidate voting flow with strong validation and error handling.
- Post-vote receipt screen shell (before IPFS deep integration).

### Exit Criteria
- Eligible voter can complete end-to-end on-chain voting from mobile.
- Ineligible conditions are blocked with actionable feedback.

## Phase 4: Admin Experience Parity
### Objective
Deliver owner/admin controls in mobile for full election management.

### Scope
- Add candidate management.
- Register voter addresses.
- Set and cancel voting periods.
- Pause and unpause contract operations.
- View election status and summary information.

### Deliverables
- Admin dashboard with guarded access.
- Admin action forms with transaction feedback.
- Basic export-ready summary view for election state.

### Exit Criteria
- Contract owner can execute all admin actions from mobile.
- Non-owner users are blocked from admin operations.

## Phase 5: Backend and IPFS Integration
### Objective
Integrate off-chain vote payload and receipt verification workflow.

### Scope
- Connect Flutter app to backend endpoints for IPFS upload.
- Build vote payload and compute/store vote hash flow consistent with contract call.
- Store and display CID and transaction hash in receipt UI.
- Add external verification links (IPFS gateway and block explorer).

### Deliverables
- Backend API client service.
- IPFS-backed vote receipt screen.
- Retry/fallback behavior for IPFS/upload failures.

### Exit Criteria
- Vote flow includes both off-chain payload persistence and on-chain proof.
- User can verify vote artifact from receipt screen.

## Phase 6: Security, Quality, and Release Readiness
### Objective
Harden the app for testnet rollout and reliable demos.

### Scope
- Remove all residual insecure patterns.
- Add input validation and defensive error handling across features.
- Add widget and service tests for critical paths.
- Add logging and diagnostics for wallet, network, and transaction failures.
- Prepare release checklist and runbook.

### Deliverables
- Security pass report.
- Test suite for high-risk user journeys.
- Deployment checklist for Android and iOS test builds.

### Exit Criteria
- Critical flows pass tests and manual QA scenarios.
- App is ready for structured testnet user acceptance.

## Milestone Sequence
1. Foundation and architecture finalized.
2. Blockchain service parity completed.
3. Wallet flow stabilized.
4. Voter and admin UX completed.
5. IPFS receipt workflow integrated.
6. Security and release hardening completed.

## Out of Scope for Initial Mobile Release
- Full production-grade KYC and OTP infrastructure redesign.
- Zero-knowledge proof integration.
- Mainnet launch and cost optimization.

## Definition of Done for Initial Mobile Version
- Wallet-based secure signing only.
- End-to-end voter flow works on selected test network.
- Admin can manage election lifecycle fully from mobile.
- Vote receipt includes blockchain proof and IPFS reference.
- No hardcoded secrets in repository.
- Basic automated tests cover core happy paths and key failure paths.
