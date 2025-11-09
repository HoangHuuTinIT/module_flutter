import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../models/collection.dart';
import '../networking/api_service.dart';
import 'controller.dart';

class CollectionsController extends Controller {
  CollectionsController._privateConstructor();
  static final CollectionsController _instance = CollectionsController._privateConstructor();
  static CollectionsController get instance => _instance;

  final ValueNotifier<List<Collection>> allCollections = ValueNotifier([]);
  int _allCollectionsPage = 1;
  bool isLoadingMoreCollections = false;
  bool _hasMoreCollections = true;

  Future<void> fetchInitialCollections() async {
    allCollections.value = [];
    _allCollectionsPage = 1;
    _hasMoreCollections = true;
    isLoadingMoreCollections = false;

    List<Collection>? initialCollections = await api<ApiService>(
            (request) => request.fetchAllCollections(page: _allCollectionsPage));

    if (initialCollections != null) {
      allCollections.value = initialCollections;
      if (initialCollections.length < 20) {
        _hasMoreCollections = false;
      }
    }
  }

  Future<void> fetchMoreCollections() async {
    if (isLoadingMoreCollections || !_hasMoreCollections) return;

    isLoadingMoreCollections = true;
    allCollections.notifyListeners();

    _allCollectionsPage++;

    List<Collection>? newCollections = await api<ApiService>(
            (request) => request.fetchAllCollections(page: _allCollectionsPage));

    if (newCollections != null) {
      if (newCollections.isEmpty || newCollections.length < 20) {
        _hasMoreCollections = false;
      }
      allCollections.value = List.from(allCollections.value)..addAll(newCollections);
    } else {
      _hasMoreCollections = false;
    }

    isLoadingMoreCollections = false;
  }

  void handleCollectionsScroll(ScrollController scrollController) {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.9) {
      fetchMoreCollections();
    }
  }
}