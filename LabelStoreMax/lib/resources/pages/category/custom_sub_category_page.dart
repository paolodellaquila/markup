import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/category/sub_category_data.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/cached_image_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';

class BrowseCustomCategoryPage extends NyStatefulWidget {
  static String path = "/browse-custom-category";

  BrowseCustomCategoryPage({Key? key}) : super(path, key: key, child: _BrowseCategoriesPageState());
}

class _BrowseCategoriesPageState extends NyState<BrowseCustomCategoryPage> with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  SubCategoryData? _categoryData;

  TabController? _tabController;
  Map<String, List<ProductCategory>> subCategories = {};
  int _selectedCatId = 0;

  @override
  init() async {
    _categoryData = widget.controller.data();
  }

  _loadSubCategories() async {
    _selectedCatId = _categoryData?.mainCategories.first.id ?? 0;
    await _loadCategoryItems(_selectedCatId);

    _tabController = TabController(length: _categoryData?.mainCategories.length ?? 0, vsync: this);
    _tabController?.addListener(_tabChanged);

    setState(() {});
  }

  _tabChanged() {
    _selectedCatId = _categoryData?.mainCategories[_tabController!.index].id ?? 0;
    setState(() {});

    if (subCategories[_selectedCatId.toString()] != null) return;

    _loadCategoryItems(_selectedCatId);
  }

  _loadCategoryItems(int subCatId) async {
    List<ProductCategory> subCats = await (appWooSignal((api) => api.getProductCategories(parent: subCatId, perPage: 50, hideEmpty: true)));
    subCategories[subCatId.toString()] = subCats;
    setState(() {});
  }

  @override
  boot() async {
    await _loadSubCategories();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_categoryData?.title ?? ""),
      ),
      body: _categoryData == null || _tabController == null
          ? Center(
              child: AppLoaderWidget(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TabBar(
                    enableFeedback: true,
                    dividerHeight: 0,
                    tabAlignment: TabAlignment.fill,
                    indicatorSize: TabBarIndicatorSize.tab,
                    controller: _tabController,
                    tabs: _categoryData!.mainCategories.map((category) => Tab(text: category.name)).toList(),
                  ),
                  Expanded(
                    child: subCategories[_selectedCatId.toString()] == null
                        ? Center(
                            child: AppLoaderWidget(),
                          )
                        : TabBarView(
                            controller: _tabController,
                            children: _categoryData!.mainCategories.map((category) {
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
                                              ///Fix only for Outlet
                                              if (subCategory.id == 276 || subCategory.id == 275) {
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
