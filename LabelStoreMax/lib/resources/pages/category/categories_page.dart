import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/pages/category/custom_sub_category_page.dart';
import 'package:flutter_app/resources/pages/category/sub_category_data.dart';
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
  TabController? _tabController;

  List<ProductCategory> mainCategories = [];
  Map<String, List<ProductCategory>> subCategories = {};

  final TextEditingController _txtSearchController = TextEditingController();
  bool isSearching = false;

  int _selectedCatId = 0;

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

    _selectedCatId = mainCategories.first.id!;
    await _loadCategoryItems(_selectedCatId);

    _tabController = TabController(length: mainCategories.length, vsync: this);
    _tabController?.addListener(_tabChanged);

    setState(() {});
  }

  ///reset selected outlet
  void _tabChanged() {
    _selectedCatId = mainCategories[_tabController!.index].id!;
    setState(() {});

    if (subCategories[_selectedCatId.toString()] != null) return;

    _loadCategoryItems(_selectedCatId);
  }

  _loadCategoryItems(int subCatId) async {
    List<ProductCategory> subCats = await (appWooSignal((api) => api.getProductCategories(parent: subCatId, perPage: 50, hideEmpty: true)));
    subCategories[subCatId.toString()] = subCats;
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
    _tabController?.dispose();
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
      body: _tabController == null
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
                    child: subCategories[_selectedCatId.toString()] == null
                        ? Center(
                            child: AppLoaderWidget(),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: mainCategories.map((category) {
                              final subCats = subCategories[category.id.toString()] ?? [];
                              return subCats.isEmpty
                                  ? SizedBox.shrink()
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
                                              ///Outlet sub category explore
                                              if (subCategory.id == 276 || subCategory.id == 275) {
                                                routeTo(BrowseCustomCategoryPage.path,
                                                    data: SubCategoryData(title: category.name ?? "", mainCategories: subCats));
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
