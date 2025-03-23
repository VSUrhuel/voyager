import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:voyager/src/features/authentication/models/user_model.dart';
import 'package:voyager/src/repository/authentication-repository/supabase_auth_repository.dart';

class SupabaseInstance {
  final _supabase = Supabase.instance.client;

  // Set or update a user in the 'users' table
  Future<void> setUser(UserModel user) async {
    try {
      await _supabase.from('users').upsert(user.toJson());
    } catch (e) {
      _handleError('Error setting user', e);
    }
  }

  // Fetch the role of a user based on their accountApiID
  Future<String> getUserRole(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select('accountRole')
          .eq('accountApiID', uid)
          .single();

      final String? role = response['accountRole'] as String?;
      return role ?? 'mentee'; // Default to 'mentee' if role is null
    } on PostgrestException catch (e) {
      _handleError('Error fetching user role', e);
      return 'mentee';
    } catch (e) {
      _handleError('Unexpected error fetching user role', e);
      return 'mentee';
    }
  }

  // Set or update a user from Google authentication
  Future<void> setUserFromGoogle(Rx<User?> user) async {
    try {
      if (user.value == null) throw Exception('User is null');

      final userEmail = user.value?.email;
      final userUid = user.value?.id;

      if (userUid == null || userEmail == null) {
        throw Exception('User UID or Email is null');
      }

      final auth = Get.put(AuthenticationRepository());
      if ((await getAPIIds()).contains(auth.supabaseUser.value?.id)) {
        return; // User already exists, no need to upsert
      }

      await _supabase.from('users').upsert({
        'accountApiID': userUid,
        'accountApiEmail': userEmail,
        'accountApiName': user.value?.userMetadata?['full_name'] ?? 'Unknown',
        'accountApiPhoto': user.value?.userMetadata?['avatar_url'] ?? '',
        'accountPassword': '', // No password for Google-authenticated users
        'accountUsername': user.value?.userMetadata?['full_name'] ?? 'Unknown',
        'accountRole': await getUserRole(userUid),
        'accountStudentId': '', // Default empty student ID
        'accountCreatedTimestamp': DateTime.now().toIso8601String(),
        'accountModifiedTimestamp': DateTime.now().toIso8601String(),
        'accountSoftDeleted': false,
      });
    } catch (e) {
      _handleError('Error setting user from Google', e);
    }
  }

  // Update the username of a user
  Future<void> updateUsername(String username, String uid) async {
    try {
      await _supabase
          .from('users')
          .update({'accountUsername': username}).eq('accountApiID', uid);
    } catch (e) {
      _handleError('Error updating username', e);
    }
  }

  // Update the student ID of a user
  Future<void> updateStudentID(String studentID, String uid) async {
    try {
      await _supabase
          .from('users')
          .update({'accountStudentId': studentID}).eq('accountApiID', uid);
    } catch (e) {
      _handleError('Error updating student ID', e);
    }
  }

  // Fetch all user IDs from the 'users' table
  Future<List<String>> getUserIDs() async {
    try {
      final users = await _supabase.from('users').select('accountApiID');
      return users
          .map<String>((user) => user['accountApiID'].toString())
          .toList();
    } catch (e) {
      _handleError('Error fetching user IDs', e);
      return [];
    }
  }

  // Fetch all mentor IDs from the 'mentors' table
  Future<List<String>> getMentorIDs() async {
    try {
      final mentors = await _supabase.from('mentors').select('id');
      return mentors.map<String>((mentor) => mentor['id'].toString()).toList();
    } catch (e) {
      _handleError('Error fetching mentor IDs', e);
      return [];
    }
  }

  // Fetch all account IDs from the 'mentors' table
  Future<List<String>> getAccountIDInMentor() async {
    try {
      final mentors = await _supabase.from('mentors').select('accountApiID');
      return mentors
          .map<String>((mentor) => mentor['accountApiID'].toString())
          .toList();
    } catch (e) {
      _handleError('Error fetching account IDs in mentors', e);
      return [];
    }
  }

  // Fetch all users from the 'users' table
  Future<List<UserModel>> getAllUsers() async {
    try {
      final users = await _supabase.from('users').select();
      return users.map<UserModel>((user) => UserModel.fromJson(user)).toList();
    } catch (e) {
      _handleError('Error fetching all users', e);
      return [];
    }
  }

  // Fetch a single user by accountApiID
  Future<UserModel> getUser(String id) async {
    try {
      final user = await _supabase
          .from('users')
          .select()
          .eq('accountApiID', id)
          .single();
      return UserModel.fromJson(user);
    } catch (e) {
      _handleError('Error fetching user', e);
      rethrow;
    }
  }

  // Fetch a user by email
  Future<UserModel> getUserThroughEmail(String email) async {
    try {
      final user = await _supabase
          .from('users')
          .select()
          .eq('accountApiEmail', email)
          .single();
      return UserModel.fromJson(user);
    } catch (e) {
      _handleError('Error fetching user by email', e);
      rethrow;
    }
  }

  Future<String> getSupabaseUser() async {
    try {
      final user = _supabase.auth.currentUser;
      return user!.id;
    } catch (e) {
      _handleError('Error fetching Supabase user', e);
      return '';
    }
  }

  // Fetch all accountApiIDs from the 'users' table
  Future<List<String>> getAPIIds() async {
    try {
      final users = await _supabase.from('users').select('accountApiID');
      return users
          .map<String>((user) => user['accountApiID'].toString())
          .toList();
    } catch (e) {
      _handleError('Error fetching accountApiIDs', e);
      return [];
    }
  }

  // Fetch all mentor accountApiIDs from the 'mentors' table
  Future<List<String>> getMentorApPIIds() async {
    try {
      final mentors = await _supabase.from('mentors').select('accountApiID');
      return mentors
          .map<String>((mentor) => mentor['accountApiID'].toString())
          .toList();
    } catch (e) {
      _handleError('Error fetching mentor accountApiIDs', e);
      return [];
    }
  }

  Future<String> getMentorID(String uid) async {
    try {
      final mentor = await _supabase
          .from('mentors')
          .select('id')
          .eq('accountApiID', uid)
          .single();
      return mentor['id'].toString();
    } catch (e) {
      _handleError('Error fetching mentor ID', e);
      return '';
    }
  }

  // Fetch all mentee accountApiIDs from the 'mentees' table
  Future<List<String>> getMenteeAPIIds() async {
    try {
      final mentees = await _supabase.from('mentees').select('accountApiID');
      return mentees
          .map<String>((mentee) => mentee['accountApiID'].toString())
          .toList();
    } catch (e) {
      _handleError('Error fetching mentee accountApiIDs', e);
      return [];
    }
  }

  // Fetch mentees based on allocation status
  Future<List<UserModel>> getMentees(String status) async {
    try {
      final menteeAllocations = await _supabase
          .from('mentee_course_alloc')
          .select()
          .eq('mca_alloc_status', status);

      final List<UserModel> users = [];
      for (var allocation in menteeAllocations) {
        final menteeId = allocation['mentee_id'];
        final mentee = await _supabase
            .from('mentees')
            .select()
            .eq('id', menteeId)
            .single();

        final user = await getUser(mentee['accountApiID']);
        users.add(user);
      }
      return users;
    } catch (e) {
      _handleError('Error fetching mentees', e);
      return [];
    }
  }

  // Helper method to handle errors consistently
  void _handleError(String message, dynamic error) {
    print('$message: $error');
    Get.snackbar('Error', message);
  }
}
