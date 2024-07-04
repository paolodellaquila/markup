//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/home_data/home_banner.dart';
import 'package:flutter_app/resources/widgets/home_data/home_flash_promo.dart';
import 'package:flutter_app/resources/widgets/home_data/home_hottest.dart';
import 'package:flutter_app/resources/widgets/home_data/home_influencer.dart';
import 'package:flutter_app/resources/widgets/home_data/home_new_in_donna.dart';
import 'package:flutter_app/resources/widgets/home_data/home_new_in_uomo.dart';
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:marquee/marquee.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:video_player/video_player.dart';
import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

import '/bootstrap/helpers.dart';
import '/resources/pages/browse_category_page.dart';
import '/resources/pages/product_detail_page.dart';
import '/resources/widgets/app_loader_widget.dart';
import '/resources/widgets/buttons.dart';
import '/resources/widgets/cached_image_widget.dart';
import '/resources/widgets/notification_icon_widget.dart';
import '/resources/widgets/product_item_container_widget.dart';

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
  HomeInfluencer? homeInfluencer;
  HomeNewInDonna? homeNewInDonna;
  HomeNewInUomo? homeNewInUomo;

  @override
  boot() async {
    await _loadHome();
  }

  _loadFirebaseData() async {
    try {
      final ref = FirebaseDatabase.instance.ref("homeApp");
      final snapshot = await ref.get();
      if (snapshot.exists) {
        final banner = snapshot.child("banner");
        final flashPromo = snapshot.child("flashPromo");
        final hottest = snapshot.child("hottest");
        final influencer = snapshot.child("influencer");
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

        homeInfluencer = HomeInfluencer(
          title: influencer.child("title").value.toString(),
          subtitle: influencer.child("subtitle").value.toString(),
          images: (influencer.child("images").value as List<dynamic>).map((value) => value.toString()).toList(),
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
      } else {
        return true;
      }
    } catch (e) {
      print("error: $e");
    }
  }

  _loadHome() async {
    await _loadFirebaseData();

    //HOME CATEGORIES
    ///influencer 386
    ///hottest 387
    ///new in donna 196
    ///new in uomo 195
    List<int> productCategoryId = [386, 387];
    categories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, include: productCategoryId)));

    List<int> subNewproductCategoryId = [196, 195];
    categories.addAll(await (appWooSignal((api) => api.getProductCategories(parent: 193, perPage: 50, include: subNewproductCategoryId))));

    ///Add New in name
    final indexUomo = categories.indexWhere((cat) => (cat.slug ?? "").contains("uomo_174"));
    final indexDonna = categories.indexWhere((cat) => (cat.slug ?? "").contains("donna_173"));
    categories[indexUomo].name = "New in Uomo";
    categories[indexDonna].name = "New in Donna";

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

  List<String> _getCategoryImages(int catId) {
    switch (catId) {
      case 386:
        return homeInfluencer?.images ?? [];
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
      case 386:
        return homeInfluencer?.title ?? "";
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
      case 386:
        return homeInfluencer?.subtitle ?? "";
      case 387:
        return homeHottest?.subtitle ?? "";
      case 196:
        return homeNewInDonna?.subtitle ?? "";
      case 195:
        return homeNewInUomo?.subtitle ?? "";
    }
    return "";
  }

  List<ProductCategory> categories = [];
  Map<ProductCategory, List<Product>> categoryAndProducts = {};

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Size size = MediaQuery.of(context).size;
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
          : ListView(
              shrinkWrap: true,
              children: [
                if (homeBanner?.homeVideoBanner != null && _controller != null && _controller!.value.isInitialized)
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: homeBanner?.homeVideoBanner != null ? 1 : 0,
                    child: GestureDetector(
                      onTap: () => openBrowserTab(url: homeBanner?.videoLink ?? ""),
                      child: Container(
                        child: Center(
                          child: Stack(
                            children: [
                              VideoPlayer(_controller!),
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        homeBanner?.homeTitle ?? "",
                                        style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                                      ),
                                      Text(
                                        homeBanner?.homeSubtitle ?? "",
                                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        height: size.height / 3,
                      ),
                    ),
                  ),
                if (homeFlashPromo != null && (homeFlashPromo?.title ?? "").isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 20,
                    child: Marquee(
                      text: homeFlashPromo?.title ?? "",
                      style: TextStyle(fontWeight: FontWeight.bold),
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
                ...categoryAndProducts.entries.map((catProds) {
                  double containerHeight = size.height;
                  return Container(
                    height: containerHeight,
                    width: size.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FlutterCarousel(
                          options: CarouselOptions(
                            viewportFraction: 1,
                            height: containerHeight / 2.2,
                            showIndicator: true,
                            slideIndicator: CircularSlideIndicator(),
                          ),
                          items: _getCategoryImages(catProds.key.id!).map((image) {
                            return InkWell(
                              child: Stack(
                                children: [
                                  CachedImageWidget(
                                    image: image,
                                    height: containerHeight / 2.2,
                                    width: MediaQuery.of(context).size.width,
                                    fit: BoxFit.cover,
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 24.0, left: 8),
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
                        ),
                        const SizedBox(height: 16),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: 50,
                            minWidth: double.infinity,
                            maxHeight: 80.0,
                            maxWidth: double.infinity,
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    parseHtmlString(catProds.key.name!),
                                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, fontSize: 22),
                                    maxLines: 1,
                                  ),
                                ),
                                Flexible(
                                  child: Container(
                                    width: size.width / 3,
                                    child: LinkButton(
                                      title: trans("View All"),
                                      action: () => _showCategory(catProds.key),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: (containerHeight / 2.5) / 1.2,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: false,
                            itemBuilder: (cxt, i) {
                              Product product = catProds.value[i];
                              return Container(
                                height: (containerHeight / 2.2) / 1.2,
                                width: size.width / 2.5,
                                child: ProductItemContainer(product: product, onTap: () => _showProduct(product)),
                              );
                            },
                            itemCount: catProds.value.length,
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ],
            ),
    );
  }

  _showCategory(ProductCategory productCategory) {
    routeTo(BrowseCategoryPage.path, data: productCategory);
  }

  _showProduct(Product product) => routeTo(ProductDetailPage.path, data: product);

  @override
  bool get wantKeepAlive => true;
}
