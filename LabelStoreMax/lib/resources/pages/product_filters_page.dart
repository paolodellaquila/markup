import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/filter_rules.dart';
import 'package:flutter_app/resources/widgets/app_loader_widget.dart';
import 'package:flutter_app/resources/widgets/filters/accept_bottom.dart';
import 'package:flutter_app/resources/widgets/filters/filter_selectable_item.dart';
import 'package:flutter_app/resources/widgets/filters/filter_selectable_visible_option.dart';
import 'package:flutter_app/resources/widgets/filters/price_range_slider.dart';
import 'package:flutter_app/utils/product_manager.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product.dart' as PR;

class ProductFiltersPage extends NyStatefulWidget {
  static String path = "/product-filters";

  ProductFiltersPage({Key? key}) : super(path, key: key, child: _ProductFiltersPageState());
}

class _ProductFiltersPageState extends NyState<ProductFiltersPage> {
  FilterRules? rules;

  _prepareFilters() {
    final data = widget.controller.data();

    List<PR.Product> products = data["products"];
    if (data["filters"] != null) {
      rules = data["filters"];
    } else {
      rules = FilterRules.getSelectableAttributes(products);
    }
  }

  @override
  boot() async {
    _prepareFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filters'.tr()),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                context.pop(result: {"rules": null});
              },
              child: Text('Clear filters'.tr()),
            ),
          ),
        ],
      ),
      body: rules == null
          ? AppLoaderWidget()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  OpenFlutterPriceRangeSlider(
                    selectedMin: rules!.selectedPriceRange.minPrice,
                    selectedMax: rules!.selectedPriceRange.maxPrice,
                    label: 'Price range'.tr(),
                    min: 0,
                    max: 1000,
                    onChanged: _changeSelectedPrice,
                  ),
                  if (rules!.selectableAttributes != null) ...[
                    ...rules!.selectableAttributes!
                        .map((attribute, selectedValues) => MapEntry(
                            attribute,
                            FilterSelectableVisibleOption<String>(
                              title: attribute.name ?? "",
                              onSelected: (String value) {
                                _onAttributeSelected(attribute, value);
                              },
                              children: Map.fromEntries(
                                (selectedValues).map(
                                  (option) => MapEntry(
                                    option,
                                    (attribute.name ?? "").contains("Colore")
                                        ? Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: rules!.selectedAttributes[attribute] != null
                                                      ? rules!.selectedAttributes[attribute]!.contains(option)
                                                          ? 36
                                                          : 32
                                                      : 32,
                                                  height: rules!.selectedAttributes[attribute] != null
                                                      ? rules!.selectedAttributes[attribute]!.contains(option)
                                                          ? 36
                                                          : 32
                                                      : 32,
                                                  decoration: BoxDecoration(
                                                    color: HexColor.fromHex(ProductManager().getColorsFromProductTaxomonies([option]).first.hex),
                                                    border: Border.all(
                                                        color: Colors.black38,
                                                        width: rules!.selectedAttributes[attribute] != null
                                                            ? rules!.selectedAttributes[attribute]!.contains(option)
                                                                ? 1
                                                                : 0.5
                                                            : 0.5),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                rules!.selectedAttributes[attribute] != null
                                                    ? rules!.selectedAttributes[attribute]!.contains(option)
                                                        ? Positioned.fill(
                                                            top: 0,
                                                            right: 0,
                                                            child: Icon(
                                                              Icons.check,
                                                              color: ProductManager().getColorsFromProductTaxomonies([option]).first.name.contains("Nero")
                                                                  ? Colors.white
                                                                  : Colors.black,
                                                              size: 16,
                                                            ),
                                                          )
                                                        : const SizedBox.shrink()
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          )
                                        : FilterSelectableItem(
                                            text: option,
                                            isSelected:
                                                rules!.selectedAttributes[attribute] != null ? rules!.selectedAttributes[attribute]!.contains(option) : false,
                                          ),
                                  ),
                                ),
                              ),
                            )))
                        .values
                        .toList(growable: false),
                  ],
                  // FilterSelectableVisibleOption<PR.Category>(
                  //   title: 'Category',
                  //   children: rules!.categories.map((category, isSelected) => MapEntry(
                  //       category,
                  //       FilterSelectableItem(
                  //         text: (category.name ?? "").replaceAll("&amp;", "&").tr(),
                  //         isSelected: isSelected,
                  //       ))),
                  //   onSelected: _onCategorySelected,
                  // ),
                ],
              ),
            ),
      bottomNavigationBar: AcceptBottomNavigation(
        onApply: () {
          context.pop(result: {"rules": rules});
        },
      ),
    );
  }

  void _onCategorySelected(PR.Category value) {
    setState(() {
      rules!.categories[value] = !rules!.categories[value]!;
    });
  }

  void _onAttributeSelected(PR.Attribute attribute, String value) {
    if (rules!.selectedAttributes[attribute] == null) {
      rules!.selectedAttributes[attribute] = [];
    }
    if (rules!.selectedAttributes[attribute]!.contains(value)) {
      setState(() {
        rules!.selectedAttributes[attribute]!.remove(value);
      });
    } else {
      setState(() {
        rules!.selectedAttributes[attribute]!.add(value);
      });
    }
  }

  void _changeSelectedPrice(RangeValues value) {
    setState(() {
      rules = rules!.copyWithPriceRange(PriceRange(value.start, value.end));
    });
  }
}
