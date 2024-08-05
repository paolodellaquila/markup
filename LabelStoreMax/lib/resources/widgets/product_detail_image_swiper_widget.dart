//  Label StoreMax
//
//  Created by Anthony Gordon.
//  2024, WooSignal Ltd. All rights reserved.
//

//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:woosignal/models/image.dart' as Im;

class ProductDetailImageSwiperWidget extends StatelessWidget {
  const ProductDetailImageSwiperWidget({super.key, required this.images, required this.onTapImage});

  final List<Im.Image> images;
  final void Function(int i) onTapImage;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) => CachedNetworkImage(
          imageUrl: images.isNotEmpty ? images[index].src : getEnv("PRODUCT_PLACEHOLDER_IMAGE"),
          imageBuilder: (context, imageProvider) => Container(
            width: 70.0,
            height: 70.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: Colors.black12, color: Colors.black54),
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        itemCount: images.isEmpty ? 1 : images.length,
        viewportFraction: 0.6,
        scale: 0.9,
        onTap: onTapImage,
      ),
    );
  }
}
