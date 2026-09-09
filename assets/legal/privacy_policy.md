# Privacy Policy

**Last Updated:** September 9, 2026

At **CinReco** ("we," "us," or "our"), we are committed to protecting your privacy. This Privacy Policy describes how we collect, use, process, and share your personal information when you use our mobile application, web application, and related services (collectively, the "Services").

CinReco is designed for users worldwide, including the European Union (EU) and the United States (US). We comply with the General Data Protection Regulation (GDPR) for users in the European Economic Area (EEA), and state-specific regulations in the United States, including the California Consumer Privacy Act (CCPA/CPRA).

---

## 1. Data Controller and Contact Information

For the purposes of the GDPR and other applicable data protection laws, the Data Controller is:
* **Entity Name:** Ali Mobini, operating CinReco as an independent developer based in the Netherlands (sole proprietor; not yet a registered company)
* **Email Contact:** `info@mail.mobini.nl`

If you have any questions, concerns, or requests regarding your personal data, please email us. As an independent developer rather than a registered company, we handle requests personally rather than through a dedicated privacy team — expect a direct reply, not a form letter.

---

## 2. Information We Collect

We collect information that you provide directly to us, information collected automatically, and information from third parties.

### 2.1 Information You Provide Directly
* **Account Registration Details:** When you create an account, we collect your email address and password (hashed using the Argon2 algorithm — we never store your password in plain text). We do not currently offer sign-in via Google, Apple, or other third-party identity providers; accounts are created with email and password only.
* **Onboarding & Preferences:** Movie genre preferences, minimum rating filters, language preference, and app theme (light/dark) you select during onboarding or in your settings.
* **Waitlist Signups:** If you join our pre-launch waitlist on our website, we collect the name, email address, and optional "use case" text you submit, along with the IP address of the submission. This is used solely to notify you about app availability and is stored separately from in-app account data.
* **Support Communications:** Any information you provide when contacting customer support or sending legal inquiries.

### 2.2 Information Collected Automatically (App Usage & Device Info)
* **Swiping & Session Data:** Your swipe actions (likes, dislikes, super-likes), watchlist additions, and group session activity (session codes you create or join, mood filters, and membership status). If you create or join a group session, your email address is visible to the other members of that session so you can see who you're matching with.
* **Analytics Data:** We track in-app usage (such as button clicks, screen navigation, onboarding progress, and swiping volume) using **PostHog**. Events are tied to your account's numeric ID once you are logged in (via PostHog's `identify` call), not your email address; PostHog does not receive your password or movie preference text.
* **Technical & Diagnostic Data:** General device and app information automatically captured by PostHog (such as operating system, app version, and device type), and IP address logged by our servers and hosting infrastructure for security, abuse-prevention, and diagnostic purposes.

### 2.3 Cookies and Local Storage
We use local storage mechanisms (such as `SharedPreferences`, `SecureStorage`, and `Hive` databases) to store information locally on your device. This includes caching your login token, theme preference, and movie metadata to enable offline functionality. These are strictly necessary for the performance of our contract with you.

---

## 3. How and Why We Use Your Information

We process your personal information for the following purposes:

1. **To Provide the Services:** Registering your account, logging you in, managing group sessions, syncing your watchlist across devices, and displaying movie metadata.
2. **To Personalize Recommendations:** Running recommendation algorithms based on your genre preferences and swipe history.
3. **To Monitor and Improve the App:** Analyzing usage and app-flow metrics (via PostHog) to optimize speed, usability, and visual layout.
4. **To Ensure App Security:** Preventing spam, bot attacks, and fraudulent registrations.

---

## 4. Legal Bases for Processing (EEA Users)

Under the GDPR, we only process your personal data under the following legal bases:
* **Performance of a Contract (Art. 6(1)(b) GDPR):** Processing is necessary to provide the CinReco app features that you request, such as account creation, login, watchlist syncing, and matching sessions.
* **Consent (Art. 6(1)(a) GDPR):** Where you have given explicit consent, such as allowing analytical tracking or telemetry. You can withdraw your consent at any time via the Settings screen.
* **Legitimate Interests (Art. 6(1)(f) GDPR):** For security monitoring, fraud prevention, debugging, and conducting aggregated usage statistics to improve the product.

---

## 5. Data Sharing and Third-Party Processors

