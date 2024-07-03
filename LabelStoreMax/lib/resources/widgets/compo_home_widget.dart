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
import 'package:flutter_app/resources/widgets/store_logo_widget.dart';
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

class _CompoHomeWidgetState extends NyState<CompoHomeWidget> {
  VideoPlayerController? _controller;

  ///HOME banner URL
  String? lifestyleBanner;

  @override
  boot() async {
    await _loadHome();
  }

  _loadFirebaseUrl() async {
    try {
      final ref = FirebaseDatabase.instance.ref("homeApp").child('lifestyleBanner');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        lifestyleBanner = snapshot.value.toString();
        _controller = VideoPlayerController.networkUrl(Uri.parse(lifestyleBanner ?? ""))
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
    await _loadFirebaseUrl();

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

  List<ProductCategory> categories = [];
  Map<ProductCategory, List<Product>> categoryAndProducts = {};

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> bannerImages = widget.wooSignalApp?.bannerImages ?? [];
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
                ...categoryAndProducts.entries.map((catProds) {
                  double containerHeight = size.height / 0.8;
                  bool hasImage = catProds.key.image != null;
                  if (hasImage == false) {
                    containerHeight = (containerHeight / 2);
                  }
                  return Container(
                    height: containerHeight,
                    width: size.width,
                    margin: EdgeInsets.only(top: 10),
                    child: Column(
                      children: [
                        if (hasImage)
                          InkWell(
                            child: CachedImageWidget(
                              image: catProds.key.image!.src,
                              height: containerHeight / 1.8,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                            onTap: () => _showCategory(catProds.key),
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
                                    width: size.width / 4,
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
                          height: hasImage ? (containerHeight / 2.2) / 1.2 : containerHeight / 1.2,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: false,
                            itemBuilder: (cxt, i) {
                              Product product = catProds.value[i];
                              return Container(
                                height: MediaQuery.of(cxt).size.height,
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
                if (bannerImages.isNotEmpty)
                  Container(
                    child: Column(
                      children: [
                        ///DONNA
                        GestureDetector(
                          child: Stack(
                            children: [
                              CachedImageWidget(
                                image: bannerImages[0],
                                height: size.height / 2.5,
                                width: size.width,
                                fit: BoxFit.cover,
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Donna",
                                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),

                        ///UOMO
                        Stack(
                          children: [
                            CachedImageWidget(
                              image: bannerImages[1],
                              height: size.height / 2.5,
                              width: size.width,
                              fit: BoxFit.cover,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Uomo",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    height: size.height / 2.5,
                  ),
                if (lifestyleBanner != null && _controller != null && _controller!.value.isInitialized)
                  GestureDetector(
                    onTap: () => openBrowserTab(url: 'https://markupitalia.com/primavera-estate-2024/'),
                    child: Container(
                      child: Center(
                        child: Stack(
                          children: [
                            VideoPlayer(_controller!),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Esplora Lifestyle",
                                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      height: size.height / 2.5,
                    ),
                  ),
              ],
            ),
    );
  }

  _showCategory(ProductCategory productCategory) {
    routeTo(BrowseCategoryPage.path, data: productCategory);
  }

  _showProduct(Product product) => routeTo(ProductDetailPage.path, data: product);
}
