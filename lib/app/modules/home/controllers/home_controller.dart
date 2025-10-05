import 'package:gym_management_app/app/data/models/member_model.dart';
import '../../../data/services/member_service.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final MemberService _memberService = MemberService();

  final RxList<Member> allMembers = <Member>[].obs;
  final RxList<Member> expiringMembers = <Member>[].obs;
  final RxList<Member> expiredMembers = <Member>[].obs;

  final RxBool isLoadingAllMembers = false.obs;
  final RxBool isLoadingExpiringMembers = false.obs;
  final RxBool isLoadingExpiredMembers = false.obs;

  final RxInt currentTabIndex = 0.obs;
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    loadAllMembers();
    loadExpiringMembers();
    loadExpiredMembers();

    debounce<String>(
      searchQuery,
      (_) => _handleSearchDebounced(),
      time: const Duration(milliseconds: 350),
    );
  }

  @override
  void onClose() {
    tabController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadAllMembers() async {
    try {
      isLoadingAllMembers.value = true;
      final members = await _memberService.getAllMembers();
      allMembers.assignAll(members);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load members: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAllMembers.value = false;
    }
  }

  Future<void> loadExpiringMembers() async {
    try {
      isLoadingExpiringMembers.value = true;
      final members = await _memberService.getMembersExpiringSoon();
      expiringMembers.assignAll(members);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load expiring members: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingExpiringMembers.value = false;
    }
  }

  Future<void> loadExpiredMembers() async {
    try {
      isLoadingExpiredMembers.value = true;
      final members = await _memberService.getExpiredMembers();
      expiredMembers.assignAll(members);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load expired members: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingExpiredMembers.value = false;
    }
  }

  Future<void> refreshData() async {
    final List<Future<void>> tasks = [];
    if (currentTabIndex.value == 0 && searchQuery.value.trim().isNotEmpty) {
      tasks.add(_performSearch());
    } else {
      tasks.add(loadAllMembers());
    }
    tasks.addAll([loadExpiringMembers(), loadExpiredMembers()]);
    await Future.wait(tasks);
  }

  void onTabChanged(int index) {
    currentTabIndex.value = index;
    tabController.animateTo(index);
  }

  void addMemberLocally(Member member) {
    allMembers.insert(0, member);

    final now = DateTime.now();
    final daysUntilExpiry = member.planEndDate.difference(now).inDays;

    if (member.planEndDate.isAfter(now) && daysUntilExpiry <= 7) {
      expiringMembers.insert(0, member);
      expiringMembers.sort((a, b) => a.planEndDate.compareTo(b.planEndDate));
    }

    if (member.planEndDate.isBefore(now)) {
      expiredMembers.insert(0, member);
    }
  }

  void updateMemberLocally(Member updatedMember) {
    final allIndex = allMembers.indexWhere((m) => m.id == updatedMember.id);
    if (allIndex != -1) {
      allMembers[allIndex] = updatedMember;
    }

    final expiringIndex = expiringMembers.indexWhere(
      (m) => m.id == updatedMember.id,
    );
    final now = DateTime.now();
    final daysUntilExpiry = updatedMember.planEndDate.difference(now).inDays;
    final shouldBeInExpiring =
        updatedMember.planEndDate.isAfter(now) && daysUntilExpiry <= 7;

    if (expiringIndex != -1 && !shouldBeInExpiring) {
      expiringMembers.removeAt(expiringIndex);
    } else if (expiringIndex == -1 && shouldBeInExpiring) {
      expiringMembers.add(updatedMember);
      expiringMembers.sort((a, b) => a.planEndDate.compareTo(b.planEndDate));
    } else if (expiringIndex != -1 && shouldBeInExpiring) {
      expiringMembers[expiringIndex] = updatedMember;
      expiringMembers.sort((a, b) => a.planEndDate.compareTo(b.planEndDate));
    }

    final expiredIndex = expiredMembers.indexWhere(
      (m) => m.id == updatedMember.id,
    );
    final isExpired = updatedMember.planEndDate.isBefore(now);

    if (expiredIndex != -1 && !isExpired) {
      expiredMembers.removeAt(expiredIndex);
    } else if (expiredIndex == -1 && isExpired) {
      expiredMembers.insert(0, updatedMember);
    } else if (expiredIndex != -1 && isExpired) {
      expiredMembers[expiredIndex] = updatedMember;
    }
  }

  void deleteMemberLocally(String memberId) {
    allMembers.removeWhere((m) => m.id == memberId);
    expiringMembers.removeWhere((m) => m.id == memberId);
    expiredMembers.removeWhere((m) => m.id == memberId);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    searchController.clear();
    if (searchQuery.value.isEmpty) return;
    searchQuery.value = '';
    loadAllMembers();
  }

  Future<void> _handleSearchDebounced() async {
    if (currentTabIndex.value != 0) return;
    await _performSearch();
  }

  Future<void> _performSearch() async {
    final q = searchQuery.value.trim();
    if (q.isEmpty) {
      await loadAllMembers();
      return;
    }
    try {
      isLoadingAllMembers.value = true;
      final results = await _memberService.searchMembers(query: q);
      allMembers.assignAll(results);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to search members: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingAllMembers.value = false;
    }
  }
}