We do not sell, rent, or trade your personal information. We only share your data with service providers (processors) that support our operations:
* **Hosting and Cloud Infrastructure:** Our servers and database are hosted with Hetzner Online GmbH, a German provider, with our infrastructure located in Germany (EU).
* **Content Delivery / Proxy (Cloudflare):** Some of our web domains route through Cloudflare, which sees connection metadata (such as your IP address) as a reverse proxy in front of our servers, for DDoS protection and performance.
* **Analytics Providers (PostHog):** PostHog processes pseudonymous event data (tied to your account's numeric ID, not your email) to help us understand app performance. Events are processed in PostHog's EU region. You can opt out of analytics tracking in the settings.
* **Transactional Email (Resend):** We use Resend to send password-reset and email-verification messages. Resend processes the email address you register with in order to deliver these emails, on infrastructure located in the EU (eu-west-1).
* **Movie Metadata Providers (TMDb):** We query TMDb to fetch movie posters, trailers, and details. We **do not** transmit your email, account identifier, or any personal data to TMDb.
* **AI Recommendation Processing (Google Gemini API):** To power personalized recommendations, our backend uses the Google Gemini API to generate vector embeddings from movie catalog text (titles, descriptions, genres). Your personal swipe history is never sent to Gemini or any external AI provider — the matching between your preferences and movie embeddings happens entirely within our own backend.
* **Video Playback (YouTube):** Movie trailers are played using YouTube's embedded player. Viewing a trailer may involve YouTube (Google LLC) processing data under its own privacy policy — see Section 10 of our Terms of Service.

---

## 6. International Data Transfers

Our core hosting infrastructure — servers and database — is located in Germany, within the European Economic Area. Some of our service providers (including Google, for the Gemini API, and Resend, a US-headquartered company whose email-sending infrastructure for this app runs in the EU) may process data outside the EEA or are based outside it. Where that happens, we rely on appropriate safeguards, including Standard Contractual Clauses (SCCs) approved by the European Commission and providers' own compliance certifications, to protect your personal data.

---

## 7. Data Retention & Deletion

We retain your personal data for as long as your account is active or as needed to provide you with the Services.

### 7.1 Data Deletion Right
You can request the deletion of your account and all associated personal data at any time:
* **In-App:** Go to **Settings** -> select **Clear User Data** / **Delete Account**.
* **Web Form:** Visit `https://api.cinreco.com/account/delete` and confirm with your email and password — this works even if you no longer have the app installed.
* **By Email:** Send a deletion request from your registered email address to `info@mail.mobini.nl`.

Upon deletion, your email address and password will be permanently deleted from our databases. Your swipe history and watchlists will be either permanently deleted or fully anonymized (de-identified) so they can no longer be associated with you or traced back to your identity.

---

## 8. Your Rights Under GDPR (EEA Users)

If you are a resident of the European Economic Area (EEA), you have the following rights:
* **Right of Access:** You can request a copy of the personal data we hold about you.
* **Right to Rectification:** You can request that we correct inaccurate or incomplete data.
* **Right to Erasure (Right to be Forgotten):** You can request that we delete your personal data.
* **Right to Restrict or Object:** You can object to or request that we restrict the processing of your data.
* **Right to Data Portability:** You can request a structured, machine-readable copy of your personal data.
* **Right to Withdraw Consent:** Where we rely on consent, you can withdraw it at any time.
* **Right to Lodge a Complaint:** You have the right to lodge a complaint with your local Data Protection Authority.

To exercise these rights, please contact us at `info@mail.mobini.nl`. As we are a very small operation, requests are handled by hand — expect a response within one month, as required by GDPR, though we will typically respond sooner.

---

## 9. Your Rights Under CCPA/CPRA (California Users)

If you are a California resident, you have specific rights under the CCPA/CPRA:
* **Right to Know:** You have the right to request disclosure of the categories and specific pieces of personal information we have collected about you, the sources, and the purposes.
* **Right to Delete:** You have the right to request the deletion of personal information collected from you.
* **Right to Opt-Out of Sale or Sharing:** We do not "sell" or "share" (for cross-context behavioral advertising) your personal information. If this changes, we will provide a clear "Do Not Sell/Share My Info" link.
* **Right to Non-Discrimination:** We will not discriminate against you (e.g., charge different prices, deny service) for exercising your privacy rights.

To exercise these CCPA rights, please submit a request to `info@mail.mobini.nl`.

---

## 10. Children's Privacy

Our Services are not directed to children. We do not knowingly collect personal information from children under 13 years of age (in the US) or under 16 years of age (in the EU). If we become aware that we have collected personal data from a child under these ages without verifiable parental consent, we will take immediate steps to delete that information and terminate the account.

---

## 11. Security of Your Data

We implement industry-standard technical and organizational security measures to protect your personal information against unauthorized access, loss, alteration, or disclosure. This includes:
* Encrypting data in transit (SSL/TLS).
* Salting and hashing passwords.
* Requiring authentication controls for database access.
Please remember, however, that no method of transmission over the Internet or electronic storage is 100% secure, and we cannot guarantee absolute security.

---

## 12. Changes to this Privacy Policy

We may update this Privacy Policy from time to time. We will notify you of any material changes by posting the new Privacy Policy in the app or via email, and updating the "Last Updated" date at the top. We encourage you to review this page periodically.

---

## 13. Contact Information

If you wish to exercise your rights, or if you have any questions or complaints regarding this Privacy Policy, please contact us at:

* **Email:** `info@mail.mobini.nl`
