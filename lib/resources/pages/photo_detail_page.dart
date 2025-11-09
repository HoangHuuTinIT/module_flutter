import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import '../../app/controllers/photo_detail_page_controller.dart';
import '../../app/models/photo.dart';
import '../widgets/photo_info_section.dart';
import '../../app/states/photo_detail_state.dart';

class PhotoDetailPage extends NyStatefulWidget<PhotoDetailPageController> {
  static RouteView path = ("/photo-detail", (_) => PhotoDetailPage());

  PhotoDetailPage({super.key}) : super(child: () => _PhotoDetailPageState());
}

class _PhotoDetailPageState extends NyPage<PhotoDetailPage> {
  @override
  get init => () {
    widget.controller.setupInitial(widget.data());
    widget.controller.fetchFullDetails();
  };

  @override
  Widget view(BuildContext context) {
    final Photo initialPhoto = widget.data();
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 350,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (initialPhoto.blurHash != null)
                    BlurHash(hash: initialPhoto.blurHash!),
                  Image.network(
                    initialPhoto.urls?.regular ?? "",
                    fit: BoxFit.cover,
                    frameBuilder:
                        (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        child: child,
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child:
                        Icon(Icons.broken_image, color: Colors.grey[600]),
                      );
                    },
                  ),
                  ValueListenableBuilder<PhotoDetailState>(
                    valueListenable: widget.controller.photoState,
                    builder: (context, state, child) {
                      if (state.photo?.location?.displayName == null) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                state.photo!.location!.displayName ?? "",
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            PhotoInfoSection(
              controller: widget.controller,
              initialPhoto: initialPhoto,
            ),
          ],
        ),
      ),
    );
  }
}