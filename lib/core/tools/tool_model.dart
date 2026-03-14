class ToolModel {
  final String name;
  final String description;
  final Map<String, dynamic> parameters;
  final Future<String> Function(Map<String, dynamic> args) onExecute;

  ToolModel({
    required this.name,
    required this.description,
    required this.parameters,
    required this.onExecute,
  });

  Map<String, dynamic> toApiJson() {
    return {
      'type': 'function',
      'function': {
        'name': name,
        'description': description,
        'parameters': parameters,
      },
    };
  }
}
