import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bootstrap/helpers.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:flutter_app/resources/pages/browse_search_page.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/buttons.dart';
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

class _CategoriesPageState extends NyState<CategoriesPage> with AutomaticKeepAliveClientMixin {
  List<ProductCategory> mainCategories = [];
  Map<String, List<ProductCategory>> subCategories = {};
  Map<String, List<ProductCategory>> outletSubCategories = {};

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _txtSearchController = TextEditingController();

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

      ///Only for outlet
      if (category.name == "Outlet") {
        for (ProductCategory subCat in subCats) {
          List<ProductCategory> subSubCats = await (appWooSignal((api) => api.getProductCategories(parent: subCat.id, perPage: 50, hideEmpty: true)));
          outletSubCategories[subCat.id.toString()] = subSubCats;
          subCategories[category.id.toString()] = subCats;
        }
      } else {
        subCategories[category.id.toString()] = subCats;
      }
    }
  }

  @override
  boot() async {
    await _loadCategories();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(trans("Categories")),
      ),
      body: mainCategories.isEmpty
          ? Center(
              child: AppLoaderWidget(),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
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
                        PrimaryButton(
                          title: trans("Search"),
                          action: _actionSearch,
                        ),
                        const SizedBox(height: 36),
                      ],
                    ),
                    // Wrapping ExpandedTileList in a ConstrainedBox to make it scrollable
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 0,
                        maxHeight: MediaQuery.of(context).size.height,
                      ),
                      child: Accordion(
                          scrollIntoViewOfItems: ScrollIntoViewOfItems.none,
                          disableScrolling: true,
                          scaleWhenAnimating: true,
                          openAndCloseAnimation: true,
                          headerBackgroundColor: Colors.grey.shade200,
                          headerPadding: EdgeInsets.symmetric(horizontal: 16),
                          rightIcon: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.black,
                            size: 20,
                          ),
                          contentBorderWidth: 0,
                          contentHorizontalPadding: 0,
                          sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                          sectionClosingHapticFeedback: SectionHapticFeedback.light,
                          children: mainCategories.map((item) {
                            return AccordionSection(
                              contentBorderColor: Colors.transparent,
                              header: Container(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text(
                                  item.name ?? "",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black,
                                      ),
                                ),
                              ),
                              content: Accordion(
                                scrollIntoViewOfItems: ScrollIntoViewOfItems.none,
                                disableScrolling: true,
                                scaleWhenAnimating: true,
                                openAndCloseAnimation: true,
                                headerBackgroundColor: Colors.grey.shade200,
                                headerPadding: EdgeInsets.symmetric(horizontal: 16),
                                rightIcon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                contentBorderWidth: 0,
                                contentHorizontalPadding: 0,
                                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                                sectionClosingHapticFeedback: SectionHapticFeedback.light,
                                children: subCategories[item.id.toString()]?.map((subItem) {
                                      return AccordionSection(
                                        onOpenSection: () {
                                          if ((item.name ?? "").toLowerCase().contains("outlet")) {
                                            return;
                                          }
                                          if ((subCategories[subItem.id.toString()] ?? []).isEmpty) {
                                            routeTo(BrowseCategoryPage.path, data: subItem);
                                          }
                                        },
                                        contentBackgroundColor: Colors.white,
                                        contentBorderColor: Colors.grey.shade300,
                                        header: Container(
                                          padding: EdgeInsets.symmetric(vertical: 16),
                                          child: Text(
                                            subItem.name ?? "",
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Colors.black,
                                                ),
                                          ),
                                        ),
                                        content: ((item.name ?? "").toLowerCase().contains("outlet"))
                                            ? Accordion(
                                                scrollIntoViewOfItems: ScrollIntoViewOfItems.none,
                                                disableScrolling: true,
                                                scaleWhenAnimating: true,
                                                openAndCloseAnimation: true,
                                                headerBackgroundColor: Colors.grey.shade200,
                                                headerPadding: EdgeInsets.symmetric(horizontal: 16),
                                                rightIcon: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black,
                                                  size: 20,
                                                ),
                                                contentBorderWidth: 0,
                                                contentHorizontalPadding: 0,
                                                sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
                                                sectionClosingHapticFeedback: SectionHapticFeedback.light,
                                                children: outletSubCategories[subItem.id.toString()]?.map((subItem) {
                                                      return AccordionSection(
                                                        onOpenSection: () {
                                                          if ((outletSubCategories[subItem.id.toString()] ?? []).isEmpty) {
                                                            routeTo(BrowseCategoryPage.path, data: subItem);
                                                          }
                                                        },
                                                        contentBackgroundColor: Colors.white,
                                                        contentBorderColor: Colors.grey.shade300,
                                                        header: Container(
                                                          padding: EdgeInsets.symmetric(vertical: 16),
                                                          child: Text(
                                                            subItem.name ?? "",
                                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                                  color: Colors.black,
                                                                ),
                                                          ),
                                                        ),
                                                        content: Container(
                                                          padding: EdgeInsets.symmetric(vertical: 16),
                                                          child: Text(
                                                            subItem.description ?? "",
                                                            style: Theme.of(context).textTheme.bodySmall,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList() ??
                                                    [],
                                              )
                                            : Container(
                                                padding: EdgeInsets.symmetric(vertical: 16),
                                                child: Text(
                                                  subItem.description ?? "",
                                                  style: Theme.of(context).textTheme.bodySmall,
                                                ),
                                              ),
                                      );
                                    }).toList() ??
                                    [],
                              ),
                            );
                          }).toList()),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
