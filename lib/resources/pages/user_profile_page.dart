import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/user_profile_controller.dart';
import '../../app/helpers/formatters.dart';
import '../../app/models/user_detail.dart';
import '../../app/states/user_profile_state.dart';
import '../../app/constants/app_dimensions.dart';
import '../widgets/user_collections_tab.dart';
import '../widgets/user_likes_tab.dart';
import '../widgets/user_photos_tab.dart';

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
          if (state.errorMessage != null && !state.isUserLoading) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(kSpacingLarge),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }
          if (state.isUserLoading || state.userDetail == null) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: kLoaderSize,
              ),
            );
          }
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
            if (state.isTabsLoading) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.grey.shade400,
                  size: kLoaderSize,
                ),
              );
            }
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
          Formatters.formatNumber(count),
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