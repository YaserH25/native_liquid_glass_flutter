import 'dart:async';
import 'dart:convert';
import 'dart:io';

const String _appId = 'com.example.nativeLiquidGlassFlutterExample';
const String _defaultDeviceName = 'iPhone';
const String _defaultOutputDirectory = 'doc/screenshots/gifs';
const String _flowDirectory = 'tool/maestro/showcase';

const List<ComponentRecording> _recordings = <ComponentRecording>[
  ComponentRecording(
    name: 'button',
    crop: Crop(x: 56, y: 420, width: 1094, height: 440),
    width: 360,
    playbackFps: 2,
    preserveSourceFrames: true,
  ),
  ComponentRecording(
    name: 'slider',
    crop: Crop(x: 56, y: 860, width: 1094, height: 580),
    width: 360,
  ),
  ComponentRecording(
    name: 'slider_endpoints',
    crop: Crop(x: 56, y: 1360, width: 1094, height: 560),
    width: 360,
    playbackFps: 5,
  ),
  ComponentRecording(
    name: 'switch',
    crop: Crop(x: 56, y: 1880, width: 1094, height: 400),
    width: 360,
    playbackFps: 5,
  ),
  ComponentRecording(
    name: 'segmented_stepper',
    crop: Crop(x: 56, y: 1420, width: 1094, height: 880),
    width: 360,
    playbackFps: 5,
    setupFlow: 'controls_segmented_stepper',
  ),
  ComponentRecording(
    name: 'sheet',
    crop: Crop(x: 0, y: 0, width: 1206, height: 2622),
    width: 320,
    playbackFps: 5,
    preserveSourceFrames: true,
    setupFlow: 'overlays_top',
  ),
  ComponentRecording(
    name: 'alert',
    crop: Crop(x: 0, y: 0, width: 1206, height: 2622),
    width: 320,
    playbackFps: 8,
    preserveSourceFrames: true,
    setupFlow: 'overlays_top',
  ),
  ComponentRecording(
    name: 'action_sheet',
    crop: Crop(x: 0, y: 0, width: 1206, height: 2622),
    width: 320,
    playbackFps: 8,
    holdSeconds: 2,
    preserveSourceFrames: true,
    setupFlow: 'overlays_top',
  ),
  ComponentRecording(
    name: 'menu',
    crop: Crop(x: 0, y: 0, width: 1206, height: 2622),
    width: 320,
    playbackFps: 8,
    preserveSourceFrames: true,
    setupFlow: 'overlays_top',
  ),
  ComponentRecording(
    name: 'pull_down',
    crop: Crop(x: 40, y: 760, width: 1126, height: 1180),
    width: 360,
    playbackFps: 8,
    preserveSourceFrames: true,
    setupFlow: 'overlays_pull_down',
  ),
];

Future<void> main(List<String> arguments) async {
  try {
    await runRecorder(arguments);
  } on Object catch (error) {
    fail(error.toString());
  }
}

Future<void> runRecorder(List<String> arguments) async {
  final options = RecorderOptions.parse(arguments);
  final repo = Directory.current;
  final example = Directory('${repo.path}/example');

  if (!example.existsSync()) {
    fail('Run this tool from the package root.');
  }

  await requireExecutable('ffmpeg');
  await requireExecutable('maestro');
  await requireExecutable('xcrun');

  final deviceId = options.deviceId ?? await findBootedSimulator(options);
  final outputDirectory = Directory(options.outputDirectory);
  final tempDirectory = Directory('/private/tmp/native-liquid-glass-gifs');
  final debugDirectory = Directory('/private/tmp/native-liquid-glass-maestro');

  await outputDirectory.create(recursive: true);
  await tempDirectory.create(recursive: true);
  await debugDirectory.create(recursive: true);

  await runChecked(<String>[
    'fvm',
    'flutter',
    'build',
    'ios',
    '--simulator',
    '--debug',
  ], workingDirectory: example.path);
  await runChecked(<String>[
    'xcrun',
    'simctl',
    'install',
    deviceId,
    'build/ios/iphonesimulator/Runner.app',
  ], workingDirectory: example.path);
  await runChecked(<String>[
    'xcrun',
    'simctl',
    'ui',
    deviceId,
    'appearance',
    options.appearance,
  ]);

  for (final recording in options.recordings) {
    await recordComponent(
      recording: recording,
      deviceId: deviceId,
      outputDirectory: outputDirectory,
      tempDirectory: tempDirectory,
      debugDirectory: debugDirectory,
      fps: options.fps,
    );
  }
}

