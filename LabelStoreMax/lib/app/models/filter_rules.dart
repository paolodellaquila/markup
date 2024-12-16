import 'dart:collection';

import 'package:woosignal/models/response/product.dart';
import 'package:woosignal/models/response/product_attributes.dart';

class FilterRules {
  final HashMap<Category, bool> categories;
  final HashMap<Attribute, List<String>>? selectableAttributes;
  final List<Tag> hashTags;

  //Selected attributes
  final HashMap<Attribute, List<String>> selectedAttributes;
  final PriceRange selectedPriceRange;
  final HashMap<Tag, bool>? selectedHashTags;

  FilterRules(
      {required this.categories,
      required this.hashTags,
      this.selectedHashTags,
      selectedAttributes,
      this.selectableAttributes,
      required this.selectedPriceRange})
      : selectedAttributes = selectedAttributes ?? HashMap<Attribute, List<String>>();

  FilterRules copyWithAdditionalAttribute(Attribute attribute, String value) {
    HashMap<Attribute, List<String>>? updatedAttributes = selectableAttributes;
    if (updatedAttributes?.containsKey(attribute) ?? false) {
      updatedAttributes?[attribute]?.add(value);
    } else {
      updatedAttributes?[attribute] = [value];
    }
    return FilterRules(
        categories: categories,
        hashTags: hashTags,
        selectedHashTags: selectedHashTags,
        selectedPriceRange: selectedPriceRange,
        selectableAttributes: updatedAttributes);
  }

  /// this behavior can be changed in subclasses to show special attribute instead of first
  MapEntry<Attribute, List<String>>? get topmostOption => selectableAttributes?.entries?.isNotEmpty == true
      ? selectableAttributes?.entries?.first
      : MapEntry<Attribute, List<String>>(Attribute(-1, "", null, null, null, []), []);

  FilterRules copyWithRemovedAttributeValue(ProductAttribute attribute, String value) {
    HashMap<Attribute, List<String>>? updatedAttributes = selectableAttributes;
    updatedAttributes?[attribute]?.remove(value);
    if (updatedAttributes?[attribute]?.isEmpty == true) {
      updatedAttributes?.remove(attribute);
    }
    return FilterRules(
        categories: categories,
        hashTags: hashTags,
        selectedHashTags: selectedHashTags,
        selectedPriceRange: selectedPriceRange,
        selectableAttributes: updatedAttributes);
  }

  FilterRules copyWithPriceRange(PriceRange priceRange) {
    return FilterRules(
        categories: categories,
        hashTags: hashTags,
        selectedHashTags: selectedHashTags,
        selectedPriceRange: priceRange,
        selectableAttributes: selectableAttributes);
  }

  factory FilterRules.getSelectableAttributes(List<Product> products) {
    HashMap<Attribute, List<String>> returnAttributes = HashMap();
    //hashmap to store option list by id
    HashMap<int, List<String>> attributesIdToString = HashMap();
    //hashmap to store ProductAttribute by id
    HashMap<int, Attribute> attributesIdToAttribute = HashMap();
    //price ranges
    double maxPrice = 0;
    double minPrice = 0;
    List<int> categoryIds = [];
    HashMap<Category, bool> categories = HashMap();
    List<int> hashTagIds = [];
    List<Tag> hashTags = [];

    products.forEach((product) => {
          product.tags != null
              ? product.tags.forEach((Tag hashTag) => {
                    if (!hashTagIds.contains(hashTag.id)) {hashTagIds.add(hashTag.id!), hashTags.add(hashTag)}
                  })
              : {},
          product.attributes != null
              ?
              // returnAttributes.addAll({for (var attribute in product.selectableAttributes) attribute: []})
              product.attributes.forEach((attribute) => {
                    if (attribute != null)
                      {
                        if (attributesIdToString[attribute.id] == null)
                          {attributesIdToString[attribute.id!] = [], attributesIdToAttribute[attribute.id!] = attribute},
                        attributesIdToString[attribute.id]?.addAll(attribute.options?.toList() ?? [])
                      }
                  })
              : {},
          if (double.parse(product.price ?? "0") > maxPrice) maxPrice = double.parse(product.price ?? "0"),
          if (double.parse(product.price ?? "0") < minPrice) minPrice = double.parse(product.price ?? "0"),
          //TOOD: change to categories instead of categoryIds
          product.categories.forEach((Category category) => {
                if (!categoryIds.contains(category.id)) {categoryIds.add(category.id!), categories[category] = false}
              })
        });
    attributesIdToString.keys
        .forEach((attributeById) => {returnAttributes[attributesIdToAttribute[attributeById]!!] = attributesIdToString[attributeById]!.toSet().toList()});

    return FilterRules(
        categories: categories,
        selectableAttributes: returnAttributes,
        hashTags: hashTags,
        selectedHashTags: HashMap<Tag, bool>(),
        selectedPriceRange: PriceRange(minPrice, maxPrice));
  }

  factory FilterRules.getFavoriteSelectableAttributes(List<Product> favoriteProducts) {
    List<Product> products = [];
    favoriteProducts.forEach((favoriteProduct) {
      products.add(favoriteProduct);
    });
    return FilterRules.getSelectableAttributes(products);
  }
}

class PriceRange {
  final double minPrice;
  final double maxPrice;

  PriceRange(this.minPrice, this.maxPrice);
}
