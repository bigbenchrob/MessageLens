import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sidebar_navigation_restoration_policy_provider.g.dart';

/// Controls whether a newly constructed sidebar flow may restore durable
/// semantic navigation from the preference store.
///
/// Legacy compositions retain restoration by default. Compositions that need
/// a neutral first frame can override this at their root provider scope without
/// disabling persistence of subsequent same-session navigation mutations.
@riverpod
bool sidebarNavigationRestorationEnabled(Ref ref) {
  return true;
}