Future<void> recordComponent({
  required ComponentRecording recording,
  required String deviceId,
  required Directory outputDirectory,
  required Directory tempDirectory,
  required Directory debugDirectory,
  required int fps,
}) async {
  final flow = File('$_flowDirectory/${recording.name}.yaml');
  final videoPath = '${tempDirectory.path}/${recording.name}.mp4';
  final gifPath = '${outputDirectory.path}/liquid-glass-${recording.name}.gif';

  if (!flow.existsSync()) {
    fail('Missing Maestro flow: ${flow.path}');
  }

  await runChecked(<String>[
    'xcrun',
    'simctl',
    'terminate',
    deviceId,
    _appId,
  ], allowFailure: true);

  await runChecked(<String>['xcrun', 'simctl', 'launch', deviceId, _appId]);
  await Future<void>.delayed(const Duration(seconds: 2));

  if (recording.setupFlow != null) {
    await runMaestroFlow(
      deviceId: deviceId,
      debugDirectory: debugDirectory,
      debugName: '${recording.name}_setup',
      flowPath: '$_flowDirectory/setup/${recording.setupFlow}.yaml',
    );
    await Future<void>.delayed(const Duration(seconds: 1));
  }

  final recorder = await startRecording(deviceId, videoPath);

  try {
    await runMaestroFlow(
      deviceId: deviceId,
      debugDirectory: debugDirectory,
      debugName: recording.name,
      flowPath: flow.path,
    );
  } finally {
    await stopRecording(recorder);
  }

  await convertVideoToGif(
    videoPath: videoPath,
    gifPath: gifPath,
    crop: recording.crop,
    width: recording.width,
    fps: fps,
    holdSeconds: recording.holdSeconds,
    playbackFps: recording.playbackFps ?? fps,
    preserveSourceFrames: recording.preserveSourceFrames,
  );

  final sizeKb = (File(gifPath).lengthSync() / 1024).round();
  stdout.writeln('Wrote $gifPath ($sizeKb KB)');
}

Future<void> runMaestroFlow({
  required String deviceId,
  required Directory debugDirectory,
  required String debugName,
  required String flowPath,
}) async {
  await runChecked(<String>[
    'maestro',
    '--udid',
    deviceId,
    'test',
    '--no-ansi',
    '--no-reinstall-driver',
    '--debug-output',
    '${debugDirectory.path}/$debugName',
    flowPath,
  ]);
}

Future<Process> startRecording(String deviceId, String videoPath) async {
  final process = await Process.start('xcrun', <String>[
    'simctl',
    'io',
    deviceId,
    'recordVideo',
    '--codec=h264',
    '--force',
    videoPath,
  ]);

  final started = Completer<void>();
  final stderrSubscription = process.stderr.transform(utf8.decoder).listen((
    chunk,
  ) {
    stderr.write(chunk);
    if (chunk.contains('Recording started') && !started.isCompleted) {
      started.complete();
    }
  });

  process.stdout.transform(utf8.decoder).listen(stdout.write);

  await started.future.timeout(
    const Duration(seconds: 20),
    onTimeout: () {
      throw TimeoutException(
        'Timed out waiting for simctl recording to start.',
      );
    },
  );

  await stderrSubscription.cancel();
  return process;
}

Future<void> stopRecording(Process process) async {
  process.kill(ProcessSignal.sigint);
  final code = await process.exitCode.timeout(const Duration(seconds: 20));
  if (code != 0) {
    fail('simctl recordVideo exited with code $code.');
  }
}

Future<void> convertVideoToGif({
  required String videoPath,
  required String gifPath,
  required Crop crop,
  required int width,
  required int fps,
  required int holdSeconds,
  required int playbackFps,
  required bool preserveSourceFrames,
}) async {
  final palettePath = '$gifPath.palette.png';
  final frameFilter = preserveSourceFrames
      ? 'crop=${crop.width}:${crop.height}:${crop.x}:${crop.y},'
            'scale=$width:-1:flags=lanczos,'
            'setpts=N/($playbackFps*TB),fps=$playbackFps'
      : 'fps=$fps,crop=${crop.width}:${crop.height}:${crop.x}:${crop.y},'
            'scale=$width:-1:flags=lanczos,mpdecimate,'
            'setpts=N/($playbackFps*TB),fps=$playbackFps';
  final filter = holdSeconds > 0
      ? '$frameFilter,tpad=stop_mode=clone:stop_duration=$holdSeconds'
      : frameFilter;

  await runChecked(<String>[
    'ffmpeg',
    '-y',
    '-i',
    videoPath,
    '-vf',
    '$filter,palettegen=stats_mode=diff',
    '-frames:v',
    '1',
    '-update',
    '1',
    palettePath,
  ]);

  await runChecked(<String>[
    'ffmpeg',
    '-y',
    '-i',
    videoPath,
    '-i',
    palettePath,
    '-lavfi',
    '$filter [x]; [x][1:v] paletteuse=dither=bayer:bayer_scale=2',
    gifPath,
  ]);

  await File(palettePath).delete();
}

Future<void> requireExecutable(String name) async {
  final result = await Process.run('which', <String>[name]);
  if (result.exitCode != 0) {
    fail('Required executable not found: $name');
  }
}

