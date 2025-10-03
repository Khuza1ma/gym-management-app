import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';
import '../../../data/services/auth_service.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(),
    );
  }
}
