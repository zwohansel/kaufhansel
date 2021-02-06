class Version {
  final int _major;
  final int _minor;
  final int _patch;

  Version(this._major, this._minor, this._patch);

  factory Version.fromString(String version) {
    final versionNumbers = version.split(".").map(int.parse).toList(growable: false);
    if (versionNumbers.length != 3) {
      throw FormatException("Invalid version string: $version");
    }
    return Version(versionNumbers[0], versionNumbers[1], versionNumbers[2]);
  }

  bool isCompatibleTo(Version other) {
    return _major == other._major;
  }

  bool isMoreRecentThan(Version other) {
    if (_major > other._major) {
      return true;
    }

    if (_minor > other._minor) {
      return true;
    }

    return _patch > other._patch;
  }

  String toString() {
    return "$_major.$_minor.$_patch";
  }
}
