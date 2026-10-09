import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which app this build is. One codebase makes two apps: the app for
/// workspace members (`--flavor user`, or no flavor) and the Admin cabinet
/// (`--flavor admin`), each with its own id so both install side by side.
final adminAppProvider = Provider<bool>((_) => isAdminApp);

/// The same, for code that runs before the providers exist (main).
bool get isAdminApp => appFlavor == 'admin';
