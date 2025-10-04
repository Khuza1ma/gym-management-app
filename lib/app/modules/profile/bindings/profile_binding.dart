import 'package:get/get.dart';

import '../controllers/profile_controller.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/user_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<UserService>(() => UserService());
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
