
import 'dart:io';

import 'package:pub_cache/pub_cache.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

getLocalVersion(String package) {
  //  pub_cache:
  //    description:
  //      ref: null
  //      resolved-ref: "79e391c85396f39d376135980def2cc05ab87170"
  //      url: "git://github.com/dart-lang/pub_cache.git"
  //    source: git
  //    version: "0.0.1+2"

  var lockfile;
  try {
    lockfile = loadYaml(new File("pubspec.lock").readAsStringSync());
  } on FormatException catch (_) {
    return null;
  } on IOException catch (_) {
    return null;
  }

  if (lockfile is! Map) return null;
  var packages = lockfile["packages"];
  if (packages is! Map) return null;
  var package = packages["test"];
  if (package is! Map) return null;

  var source = package["source"];
  if (source is! String) return null;

  switch (source) {
    case "hosted":
      var version = package["version"];
      if (version is! String) return null;

      print(version);
      return true;

    case "git":
      var version = package["version"];
      if (version is! String) return null;
      var description = package["description"];
      if (description is! Map) return null;
      var ref = description["resolved-ref"];
      if (ref is! String) return null;

      print("$version (${ref.substring(0, 7)})");
      return true;

    case "path":
      var version = package["version"];
      if (version is! String) return null;
      var description = package["description"];
      if (description is! Map) return null;
      var path = description["path"];
      if (path is! String) return null;

      print("$version (from $path)");
      return true;

    default: return null;
  }
}

Version getGlobalVersion(String package) {
  var cache = new PubCache();

  var apps = cache.getGlobalApplications();

  var app = apps.firstWhere((Application app) => app.name == package);

  return app.version;
}