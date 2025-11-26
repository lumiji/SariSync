import 'package:firebase_auth/firebase_auth.dart';

class UserDisplay {
  static String getDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    final fullName = user?.displayName ?? 'User';

    final nameParts = fullName.split(' ');
    final displayName = nameParts.length >= 2
        ? '${nameParts[0]} ${nameParts[1]}'
        : fullName;

    return displayName;
  }
}
