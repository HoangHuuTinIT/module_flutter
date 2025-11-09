import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/collection_detail_controller.dart';
import '../../app/models/collection.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/photo_list_item.dart';
import '../../app/states/collection_detail_state.dart';

class CollectionDetailPage extends NyStatefulWidget<CollectionDetailController> {
  static RouteView path = ("/collection-detail", (_) => CollectionDetailPage());

  CollectionDetailPage({super.key})
      : super(child: () => _CollectionDetailPageState());
}

class _CollectionDetailPageState extends NyPage<CollectionDetailPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
    widget.controller.setupInitial(widget.data());
    await widget.controller.fetchAllDetails();
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.controller.handleScroll(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    final Collection initialCollection = widget.data();
    final controller = widget.controller;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Text(initialCollection.title ?? "Collection",
            style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_browser, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: ValueListenableBuilder<CollectionDetailState>(
        valueListenable: controller.detailState,
        builder: (context, state, _) {
          if (state.errorMessage != null && !state.isLoading) {
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
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.detailedCollection?.description != null &&
                  state.detailedCollection!.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    state.detailedCollection!.description!,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      children: <TextSpan>[
                        TextSpan(
                            text: '${initialCollection.totalPhotos ?? 0} Photos',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold)),
                        TextSpan(text: ' • Curated by '),
                        TextSpan(
                            text: initialCollection.user?.name ?? 'Unknown',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Expanded(
                child: state.isLoading
                    ? Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.grey.shade400,
                    size: 50,
                  ),
                )
                    : state.photos.isEmpty
                    ? const EmptyStateWidget()
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: state.photos.length +
                      (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.photos.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Colors.black)),
                      );
                    }
                    return PhotoListItem(photo: state.photos[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}