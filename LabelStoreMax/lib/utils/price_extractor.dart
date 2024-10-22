import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

class PriceExtractor {
  /// Extracts the regular price from the provided HTML string.
  static String? extractRegularPrice(String? html) {
    // Parse the HTML string
    final Document document = html_parser.parse(html);

    // Locate the <del> element containing the regular price
    final Element? delElement = document.querySelector('del .woocommerce-Price-amount');

    // Extract the text content of the <del> element, which contains the regular price
    if (delElement != null) {
      // Retrieve and clean the price text (removing non-numeric characters except for the decimal separator)
      final priceText = delElement.text.replaceAll(RegExp(r'[^\d,\.]'), '');
      return priceText;
    }

    // Return null if the <del> element is not found
    return null;
  }
}
