import 'package:woosignal/models/response/product_category.dart';

class SubCategoryData {
  final String title;
  final List<ProductCategory> mainCategories;

  SubCategoryData({required this.title, required this.mainCategories});
}
