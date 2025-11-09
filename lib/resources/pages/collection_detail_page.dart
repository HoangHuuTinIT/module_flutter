import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../app/controllers/collection_detail_controller.dart';
import '../../app/models/collection.dart';
import '../../app/models/photo.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/photo_list_item.dart';

class CollectionDetailPage extends NyStatefulWidget<CollectionDetailController> {
  static RouteView path = ("/collection-detail", (_) => CollectionDetailPage());

  CollectionDetailPage({super.key}) : super(child: () => _CollectionDetailPageState());
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<Collection?>(
            valueListenable: controller.detailedCollection,
            builder: (context, detailedCollection, child) {
              if (detailedCollection?.description == null ||
                  detailedCollection!.description!.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Text(
                  detailedCollection.description!,
                  style: TextStyle(color: Colors.black, fontSize: 14 , fontWeight: FontWeight.bold),
                ),
              );
            },
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
            child: ValueListenableBuilder<bool>(
              valueListenable: controller.isLoading,
              builder: (context, isLoading, child) {
                if (isLoading) {
                  return Center(
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: Colors.grey.shade400,
                      size: 50,
                    ),
                  );
                }
                return ValueListenableBuilder<List<Photo>>(
                    valueListenable: controller.photos,
                    builder: (context, photos, _) {
                      if (photos.isEmpty) {
                        return const EmptyStateWidget();
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        itemCount:
                        photos.length + (controller.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= photos.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.black)),
                            );
                          }
                          return PhotoListItem(photo: photos[index]);
                        },
                      );
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}