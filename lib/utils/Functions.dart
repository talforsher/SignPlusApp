/**
 * A function to validate email
 * @param value - the email the to validate before sending validation
 * return String - if No mail was typed: "can't add empty email" , if mail was typed incorrectly: "invalid email", if mail is correct in the right form return null
 * */
String _validateEmail(String value) {
  if (value != null) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Can\'t add an empty email';
    } else {
      final regex = RegExp(
          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return null;
        }
      }
    }
  } else {
    return 'Can\'t add an empty email';
  }

  return 'Invalid email';
}
