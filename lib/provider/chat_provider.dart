import 'package:material_ui/material_ui.dart';
import 'package:netshare/entity/message.dart';
import 'package:netshare/entity/message_state.dart';

class ChatProvider extends ChangeNotifier {
  final List<Message> _messages = [];
  List<Message> get messages => _messages;


  void addMessage({required Message message}) {
    _messages.add(message);
    notifyListeners();
  }

  void addAllMessages({required Set<Message> messages, bool isAppending = false}) {
    if(!isAppending) {
      _messages.clear();
    }
    _messages.addAll(messages);
    notifyListeners();
  }

  void clearAllMessages() {
    _messages.clear();
    notifyListeners();
  }

  void updateMessage({
    required Message sourceMessage,
    String? newText,
    bool? isDeleted,
    MessageState? messageState,
  }) {
    if(_messages.isEmpty) return;
    Message? oldMessage;
    try {
      oldMessage = _messages.firstWhere((message) => message == sourceMessage);
    } catch (e) {
      oldMessage == null;
    }
    if(oldMessage == null)  return;
    final oldIndex = _messages.indexOf(oldMessage);
    final updatedMessage = oldMessage.copyWith(
      text: newText,
      isDeleted: isDeleted,
      messageState: messageState,
    );
    _messages[oldIndex] = updatedMessage;
    notifyListeners();
  }
}