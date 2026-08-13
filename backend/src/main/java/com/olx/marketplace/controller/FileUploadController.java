package com.olx.marketplace.controller;

import com.olx.marketplace.dto.common.ApiResponse;
import com.olx.marketplace.service.FileStorageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileStorageService fileStorageService;

    @PostMapping("/image")
    public ResponseEntity<ApiResponse<Map<String, String>>> uploadImage(@RequestParam("file") MultipartFile file) {
        String url = fileStorageService.storeFile(file);
        Map<String, String> data = new HashMap<>();
        data.put("url", url);
        return ResponseEntity.ok(ApiResponse.success("Image uploaded successfully", data));
    }

    @PostMapping("/images")
    public ResponseEntity<ApiResponse<Map<String, List<String>>>> uploadImages(@RequestParam("files") MultipartFile[] files) {
        List<String> urls = fileStorageService.storeFiles(files);
        Map<String, List<String>> data = new HashMap<>();
        data.put("urls", urls);
        return ResponseEntity.ok(ApiResponse.success("Images uploaded successfully", data));
    }
}
