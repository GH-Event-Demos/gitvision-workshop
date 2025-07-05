// Type definitions for GitHub Models API responses

class GitHubModelsResponse {
  final String id;
  final String model;
  final List<GitHubModelsChoice> choices;
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  const GitHubModelsResponse({
    required this.id,
    required this.model,
    required this.choices,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  factory GitHubModelsResponse.fromJson(Map<String, dynamic> json) {
    return GitHubModelsResponse(
      id: json['id'] as String,
      model: json['model'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((c) => GitHubModelsChoice.fromJson(c as Map<String, dynamic>))
          .toList(),
      promptTokens: json['usage']['prompt_tokens'] as int,
      completionTokens: json['usage']['completion_tokens'] as int,
      totalTokens: json['usage']['total_tokens'] as int,
    );
  }
}

class GitHubModelsChoice {
  final int index;
  final GitHubModelsMessage message;
  final String? finishReason;

  const GitHubModelsChoice({
    required this.index,
    required this.message,
    this.finishReason,
  });

  factory GitHubModelsChoice.fromJson(Map<String, dynamic> json) {
    return GitHubModelsChoice(
      index: json['index'] as int,
      message: GitHubModelsMessage.fromJson(json['message'] as Map<String, dynamic>),
      finishReason: json['finish_reason'] as String?,
    );
  }
}

class GitHubModelsMessage {
  final String role;
  final String content;

  const GitHubModelsMessage({
    required this.role,
    required this.content,
  });

  factory GitHubModelsMessage.fromJson(Map<String, dynamic> json) {
    return GitHubModelsMessage(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}
