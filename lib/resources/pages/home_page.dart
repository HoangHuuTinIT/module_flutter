import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/home_controller.dart';
import '../../app/constants/app_dimensions.dart';
import '../widgets/animated_circular_notch.dart';
import '../widgets/photo_list_item.dart';
import 'collections_page.dart';
import '../../app/states/home_state.dart';

class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _homeScrollController = ScrollController();
  late AnimationController _bottomNavBarAnimationController;
  late Animation<double> _fabAndNotchAnimation;
  final double _bottomNavBarHeight = kBottomNavBarHeight;
  final double _fabDiameter = kFabDiameter;
  final double _fabMargin = kFabMargin;

  @override
  get init => () async {
    if (widget.controller.homeState.value.photos.isEmpty) {
      await widget.controller.fetchInitialPhotos();
    }
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _bottomNavBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    _fabAndNotchAnimation = CurvedAnimation(
      parent: _bottomNavBarAnimationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _homeScrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final direction = _homeScrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      if (_bottomNavBarAnimationController.status != AnimationStatus.reverse &&
          _bottomNavBarAnimationController.status != AnimationStatus.dismissed) {
        _bottomNavBarAnimationController.reverse();
      }
    } else if (direction == ScrollDirection.forward) {
      if (_bottomNavBarAnimationController.status != AnimationStatus.forward &&
          _bottomNavBarAnimationController.status != AnimationStatus.completed) {
        _bottomNavBarAnimationController.forward();
      }
    }
    if (_homeScrollController.position.pixels >=
        _homeScrollController.position.maxScrollExtent * 0.9) {
      widget.controller.fetchMorePhotos();
    }
  }

  @override
  void dispose() {
    _homeScrollController.removeListener(_handleScroll);
    _homeScrollController.dispose();
    _tabController.dispose();
    _bottomNavBarAnimationController.dispose();
    super.dispose();
  }


  @override
  Widget view(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final orientation = MediaQuery.of(context).orientation;
    final appBarHeight =
    orientation == Orientation.portrait ? screenHeight * 0.1 : 56.0;

    return Scaffold(
      primary: false,
      resizeToAvoidBottomInset: false,
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(appBarHeight),
        child: SafeArea(
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              if (index == 0) {
                widget.controller.scrollToTop(_homeScrollController);
              }
            },
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.04,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: screenWidth * 0.04,
            ),
            tabs: const [
              Tab(text: "HOME"),
              Tab(text: "COLLECTIONS"),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ValueListenableBuilder<HomeState>(
            valueListenable: widget.controller.homeState,
            builder: (context, state, child) {
              return _buildHomeTabBody(state);
            },
          ),
          CollectionsPage(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: AnimatedBuilder(
        animation: _fabAndNotchAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAndNotchAnimation.value,
            child: child,
          );
        },
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.black,
          shape: const CircleBorder(),
          elevation: 6.0,
          child: SizedBox(
            width: _fabDiameter,
            height: _fabDiameter,
            child: const Icon(Icons.add, color: Colors.white, size: 32),
          ),
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: _bottomNavBarAnimationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
                0, (1 - _bottomNavBarAnimationController.value) * _bottomNavBarHeight),
            child: BottomAppBar(
              height: _bottomNavBarHeight,
              color: Colors.white,
              elevation: 8.0,
              shape: AnimatedCircularNotch(
                growthAnimation: _fabAndNotchAnimation,
                notchMargin: _fabMargin,
              ),
              notchMargin: _fabMargin,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  IconButton(
                      icon: const Icon(Icons.menu),
                      color: Colors.grey.shade700,
                      onPressed: () => _onIconTapped(0)),
                  const Spacer(),
                  IconButton(
                      icon: const Icon(Icons.search),
                      color: Colors.grey.shade700,
                      onPressed: () => _onIconTapped(1)),
                  IconButton(
                      icon: const Icon(Icons.sort),
                      color: Colors.grey.shade700,
                      onPressed: () => _onIconTapped(2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onIconTapped(int index) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped on icon index $index'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildHomeTabBody(HomeState state) {
    final listVerticalPadding = kSpacingLarge;
    final listBottomPadding = _bottomNavBarHeight + kSpacingXLarge;
    if (state.errorMessage != null && !state.isRefreshing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    if (state.photos.isEmpty && !state.isLoadingMore && state.errorMessage == null) {
      return Center(
        child: LoadingAnimationWidget.fourRotatingDots(
          color: Colors.grey.shade400,
          size: 50,
        ),
      );
    }
    Widget listView = ListView.builder(
      padding:
      EdgeInsets.only(bottom: listBottomPadding, top: listVerticalPadding),
      controller: _homeScrollController,
      itemCount: state.photos.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.photos.length) {
          return const Padding(
            padding: EdgeInsets.all(kSpacingLarge),
            child: Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }
        final photo = state.photos[index];
        return PhotoListItem(photo: photo);
      },
    );
    return RefreshIndicator(
      onRefresh: widget.controller.onRefresh,
      child: listView,
    );
  }
}