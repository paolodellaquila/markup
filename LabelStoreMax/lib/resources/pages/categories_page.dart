import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/browse_category_page.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/response/product_category.dart';
import 'package:woosignal/models/response/woosignal_app.dart';

class CategoriesPage extends StatelessWidget {
  static String path = "/categories";

  const CategoriesPage({super.key, required this.wooSignalApp, this.productCategories = const []});

  final WooSignalApp? wooSignalApp;
  final List<ProductCategory> productCategories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (wooSignalApp?.productCategoryCollections.isNotEmpty ?? false)
              Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                  child: Text(
                    trans("Categories".tr()),
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.left,
                  ),
                  padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
                ),
                ...productCategories.map((collection) {
                  return ListTile(
                    title: Text(
                      collection.name ?? "",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontSize: 16),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_right_rounded),
                    onTap: () {
                      routeTo(BrowseCategoryPage.path, data: collection);
                    },
                  );
                })
              ]),
          ],
        ),
      ),
    );
  }
}
