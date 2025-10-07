import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:gym_management_app/app/data/models/member_model.dart';

import '../../../core/theme/app_colors.dart';
import '../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../widgets/member_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gym Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        bottom: TabBar(
          controller: controller.tabController,
          indicatorColor: AppColors.surface,
          indicatorWeight: 3,
          dividerHeight: 0,
          labelColor: AppColors.surface,
          unselectedLabelColor: AppColors.surface.withValues(alpha: 0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          tabs: const [
            Tab(
              icon: Icon(FontAwesomeIcons.userGroup, size: 20),
              text: 'All Members',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.triangleExclamation, size: 20),
              text: 'Expiring Soon',
            ),
            Tab(
              icon: Icon(FontAwesomeIcons.hourglassEnd, size: 20),
              text: 'Expired',
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton.outlined(
              icon: const Icon(
                FontAwesomeIcons.user,
                color: AppColors.surface,
                size: 20,
              ),
              onPressed: () => Get.toNamed(Routes.PROFILE),
              style: IconButton.styleFrom(
                side: const BorderSide(color: AppColors.surface),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              tooltip: 'Profile',
            ),
          ),
        ],
      ),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          _buildAllMembersTab(),
          _buildExpiringMembersTab(),
          _buildExpiredMembersTab(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Get.toNamed(Routes.ADD_MEMBER);
            if (result is Member) {
              controller.addMemberLocally(result);
            }
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          icon: const FaIcon(FontAwesomeIcons.userPlus, size: 24),
          label: const Text(
            'Add Member',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildAllMembersTab() {
    return Obx(() {
      return Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: controller.isLoadingAllMembers.value
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : controller.allMembers.isEmpty
                ? _buildEmptyState(
                    icon: FontAwesomeIcons.userGroup,
                    title: 'No Members Yet',
                    subtitle: 'Add your first gym member to get started',
                  )
                : RefreshIndicator(
                    onRefresh: controller.refreshData,
                    color: AppColors.primary,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                          controller.loadNextAllMembersPage();
                        }
                        return false;
                      },
                      child: Obx(() {
                        final total = controller.allMembers.length;
                        final showFooter = controller.isLoadingMoreAll.value;
                        final itemCount = total + (showFooter ? 1 : 0);

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (showFooter && index == itemCount - 1) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }
                            final member = controller.allMembers[index];
                            return MemberCard(
                              member: member,
                              onTap: () => _editMember(member),
                            );
                          },
                        );
                      }),
                    ),
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildExpiringMembersTab() {
    return Obx(() {
      if (controller.isLoadingExpiringMembers.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.expiringMembers.isEmpty) {
        return _buildEmptyState(
          icon: FontAwesomeIcons.clock,
          title: 'No Expiring Members',
          subtitle: 'All members have valid memberships',
          color: Colors.green,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.expiringMembers.length,
          itemBuilder: (context, index) {
            final member = controller.expiringMembers[index];
            return MemberCard(
              member: member,
              isExpiring: true,
              onTap: () => _editMember(member),
            );
          },
        ),
      );
    });
  }

  Widget _buildExpiredMembersTab() {
    return Obx(() {
      if (controller.isLoadingExpiredMembers.value) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      if (controller.expiredMembers.isEmpty) {
        return _buildEmptyState(
          icon: FontAwesomeIcons.circleCheck,
          title: 'No Expired Members',
          subtitle: 'All members have active or upcoming plans',
          color: Colors.green,
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: AppColors.primary,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.expiredMembers.length,
          itemBuilder: (context, index) {
            final member = controller.expiredMembers[index];
            return MemberCard(member: member, onTap: () => _editMember(member));
          },
        ),
      );
    });
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? color,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 64, color: color ?? AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _editMember(Member member) async {
    final result = await Get.toNamed(
      Routes.ADD_MEMBER,
      arguments: {'isEditing': true, 'member': member},
    );

    if (result is Member) {
      controller.updateMemberLocally(result);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.setSearchQuery,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search by name or last name',
          hintStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            FontAwesomeIcons.magnifyingGlass,
            size: 18,
            color: AppColors.textSecondary,
          ),
          suffixIcon: Obx(() {
            final hasQuery = controller.searchQuery.value.trim().isNotEmpty;
            if (!hasQuery) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Clear',
              icon: const Icon(
                FontAwesomeIcons.xmark,
                size: 18,
                color: AppColors.textSecondary,
              ),
              onPressed: controller.clearSearch,
            );
          }),
          filled: true,
          fillColor: AppColors.surface.withValues(alpha: 0.06),
          border: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 12,
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _outlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary),
    );
  }
}
