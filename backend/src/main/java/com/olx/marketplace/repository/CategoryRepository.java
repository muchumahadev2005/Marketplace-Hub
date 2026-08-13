package com.olx.marketplace.repository;

import com.olx.marketplace.entity.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {

    List<Category> findByParentCategoryIsNullOrderByDisplayOrderAscNameAsc();

    List<Category> findByParentCategoryIdOrderByDisplayOrderAscNameAsc(Long parentId);
}
