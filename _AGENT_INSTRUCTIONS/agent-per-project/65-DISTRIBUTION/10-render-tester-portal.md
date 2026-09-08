---
tier: project
scope: distribution
owner: agent-per-project
last_reviewed: 2026-08-30
source_of_truth: doc
links:
  - ./README.md
  - ../60-BUILD-CONSIDERATIONS/README.md
tests: []
---

# Render Tester Portal

## Hosting Authority

The MessageLens tester portal is hosted by **Render** as a **Render Static
Site**. Render is connected to the tester portal's GitHub repository and
automatically deploys the site when its configured publishing branch is pushed.

The public endpoints are:

- Site: <https://message-lens-site.onrender.com/>
- Latest DMG:
  <https://message-lens-site.onrender.com/assets/downloads/MessageLens-latest.dmg>

Both endpoints returned HTTP 200 on 2026-08-30. The DMG endpoint reported
`application/x-apple-diskimage`.

Do not append analytics query parameters when recording or sharing the
canonical URLs.

## Repository And Artifact Locations

The tester portal is a separate repository from the MessageLens application:

```text
/Users/rob/Development/website/MessageLens
```

Its GitHub remote is:

```text
https://github.com/bigbenchrob/message-lens-site.git
```

The downloadable artifact is stored in the website repository at:

```text
/Users/rob/Development/website/MessageLens/assets/downloads/MessageLens-latest.dmg
```

The packaged local release is also normally available at:

```text
/Users/rob/Desktop/MessageLens-latest.dmg
```

The website is static. `npm run build` generates its root pages from the
sources under `src/`. The MessageLens release script copies the finalized DMG
into `assets/downloads/`, writes the current release metadata, and builds the
portal. It does **not** deploy the website.

## Publishing Sequence

1. Build, sign, notarize, and package MessageLens using the production release
   process documented under `60-BUILD-CONSIDERATIONS/`.
2. Confirm that the finalized DMG, generated release metadata, and generated
   portal pages are present in the website repository.
3. In the website repository, inspect `git remote -v` and the current
   branch/upstream before pushing. Do not rely on memory when deciding which
   push Render watches.
4. Review and commit only the intended tester-portal release changes.
5. Push the confirmed Render publishing branch to GitHub.
6. Wait for the Render Static Site deployment to finish.
7. Verify the public site and exact DMG URL.
8. Download or hash the public DMG when release identity matters; do not assume
   that a successful site response proves the new artifact was deployed.

At the time this document was created, the website checkout was on `main`,
tracking `origin/main`, and was one commit ahead. The unpushed release commit
was:

```text
fa0749a prepare MessageLens 0.2.99 tester release
```

That commit contains `MessageLens 0.2.99+117`. Its expected DMG SHA-256 is:

```text
76888964d10f4ad0513d29d6ef410788e21c0815266262214f167a2c9ec682a7
```

No new app build is required for that handoff. Once the website commit is
pushed and Render deploys it, verify that the public DMG has this exact hash,
then update or remove this time-specific handoff note.

## Distribution Invariants

- GitHub stores the tester-portal source; Render serves the public site.
- The application repository does not directly deploy the tester portal.
- Copying the DMG into the website checkout does not publish it.
- A website commit that has not been pushed cannot trigger Render.
- Confirm the publishing branch and upstream before every release push.
- Do not tell testers a release is available until the public DMG has been
  verified as the intended build.

