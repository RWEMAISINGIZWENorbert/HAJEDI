
import 'package:equatable/equatable.dart';

class AuthData extends Equatable { 
   final String? name;
   final String? role;

   const AuthData({this.name, this.role});

   factory AuthData.fromJson(Map<String, dynamic> json) {
     return AuthData(
       name: json['name'] as String?,
       role: json['role'] as String?,
     );
   }

   Map<String, dynamic> toJson() {
    return {
      'name': name,
      'role': role,
    };
  }

   @override
   List<Object?> get props => [name, role];
}