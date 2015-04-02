// Copyright 2015 Google. All rights reserved. Use of this source code is
// governed by a BSD-style license that can be found in the LICENSE file.

library grinder.src.cli;

import 'dart:async';
import 'dart:convert' show JSON, UTF8;
import 'dart:io';

import 'package:unscripted/unscripted.dart';

import 'singleton.dart';
import 'utils.dart';
import '../grinder.dart';

// This version must be updated in tandem with the pubspec version.
const String APP_VERSION = '0.7.0-dev.1';

List<String> grinderArgs() => _args;
List<String> _args;

Future handleArgs(List<String> args) {
  _args = args == null ? [] : args;

  cli(
    List<String> tasks,
    {@Flag(help: 'Print the version of grinder.')
     bool version,
     @Flag(help: 'Print the dependencies of tasks.')
     bool deps
    }) {

    if (version) {
      const String pubUrl = 'https://pub.dartlang.org/packages/grinder.json';

      print('grinder version ${APP_VERSION}');

      return httpGet(pubUrl).then((String str) {
        List versions = JSON.decode(str)['versions'];
        if (APP_VERSION != versions.last) {
          print("Version ${versions.last} is available! Run `pub global activate"
              " grinder` to get the latest version.");
        } else {
          print('grinder is up to date!');
        }
      }).catchError((e) => null);
    } else if (deps) {
      printDeps(grinder);
    } else {
      return grinder.start(tasks).catchError((e, st) {
        if (st != null) {
          print('\n${e}\n${st}');
        } else {
          print('\n${e}');
        }
        exit(1);
      });
    }
  }

  return declare(cli).execute(grinderArgs());
}

void printUsage(Grinder grinder) {
  if (!grinder.tasks.isEmpty) {
    List<GrinderTask> tasks = grinder.tasks.toList();
    tasks.forEach((t) {
      var buffer = new StringBuffer()..write('  $t');
      if (grinder.defaultTask == t) buffer.write(' (default)');
      if (t.description != null) buffer.write(' ${t.description}');
      print(buffer.toString());
    });
  }
}

void printDeps(Grinder grinder) {
  // calculate the dependencies
  grinder.start([], dontRun: true);

  if (grinder.tasks.isEmpty) {
    print("no grinder tasks defined");
  } else {
    print('grinder tasks:');
    print('');

    List<GrinderTask> tasks = grinder.tasks.toList();
    tasks.forEach((GrinderTask t) {
      t.description == null ? print("${t}") : print("  ${t} ${t.description}");

      if (!grinder.getImmediateDependencies(t).isEmpty) {
        print("  ${grinder.getAllDependencies(t).join(', ')}");
      }
    });
  }
}
