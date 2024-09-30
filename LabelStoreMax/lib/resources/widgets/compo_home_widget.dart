//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:flutter_app/resources/widgets/home_data/home_banner.dart';
import 'package:flutter_app/resources/widgets/home_data/home_flash_promo.dart';
import 'package:flutter_app/resources/widgets/home_data/home_hottest.dart';
import 'package:flutter_app/resources/widgets/home_data/home_influencer.dart';
import 'package:flutter_app/resources/widgets/home_data/home_new_in_donna.dart';
import 'package:flutter_app/resources/widgets/home_data/home_new_in_uomo.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import 'package:flutter_app/utils/shake_service.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:marquee/marquee.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:video_player/video_player.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/helpers.dart';
import '/resources/pages/browse_category_page.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/notification_icon_widget.dart';

class CompoHomeWidget extends StatefulWidget {
  CompoHomeWidget({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  @override
  createState() => _CompoHomeWidgetState();
}

class _CompoHomeWidgetState extends NyState<CompoHomeWidget> with AutomaticKeepAliveClientMixin {
  VideoPlayerController? _controller;

  HomeBanner? homeBanner;
  HomeFlashPromo? homeFlashPromo;
  HomeHottest? homeHottest;
  HomeTrend? homeTrend;
  HomeNewInDonna? homeNewInDonna;
  HomeNewInUomo? homeNewInUomo;

  List<ProductCategory> categories = [];
  Map<ProductCategory, List<Product>> categoryAndProducts = {};

  PageController controller = PageController(initialPage: 0);
  bool loadHomeCompleted = false;

  @override
  boot() async {
    // Start listening for shake events
    ShakeService().startListening(context);
    await _loadHome();
  }

  @override
  void dispose() {
    // Stop listening for shake events
    ShakeService().dispose();
    _controller?.dispose();
    super.dispose();
  }

  _loadFirebaseData() async {
    if (loadHomeCompleted) return;

    try {
      final ref = FirebaseDatabase.instance.ref("homeApp");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final banner = snapshot.child("banner");
        final flashPromo = snapshot.child("flashPromo");
        final hottest = snapshot.child("hottest");
        final trend = snapshot.child("trend");
        final new_donna = snapshot.child("new-donna");
        final new_uomo = snapshot.child("new-uomo");

        ///Banner
        homeBanner = HomeBanner(
          homeTitle: banner.child("title").value.toString(),
          homeSubtitle: banner.child("subtitle").value.toString(),
          homeVideoBanner: banner.child("videoUrl").value.toString(),
          videoLink: banner.child("videoLink").value.toString(),
        );

        ///flash promo
        homeFlashPromo = HomeFlashPromo(
          title: flashPromo.child("title").value.toString(),
        );

        ///categories
        homeHottest = HomeHottest(
          title: hottest.child("title").value.toString(),
          subtitle: hottest.child("subtitle").value.toString(),
          images: (hottest.child("images").value as List<dynamic>).map((value) => value.toString()).toList(),
        );

        homeTrend = HomeTrend(
          title: trend.child("title").value.toString(),
          subtitle: trend.child("subtitle").value.toString(),
          images: (trend.child("images").value as List<dynamic>).map((value) => value.toString()).toList(),
        );

        homeNewInDonna = HomeNewInDonna(
          title: new_donna.child("title").value.toString(),
          subtitle: new_donna.child("subtitle").value.toString(),
          images: (new_donna.child("images").value as List<dynamic>).map((value) => value.toString()).toList(),
        );

        homeNewInUomo = HomeNewInUomo(
          title: new_uomo.child("title").value.toString(),
          subtitle: new_uomo.child("subtitle").value.toString(),
          images: (new_uomo.child("images").value as List<dynamic>).map((value) => value.toString()).toList(),
        );

        ///video controller
        _controller = VideoPlayerController.networkUrl(Uri.parse(homeBanner?.homeVideoBanner ?? ""))
          ..initialize().then((_) {
            setState(() {});
            _controller?.setVolume(0);
            _controller?.play();
            _controller?.setLooping(true);
          });

        loadHomeCompleted = true;
      } else {
        return;
      }
    } catch (e) {
      print("error: $e");
    }
  }

  _loadHome() async {
    await _loadFirebaseData();

    //HOME CATEGORIES
    ///new in donna 196
    ///new in uomo 195
    ///trend 393
    ///hottest 387
    List<int> productCategoryId = [393, 387];
    categories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, include: productCategoryId)));

    List<int> subNewproductCategoryId = [196, 195];
    categories.addAll(await (appWooSignal((api) => api.getProductCategories(parent: 193, perPage: 50, include: subNewproductCategoryId))));

    ///Add New in name
    final indexUomo = categories.indexWhere((cat) => (cat.slug ?? "").contains("uomo_174"));
    final indexDonna = categories.indexWhere((cat) => (cat.slug ?? "").contains("donna_173"));
    categories[indexUomo].name = "New in Uomo";
    categories[indexDonna].name = "New in Donna";

    categories.sort((a, b) => a.id!.compareTo(b.id!));

    for (var category in categories) {
      List<Product> products = await (appWooSignal(
        (api) => api.getProducts(
          perPage: 10,
          category: category.id.toString(),
          status: "publish",
          stockStatus: "instock",
        ),
      ));
      if (products.isNotEmpty) {
        categoryAndProducts.addAll({category: products});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: StoreLogo(),
        actions: [
          Flexible(
              child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: NotificationIcon(),
          )),
        ],
        elevation: 8,
      ),
      body: categoryAndProducts.isEmpty
          ? AppLoaderWidget()
          : PageView(
              controller: controller,
              scrollDirection: Axis.vertical,
              children: [
                ///1. Video Section
                _videoSectionWidget(
                  context,
                  homeBanner,
                  _controller,
                  homeFlashPromo,
                ),

                ///2. Category Cover Sections
                ...categoryAndProducts.entries.map((catProds) {
                  return _categoryCoverSection(context, catProds, homeTrend, homeHottest, homeNewInDonna, homeNewInUomo);
                }),
              ],
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

///1. Video Section
Widget _videoSectionWidget(BuildContext context, HomeBanner? homeBanner, VideoPlayerController? _controller, HomeFlashPromo? homeFlashPromo) {
  ///1A. Flash Promo Section
  Widget _flashPromoSectionWidget(BuildContext context, HomeFlashPromo? homeFlashPromo) {
    return Container(
      child: (homeFlashPromo != null && (homeFlashPromo.title ?? "").isNotEmpty)
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                SizedBox(
                  height: 22,
                  child: Marquee(
                    text: homeFlashPromo.title ?? "",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    blankSpace: 20.0,
                    velocity: 100.0,
                    pauseAfterRound: Duration(seconds: 1),
                    startPadding: 10.0,
                    accelerationDuration: Duration(seconds: 1),
                    accelerationCurve: Curves.linear,
                    decelerationDuration: Duration(milliseconds: 500),
                    decelerationCurve: Curves.easeOut,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  if (homeBanner?.homeVideoBanner != null && _controller != null && _controller.value.isInitialized) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 500),
        opacity: homeBanner?.homeVideoBanner != null ? 1 : 0,
        child: GestureDetector(
          onTap: () => openBrowserTab(url: homeBanner?.videoLink ?? ""),
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Container(
              child: Center(
                child: Stack(
                  children: [
                    VideoPlayer(
                      _controller,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              homeBanner?.homeTitle ?? "",
                              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                            ),
                            Text(
                              homeBanner?.homeSubtitle ?? "",
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                            ),
                            SizedBox(height: 32),
                            AnimatedOpacity(
                              opacity: 1.0,
                              duration: Duration(seconds: 1),
                              child: Icon(
                                Icons.keyboard_double_arrow_down,
                                color: Colors.white,
                                size: 32,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: _flashPromoSectionWidget(context, homeFlashPromo),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  return SizedBox.shrink();
}

///2. Category Cover Sections
Widget _categoryCoverSection(BuildContext context, MapEntry<ProductCategory, List<Product>> catProds, HomeTrend? homeTrend, HomeHottest? homeHottest,
    HomeNewInDonna? homeNewInDonna, HomeNewInUomo? homeNewInUomo) {
  List<String> _getCategoryImages(int catId) {
    switch (catId) {
      case 393:
        return homeTrend?.images ?? [];
      case 387:
        return homeHottest?.images ?? [];
      case 196:
        return homeNewInDonna?.images ?? [];
      case 195:
        return homeNewInUomo?.images ?? [];
    }
    return [];
  }

  String _getCatTitle(int catId) {
    switch (catId) {
      case 393:
        return homeTrend?.title ?? "";
      case 387:
        return homeHottest?.title ?? "";
      case 196:
        return homeNewInDonna?.title ?? "";
      case 195:
        return homeNewInUomo?.title ?? "";
    }
    return "";
  }

  String _getCatSubtitle(int catId) {
    switch (catId) {
      case 393:
        return homeTrend?.subtitle ?? "";
      case 387:
        return homeHottest?.subtitle ?? "";
      case 196:
        return homeNewInDonna?.subtitle ?? "";
      case 195:
        return homeNewInUomo?.subtitle ?? "";
    }
    return "";
  }

  _showCategory(ProductCategory productCategory) {
    routeTo(BrowseCategoryPage.path, data: productCategory);
  }

  return FlutterCarousel(
    options: CarouselOptions(
      viewportFraction: 1,
      height: MediaQuery.of(context).size.height,
      showIndicator: true,
      slideIndicator: CircularSlideIndicator(),
      indicatorMargin: 96,
    ),
    items: _getCategoryImages(catProds.key.id!).map((image) {
      return InkWell(
        child: Stack(
          children: [
            CachedImageWidget(
              image: image,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.2, bottom: 24.0, left: 8),
                child: Container(
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCatTitle(catProds.key.id!),
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                        ),
                        Text(
                          _getCatSubtitle(catProds.key.id!),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "View More".tr(),
                              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () => _showCategory(catProds.key),
      );
    }).toList(),
  );
}
