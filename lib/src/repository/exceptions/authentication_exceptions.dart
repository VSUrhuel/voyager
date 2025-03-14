class AuthenticationExceptions {
  final String message;

  const AuthenticationExceptions([this.message = 'An unknown error occurred.']);

  factory AuthenticationExceptions.code(String code) {
    switch (code) {
      case 'email-already-in-use':
        return AuthenticationExceptions(
            'The email address is already in use. Please use a different email or log in.');

      case 'invalid-email':
        return AuthenticationExceptions(
            'The email address is not valid or is badly formatted. Please check and try again.');

      case 'weak-password':
        return AuthenticationExceptions(
            'The password is too weak. Please use a stronger password with at least 8 characters, including numbers and symbols.');

      case 'user-disabled':
        return AuthenticationExceptions(
            'This account has been disabled. Please contact support for assistance.');

      case 'operation-not-allowed':
        return AuthenticationExceptions(
            'This operation is not allowed. Please contact support for more information.');

      case 'user-not-found':
        return AuthenticationExceptions(
            'No account found for the provided email. Please check the email address or sign up.');

      case 'wrong-password':
        return AuthenticationExceptions(
            'The password entered is incorrect. Please try again.');

      case 'account-exists-with-different-credential':
        return AuthenticationExceptions(
            'An account already exists with a different sign-in method. Please use that method to log in.');

      case 'invalid-credential':
        return AuthenticationExceptions(
            'The credentials provided are invalid. Please try again or reset your password.');

      case 'credential-already-in-use':
        return AuthenticationExceptions(
            'This credential is already associated with another account. Please try a different one.');

      case 'expired-action-code':
        return AuthenticationExceptions(
            'The action code has expired. Please request a new one and try again.');

      case 'invalid-action-code':
        return AuthenticationExceptions(
            'The action code is invalid. Please request a new one and try again.');

      case 'requires-recent-login':
        return AuthenticationExceptions(
            'This action requires recent authentication. Please log in again and try.');

      case 'network-request-failed':
        return AuthenticationExceptions(
            'A network error occurred. Please check your connection and try again.');

      case 'too-many-requests':
        return AuthenticationExceptions(
            'Too many requests have been made in a short period. Please wait and try again later.');

      case 'cookies-not-enabled':
        return AuthenticationExceptions(
            'Cookies are not enabled in your browser. Please enable cookies and try again.');

      case 'session-cookie-expired':
        return AuthenticationExceptions(
            'Your session has expired. Please log in again.');

      case 'invalid-session-cookie':
        return AuthenticationExceptions(
            'Your session cookie is invalid. Please log in again.');

      case 'internal-error':
        return AuthenticationExceptions(
            'An internal error occurred. Please try again later or contact support.');

      case 'invalid-verification-code':
        return AuthenticationExceptions(
            'The verification code entered is invalid. Please check the code and try again.');

      case 'invalid-verification-id':
        return AuthenticationExceptions(
            'The verification ID provided is invalid. Please request a new code and try again.');

      case 'missing-verification-code':
        return AuthenticationExceptions(
            'The verification code is missing. Please check your message and enter the code.');

      case 'missing-verification-id':
        return AuthenticationExceptions(
            'The verification ID is missing. Please restart the process.');

      case 'app-not-authorized':
        return AuthenticationExceptions(
            'This app is not authorized to use Firebase Authentication. Please contact support.');

      case 'quota-exceeded':
        return AuthenticationExceptions(
            'The quota for authentication requests has been exceeded. Please try again later.');

      case 'timeout':
        return AuthenticationExceptions(
            'The operation timed out. Please check your connection and try again.');

      case 'unauthorized-domain':
        return AuthenticationExceptions(
            'This domain is not authorized to perform this operation. Please contact support.');

      case 'email-change-needed':
        return AuthenticationExceptions(
            'You need to change your email address. Please update it and try again.');

      case 'multi-factor-auth-required':
        return AuthenticationExceptions(
            'Multi-factor authentication is required. Please complete the additional verification.');

      default:
        return AuthenticationExceptions(
            'An unknown error occurred. Please try again or contact support.');
    }
  }
}
