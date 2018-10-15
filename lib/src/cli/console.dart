import 'dart:io';

class Console {
  final Stdout output;
  final Stdout error;
  final Stdin input;

  Console({Stdin input, Stdout output, Stdout error})
      : input = input ?? stdin,
        output = output ?? stdout,
        error = error ?? stderr;

  void logError(Object e) => error.writeln(e);

  void log(Object message) => output.writeln(message);
}
