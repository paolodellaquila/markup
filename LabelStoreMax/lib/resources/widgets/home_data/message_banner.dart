import 'dart:convert';

class MessageBanner {
  ///HOME banner URL
  List<dynamic> messages;

  MessageBanner({
    this.messages = const [],
  });
}

class Message {
  final String title;
  final String? subtitle;

  const Message(this.title, {this.subtitle = null});

  static fromJsonString(String string) {
    final jsonData = json.decode(string);
    return Message(jsonData['title'], subtitle: jsonData['subtitle']);
  }
}
