package com.olx.marketplace.config;

import com.olx.marketplace.entity.*;
import com.olx.marketplace.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final AdRepository adRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ChatRoomRepository chatRoomRepository;
    private final FavoriteRepository favoriteRepository;
    private final PromotionPlanRepository promotionPlanRepository;
    private final PromotionBannerRepository promotionBannerRepository;
    private final PasswordEncoder passwordEncoder;
    private final org.springframework.jdbc.core.JdbcTemplate jdbcTemplate;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        try {
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS seller_type VARCHAR(255) DEFAULT 'FREE'");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS business_name VARCHAR(255)");
            jdbcTemplate.execute("ALTER TABLE users ADD COLUMN IF NOT EXISTS business_verified BOOLEAN DEFAULT FALSE");
            jdbcTemplate.execute("ALTER TABLE ads ADD COLUMN IF NOT EXISTS featured_until TIMESTAMP");
        } catch (Exception e) {
            // Ignore if columns already exist or DDL handled
        }

        boolean hasCategoryImages = categoryRepository.findAll().stream()
                .anyMatch(c -> c.getImageUrl() != null && !c.getImageUrl().isEmpty());
        if (categoryRepository.count() == 0 || !hasCategoryImages) {
            chatMessageRepository.deleteAll();
            chatRoomRepository.deleteAll();
            favoriteRepository.deleteAll();
            adRepository.deleteAll();
            categoryRepository.deleteAll();
            seedCategories();
        }
        if (userRepository.count() == 0) {
            seedUser();
        }
        boolean hasSeedAds = adRepository.findAll().stream().anyMatch(a -> a.getTitle().equals("MacBook Pro 14 M1 Pro"));
        if (!hasSeedAds) {
            chatMessageRepository.deleteAll();
            chatRoomRepository.deleteAll();
            favoriteRepository.deleteAll();
            adRepository.deleteAll();
            seedAds();
        }
        if (promotionPlanRepository.count() == 0) {
            seedPromotionPlans();
        }
        if (promotionBannerRepository.count() == 0) {
            seedPromotionBanners();
        }
    }

    private void seedUser() {
        User seller = User.builder()
                .name("Verified Seller")
                .email("seller@olx.com")
                .phone("+91 9876543210")
                .password(passwordEncoder.encode("password123"))
                .role(Role.USER)
                .active(true)
                .profileImage("https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&q=80")
                .build();
        userRepository.save(seller);
    }

    private void seedAds() {
        User seller = userRepository.findAll().stream().findFirst().orElse(null);
        if (seller == null) return;

        Category mobiles = categoryRepository.findByName("Mobiles").orElse(null);
        Category vehicles = categoryRepository.findByName("Vehicles").orElse(null);
        Category bikes = categoryRepository.findByName("Bikes").orElse(null);
        Category electronics = categoryRepository.findByName("Electronics & Home Appliances").orElse(null);
        Category property = categoryRepository.findByName("Property for Sale").orElse(null);

        // Fallbacks if not found
        Category defaultCat = categoryRepository.findAll().stream().findFirst().orElse(null);

        // 1. MacBook Pro
        createAd(
                "MacBook Pro 14 M1 Pro",
                "Super clean MacBook Pro with M1 Pro chip, 16GB RAM and 512GB SSD. Scratchless condition, comes with original charger and box.",
                new BigDecimal("145000.00"),
                AdCondition.LIKE_NEW,
                electronics != null ? electronics : defaultCat,
                "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=600&q=80",
                seller,
                "Gulberg Phase 4, Lahore",
                true
        );

        // 2. iPhone 14 Pro Max
        createAd(
                "iPhone 14 Pro Max 256GB",
                "Yellow iPhone 14 Pro Max in pristine condition. Battery health is 92%. Box and charging cable included.",
                new BigDecimal("95000.00"),
                AdCondition.USED,
                mobiles != null ? mobiles : defaultCat,
                "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600&q=80",
                seller,
                "Gulberg Phase 4, Lahore",
                true
        );

        // 3. Suzuki Red Dragon
        createAd(
                "Suzuki Red Dragon",
                "Beautiful custom red Suzuki motorcycle. Runs perfectly, regular tuning done. Selling due to upgrade.",
                new BigDecimal("185000.00"),
                AdCondition.USED,
                bikes != null ? bikes : defaultCat,
                "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80",
                seller,
                "DHA Phase 6, Lahore",
                false
        );

        // 4. Audi R8 Spyder
        createAd(
                "Audi R8 Spyder V10",
                "Brand new exotic Audi R8 Spyder V10 in solid white. Full carbon package, bang & olufsen sound system.",
                new BigDecimal("24500000.00"),
                AdCondition.NEW,
                vehicles != null ? vehicles : defaultCat,
                "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=600&q=80",
                seller,
                "Model Town, Lahore",
                true
        );

        // 5. Modern Apartment
        createAd(
                "Modern Apartment in Gulberg",
                "Luxury 2 bedroom apartment in the heart of Gulberg. Fully furnished, round the clock security, dedicated parking.",
                new BigDecimal("18500000.00"),
                AdCondition.LIKE_NEW,
                property != null ? property : defaultCat,
                "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=600&q=80",
                seller,
                "Gulberg 3, Lahore",
                false
        );
    }

    private void createAd(String title, String desc, BigDecimal price, AdCondition cond, Category cat, String imgUrl, User seller, String loc, boolean featured) {
        Ad ad = Ad.builder()
                .title(title)
                .description(desc)
                .price(price)
                .condition(cond)
                .category(cat)
                .seller(seller)
                .location(loc)
                .isFeatured(featured)
                .status(AdStatus.ACTIVE)
                .views(120)
                .images(new ArrayList<>())
                .build();

        AdImage adImage = AdImage.builder()
                .imageUrl(imgUrl)
                .displayOrder(0)
                .build();
        ad.addImage(adImage);

        adRepository.save(ad);
    }

    private void seedCategories() {
        // 1. Mobiles
        Category mobiles = createCat("Mobiles", "Mobile phones, tablets & accessories", "phone_android", "https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=200&q=80", 1, null);
        createCat("Mobile Phones", "Smartphones & feature phones", "smartphone", "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=200&q=80", 1, mobiles);
        createCat("Tablets", "Android & iOS tablets", "tablet", "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=200&q=80", 2, mobiles);
        createCat("Accessories", "Chargers, cases, covers & headphones", "headphones", "https://images.unsplash.com/photo-1546868871-7041f2a55e12?w=200&q=80", 3, mobiles);

        // 2. Vehicles
        Category vehicles = createCat("Vehicles", "Cars, buses & commercial vehicles", "directions_car", "https://images.unsplash.com/photo-1583121274602-3e2820c69888?w=200&q=80", 2, null);
        createCat("Cars", "Sedans, SUVs, hatchbacks & luxury cars", "directions_car", "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=200&q=80", 1, vehicles);
        createCat("Buses & Vans", "Vans, pickup trucks & transport", "airport_shuttle", "https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=200&q=80", 2, vehicles);

        // 3. Property for Sale
        Category propertySale = createCat("Property for Sale", "Houses, apartments, plots & land", "home", "https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=200&q=80", 3, null);
        createCat("Houses", "Independent houses & villas", "house", "https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=200&q=80", 1, propertySale);
        createCat("Apartments & Flats", "Modern apartments & flats", "apartment", "https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=200&q=80", 2, propertySale);
        createCat("Land & Plots", "Residential & commercial plots", "landscape", "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=200&q=80", 3, propertySale);

        // 4. Bikes
        Category bikes = createCat("Bikes", "Motorcycles, scooters & bicycles", "two_wheeler", "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&q=80", 4, null);
        createCat("Motorcycles", "Sports, heavy & standard bikes", "two_wheeler", "https://images.unsplash.com/photo-1558981806-ec527fa84c39?w=200&q=80", 1, bikes);
        createCat("Scooters", "Automatic scooters", "moped", "https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=200&q=80", 2, bikes);

        // 5. Electronics & Home Appliances
        Category electronics = createCat("Electronics & Home Appliances", "TV, audio, refrigerators & laptops", "tv", "https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=200&q=80", 5, null);
        createCat("TV - Video - Audio", "LED TVs, speakers & soundbars", "tv", "https://images.unsplash.com/photo-1461151304267-38535e780c79?w=200&q=80", 1, electronics);
        createCat("Computers & Laptops", "Laptops, desktops & monitors", "computer", "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=200&q=80", 2, electronics);
        createCat("Home Appliances", "Refrigerators, washing machines & ACs", "kitchen", "https://images.unsplash.com/photo-1574269909862-7e1d70bb8078?w=200&q=80", 3, electronics);

        // 6. Business, Industrial & Agriculture
        createCat("Business, Industrial & Agriculture", "Machinery, equipment & supplies", "business_center", "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=200&q=80", 6, null);

        // 7. Services
        createCat("Services", "Home repair, tuition & professional services", "build", "https://images.unsplash.com/photo-1521791136368-1a46827d3ad1?w=200&q=80", 7, null);

        // 8. Jobs
        createCat("Jobs", "Full-time, part-time & freelance jobs", "work", "https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?w=200&q=80", 8, null);

        // 9. Furniture & Home Decor
        createCat("Furniture & Home Decor", "Sofa sets, beds, tables & decor", "chair", "https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=200&q=80", 9, null);

        // 10. Fashion & Beauty
        createCat("Fashion & Beauty", "Clothes, shoes, watches & cosmetics", "checkroom", "https://images.unsplash.com/photo-1483985988355-763728e1935b?w=200&q=80", 10, null);
    }

    private Category createCat(String name, String desc, String icon, String imageUrl, int order, Category parent) {
        Category category = Category.builder()
                .name(name)
                .description(desc)
                .icon(icon)
                .imageUrl(imageUrl)
                .displayOrder(order)
                .parentCategory(parent)
                .build();
        return categoryRepository.save(category);
    }

    private void seedPromotionPlans() {
        promotionPlanRepository.save(PromotionPlan.builder()
                .name("Featured (3 Days)")
                .type(PromotionType.FEATURED)
                .durationDays(3)
                .price(new BigDecimal("99"))
                .description("Get 5x more views with a Featured badge on search results & home feed.")
                .active(true)
                .build());

        promotionPlanRepository.save(PromotionPlan.builder()
                .name("Featured (7 Days)")
                .type(PromotionType.FEATURED)
                .durationDays(7)
                .price(new BigDecimal("199"))
                .description("Maximize buyer inquiries with 7 days of prime Featured positioning.")
                .active(true)
                .build());

        promotionPlanRepository.save(PromotionPlan.builder()
                .name("Boost Ad (3 Days)")
                .type(PromotionType.BOOST)
                .durationDays(3)
                .price(new BigDecimal("149"))
                .description("Instantly bump your ad to the top of category listings.")
                .active(true)
                .build());

        promotionPlanRepository.save(PromotionPlan.builder()
                .name("Top Placement (24 Hours)")
                .type(PromotionType.TOP_PLACEMENT)
                .durationDays(1)
                .price(new BigDecimal("299"))
                .description("Guaranteed #1 placement at the very top of relevant search results for 24 hours.")
                .active(true)
                .build());
    }

    private void seedPromotionBanners() {
        promotionBannerRepository.save(PromotionBanner.builder()
                .title("Sell Faster with Featured Ads!")
                .description("Promote your ad today and get up to 10x more buyer responses.")
                .imageUrl("https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&q=80")
                .targetUrl("/api/promotions/plans")
                .active(true)
                .build());

        promotionBannerRepository.save(PromotionBanner.builder()
                .title("Upgrade to Business Seller")
                .description("Post up to 100 ads, get a verified badge, and dedicated support.")
                .imageUrl("https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80")
                .targetUrl("/api/subscriptions/plans")
                .active(true)
                .build());
    }
}
