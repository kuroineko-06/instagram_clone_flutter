class User {
  final String name;
  final String uid;
  final String id_number;
  final String photoURL;
  final String email;
  final String dateOfBirth;
  final List followers;
  final List following;

  const User(
      {required this.name,
      required this.uid,
      required this.id_number,
      required this.photoURL,
      required this.email,
      required this.dateOfBirth,
      required this.followers,
      required this.following});

  factory User.fromJson(Map<String, dynamic> json) => User(
        name: json["name"],
        uid: json["uid"],
        id_number: json["id_number"],
        email: json["email"],
        photoURL: json["photoURL"],
        dateOfBirth: json["dateOfBirth"],
        followers: json["followers"],
        following: json["following"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "email": email,
        "uid": uid,
        "id_number": id_number,
        "photoURL": photoURL,
        "dateOfBirth": dateOfBirth,
        "followers": followers,
        "following": following,
      };
}
