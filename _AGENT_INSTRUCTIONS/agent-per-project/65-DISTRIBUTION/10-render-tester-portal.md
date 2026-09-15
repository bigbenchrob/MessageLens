---
tier: project
scope: distribution
owner: agent-per-project
last_reviewed: 2026-09-15
source_of_truth: doc
links:
  - ./README.md
  - ../60-BUILD-CONSIDERATIONS/README.md
  - ../60-BUILD-CONSIDERATIONS/02-macos-fda-grant-continuity.md
  - ../45-NEW-FEATURE-ADDITION/32-TESTER-ARCHIVE-IMPORT-FAILURE/13-PHASE-4-AND-RELEASE-QUALIFICATION.md
tests: []
---

# Render Tester Portal

## Hosting and Repository Authority

The MessageLens tester portal is a Render Static Site. Render deploys the
tester-portal repository after its configured publishing branch is pushed.

- Public site: <https://message-lens-site.onrender.com/>
- Public DMG:
  <https://message-lens-site.onrender.com/assets/downloads/MessageLens-latest.dmg>
- Local portal checkout:
  `/Users/rob/Development/website/MessageLens`
- GitHub remote:
  `https://github.com/bigbenchrob/message-lens-site.git`
- Portal artifact:
  `assets/downloads/MessageLens-latest.dmg`

The application repository builds/signs/notarizes the app. The portal
repository owns tester-facing download bytes and release metadata. Render owns
public deployment. Copying files locally is not publication.

## Qualified-Artifact Rule

When a release candidate has already passed signing, notarization, stapling,
Gatekeeper, and packaged-process qualification, publication must use those
exact DMG bytes.

Before portal mutation:

1. Read the qualification record's version/build, byte size, and final
   post-staple SHA-256.
2. Hash the proposed local DMG and require an exact match.
3. Confirm publication does not require a version/build change, rebuild,
   re-sign, re-notarization, or artifact modification.
4. Stop for new authorization if any value differs.

Do not rerun `tool/build_and_notarize.sh` merely to publish a qualified
artifact. Its ordinary build path creates a new candidate. `--artifact-only`
also stops before portal work and is not a publication command.

## Portal Publication Procedure

1. Inspect the portal checkout's current branch, upstream, remote, status, and
   recent release history. Confirm which pushed branch Render watches.
2. Copy the already-verified DMG bytes to
   `assets/downloads/MessageLens-latest.dmg`.
3. Update `assets/data/latest-build.json` with exact version/build, date,
   channel, filename/path, and reset requirement.
4. Add the tester-facing release entry to
   `assets/data/tester-changelog.json`.
5. Update the source landing page and run the portal's established
   `npm run build` so generated `index.html` agrees with `src/pages/index.html`.
6. Re-hash the portal copy and require the qualified hash again.
7. Review and commit only the intended DMG, release-data, source-page, and
   generated-page changes.
8. Push the confirmed Render publishing branch.
9. Wait for the Render deployment, verify the public page's version/build and
   tester notes, then download/hash the public DMG and require the same hash.

A successful HTTP response alone does not prove that Render serves the intended
candidate. Final public hash verification is part of publication.

## Publication Record: `0.2.111+129`

On 2026-09-13, the qualified `0.2.111+129` production tester candidate was
published without rebuilding.

| Fact | Recorded value |
| --- | --- |
| App version/build | `0.2.111+129` |
| Bundle identifier | `com.bigbenchsoftware.MessageLens` |
| Final notarized/stapled DMG bytes | 47,921,437 |
| Final SHA-256 | `5f2313eb8526b23981396f376552259ba924d69d3d9336097f52538c34039e35` |
| Portal branch/upstream | `main` / `origin/main` |
| Portal publication commit | `1fd49d33c719b797d598c4ab4294899884377732` (`publish MessageLens 0.2.111 tester build`) |
| Public destination | `MessageLens-latest.dmg` at the canonical Render URL above |
| Reset metadata | `requiresDataReset: false` / `Not required` |

The Desktop qualified artifact and portal repository copy were independently
hashed after publication preparation and matched the recorded SHA-256 and byte
size. The portal commit changed only:

- `assets/downloads/MessageLens-latest.dmg`;
- `assets/data/latest-build.json`;
- `assets/data/tester-changelog.json`;
- `src/pages/index.html`; and
- generated `index.html`.

Tester-facing notes describe bounded first-time/archive message import,
high-water/keyset/byte-bounded rich-text work, durable continuation after
interruption, single-record decoder containment, exact recovery-stage
reporting, privacy-safe support evidence, and unchanged production identity.

## Qualification Boundary

Publication records distribution, not every release-qualification gate. For
`0.2.111+129`:

- the available 24 GB host passed the packaged 150,000-candidate memory
  plateau and process interruption/relaunch rehearsals;
- signing, notarization, stapling, and Gatekeeper checks passed;
- the exact qualified artifact was published without rebuilding; and
- the separate ordinary-load run on the intended low-memory target Mac remains
  **not run / outstanding**.

Do not state or imply that portal publication satisfied that low-memory gate.

## Distribution Invariants

- Preserve bundle ID, signing team/identity, hardened runtime, notarization,
  and app name so Full Disk Access continuity is not knowingly broken.
- Never silently rebuild a hash-qualified candidate during publication.
- Never change version/build metadata to fit an artifact; stop on mismatch.
- Confirm the portal publishing branch and upstream for every release.
- Keep tester notes and reset metadata truthful for the exact artifact.
- Do not tell testers a release is available until the Render deployment and
  public artifact identity have been verified.
