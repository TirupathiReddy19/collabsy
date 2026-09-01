import { LegalPage, LegalH2, LegalP, LegalBullets, MailLink } from '../components/Legal'

export function Terms() {
  return (
    <LegalPage title="Terms of Service" effectiveDate="August 4, 2026">
      <LegalP>
        These Terms govern your use of Collabsy as a Creator or a Brand. By
        creating an account or using the app, you agree to them.
      </LegalP>

      <LegalH2>1. Eligibility</LegalH2>
      <LegalP>
        You must be at least 18 years old to use Collabsy. If you're creating a
        Brand account on behalf of a company, you confirm you have the authority
        to represent that company and agree to these Terms on its behalf.
      </LegalP>

      <LegalH2>2. Your account</LegalH2>
      <LegalBullets
        items={[
          'Provide accurate information when you sign up, and keep it up to date.',
          "One account per person or company — don't create accounts to impersonate someone else or misrepresent your identity, follower count, or company.",
          "You're responsible for anything that happens under your account, so keep your credentials secure.",
        ]}
      />

      <LegalH2>3. Creator and Brand conduct</LegalH2>
      <LegalP>Collabsy is a place for genuine collaboration. You agree not to:</LegalP>
      <LegalBullets
        items={[
          'Harass, threaten, or abuse other users in messages, profiles, or campaign listings',
          "Post spam, illegal content, or content that infringes someone else's rights",
          'Misrepresent your identity, your company, or your Instagram metrics',
          "Attempt to circumvent our verification process or another user's block",
        ]}
      />
      <LegalP>
        Report and Block tools are available on every profile and conversation.
        We review reports and, depending on severity, may remove content, warn an
        account, or suspend or terminate it — repeat violations lead to stronger
        action.
      </LegalP>

      <LegalH2>4. Campaigns between Creators and Brands</LegalH2>
      <LegalP>
        Collabsy helps Creators and Brands discover each other, apply to
        campaigns, and communicate. Any agreement about deliverables,
        compensation, or timelines is between the Creator and the Brand directly
        — Collabsy is not a party to that agreement and doesn't guarantee
        payment, performance, or the outcome of any campaign.
      </LegalP>

      <LegalH2>5. Content you post</LegalH2>
      <LegalP>
        You retain ownership of anything you post — your profile, campaign
        listings, and messages. By posting it, you grant Collabsy a license to
        display it within the app to the users it's meant for, which is what
        makes discovery and messaging work. You're responsible for having the
        rights to anything you upload.
      </LegalP>

      <LegalH2>6. Instagram and other connected accounts</LegalH2>
      <LegalP>
        Connecting your Instagram Business account is optional. That connection
        is also governed by Meta's own terms, in addition to these. You can
        disconnect it at any time from Connected Accounts in Settings.
      </LegalP>

      <LegalH2>7. Ending your account</LegalH2>
      <LegalP>
        You can delete your account at any time from Settings. We may suspend or
        terminate an account that violates these Terms or applicable law, with
        notice where practical.
      </LegalP>

      <LegalH2>8. Disclaimers</LegalH2>
      <LegalP>
        Collabsy is provided "as is." We don't guarantee uninterrupted service,
        or the accuracy, quality, or outcome of any Creator profile, Brand
        listing, or campaign.
      </LegalP>

      <LegalH2>9. Limitation of liability</LegalH2>
      <LegalP>
        To the extent permitted by law, Collabsy isn't liable for indirect,
        incidental, or consequential damages arising from your use of the app, or
        from agreements you enter into with another user through it.
      </LegalP>

      <LegalH2>10. Governing law</LegalH2>
      <LegalP>These Terms are governed by the laws of India.</LegalP>

      <LegalH2>11. Changes to these Terms</LegalH2>
      <LegalP>
        We may update these Terms from time to time. Continuing to use Collabsy
        after a change means you accept the updated Terms.
      </LegalP>

      <LegalH2>12. Contact us</LegalH2>
      <LegalP>
        Questions about these Terms? Email us at{' '}
        <MailLink>support@collabsy.online</MailLink>.
      </LegalP>
    </LegalPage>
  )
}
