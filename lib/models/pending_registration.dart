class PendingRegistration {
  final String? email;
  final String? password;
  final String? googleIdToken;
  final String? googleAccessToken;
  final String? facebookAccessToken;
  final String? phoneVerificationId;
  final String? phoneCode;
  final String accountType;
  final String displayIdentifier;

  PendingRegistration({
    this.email,
    this.password,
    this.googleIdToken,
    this.googleAccessToken,
    this.facebookAccessToken,
    this.phoneVerificationId,
    this.phoneCode,
    required this.accountType,
    required this.displayIdentifier,
  });
}