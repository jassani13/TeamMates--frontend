# TeamMates--frontend

// Send a reaction using the unified API void 
sendMessageReaction({ required dynamic messageId, // String or int required String emoji, // e.g. '👍', '❤️' }) 
{ 
if (emoji.isEmpty) return; 
final mid = messageId.toString(); 
final payload = { 'message_id': mid, 'reaction_type': emoji, }; 
socket.emit('message_reaction', payload); 
}

