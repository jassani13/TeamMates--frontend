import 'package:base_code/package/config_packages.dart';
import 'package:base_code/package/screen_packages.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          getTitle(),
          style: TextStyle().normal20w500,
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    8,
                  ),
                  border: Border.all(color: AppColor.greyEAColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: AppColor.black12Color,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          )),
                      child: Text(
                        getTitle(),
                        style: TextStyle().normal16w500.textColor(
                              AppColor.white,
                            ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColor.greyF6Color, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        getData(),
                        textAlign: TextAlign.start,
                        style: TextStyle().normal16w500.textColor(
                              AppColor.black12Color,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getTitle() {
    if (Get.arguments[0] == 1) {
      return "Privacy & Policy";
    } else if (Get.arguments[0] == 2) {
      return "Terms & condition";
    } else if (Get.arguments[0] == 3) {
      return "Refund Policy";
    } else if (Get.arguments[0] == 4) {
      return "User Agreement";
    }else if (Get.arguments[0] == 5) {
      return "Subscription Terms";
    }
    return "";
  }

  String getData() {
    if (Get.arguments[0] == 1) {
      return '''
TeamMates – Privacy Policy
Last Updated: April 2nd, 2025

At TeamMates, your privacy is a priority. This Privacy Policy outlines how we collect, use, and protect your personal information when you use our App and services.

1. Information We Collect
We may collect:
	•	Account Information: Name, email, team or organization details.
	•	Content: Messages, schedules, media, files shared via the App.
	
2. How We Use Your Information
	•	To provide, maintain, and improve our services.
	•	To personalize user experience.
	•	To communicate updates, news, or support.
	•	For security, fraud prevention, and legal compliance.
	
3. Sharing Your Information
We do not sell your personal data. We may share data only:
	•	We do not share your personal information with any third-party services, advertisers, or partners without your explicit consent.
	•	Your data, including name, email, and any other personal details, is used solely to improve your experience within the app.
	•	We do not sell, rent, or disclose your data to anyone for marketing or advertising purposes.
	
4. Data Storage and Security
We implement security measures to protect your data. However, no online system is 100% secure.

5. Cookies & Tracking
The App and website may use cookies or similar tracking to enhance functionality and analytics.

6. Children’s Privacy
We do not knowingly collect personal information from children under 13 without parental consent.

7. Data Retention
We retain your data for as long as your account is active or as required by law.

8. Your Rights
Depending on your region, you may have the right to access, correct, or delete your personal data. Contact us to exercise these rights.

9. Changes to this Policy
We may update this Privacy Policy. Significant changes will be communicated via the App or email.

10. Contact Us
Questions or concerns?
Email: info@teammatesapp.org     
      ''';
    }
    if (Get.arguments[0] == 2) {
      return '''
TeamMates – Terms and Conditions
Last Updated: April 2nd, 2025

Welcome to TeamMates (“we,” “us,” or “our”). These Terms and Conditions (“Terms”) govern your use of the TeamMates mobile application and website (collectively, the “App”). By accessing or using the App, you agree to be bound by these Terms. If you do not agree, please do not use the App.

1. Eligibility
You must be at least 13 years old to use the App. If you are under 18, you must have permission from a parent or legal guardian.

2. User Accounts
	•	You are responsible for maintaining the confidentiality of your account login details.
	•	You agree to provide accurate and complete information when registering.
	•	You are responsible for all activities that occur under your account.

3. Acceptable Use
You agree not to:
	•	Use the App for any unlawful purpose.
	•	Post or transmit offensive, abusive, or inappropriate content.
	•	Interfere with or disrupt the App’s functionality.
	•	Attempt to access other users’ accounts or data.

4. Content Ownership
	•	You retain ownership of any content you upload (messages, schedules, team data, media, etc.).
	•	By uploading content, you grant us a non-exclusive, royalty-free license to use, host, and display your content to operate and improve the App.

5. Objectionable Content and Abuse Policy
 • We will not post, upload, or share any content that is objectionable, abusive, harassing, hateful, sexually explicit, or illegal.
 • This app has a zero tolerance policy for harassment, abuse, or any harmful behavior directed toward other users.
 • Any user found engaging in such activities will have their content immediately removed and may be permanently banned from the app without warning.
 • Users can report objectionable content or block other users through in-app features, and all reports will be reviewed and acted upon within 24 hours.

6. Privacy
Your privacy is important to us. Please refer to our Privacy Policy to understand how we collect, use, and protect your personal information.

7. Termination
We reserve the right to suspend or terminate your access if you violate these Terms or misuse the App. You may delete your account at any time from within the app or by contacting us.

8. Disclaimers
	•	The App is provided “as is” and “as available.”
	•	We do not guarantee the App will be error-free or uninterrupted.
	•	We are not liable for any loss or damages resulting from use of the App.

9. Limitation of Liability
To the maximum extent permitted by law, TeamMates will not be liable for indirect, incidental, or consequential damages arising out of your use or inability to use the App.

10. Indemnification
You agree to indemnify and hold us harmless from any claims, liabilities, or damages resulting from your use of the App or violation of these Terms.

11. Changes to Terms
We may update these Terms at any time. We will notify you of significant changes, and your continued use after changes means you accept the updated Terms.

12. Governing Law
These Terms are governed by the laws of [Insert Jurisdiction, e.g., Ontario, Canada], without regard to its conflict of laws principles.

13. Contact Us
If you have questions about these Terms, contact us at:
Email: info@teammatesapp.org
      
      ''';
    }
    if (Get.arguments[0] == 5) {
      return '''
Effective Date: April 28, 2025

Thank you for supporting TeamMates! Before completing your subscription, please review these terms carefully. By subscribing, you agree to these Subscription Terms, our Terms of Service, and our Privacy Policy.

1. Subscription & Payment
When you subscribe to TeamMates, you authorize us to charge your provided payment method on a recurring basis.

- Annual Plan: Enjoy the first 3 months free. After that, your payment method will be charged annually unless canceled before the billing date.
- Monthly Plan: Billed immediately and then monthly.

Note: Subscription fees are non-refundable unless required by law.

2. Auto-Renewal & Billing
Subscriptions renew automatically at the end of each billing cycle at the current price. Any pricing changes will be communicated in advance.

3. Free Period Terms
To activate the annual plan, a valid payment method is required. Cancel before the end of the free 3-month period to avoid charges. If not canceled, the subscription continues and billing will begin.

4. Cancellation
You can cancel your subscription anytime from the TeamMates app settings.

- If canceled during the free period, no payment will be charged.
- If canceled after billing, access will continue until the end of the paid period. No refunds will be issued.

5. Refund Policy
All subscription payments are final and non-refundable, except where required by applicable law.

6. Changes to Terms
We may update these terms. If changes are significant, we will notify you. Continued use after changes means you accept the updated terms.

7. Contact Us
For help with your subscription or billing questions, please contact:
Email: info@teammatesapp.org

Cancel Anytime Policy:
- Cancel anytime from within the app settings.
- Cancel during the 3-month free period to avoid charges.
- No refunds are issued after billing.
- Once canceled, no further billing will occur.
''';
    }

    return "";
  }
}
