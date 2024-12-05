import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CategoriesPage extends StatefulWidget {
  static String path = "/categories";

  const CategoriesPage({super.key, required this.wooSignalApp});

  final WooSignalApp? wooSignalApp;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends NyState<CategoriesPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late TabController _tabController;

  List<ProductCategory> mainCategories = [];
  Map<String, List<ProductCategory>> subCategories = {};
  Map<String, List<ProductCategory>> outlet = {};

  final TextEditingController _txtSearchController = TextEditingController();
  bool isSearching = false;
  int? selectedOutletId;

  int _previousTabIndex = 0;

  _loadCategories() async {
    // Define the static order
    final List<String> categoryOrder = ["New-in", "Donna", "Uomo", "Outlet"];

    if ((widget.wooSignalApp?.productCategoryCollections ?? []).isNotEmpty) {
      List<int> productCategoryId = widget.wooSignalApp?.productCategoryCollections.map((e) => int.parse(e.collectionId!)).toList() ?? [];
      mainCategories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true, include: productCategoryId)));

      // Sort categories by the static order defined above
      mainCategories.sort((category1, category2) {
        int index1 = categoryOrder.indexOf(category1.name ?? "");
        int index2 = categoryOrder.indexOf(category2.name ?? "");
        return index1.compareTo(index2);
      });

      // Remove uncategorized category
      mainCategories.removeWhere((element) => (element.name ?? "").contains("Uncategorized"));
    } else {
      mainCategories = await (appWooSignal((api) => api.getProductCategories(parent: 0, perPage: 50, hideEmpty: true)));

      // Sort categories by the static order
      mainCategories.sort((category1, category2) {
        int index1 = categoryOrder.indexOf(category1.name ?? "");
        int index2 = categoryOrder.indexOf(category2.name ?? "");
        return index1.compareTo(index2);
      });

      // Remove unwanted categories
      mainCategories.removeWhere((element) => (element.name ?? "").contains("Uncategorized"));
      mainCategories.removeWhere((element) => (element.name ?? "").contains("Special Price"));
    }

    for (ProductCategory category in mainCategories) {
      List<ProductCategory> subCats = await (appWooSignal((api) => api.getProductCategories(parent: category.id, perPage: 50, hideEmpty: true)));
      subCategories[category.id.toString()] = subCats;
    }

    _tabController = TabController(length: mainCategories.length, vsync: this);
    _tabController.addListener(_tabChanged);
    setState(() {});
  }

  ///reset selected outlet
  void _tabChanged() {
    selectedOutletId = null;
    outlet.clear();
    setState(() {});
  }

  _loadOutlet(int subCatId) async {
    ///Only for outlet
    List<ProductCategory> subSubCats = await (appWooSignal((api) => api.getProductCategories(parent: subCatId, perPage: 50, hideEmpty: true)));
    outlet[subCatId.toString()] = subSubCats;
    setState(() {});
  }

  _actionSearch() {
    if (_txtSearchController.text.isEmpty) return;
    if (_txtSearchController.text.length < 3) return;

    ///firebase
    FirebaseAnalytics.instance.logSearch(searchTerm: _txtSearchController.text);
    FacebookAppEvents().logViewContent(type: "search", id: _txtSearchController.text);

    routeTo(BrowseSearchPage.path, data: _txtSearchController.text, onPop: (value) {
      if (["notic", "compo"].contains(widget.wooSignalApp!.theme) == false) {
        Navigator.pop(context);
      }
    });
  }

  @override
  boot() async {
    await _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _txtSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Categories")),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
              });
            },
          ),
        ],
      ),
      body: mainCategories.isEmpty || (selectedOutletId != null && outlet.isEmpty)
          ? Center(
              child: AppLoaderWidget(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  if (isSearching) ...[
                    NyTextField.compact(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: trans("Search hint"),
                        hintStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.black),
                      ),
                      backgroundColor: Colors.grey.shade200,
                      controller: _txtSearchController,
                      style: Theme.of(context).textTheme.bodySmall,
                      keyboardType: TextInputType.text,
                      autocorrect: false,
                      autoFocus: false,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _actionSearch,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TabBar(
                    enableFeedback: true,
                    dividerHeight: 0,
                    tabAlignment: TabAlignment.fill,
                    indicatorSize: TabBarIndicatorSize.tab,
                    controller: _tabController,
                    tabs: mainCategories.map((category) => Tab(text: category.name)).toList(),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: mainCategories.map((category) {
                        final subCats = selectedOutletId != null ? outlet[selectedOutletId.toString()] ?? [] : subCategories[category.id.toString()] ?? [];
                        return subCats.isEmpty
                            ? Center(child: Text("No categories available".tr()))
                            : GridView.builder(
                                padding: const EdgeInsets.all(8),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.8,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: subCats.length,
                                itemBuilder: (context, index) {
                                  final subCategory = subCats[index];
                                  return Card(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        ///Fix only for Outlet
                                        if (subCategory.id == 276 || subCategory.id == 275) {
                                          setState(() {
                                            selectedOutletId = subCategory.id;
                                          });
                                          _loadOutlet(subCategory.id!);
                                          return;
                                        }
                                        routeTo(BrowseCategoryPage.path, data: subCategory);
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            if (subCategory.image?.src != null) ...[
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                                  child: CachedImageWidget(
                                                    image: subCategory.image?.src ?? "",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                                  child: Container(
                                                    color: Colors.black.withOpacity(0.1),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            // Stacked text
                                            Align(
                                              alignment: subCategory.image?.src == null ? Alignment.center : Alignment.bottomCenter,
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      (subCategory.name ?? "").replaceAll("&amp;", "&"),
                                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                            color: subCategory.image?.src == null ? Colors.black : Colors.white,
                                                          ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
