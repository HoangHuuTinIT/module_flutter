import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/home_controller.dart';
import '../../app/models/photo.dart';
import '../widgets/animated_circular_notch.dart';
import '../widgets/photo_list_item.dart';
import 'collections_page.dart';


class HomePage extends NyStatefulWidget<HomeController> {
  static RouteView path = ("/home", (_) => HomePage());

  HomePage({super.key}) : super(child: () => _HomePageState());
}

class _HomePageState extends NyPage<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _homeScrollController = ScrollController();

  late AnimationController _bottomNavBarAnimationController;
  late Animation<double> _fabAndNotchAnimation;

  final double _bottomNavBarHeight = 70.0;
  final double _fabDiameter = 60.0;
  final double _fabMargin = 2.5;

  @override
  get init => () async {
    if (widget.controller.photos.value.isEmpty) {
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
    }
    else if (direction == ScrollDirection.forward) {
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
        child: SafeArea(child: TabBar(controller: _tabController, onTap: (index) { if (index == 0) { widget.controller.scrollToTop(_homeScrollController); } }, labelColor: Colors.black, indicatorColor: Colors.black, indicatorSize: TabBarIndicatorSize.tab, indicatorWeight: 3, labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04,), unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: screenWidth * 0.04,), tabs: const [Tab(text: "HOME"), Tab(text: "COLLECTIONS"),],),),
      ),
      body: TabBarView(
        controller: _tabController, physics: const NeverScrollableScrollPhysics(), children: [ValueListenableBuilder<List<Photo>>(
        valueListenable: widget.controller.photos,
        builder: (context, photoList, child) {
          // Lồng builder thứ 2 để lắng nghe isLoadingMorePhotos
          return ValueListenableBuilder<bool>(
            valueListenable: widget.controller.isLoadingMorePhotos,
            builder: (context, isLoadingMore, child) {
              // Gọi hàm build body với cả hai giá trị state
              return _buildHomeTabBody(photoList, isLoadingMore);
            },
          );
        },
      ),
        CollectionsPage(),],
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
            offset: Offset(0, (1 - _bottomNavBarAnimationController.value) * _bottomNavBarHeight),
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
                  IconButton(icon: const Icon(Icons.menu), color: Colors.grey.shade700, onPressed: () => _onIconTapped(0)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.search), color: Colors.grey.shade700, onPressed: () => _onIconTapped(1)),
                  IconButton(icon: const Icon(Icons.sort), color: Colors.grey.shade700, onPressed: () => _onIconTapped(2)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onIconTapped(int index) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on icon index $index'), duration: const Duration(seconds: 1), behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),), margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),),);
  }
  Widget _buildHomeTabBody(List<Photo> photoList, bool isLoadingMore) {
    final listVerticalPadding = MediaQuery.of(context).size.height * 0.02;
    final listBottomPadding = _bottomNavBarHeight + 20;

    if (photoList.isEmpty && !isLoadingMore) {
      return Center(child: LoadingAnimationWidget.fourRotatingDots(color: Colors.grey.shade400, size: 50,),);
    }

    return ListView.builder(
      padding: EdgeInsets.only(bottom: listBottomPadding, top: listVerticalPadding),
      controller: _homeScrollController,
      // ĐÃ SỬA: Dùng biến `isLoadingMore` từ builder
      itemCount: photoList.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= photoList.length) {
          return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator(color: Colors.black)),);
        }
        final photo = photoList[index];
        return PhotoListItem(photo: photo);
      },
    );
  }
}