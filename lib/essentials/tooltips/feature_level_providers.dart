/// Essentials Tooltips - Feature Level Providers
///
/// Public API for the tooltips system. Import this file to access
/// tooltip functionality from other features.
///
/// ## Usage
///
/// ```dart
/// import 'package:remember_this_text/essentials/tooltips/feature_level_providers.dart';
///
/// TooltipWrapper(
///   spec: TooltipSpec.contacts(ContactsTooltipSpec.editDisplayName()),
///   child: Icon(CupertinoIcons.pencil),
/// )
/// ```

// Application - Coordinator (rarely needed externally)
export 'application/tooltip_coordinator.dart';

// Domain - Specs and configuration
export 'domain/entities/tooltip_spec.dart';
export 'domain/tooltip_config.dart';

// Presentation - Widgets
export 'presentation/tooltip_wrapper.dart';
