# Group Chat Backend Integration Guide

## Overview
This document outlines the backend requirements for the new custom group chat functionality implemented in the TeamMates Flutter app.

## Database Schema Changes

### New Tables

#### 1. custom_groups
```sql
CREATE TABLE custom_groups (
    group_id INT PRIMARY KEY AUTO_INCREMENT,
    group_name VARCHAR(255) NOT NULL,
    group_description TEXT,
    group_icon VARCHAR(500),
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (created_by) REFERENCES users(user_id)
);
```

#### 2. group_participants
```sql
CREATE TABLE group_participants (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    user_id INT NOT NULL,
    role ENUM('admin', 'member') DEFAULT 'member',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    added_by INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (group_id) REFERENCES custom_groups(group_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (added_by) REFERENCES users(user_id),
    UNIQUE KEY unique_group_user (group_id, user_id)
);
```

#### 3. custom_group_messages
```sql
CREATE TABLE custom_group_messages (
    group_chat_id INT PRIMARY KEY AUTO_INCREMENT,
    group_id INT NOT NULL,
    sender_id INT NOT NULL,
    msg TEXT,
    msg_type ENUM('text', 'media', 'pdf') DEFAULT 'text',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES custom_groups(group_id),
    FOREIGN KEY (sender_id) REFERENCES users(user_id)
);
```

#### 4. custom_group_message_reactions
```sql
CREATE TABLE custom_group_message_reactions (
    id INT PRIMARY KEY AUTO_INCREMENT,
    group_chat_id INT NOT NULL,
    user_id INT NOT NULL,
    reaction VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_chat_id) REFERENCES custom_group_messages(group_chat_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    UNIQUE KEY unique_user_message_reaction (group_chat_id, user_id, reaction)
);
```

## API Endpoints

### 1. Create Custom Group
- **Endpoint**: `POST /api/createCustomGroup`
- **Parameters**:
  ```json
  {
    "group_name": "string (required)",
    "group_description": "string (optional)",
    "group_icon": "string (optional)",
    "created_by": "int (required)",
    "participant_ids": ["int array (required, min 2)"]
  }
  ```
- **Response**:
  ```json
  {
    "ResponseCode": 1,
    "ResponseMsg": "Group created successfully",
    "data": {
      "group_id": "int",
      "group_name": "string",
      "created_at": "timestamp"
    }
  }
  ```

### 2. Get Custom Groups List
- **Endpoint**: `POST /api/getCustomGroupChatList`
- **Parameters**: `user_id`
- **Response**: Array of group chat data with last message info

### 3. Get Group Participants
- **Endpoint**: `POST /api/getGroupParticipants`
- **Parameters**: 
  ```json
  {
    "group_id": "int",
    "user_id": "int"
  }
  ```
- **Response**:
  ```json
  {
    "ResponseCode": 1,
    "participants": [
      {
        "user_id": "int",
        "first_name": "string",
        "last_name": "string",
        "profile": "string",
        "role": "admin|member",
        "joined_at": "timestamp"
      }
    ]
  }
  ```

### 4. Update Group Details
- **Endpoint**: `POST /api/updateCustomGroup`
- **Parameters**:
  ```json
  {
    "group_id": "int",
    "group_name": "string",
    "group_description": "string",
    "group_icon": "string",
    "updated_by": "int"
  }
  ```

### 5. Add Group Participant
- **Endpoint**: `POST /api/addGroupParticipant`
- **Parameters**:
  ```json
  {
    "group_id": "int",
    "participant_ids": ["int array"],
    "added_by": "int"
  }
  ```

### 6. Remove Group Participant
- **Endpoint**: `POST /api/removeGroupParticipant`
- **Parameters**:
  ```json
  {
    "group_id": "int",
    "participant_id": "int",
    "removed_by": "int"
  }
  ```

## Socket.IO Events

### 1. Get Custom Group Messages
- **Event**: `getCustomGroupMessageList`
- **Parameters**: `[user_id, group_id]`
- **Response Event**: `setCustomGroupMessageList`

### 2. Send Custom Group Message
- **Event**: `sendCustomGroupMessage`
- **Parameters**: `[message, sender_id, group_id, timestamp, message_type]`
- **Broadcast Event**: `setNewCustomGroupMessage`

### 3. Add Custom Group Reaction
- **Event**: `addCustomGroupReaction`
- **Parameters**: `[message_id, user_id, group_id, reaction]`
- **Broadcast Event**: `customGroupReactionUpdated`

### 4. Update Custom Group Chat List
- **Event**: `updateCustomGroupChatList`
- **Triggered when**: New message sent, group updated, etc.

## Permission Validation

### Admin-Only Actions
- Update group name/description/icon
- Add new participants
- Remove participants (except other admins)

### Validation Rules
1. Only group creators and admins can perform admin actions
2. Users can only access groups they are participants in
3. Minimum 3 participants required for group creation
4. Cannot remove the last admin from a group

## Integration Notes

### Existing Team Chat Compatibility
- Team chats continue using existing endpoints
- Custom groups use new endpoints
- Both types appear in the same chat list
- Socket events are differentiated by event names

### Chat Type Identification
The frontend differentiates chat types using the `chat_type` field:
- `'team'`: Existing team chats
- `'custom_group'`: New custom group chats
- `'personal'`: One-on-one chats

### Migration Considerations
1. No changes needed to existing team chat tables
2. New tables are independent additions
3. Existing chat functionality remains unchanged
4. User experience is seamless between chat types

## Testing Checklist

### API Testing
- [ ] Create custom group with valid participants
- [ ] Validate minimum participant requirement (3+)
- [ ] Test admin permission validation
- [ ] Verify participant add/remove functionality
- [ ] Test group details update

### Socket Testing
- [ ] Real-time message delivery in custom groups
- [ ] Reaction updates broadcast correctly
- [ ] Group list updates when changes occur
- [ ] Multiple concurrent group chats

### UI Integration
- [ ] Custom groups appear in chat list
- [ ] Group creation flow works end-to-end
- [ ] Admin controls only visible to admins
- [ ] Group management screen functions properly

## Error Handling

### Common Error Scenarios
1. **Insufficient permissions**: Return 403 with appropriate message
2. **Group not found**: Return 404 with error message
3. **Invalid participants**: Return 400 with validation errors
4. **Database errors**: Return 500 with generic error message

### Frontend Error Handling
The app displays user-friendly error messages via `AppToast.showAppToast()` for all error scenarios.