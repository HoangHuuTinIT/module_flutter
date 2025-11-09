import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/controllers/collections_controller.dart';
import '../../app/models/collection.dart';
import '../widgets/home_collection_item.dart';

class CollectionsPage extends NyStatefulWidget<CollectionsController> {
  CollectionsPage({super.key}) : super(child: () => _CollectionsPageState());
}

class _CollectionsPageState extends NyPage<CollectionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
    if (widget.controller.allCollections.value.isEmpty) {
      await widget.controller.fetchInitialCollections();
    }
  };
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      widget.controller.handleCollectionsScroll(_scrollController);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    return ValueListenableBuilder<List<Collection>>(
        valueListenable: widget.controller.allCollections,
        builder: (context, collections, _) {
          if (collections.isEmpty && !widget.controller.isLoadingMoreCollections) {
            return Center(
              child: LoadingAnimationWidget.fourRotatingDots(
                color: Colors.grey.shade400,
                size: 50,
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: collections.length +
                (widget.controller.isLoadingMoreCollections ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= collections.length) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                      child: CircularProgressIndicator(color: Colors.black)),
                );
              }
              return HomeCollectionItem(collection: collections[index]);
            },
          );
        });
  }
}