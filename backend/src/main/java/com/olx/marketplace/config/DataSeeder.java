package com.olx.marketplace.config;

import com.olx.marketplace.entity.Category;
import com.olx.marketplace.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Component
@RequiredArgsConstructor
public class DataSeeder implements CommandLineRunner {

    private final CategoryRepository categoryRepository;

    @Override
    @Transactional
    public void run(String... args) throws Exception {
        if (categoryRepository.count() == 0) {
            seedCategories();
        }
    }

    private void seedCategories() {
        // 1. Mobiles
        Category mobiles = createCat("Mobiles", "Mobile phones, tablets & accessories", "phone_android", 1, null);
        createCat("Mobile Phones", "Smartphones & feature phones", "smartphone", 1, mobiles);
        createCat("Tablets", "Android & iOS tablets", "tablet", 2, mobiles);
        createCat("Accessories", "Chargers, cases, covers & headphones", "headphones", 3, mobiles);

        // 2. Vehicles
        Category vehicles = createCat("Vehicles", "Cars, buses & commercial vehicles", "directions_car", 2, null);
        createCat("Cars", "Sedans, SUVs, hatchbacks & luxury cars", "directions_car", 1, vehicles);
        createCat("Buses & Vans", "Vans, pickup trucks & transport", "airport_shuttle", 2, vehicles);

        // 3. Property for Sale
        Category propertySale = createCat("Property for Sale", "Houses, apartments, plots & land", "home", 3, null);
        createCat("Houses", "Independent houses & villas", "house", 1, propertySale);
        createCat("Apartments & Flats", "Modern apartments & flats", "apartment", 2, propertySale);
        createCat("Land & Plots", "Residential & commercial plots", "landscape", 3, propertySale);

        // 4. Bikes
        Category bikes = createCat("Bikes", "Motorcycles, scooters & bicycles", "two_wheeler", 4, null);
        createCat("Motorcycles", "Sports, heavy & standard bikes", "two_wheeler", 1, bikes);
        createCat("Scooters", "Automatic scooters", "moped", 2, bikes);

        // 5. Electronics & Home Appliances
        Category electronics = createCat("Electronics & Home Appliances", "TV, audio, refrigerators & laptops", "tv", 5, null);
        createCat("TV - Video - Audio", "LED TVs, speakers & soundbars", "tv", 1, electronics);
        createCat("Computers & Laptops", "Laptops, desktops & monitors", "computer", 2, electronics);
        createCat("Home Appliances", "Refrigerators, washing machines & ACs", "kitchen", 3, electronics);

        // 6. Business, Industrial & Agriculture
        Category business = createCat("Business, Industrial & Agriculture", "Machinery, equipment & supplies", "business_center", 6, null);

        // 7. Services
        Category services = createCat("Services", "Home repair, tuition & professional services", "build", 7, null);

        // 8. Jobs
        Category jobs = createCat("Jobs", "Full-time, part-time & freelance jobs", "work", 8, null);

        // 9. Furniture & Home Decor
        Category furniture = createCat("Furniture & Home Decor", "Sofa sets, beds, tables & decor", "chair", 9, null);

        // 10. Fashion & Beauty
        Category fashion = createCat("Fashion & Beauty", "Clothes, shoes, watches & cosmetics", "checkroom", 10, null);
    }

    private Category createCat(String name, String desc, String icon, int order, Category parent) {
        Category category = Category.builder()
                .name(name)
                .description(desc)
                .icon(icon)
                .displayOrder(order)
                .parentCategory(parent)
                .build();
        return categoryRepository.save(category);
    }
}
