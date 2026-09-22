import 'package:package_info_plus/package_info_plus.dart';

import '../../application/environment_package_info_reader.dart';

final class PlatformEnvironmentPackageInfoReader
    implements EnvironmentPackageInfoReader {
  const PlatformEnvironmentPackageInfoReader();

  @override
  Future<EnvironmentPackageInfoEvidence> read() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return EnvironmentPackageInfoEvidence(
      semanticVersion: packageInfo.version,
      buildNumber: packageInfo.buildNumber,
    );
  }
}
