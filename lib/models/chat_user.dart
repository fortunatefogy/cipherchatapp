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
  });
  late final String about;
  late final String name;
  late final String createdAt;
  late final String id;
  late final String lastActive;
  late final bool isOnline;
  late final String pushToken;
  late final String email;
  late final String image;

  ChatUser.fromJson(Map<String, dynamic> json) {
    about = json['about']??'';
    name = json['name']??'';
    createdAt = json['created_at']??'';
    id = json['id']??'';
    lastActive = json['last_active']??'';
    isOnline = json['is_online']??'';
    pushToken = json['push_token']??'';
    email = json['email']??'';
    image = json['image ']??'';
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
    data['image '] = image;
    return data;
  }
}
