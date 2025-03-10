import '../../../services/api_client.dart';
import '../../models/message_model_new.dart';

class ChatRepository {
  final ApiClient apiClient = ApiClient();

  Future<List<Map<String, dynamic>>> getGroups() async => await apiClient.fetchGroups();

  Future<List<MessageModel>> getMessages(String groupId) async {
    final data = await apiClient.fetchMessages(groupId);
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  Future<void> sendMessage(String groupId, String message) async {
    await apiClient.sendMessage(groupId, message);
  }
}
