# Oasis Phone

White-label SIP softphone for **[Oasis Orchard Technologies](https://oasisorchardtech.com)** — voice/video calls,
messaging and meetings on Android and iPhone.

Oasis Phone is a rebranded build of the open-source [Linphone](https://linphone.org) apps by
Belledonne Communications, distributed under the **GNU GPL v3** (see `android/LICENSE.txt`, `ios/LICENSE.txt`).

| Folder | Contents | Upstream |
|---|---|---|
| `android/` | Android app (Kotlin, Gradle) | [linphone-android](https://github.com/BelledonneCommunications/linphone-android) |
| `ios/` | iPhone app (Swift/SwiftUI, Xcode) | [linphone-iphone](https://github.com/BelledonneCommunications/linphone-iphone) |
| `branding/` | Logo sources, brand settings, rebrand + upstream-update scripts | — |

Exact upstream commits are recorded in `branding/UPSTREAM.txt`.

## What was rebranded

| | Android | iOS |
|---|---|---|
| App name | `Oasis Phone` (all languages) | `Oasis Phone` (display name, share extension, strings in all languages, Siri phrases) |
| App ID | `com.oasisorchardtech.phone` | `com.oasisorchardtech.phone` (+ `.msgNotificationService`, `.linphoneExtension`, `.intentsExtension`) |
| App group | — | `group.com.oasisorchardtech.phone.*` |
| Colors | Primary `#1BB0CE`, light `#E0F7FB` (from oasisorchardtech.com) | Same, default theme + AccentColor |
| Icons | Adaptive + legacy launcher icons, splash icon, splash wordmark, notification icon, welcome logo, Play Store icon | App icon (1024), in-app logo |
| Links | Contact/help → `/support`, download → `/services`, privacy → `/p/privacy-policy`, terms → `/p/terms-of-use` | Same |
| Debug-log email | `support@oasisorchardtech.com` | — |
| Upstream Firebase | `google-services.json` removed (it belongs to Linphone's Firebase project) | `GoogleService-Info.plist` left in place — **must be replaced** (see below) |
| Signing | Your keystore via `keystore.properties` | `DEVELOPMENT_TEAM` cleared — set your Apple team |

Kept on purpose: internal Kotlin/Swift package names (`org.linphone.*`, not user-visible; keeping them makes upstream
merges painless), the GPL licence text and the "© Belledonne Communications" copyright notice in *About*.

All settings live in `branding/brand.json`. Logo sources are SVGs in `branding/assets/`.

## Changing the brand / pulling upstream updates

```bash
pip install cairosvg
# edit branding/brand.json or branding/assets/*.svg, then:
python3 branding/rebrand.py              # re-applies everything, safe to run repeatedly

# pull newest Linphone code and re-brand it in one go:
branding/update-upstream.sh              # optional args: <android_ref> <ios_ref>, e.g. 6.2.0 6.2.0
```

## Before publishing to the stores — checklist

1. **SIP server.** The apps still default to Linphone's free SIP service (`sip.linphone.org`) for the
   "create/login with account" flow; the *third-party SIP account* login works with any SIP server, including
   your own PBX. To make your PBX the default, edit
   `android/app/src/main/assets/{linphonerc_default,linphonerc_factory,assistant_*_default_values}` and
   `ios/Linphone/Ressources/` (same files) — set `reg_proxy`, `reg_identity`, `realm`, `domain` to
   e.g. `sip.oasisorchardtech.com`. Tell me your PBX details and I can wire this up and add it to `rebrand.py`.
2. **Push notifications (incoming calls while app is closed).**
   - Android: create a Firebase project for `com.oasisorchardtech.phone`, put its `google-services.json` in `android/app/`.
   - iOS: replace `ios/GoogleService-Info.plist` and `ios/msgNotificationService/GoogleService-Info.plist` with
     your own; create an APNs VoIP certificate/key for the new bundle id.
   - Your SIP server (or a Flexisip proxy) must send the pushes.
3. **Website pages.** Publish `/p/privacy-policy` and `/p/terms-of-use` on oasisorchardtech.com (both stores
   require a privacy-policy URL), or change the URLs in `brand.json`.
4. **iOS identifiers.** In the Apple Developer portal register the 4 bundle ids above and the app groups
   `group.com.oasisorchardtech.phone.msgNotification` / `group.com.oasisorchardtech.phone.linphoneExtension`;
   set `ios_development_team` in `brand.json` and re-run `rebrand.py` (or pick the team in Xcode).
5. **Android signing.** Fill `android/keystore.properties` with your own release keystore (never commit it).
6. **GPL v3 compliance.** Linphone is GPL v3, so Oasis Phone must be too: publish this repository's source
   (or provide a written offer), keep the licence and copyright notices, and link the source from the app's
   store listing / website. Note that Apple's App Store terms are widely considered incompatible with GPL
   distribution; **Belledonne sells a proprietary licence** for exactly this case — talk to them
   (linphone.org → *Licensing*) before submitting to the App Store. "Linphone" is their trademark, which is
   why it is removed from all user-visible text.

## Building

**Android** — Android Studio (latest), JDK 17+. Open `android/` and run, or:
```bash
cd android && ./gradlew assembleDebug        # APK in app/build/outputs/apk/
```
The Linphone SDK is downloaded from `download.linphone.org/maven_repository` automatically.

**iOS** — Xcode 16+. Open `ios/LinphoneApp.xcodeproj`; Swift packages (Linphone SDK, Firebase, AppAuth…) resolve
automatically. Select your team for each target and run the `LinphoneApp` scheme.

See `android/README.md` and `ios/README.md` for upstream build details.
