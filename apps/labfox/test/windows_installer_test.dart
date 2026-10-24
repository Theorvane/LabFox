import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the Windows installer that ships beside the zip.
///
/// Windows is a direct download, not a store, so the release page is the
/// whole install experience. A zip asks the
/// user to unpack it somewhere sensible and make their own shortcut; an
/// installer is what a Windows user expects a download to be. Both ship: the
/// zip stays for anyone who wants a portable copy.
void main() {
  final workflow = File('../../.github/workflows/release.yml');
  final script = File('windows/installer/labfox.iss');

  test('the release workflow builds an installer, not only a zip', () {
    final contents = workflow.readAsStringSync();

    expect(
      contents,
      contains('windows/installer/labfox.iss'),
      reason: 'The Windows job must compile the Inno Setup script.',
    );
    expect(
      contents,
      contains('path: dist/*'),
      reason:
          'The uploaded artifact must cover the installer as well as the zip.',
    );
  });

  test('the installer script carries the version and the identity', () {
    expect(script.existsSync(), isTrue, reason: '${script.path} is missing');
    final contents = script.readAsStringSync();

    // Windows shows the publisher in the UAC prompt and in Apps & features.
    expect(contents, contains('AppPublisher=sloki9637'));
    // Passed in from the release version rather than hardcoded, so a release
    // cannot ship an installer claiming an older version.
    expect(contents, contains('AppVersion={#AppVersion}'));
    // A per-user install needs no administrator, which an unsigned installer
    // should not be asking for.
    expect(contents, contains('PrivilegesRequired=lowest'));
    expect(contents, contains('OutputBaseFilename=labfox-windows-x64-setup'));
  });
}
