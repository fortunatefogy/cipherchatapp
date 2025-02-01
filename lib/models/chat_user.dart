class ChatUser {
  ChatUser({
    required this.about,
    required this.name,
    required this.createdAt,
    required this.id,
    required this.lastActive,
    required this.isOnline,
    required this.pushToken,
    required this.email,
    required this.image,
// Added the cloudinaryImageUrl field
  });

  late String about;
  late String name;
  late String createdAt;
  late String id;
  late String lastActive;
  late bool isOnline;
  late String pushToken;
  late String email;
  late String image;
 // Added cloudinaryImageUrl field

  ChatUser.fromJson(Map<String, dynamic> json) {
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    id = json['id'] ?? '';
    lastActive = json['last_active'] ?? '';
    isOnline = json['is_online'] ?? false;
    pushToken = json['push_token'] ?? '';
    email = json['email'] ?? '';
    image = json['image'] ?? ''; // Fixed the space in the key name
     // Added cloudinaryImageUrl initialization
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['about'] = about;
    data['name'] = name;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['last_active'] = lastActive;
    data['is_online'] = isOnline;
    data['push_token'] = pushToken;
    data['email'] = email;
    data['image'] = image; // Fixed the space in the key name // Added cloudinaryImageUrl to JSON
    return data;
  }
}
