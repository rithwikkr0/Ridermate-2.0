/// RiderMate 2.0 — Structured Prompt Builder
class PromptBuilder {
  final StringBuffer _buffer = StringBuffer();

  PromptBuilder addSystemRole(String role) {
    _buffer.writeln('SYSTEM: $role');
    return this;
  }

  PromptBuilder addContext(String contextKey, String value) {
    _buffer.writeln('CONTEXT [$contextKey]: $value');
    return this;
  }

  PromptBuilder addTask(String task) {
    _buffer.writeln('TASK: $task');
    return this;
  }

  String build() => _buffer.toString();
}
