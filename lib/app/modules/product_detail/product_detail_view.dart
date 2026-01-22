import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vdc_store/app/data/models/product_model.dart';
import 'package:vdc_store/app/modules/product_detail/product_detail_controller.dart';
import 'package:vdc_store/app/shared/utils/app_colors.dart';
import 'package:vdc_store/app/shared/utils/app_fonts.dart';
import 'package:vdc_store/app/shared/utils/app_images.dart';

class ProductDetailView extends GetView<ProductDetailController> {
  const ProductDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // VDC Logo
            SvgPicture.asset(
              AppImages.vdcLogo,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            SizedBox(width: 8),
            // Adobe Logo
            SvgPicture.asset(
              AppImages.adobeLogo,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.red);
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu, color: Colors.black),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final product = controller.productDetail.value;
        if (product == null) {
          return Center(child: Text('Product not found'));
        }

        return SingleChildScrollView(
          child: RefreshIndicator(
            onRefresh: controller.refreshProduct,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Gallery
                _buildImageGallery(product),

                // Tab view
                _buildTabs(),

                // Product Info
                _buildProductInfo(product),

                // Installation & Configuration
                _buildInstallationSection(),

                // Feature Highlights
                _buildFeatureHighlights(),

                // Support Features
                _buildSupportFeatures(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildImageGallery(Product product) {
    final images = product.mediaGallery.isNotEmpty
        ? product.mediaGallery
        : [product.imageUrl ?? ''];

    return Container(
      height: 250,
      child: Row(
        children: [
          // Main Image
          Expanded(
            flex: 4,
            child: Obx(
              () => Container(
                margin: EdgeInsets.all(8),
                child: CachedNetworkImage(
                  imageUrl: images[controller.selectedImageIndex.value],
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),

          // Small Images on Right
          Container(
            width: 80,
            child: Stack(
              children: [
                ListView.builder(
                  controller: controller.scrollController,
                  itemCount: images.length,
                  itemBuilder: (context, index) => Obx(
                    () => GestureDetector(
                      onTap: () => controller.selectImage(index),
                      child: Container(
                        height: 80,
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: controller.selectedImageIndex.value == index
                                ? Colors.blue
                                : Colors.grey.shade300,

                            width: 2,
                          ),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ), // Up button
                Positioned(
                  top: 10,
                  right: 20,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.scrollUp(),
                      icon: Icon(Icons.keyboard_arrow_up, size: 20),
                    ),
                  ),
                ),

                // Down button
                Positioned(
                  bottom: 10,
                  right: 20,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => controller.scrollDown(),
                      icon: Icon(Icons.keyboard_arrow_down, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      child: TabBar(
        controller: controller.tabController,
        isScrollable: true,
        physics: BouncingScrollPhysics(),
        labelColor: AppColors.black,

        unselectedLabelColor: AppColors.lightGrey,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          fontFamily: AppFonts.kanit,
        ),
        dividerHeight: 0,
        indicatorColor: AppColors.divide,
        indicatorWeight: 1,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: [
          Tab(text: 'Overview'),
          Tab(text: 'Demo'),
          Tab(text: 'Screenshots'),
          Tab(text: 'Feature'),
          Tab(text: 'Review'),
          Tab(text: 'User Guide'),
          Tab(text: 'Support'),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Product product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name
          Text(
            product.name,
            style: TextStyle(
              fontSize: 24,
              fontFamily: AppFonts.spaceGrotesk,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),

          // Categories
          if (product.categories.isNotEmpty)
            Text(
              '- for ${product.categories.join(', ')}',
              style: TextStyle(
                color: AppColors.lightGrey,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
          SizedBox(height: 16),

          // Rating
          Row(
            children: [
              Text(
                '${(product.ratingSummary ?? 0) / 20}/5',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.kanit,
                  color: AppColors.black,
                ),
              ),
              SizedBox(width: 8),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    index < ((product.ratingSummary ?? 0) / 20).round()
                        ? Icons.star
                        : Icons.star_border,
                    color: AppColors.divide,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                '(${product.reviewCount ?? 0} Real Reviews)',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppFonts.kanit,
                  fontWeight: FontWeight.w500,
                  color: AppColors.lightGrey,
                ),
              ),
            ],
          ),

          GestureDetector(
            onTap: () => _openTrustpilot(),
            child: SvgPicture.asset(AppImages.trustpilotLogo),
          ),
          SizedBox(height: 16),
          SvgPicture.asset(AppImages.adobeApproved),
          SizedBox(height: 16),
          Text(
            '\$${product.price.toString()}',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.spaceGrotesk,
            ),
          ),
          SizedBox(height: 16),

          // Description
          if (product.shortDescription != null)
            Obx(() {
              final cleanDescription = product.shortDescription!.replaceAll(
                RegExp(r'<[^>]*>'),
                '',
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cleanDescription,
                    maxLines: controller.isDescriptionExpanded.value ? null : 4,
                    overflow: controller.isDescriptionExpanded.value
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                    ),
                  ),
                  if (cleanDescription.length > 200)
                    GestureDetector(
                      onTap: controller.toggleDescription,
                      child: Text(
                        controller.isDescriptionExpanded.value
                            ? "Read Less"
                            : "Read More",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                ],
              );
            }),

          SizedBox(height: 16),

          SvgPicture.asset(AppImages.brandsLogo),
        ],
      ),
    );
  }

  void _openTrustpilot() async {
    final Uri url = Uri.parse('https://www.trustpilot.com/review/vdcstore.com');

    try {
      bool launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error launching URL: $e');
      // Fallback
      await Clipboard.setData(ClipboardData(text: url.toString()));
      Get.snackbar(
        'Link Copied',
        'URL copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildInstallationSection() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free Installation & Configuation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            "Domain Name",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5),
          TextField(
            decoration: InputDecoration(
              hintText: 'Type here...',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Domain Name",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
          ),
          SizedBox(height: 5),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Magento Edition',
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFA3B1C6)),
              ),
            ),
            items: ['Community', 'Commerce'].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {},
          ),
          SizedBox(height: 24),
          SizedBox(
            width: 128,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.divide,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Add to Cart',
                style: TextStyle(fontSize: 17, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Feature Highlights',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          _buildFeatureItem(
            'Automatically generates an llms.txt file for AI systems like ChatGPT, Gemini, and Claude.',
          ),
          _buildFeatureItem(
            'Improves AEO and GEO to boost visibility in AI-powered search results.',
          ),
          _buildFeatureItem(
            'Lets admins choose which store entities (Products, Categories, CMS Pages) to include.',
          ),
          _buildFeatureItem(
            'Offers auto-generation scheduling to keep the llms.txt file always up to date.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: Colors.green, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 16, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportFeatures() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSupportItem(Icons.download, 'Free Installation'),
          _buildSupportItem(Icons.support_agent, 'Free 1 Year Support'),
          _buildSupportItem(Icons.money, "30 Day's Money Back"),
          _buildSupportItem(Icons.code, 'Meet Magento Coding Standard'),
        ],
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