Future<String> findBootedSimulator(RecorderOptions options) async {
  final result = await Process.run('xcrun', <String>[
    'simctl',
    'list',
    'devices',
    'booted',
    '-j',
  ]);

  if (result.exitCode != 0) {
    fail('Unable to list booted simulators:\n${result.stderr}');
  }

  final payload = jsonDecode(result.stdout as String) as Map<String, Object?>;
  final devicesByRuntime =
      (payload['devices'] as Map<String, Object?>?) ?? <String, Object?>{};
  final devices = devicesByRuntime.values
      .whereType<List<Object?>>()
      .expand((runtimeDevices) => runtimeDevices)
      .whereType<Map<String, Object?>>();

  for (final device in devices) {
    final name = device['name'] as String? ?? '';
    final udid = device['udid'] as String?;
    final state = device['state'] as String?;

    if (udid != null &&
        state == 'Booted' &&
        name.contains(options.deviceName)) {
      return udid;
    }
  }

  fail(
    'No booted simulator matching "${options.deviceName}" was found. '
    'Boot an iPhone simulator or pass --device=<UDID>.',
  );
}

Future<void> runChecked(
  List<String> command, {
  String? workingDirectory,
  bool allowFailure = false,
}) async {
  stdout.writeln(command.join(' '));
  final process = await Process.start(
    command.first,
    command.skip(1).toList(),
    workingDirectory: workingDirectory,
  );

  process.stdout.transform(utf8.decoder).listen(stdout.write);
  process.stderr.transform(utf8.decoder).listen(stderr.write);

  final code = await process.exitCode;
  if (code != 0 && !allowFailure) {
    throw ToolFailure('${command.first} exited with code $code.');
  }
}

Never fail(String message) {
  stderr.writeln(message);
  exit(1);
}

class ToolFailure {
  const ToolFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class ComponentRecording {
  const ComponentRecording({
    required this.name,
    required this.crop,
    required this.width,
    this.holdSeconds = 0,
    this.playbackFps,
    this.preserveSourceFrames = false,
    this.setupFlow,
  });

  final String name;
  final Crop crop;
  final int holdSeconds;
  final int? playbackFps;
  final bool preserveSourceFrames;
  final String? setupFlow;
  final int width;
}

class Crop {
  const Crop({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}

class RecorderOptions {
  const RecorderOptions({
    required this.appearance,
    required this.deviceName,
    required this.fps,
    required this.outputDirectory,
    required this.recordings,
    this.deviceId,
  });

  final String appearance;
  final String? deviceId;
  final String deviceName;
  final int fps;
  final String outputDirectory;
  final List<ComponentRecording> recordings;

  static RecorderOptions parse(List<String> arguments) {
    var appearance = 'light';
    String? deviceId;
    var deviceName = _defaultDeviceName;
    var fps = 12;
    var outputDirectory = _defaultOutputDirectory;
    List<ComponentRecording>? selectedRecordings;

    for (final argument in arguments) {
      if (argument.startsWith('--appearance=')) {
        appearance = argument.valueAfterEquals;
      } else if (argument.startsWith('--component=')) {
        final names = argument.valueAfterEquals.split(',');
        selectedRecordings = _recordings
            .where((recording) => names.contains(recording.name))
            .toList();
      } else if (argument.startsWith('--device=')) {
        deviceId = argument.valueAfterEquals;
      } else if (argument.startsWith('--device-name=')) {
        deviceName = argument.valueAfterEquals;
      } else if (argument.startsWith('--fps=')) {
        fps = int.parse(argument.valueAfterEquals);
      } else if (argument.startsWith('--output-dir=')) {
        outputDirectory = argument.valueAfterEquals;
      } else if (argument == '--help' || argument == '-h') {
        stdout.writeln('''
Records focused Liquid Glass component GIFs on a booted iOS simulator.

Usage:
  fvm dart run tool/record_component_gifs.dart [options]

Options:
  --component=<names>      Comma-separated names. Default: all.
                           Available: ${_recordings.map((r) => r.name).join(', ')}
  --device=<UDID>          Use a specific booted simulator.
  --device-name=<name>     Match a booted simulator by name. Default: iPhone
  --appearance=<style>     light or dark. Default: light
  --output-dir=<path>      Default: $_defaultOutputDirectory
  --fps=<count>            GIF frames per second. Default: 12
''');
        exit(0);
      } else {
        fail('Unknown option: $argument');
      }
    }

    final recordings = selectedRecordings ?? _recordings;
    if (recordings.isEmpty) {
      fail('No matching component recordings were selected.');
    }

    return RecorderOptions(
      appearance: appearance,
      deviceId: deviceId,
      deviceName: deviceName,
      fps: fps,
      outputDirectory: outputDirectory,
      recordings: recordings,
    );
  }
}

extension on String {
  String get valueAfterEquals => substring(indexOf('=') + 1);
}
