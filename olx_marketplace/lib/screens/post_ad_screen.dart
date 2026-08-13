import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme.dart';
import '../data/mock_data.dart';
import '../models/ad.dart';
import '../models/location_data.dart';
import '../services/ad_repository.dart';
import '../services/location_service.dart';
import 'location_screen.dart';
import 'map_picker_screen.dart';

class PostAdScreen extends StatefulWidget {
  final Ad? adToEdit;

  const PostAdScreen({super.key, this.adToEdit});

  @override
  State<PostAdScreen> createState() => _PostAdScreenState();
}

class _PostAdScreenState extends State<PostAdScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Form Keys
  final GlobalKey<FormState> _step5FormKey = GlobalKey<FormState>();

  // Form controllers & states
  Category? _selectedCategory;
  String? _selectedSubcategory;
  List<String> _selectedPhotos = [];
  String _selectedLocation = 'Gulberg Phase 4, Lahore';
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Step 5 fields
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _additionalDetailsController;

  String? _selectedCondition;
  String? _selectedReason;

  // Options
  final List<String> _conditionOptions = ['New', 'Like New', 'Used', 'Refurbished'];
  final List<String> _reasonOptions = ['Upgrading', 'Not using', 'Moving', 'Need money', 'Other'];

  // Available mock photos to pick
  final List<String> _mockPhotoOptions = [
    'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400&q=80',
    'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&q=80',
    'https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=400&q=80',
    'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&q=80',
    'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.adToEdit;

    _titleController = TextEditingController(text: edit?.title ?? '');
    _descController = TextEditingController(text: edit?.description ?? '');
    _priceController = TextEditingController(text: edit != null ? edit.price.toInt().toString() : '');
    _brandController = TextEditingController(text: edit?.brand ?? '');
    _modelController = TextEditingController(text: edit?.model ?? '');
    _additionalDetailsController = TextEditingController(text: edit?.additionalDetails ?? '');

    _selectedCondition = edit?.condition;
    _selectedReason = edit?.reasonForSelling;
    final defaultLoc = LocationService.instance.selectedLocation;
    _selectedLocation = edit?.location ?? defaultLoc.displayName;
    _selectedLatitude = edit?.latitude ?? defaultLoc.latitude;
    _selectedLongitude = edit?.longitude ?? defaultLoc.longitude;
    _selectedPhotos = edit != null ? List.from(edit.images) : [];

    if (edit != null) {
      _selectedCategory = MockData.categories.firstWhere(
        (c) => c.name.replaceAll('\n', ' ').toLowerCase() == edit.category.toLowerCase(),
        orElse: () => MockData.categories.first,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _additionalDetailsController.dispose();
    super.dispose();
  }

  bool get _isStep5Valid {
    final titleValid = _titleController.text.trim().isNotEmpty;
    final descValid = _descController.text.trim().isNotEmpty;
    final conditionValid = _selectedCondition != null && _selectedCondition!.isNotEmpty;
    final priceText = _priceController.text.trim();
    final priceVal = double.tryParse(priceText);
    final priceValid = priceText.isNotEmpty && priceVal != null && priceVal > 0;

    return titleValid && descValid && conditionValid && priceValid;
  }

  void _nextStep() {
    if (_currentStep < 7) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _saveAdAndComplete() {
    final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final mainImage = _selectedPhotos.isNotEmpty
        ? _selectedPhotos[0]
        : 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&q=80';

    final adToSave = Ad(
      id: widget.adToEdit?.id ?? 'ad_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      price: price,
      currency: '₹',
      imageUrl: mainImage,
      images: _selectedPhotos.isNotEmpty ? List.from(_selectedPhotos) : [mainImage],
      condition: _selectedCondition ?? 'Used',
      rating: widget.adToEdit?.rating ?? '10/10',
      location: _selectedLocation,
      latitude: _selectedLatitude ?? LocationService.instance.selectedLocation.latitude,
      longitude: _selectedLongitude ?? LocationService.instance.selectedLocation.longitude,
      date: widget.adToEdit != null ? widget.adToEdit!.date : 'Just now',
      isFeatured: widget.adToEdit?.isFeatured ?? true,
      category: _selectedCategory?.name.replaceAll('\n', ' ') ?? 'Mobiles',
      subcategory: _selectedSubcategory,
      description: _descController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      reasonForSelling: _selectedReason,
      additionalDetails: _additionalDetailsController.text.trim().isEmpty ? null : _additionalDetailsController.text.trim(),
      sellerName: widget.adToEdit?.sellerName ?? 'John Doe',
      sellerPhone: widget.adToEdit?.sellerPhone ?? '+91 9876543210',
      sellerImage: widget.adToEdit?.sellerImage ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80',
      createdAt: widget.adToEdit?.createdAt ?? DateTime.now(),
      status: widget.adToEdit?.status ?? 'active',
      isFavorite: widget.adToEdit?.isFavorite ?? false,
      userId: widget.adToEdit?.userId ?? 'current_user',
    );

    if (widget.adToEdit != null) {
      AdRepository.instance.updateAd(adToSave);
    } else {
      AdRepository.instance.addAd(adToSave);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _prevStep();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: _prevStep,
          ),
          title: Text(
            'Post Ad (${_currentStep + 1}/8)',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / 8,
              backgroundColor: AppColors.divider,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildCategoryStep(),
            _buildPhotosStep(),
            _buildQuickSpecsStep(),
            _buildLocationStep(),
            _buildItemDetailsStep(), // Step 5 / 8
            _buildContactStep(),
            _buildPreviewStep(),
            _buildPublishStep(),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Category ───────────────────────
  Widget _buildCategoryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a category',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select the category that best describes your product.',
                style: AppTextStyles.productMeta,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: MockData.categories.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
            itemBuilder: (context, index) {
              final cat = MockData.categories[index];
              final isSelected = _selectedCategory?.id == cat.id;
              return ListTile(
                title: Text(
                  cat.name.replaceAll('\n', ' '),
                  style: AppTextStyles.productTitle.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
                onTap: () {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  _nextStep();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Step 2: Photos ─────────────────────────
  Widget _buildPhotosStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add photos of your item',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add up to 4 photos. Tap mock photos below to simulate adding pictures.',
            style: AppTextStyles.productMeta,
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(4, (index) {
              final hasPhoto = index < _selectedPhotos.length;
              return Expanded(
                child: Container(
                  height: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.searchBarBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: hasPhoto
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(_selectedPhotos[index], fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 3,
                              right: 3,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedPhotos.removeAt(index);
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: Icon(Icons.camera_alt_outlined, color: AppColors.textMuted, size: 26),
                        ),
                ),
              );
            }),
          ),
          const SizedBox(height: 30),
          Text('Mock Photos (Tap to add):', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _mockPhotoOptions.length,
              itemBuilder: (context, index) {
                final url = _mockPhotoOptions[index];
                return GestureDetector(
                  onTap: () {
                    if (_selectedPhotos.length < 4) {
                      setState(() {
                        _selectedPhotos.add(url);
                      });
                    }
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedPhotos.isNotEmpty ? AppColors.primary : AppColors.divider,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _selectedPhotos.isNotEmpty ? _nextStep : null,
              child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Quick Specs ────────────────────
  Widget _buildQuickSpecsStep() {
    final subcategories = ['Smartphones', 'Tablets', 'Accessories', 'Smart Watches', 'Laptops'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Subcategory',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Refine your listing classification to reach buyers.',
            style: AppTextStyles.productMeta,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                final isSelected = _selectedSubcategory == sub;
                return ListTile(
                  title: Text(sub, style: AppTextStyles.productTitle),
                  trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
                  onTap: () {
                    setState(() {
                      _selectedSubcategory = sub;
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _nextStep,
              child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Location ───────────────────────
  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm your location',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Where is this item located?',
            style: AppTextStyles.productMeta,
          ),
          const SizedBox(height: 20),

          // Active selected location card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.searchBarBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocation,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      if (_selectedLatitude != null && _selectedLongitude != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LocationScreen()),
                    );
                    if (result != null && mounted) {
                      setState(() {
                        if (result is LocationData) {
                          _selectedLocation = result.displayName;
                          _selectedLatitude = result.latitude;
                          _selectedLongitude = result.longitude;
                        } else if (result is String) {
                          _selectedLocation = result;
                        }
                      });
                    }
                  },
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Select on OpenStreetMap button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.map, color: AppColors.primary),
            label: const Text(
              'Select on OpenStreetMap',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () async {
              final locData = LocationData(
                latitude: _selectedLatitude ??
                    LocationService.instance.selectedLocation.latitude,
                longitude: _selectedLongitude ??
                    LocationService.instance.selectedLocation.longitude,
                displayName: _selectedLocation,
              );
              final result = await Navigator.push<LocationData>(
                context,
                MaterialPageRoute(
                  builder: (_) => MapPickerScreen(initialLocation: locData),
                ),
              );
              if (result != null && mounted) {
                setState(() {
                  _selectedLocation = result.displayName;
                  _selectedLatitude = result.latitude;
                  _selectedLongitude = result.longitude;
                });
              }
            },
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _nextStep,
              child: const Text('Next',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 5: ITEM DETAILS FORM (MANDATORY FIELDS) ──────────
  Widget _buildItemDetailsStep() {
    final isFormValid = _isStep5Valid;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _step5FormKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Subtitle
                  Text(
                    'Item Details',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provide the details buyers need to know about your item.',
                    style: AppTextStyles.productMeta.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 20),

                  // 1. Item Title *
                  _buildFieldLabel('Item Title', isRequired: true),
                  TextFormField(
                    controller: _titleController,
                    onChanged: (val) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Item title is required';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      hintText: 'Enter item title',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Description *
                  _buildFieldLabel('Description', isRequired: true),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    maxLength: 4000,
                    onChanged: (val) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      hintText: 'Describe your item in detail...',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Condition *
                  _buildFieldLabel('Condition', isRequired: true),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCondition,
                    hint: Text(
                      'Select condition',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
                    ),
                    items: _conditionOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCondition = val;
                      });
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select condition';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  // 4. Price *
                  _buildFieldLabel('Price', isRequired: true),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (val) => setState(() {}),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Price is required';
                      }
                      final priceVal = double.tryParse(val.trim());
                      if (priceVal == null || priceVal <= 0) {
                        return 'Price must be greater than ₹0';
                      }
                      return null;
                    },
                    decoration: _buildInputDecoration(
                      hintText: 'Enter price',
                      prefixText: '₹ ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Brand (Optional)
                  _buildFieldLabel('Brand', isRequired: false),
                  TextFormField(
                    controller: _brandController,
                    onChanged: (val) => setState(() {}),
                    decoration: _buildInputDecoration(
                      hintText: 'Enter brand',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Model (Optional)
                  _buildFieldLabel('Model', isRequired: false),
                  TextFormField(
                    controller: _modelController,
                    onChanged: (val) => setState(() {}),
                    decoration: _buildInputDecoration(
                      hintText: 'Enter model',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 7. Reason for Selling (Optional)
                  _buildFieldLabel('Reason for Selling', isRequired: false),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedReason,
                    hint: Text(
                      'Select reason for selling',
                      style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
                    ),
                    items: _reasonOptions.map((opt) {
                      return DropdownMenuItem<String>(
                        value: opt,
                        child: Text(opt, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedReason = val;
                      });
                    },
                    decoration: _buildInputDecoration(),
                  ),
                  const SizedBox(height: 16),

                  // 8. Additional Details (Optional)
                  _buildFieldLabel('Additional Details', isRequired: false),
                  TextFormField(
                    controller: _additionalDetailsController,
                    maxLines: 3,
                    onChanged: (val) => setState(() {}),
                    decoration: _buildInputDecoration(
                      hintText: 'Add any other important information...',
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),

        // Fixed NEXT Button at bottom
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: const Border(top: BorderSide(color: AppColors.divider)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isFormValid ? AppColors.primary : AppColors.divider,
                elevation: isFormValid ? 2 : 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final isValid = _step5FormKey.currentState!.validate();
                if (isValid && isFormValid) {
                  _nextStep();
                }
              },
              child: Text(
                'Next',
                style: TextStyle(
                  color: isFormValid ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step 6: Contact Info ───────────────────
  Widget _buildContactStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Buyers will reach out to you via chat or phone.',
            style: AppTextStyles.productMeta,
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const CircleAvatar(
              backgroundImage: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80'),
            ),
            title: const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('+91 9876543210'),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your phone number will remain hidden until a buyer initiates contact.',
                  style: AppTextStyles.productMeta.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _nextStep,
              child: const Text('Next', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 7: Preview Ad ─────────────────────
  Widget _buildPreviewStep() {
    final double price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final mainImage = _selectedPhotos.isNotEmpty
        ? _selectedPhotos[0]
        : 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=400&q=80';

    final tempAd = Ad(
      id: 'temp',
      title: _titleController.text.trim().isNotEmpty ? _titleController.text.trim() : 'Ad Title',
      price: price,
      currency: '₹',
      imageUrl: mainImage,
      condition: _selectedCondition ?? 'Used',
      rating: '10/10',
      location: _selectedLocation,
      date: 'Today',
      isFeatured: true,
      category: _selectedCategory?.name.replaceAll('\n', ' ') ?? 'Mobiles',
      description: _descController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      createdAt: DateTime.now(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review ad details',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Make sure everything looks right before publishing.',
            style: AppTextStyles.productMeta,
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(tempAd.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tempAd.title, style: AppTextStyles.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(tempAd.formattedPrice, style: AppTextStyles.productPrice),
                          const SizedBox(height: 4),
                          Text('${tempAd.condition} · ${tempAd.rating}', style: AppTextStyles.productMeta),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Text(tempAd.location, style: AppTextStyles.productMeta, overflow: TextOverflow.ellipsis),
                              ),
                              Text(tempAd.date, style: AppTextStyles.productMeta),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                _saveAdAndComplete();
                _nextStep();
              },
              child: Text(
                widget.adToEdit != null ? 'Save Changes' : 'Publish Now',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 8: Publish Confirmation ───────────
  Widget _buildPublishStep() {
    final isEdit = widget.adToEdit != null;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 32),
          Text(
            isEdit ? 'Ad Updated Successfully!' : 'Ad Posted Successfully!',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            isEdit
                ? 'Your changes have been saved and are live across the marketplace.'
                : 'Your ad is now active and visible under My Ads, Home screen, search, and category listings.',
            textAlign: TextAlign.center,
            style: AppTextStyles.productMeta.copyWith(fontSize: 13, height: 1.4),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Return success result so main container switches tab to My Ads
                Navigator.pop(context, true);
              },
              child: const Text('View My Ads', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper Widgets & Helpers ───────────────
  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
      prefixText: prefixText,
      prefixStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      errorStyle: GoogleFonts.poppins(fontSize: 11, color: Colors.red),
    );
  }
}
