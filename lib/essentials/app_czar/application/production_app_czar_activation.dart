/// Source-controlled production AppCzar activation policy.
///
/// The only constructible value in the current product is [disabled]. There
/// is intentionally no runtime input, persisted setting, or alternate value
/// that can activate the incomplete production AppCzar composition.
final class ProductionAppCzarActivation {
  const ProductionAppCzarActivation._();

  static const disabled = ProductionAppCzarActivation._();

  bool get isEnabled => false;
}
