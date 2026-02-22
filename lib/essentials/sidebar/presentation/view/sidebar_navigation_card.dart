import 'package:flutter/material.dart';

import '../../../../config/theme/spacing/app_spacing.dart';

/// A full-bleed card for "back to previous state" navigation controls.
///
/// ## UI Sweep Changes
///
/// Per the design contract, this widget now provides **no visual chrome**:
/// - No distinct background (inherits from SidebarPlane)
/// - Child widget owns all internal layout and interaction
///
/// Unlike [SidebarCassetteCard] (content with rhythm) or [SidebarInfoCard]
/// (explanatory text), this card type is designed for lightweight navigation
/// affordances that need to span the full width of the sidebar.
///
/// The child widget owns all internal padding, typography, and interaction
/// (hover states, tap targets, etc.). The card provides only consistent
/// vertical margins to occupy the cassette flow.
///
/// ## Intended use cases
/// - "Change contact…" back-link after a contact is selected
/// - Future "back to …" navigation controls in other cascades
class SidebarNavigationCard extends StatelessWidget {
  const SidebarNavigationCard({super.key, required this.child});

  /// The navigation control widget. Owns all internal layout and styling.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // No visual chrome: just vertical spacing to separate from adjacent items.
    // The SidebarPlane provides the background.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: child,
    );
  }
}
