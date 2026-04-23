<template>
  <main class="page">
    <div class="container legal-content">
      <h1 class="page-title">
        Terms of Service
      </h1>
      <p class="last-updated">
        Last Updated: {{ new Date().toLocaleDateString() }}
      </p>
      <section class="prose">
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing or using this website and related services (the "Service"), you agree to these Terms of Service ("Terms"). If you do not agree, do not use the Service.</p>

        <h2>2. Scope</h2>
        <p>These Terms apply to all users of the Service, including visitors, registered users, and contributors. The Service operator may provide additional terms for specific features (e.g., paid subscriptions); those additional terms supplement these Terms.</p>

        <h2>3. Accounts, Security, and Eligibility</h2>
        <p>To access certain features you may need to create an account. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must provide accurate information and keep it up to date. The Service is intended for users who can form legally binding contracts; by using the Service you represent that you meet the minimum age and legal requirements to do so.</p>

        <h2>4. Account Suspension and Termination</h2>
        <p>We may suspend or terminate your account and access to the Service if you violate these Terms, engage in abusive or fraudulent activity, provide false information, or otherwise harm the Service or other users. In many cases we will provide notice and an opportunity to remedy the issue, but in cases of serious or repeated violations we may suspend or terminate access immediately without prior notice.</p>

        <h2>5. Acceptable Use</h2>
        <p>You agree not to use the Service for illegal activities or to harm, harass, defraud, or infringe the rights of others. You must not attempt to gain unauthorized access to any part of the Service, interfere with the operation of the Service, or abuse automated access. The Service operator reserves the right to remove, block, or refuse any content or activity that, in our sole discretion, violates these Terms or is harmful to the community.</p>

        <h2>6. User Content</h2>
        <p>You retain ownership of the content you submit, post, or display through the Service. By submitting content you grant the Service a non-exclusive, worldwide, royalty-free license to use, reproduce, modify, publish, and display that content as necessary to operate and improve the Service (for example, to display your listing or to provide search results).</p>

        <h2>7. Moderation</h2>
        <p>The Service may include community features and user-generated content. We are not obligated to monitor all content, but we may remove or restrict access to content that violates these Terms or applicable law. Decisions about content moderation are final except where local law provides otherwise.</p>

        <h2>8. Payments and Fees</h2>
        <p>Where the Service offers paid products or subscriptions, additional terms and billing policies may apply. Fees are non-refundable except where required by law or expressly stated otherwise. You are responsible for providing valid payment information and for all charges incurred through your account.</p>

        <h2>9. Intellectual Property</h2>
        <p>The Service and its original content, features and functionality are and will remain the exclusive property of the Service operator and its licensors. If you believe your intellectual property has been used in a way that violates your rights, contact us using the details below.</p>

        <h2>10. Disclaimers</h2>
        <p>The Service is provided "as is" and "as available". To the fullest extent permitted by law, the operator disclaims all warranties, whether express or implied, including merchantability, fitness for a particular purpose, and non-infringement. We do not guarantee that the Service will be uninterrupted, secure, or error-free.</p>

        <h2>11. Limitation of Liability</h2>
        <p>Except where prohibited by law, in no event will the operator be liable for indirect, incidental, special, consequential or punitive damages, or any loss of profits, data, use, goodwill, or other intangible losses arising out of or in connection with your use of the Service, even if advised of the possibility of such damages. The operator's total liability for direct damages shall not exceed the amount paid by you to the Service in the twelve (12) months preceding the claim, or €100, whichever is greater.</p>

        <h2>12. Indemnification</h2>
        <p>You agree to indemnify and hold harmless the operator and its officers, directors, agents and employees from any claim or demand, including reasonable attorneys' fees, made by any third party due to or arising out of your breach of these Terms, your violation of any law, or your use of the Service.</p>

        <h2>13. Third-Party Services</h2>
        <p>The Service may contain links to third-party websites or services that are not owned or controlled by the operator. We are not responsible for the content, privacy policies, or practices of third parties. Please review their terms before interacting with them.</p>

        <h2>14. Changes to These Terms</h2>
        <p>We may modify the Terms from time to time. When we do, we will update the "Last Updated" date above and, where appropriate, provide notice. Continued use after changes constitutes acceptance of the updated Terms.</p>

        <h2>15. Governing Law and Dispute Resolution</h2>
        <p>These Terms are governed by the laws that apply where the Service operator is located, without regard to conflict of law rules. If you have a dispute with the operator, please contact us first so we can try to resolve it informally.</p>

        <h2>16. How to Contact Us</h2>
        <p>If you have questions about these Terms or wish to report a violation, please contact: <a href="mailto:sowasvonphilipp23@gmail.com">sowasvonphilipp23@gmail.com</a>. For privacy-related questions see our <a href="/privacy">Privacy Policy</a>.</p>
      </section>
    </div>
  </main>
</template>

<script setup>
useSeoMeta({
  title: 'Terms of Service — Sunshine Studio',
  description: 'Terms of Service for Sunshine Studio applications.'
})
</script>

<style scoped>
.page { min-height: 100vh; padding: 64px 0; }
.container { max-width: 800px; margin: 0 auto; padding: 0 24px; }
.page-title { font-size: 2.5rem; font-weight: 900; color: var(--text); margin-bottom: 8px; letter-spacing: -0.02em; }
.last-updated { color: var(--muted); font-size: 0.9rem; margin-bottom: 40px; }

.prose {
  color: var(--subtle);
  line-height: 1.7;
}
.prose h2 {
  color: var(--text);
  font-size: 1.3rem;
  font-weight: 700;
  margin: 32px 0 16px;
}
.prose p {
  margin-bottom: 16px;
  font-size: 1.05rem;
}
</style>
