// lib/resources/pages/user_profile_page.dart

import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/user_profile_controller.dart';
import '../../app/models/user_detail.dart';
import '../../app/controllers/user_profile_state.dart';
import '../../constants/app_dimensions.dart';
import '../widgets/user_collections_tab.dart';
import '../widgets/user_likes_tab.dart';
import '../widgets/user_photos_tab.dart';
// Có thể bạn cần import widget này
import '../widgets/empty_state_widget.dart';

class UserProfilePage extends NyStatefulWidget<UserProfileController> {
  static RouteView path = ("/user-profile", (_) => UserProfilePage());

  UserProfilePage({super.key}) : super(child: () => _UserProfilePageState());
}

class _UserProfilePageState extends NyPage<UserProfilePage> {
  @override
  get init => () async {
    String? username = widget.data();
    if (username != null) {
      await widget.controller.fetchUserDetails(username);
      if (mounted && widget.controller.userProfileState.value.errorMessage == null) {
        // Chỉ fetch tab data nếu không có lỗi ở bước trước
        widget.controller.fetchTabsData(username);
      }
    }
  };


  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<UserProfileState>(
        valueListenable: widget.controller.userProfileState,
        builder: (context, state, child) {

          // ĐÃ THÊM: Ưu tiên kiểm tra lỗi trước
          if (state.errorMessage != null && !state.isUserLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(kSpacingLarge),
                // Bạn có thể dùng EmptyStateWidget hoặc 1 Text đơn giản
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }

          // Kiểm tra loading (như cũ)
          if (state.isUserLoading || state.userDetail == null) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: kLoaderSize,
              ),
            );
          }

          // Hiển thị nội dung (như cũ)
          return _buildUserProfile(context, state.userDetail!);
        },
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, UserDetail user) {
    final controller = widget.controller;
    return DefaultTabController(
      length: 3,
      child: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          // ... (Giữ nguyên SliverAppBar, SliverToBoxAdapter, SliverPersistentHeader) ...
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(user.username ?? "", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.normal)),
              centerTitle: false,
              titleSpacing: 0,
              actions: [
                IconButton(icon: Icon(Icons.public, color: Colors.black), onPressed: () {}),
                IconButton(icon: Icon(Icons.open_in_browser, color: Colors.black), onPressed: () {}),
              ],
              pinned: true,
              floating: true,
              elevation: 0,
              forceElevated: innerBoxIsScrolled,
            ),
            SliverToBoxAdapter(
              child: _buildHeader(context, user),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  tabs: [
                    Tab(text: 'PHOTOS'),
                    Tab(text: 'LIKES'),
                    Tab(text: 'COLLECTIONS'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: ValueListenableBuilder<UserProfileState>(
          valueListenable: controller.userProfileState,
          builder: (context, state, child) {

            // ĐÃ THÊM: Kiểm tra lỗi tải tab
            // (Chúng ta có thể hiện lỗi ở đây, hoặc để các tab tự xử lý)
            if (state.isTabsLoading) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.grey.shade400,
                  size: kLoaderSize,
                ),
              );
            }

            // Nếu lỗi xảy ra ở fetchTabsData, state.errorMessage sẽ không null
            // nhưng chúng ta vẫn muốn hiển thị các tab
            // (Một cách xử lý tốt hơn là mỗi tab có trạng thái lỗi riêng)
            // Hiện tại, chúng ta cứ hiển thị TabBarView

            return TabBarView(
              children: [
                UserPhotosTab(controller: controller),
                UserLikesTab(controller: controller),
                UserCollectionsTab(controller: controller),
              ],
            );
          },
        ),
      ),
    );
  }

  // ... (Các hàm _buildHeader, _buildStatColumn, _formatNumber, _SliverAppBarDelegate giữ nguyên) ...
  Widget _buildHeader(BuildContext context, UserDetail user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kSpacingLarge, vertical: kSpacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: kAvatarRadiusLarge,
                backgroundImage: NetworkImage(user.profileImage?.large ?? ""),
              ),
              SizedBox(width: kSpacingXLarge),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn("Photos", user.totalPhotos ?? 0),
                    _buildStatColumn("Likes", user.totalLikes ?? 0),
                    _buildStatColumn("Collections", user.totalCollections ?? 0),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: kSpacingMedium),
          Text(
            user.name ?? "",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          if (user.location != null && user.location!.isNotEmpty) ...[
            SizedBox(height: kSpacingExtraSmall),
            Text(
              user.location!,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            SizedBox(height: kSpacingSmall),
            Text(
              user.bio!,
              style: TextStyle(fontSize: 14),
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatNumber(count),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: kSpacingExtraSmall),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

}
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}