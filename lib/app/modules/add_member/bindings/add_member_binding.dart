import 'package:get/get.dart';
import '../controllers/add_member_controller.dart';

class AddMemberBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddMemberController>(() => AddMemberController());
  }
}
