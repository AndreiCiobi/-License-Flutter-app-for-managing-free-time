enum PasswordConstraint {
  missingDigit(description: 'digit'),
  missingUppercase(description: 'uppercase'),
  missingLowercase(description: 'lowercase'),
  missingLength(description: '8 characters');

  const PasswordConstraint({required this.description});

  final String description;
}

class RegisterValidator {
  RegExp digitConstraint = RegExp(r'(?=.*[0-9])');
  RegExp uppercaseConstraint = RegExp(r'(?=.*[A-Z])');
  RegExp lowercaseConstraint = RegExp(r'(?=.*[a-z])');
  RegExp lengthConstraint = RegExp(r'(?=.{8,})');
  RegExp passwordConstraint =
      RegExp(r'(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.{8,})');
  RegExp emailConstraint = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,5}))$');

  String? validatePasswordResponse(String password) {
    List<PasswordConstraint> passwdCons = [];

    final input = password.trim();

    if (input.isEmpty) {
      return 'Minimum 8 characters, including uppercase, lowercase, digit';
    }
    if (passwordConstraint.hasMatch(input)) {
      return null;
    }
    if (!lengthConstraint.hasMatch(input)) {
      passwdCons.add(PasswordConstraint.missingLength);
    }
    if (!uppercaseConstraint.hasMatch(input)) {
      passwdCons.add(PasswordConstraint.missingUppercase);
    }
    if (!lowercaseConstraint.hasMatch(input)) {
      passwdCons.add(PasswordConstraint.missingLowercase);
    }
    if (!digitConstraint.hasMatch(input)) {
      passwdCons.add(PasswordConstraint.missingDigit);
    }

    return evaluatePasswordConstraints(passwdCons);
  }

  String? validateEmailResponse(String email) {
    final input = email.trim();
    return emailConstraint.hasMatch(input) ? null : 'Invalid email';
  }

  bool isPasswordValid(String password) {
    final input = password.trim();
    return passwordConstraint.hasMatch(input) ? true : false;
  }

  bool isEmailValid(String email) {
    final input = email.trim();
    return emailConstraint.hasMatch(input) ? true : false;
  }

  bool areCredentialsValid(String email, String password) {
    return isEmailValid(email) && isPasswordValid(password) ? true : false;
  }

  String evaluatePasswordConstraints(List<PasswordConstraint> passwdCons) {
    String response = '';
    if (passwdCons.contains(PasswordConstraint.missingLength)) {
      response += 'Minimum ${PasswordConstraint.missingLength.description}';
      passwdCons.remove(PasswordConstraint.missingLength);
      if (passwdCons.isNotEmpty) {
        response += ', including';
      }
    } else {
      response += 'Missing';
    }
    for (var element in passwdCons) {
      response += ' ${element.description},';
    }

    return response.substring(0, response.length - 1);
  }
}
