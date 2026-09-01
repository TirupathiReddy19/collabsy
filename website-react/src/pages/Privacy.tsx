import { LegalPage, LegalH2, LegalP, LegalBullets, MailLink } from '../components/Legal'

export function Privacy() {
  return (
    <LegalPage title="Privacy Policy" effectiveDate="August 4, 2026">
      <LegalP>
        Collabsy connects Creators and Brands for influencer marketing campaigns.
        This policy explains what information we collect through the Collabsy
        mobile app, why we collect it, who we share it with, and the choices you
        have.
      </LegalP>

      <LegalH2>1. Information we collect</LegalH2>
      <LegalP>
        <strong>Account information. </strong>
        Your phone number (used to sign in), and — if you provide one — your email
        address and password. We never see or store your password in plain text;
        Firebase Authentication handles it for us in hashed form.
      </LegalP>
      <LegalP>
        <strong>Profile information. </strong>
        Your display name, profile photo, city and state, and role (Creator or
        Brand). Creators can add a bio, content categories, and languages. Brands
        can add a company name, designation, website, and LinkedIn URL.
      </LegalP>
      <LegalP>
        <strong>Instagram data. </strong>
        If you connect your Instagram Business account, we receive your Instagram
        username, name, profile photo, follower count, and recent media directly
        from Instagram's official API. We only request this when you choose to
        connect it, and it's shown to Brands considering you for a campaign — the
        same way it would be if they viewed your Instagram profile directly.
      </LegalP>
      <LegalP>
        <strong>Campaigns and messages. </strong>
        Campaign listings you post or apply to, your application status, and the
        messages you exchange with other users inside the app.
      </LegalP>
      <LegalP>
        <strong>Support requests. </strong>
        Anything you send us when you contact support, including messages in an
        in-app support chat.
      </LegalP>
      <LegalP>
        <strong>Reports and blocks. </strong>
        If you report or block another user, we keep a record of that action so we
        can review it and enforce our Terms.
      </LegalP>
      <LegalP>
        <strong>Usage and device data. </strong>
        Basic app analytics and crash reports (via Firebase Analytics and
        Crashlytics), and a push notification token so we can deliver
        notifications to your device.
      </LegalP>

      <LegalH2>2. What we don't collect</LegalH2>
      <LegalBullets
        items={[
          <>
            <strong>No precise location. </strong>
            City and state are typed by you — we never access your device's GPS
            location.
          </>,
          <>
            <strong>No payment information. </strong>
            Collabsy doesn't process payments between Creators and Brands or store
            any financial details.
          </>,
          <>
            <strong>No advertising tracking. </strong>
            We don't run ads and don't use advertising identifiers to track you
            across other apps.
          </>,
        ]}
      />

      <LegalH2>3. How we use your information</LegalH2>
      <LegalBullets
        items={[
          'Operate discovery, applications, and messaging between Creators and Brands',
          "Verify Creator and Brand accounts before they're publicly visible",
          'Send you notifications about applications, messages, and campaigns',
          'Respond to support requests',
          'Review reports and enforce our Terms of Service',
          'Understand how the app is used and fix problems, using aggregated analytics and crash data',
        ]}
      />

      <LegalH2>4. Who we share it with</LegalH2>
      <LegalP>
        <strong>The other side of the platform. </strong>
        Sharing profile information between Creators and Brands is core to how
        Collabsy works — a Brand can see a Creator's profile and connected
        Instagram stats, and a Creator can see a Brand's profile, the same way
        each would if they were reviewing an application or a campaign listing
        directly.
      </LegalP>
      <LegalP>
        <strong>Service providers. </strong>
        We use Firebase and Google Cloud for hosting, our database, authentication,
        analytics, crash reporting, and push notifications. If you connect
        Instagram, that connection is made directly with Meta's Instagram API.
      </LegalP>
      <LegalP>
        <strong>Legal reasons. </strong>
        We may disclose information if required by law, or where we believe it's
        necessary to protect the rights, property, or safety of Collabsy, our
        users, or the public.
      </LegalP>
      <LegalP>
        <strong>We never sell your personal information.</strong>
      </LegalP>

      <LegalH2>5. Your choices</LegalH2>
      <LegalBullets
        items={[
          <>
            <strong>Delete your account </strong>
            any time from Settings → Danger Zone → Delete Account. This permanently
            removes your profile. Campaigns, applications, and messages you were
            part of may remain visible to the other participant, the same way a
            message stays in someone else's inbox after you delete your own
            account elsewhere.
          </>,
          <>
            <strong>Block or unblock other users </strong>
            from Settings → Privacy &amp; Safety.
          </>,
          <>
            <strong>Turn push notifications on or off </strong>
            from Settings.
          </>,
          <>
            <strong>Disconnect Instagram </strong>
            any time from Settings → Connected Accounts.
          </>,
        ]}
      />

      <LegalH2>6. How long we keep your data</LegalH2>
      <LegalP>
        We keep your information while your account is active. When you delete
        your account, we delete your profile and personal data, with the
        exception described above for messages and campaign records that other
        users are still part of.
      </LegalP>

      <LegalH2>7. Children's privacy</LegalH2>
      <LegalP>
        Collabsy is a professional platform for Creators and Brands and is not
        directed at, or intended for use by, anyone under 18.
      </LegalP>

      <LegalH2>8. Security</LegalH2>
      <LegalP>
        We use Firebase's security infrastructure, encrypted connections
        (HTTPS/TLS) for all traffic, and database rules that restrict exactly who
        can read or write each piece of data.
      </LegalP>

      <LegalH2>9. Changes to this policy</LegalH2>
      <LegalP>
        If we make material changes to this policy, we'll update the effective
        date above and let you know in the app.
      </LegalP>

      <LegalH2>10. Contact us</LegalH2>
      <LegalP>
        Questions about this policy or your data? Email us at{' '}
        <MailLink>support@collabsy.online</MailLink>.
      </LegalP>
    </LegalPage>
  )
}
