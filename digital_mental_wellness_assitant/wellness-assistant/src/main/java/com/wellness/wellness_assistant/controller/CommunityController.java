package com.wellness.wellness_assistant.controller;

import com.wellness.wellness_assistant.dto.CommunityPostRequest;
import com.wellness.wellness_assistant.model.CommunityPost;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.service.AuthService;
import com.wellness.wellness_assistant.service.CommunityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/community")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class CommunityController {
    
    private final CommunityService communityService;
    private final AuthService authService;
    
    @GetMapping
    public ResponseEntity<List<CommunityPost>> getAllPosts() {
        try {
            List<CommunityPost> posts = communityService.getAllPosts();
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/category/{category}")
    public ResponseEntity<List<CommunityPost>> getPostsByCategory(@PathVariable CommunityPost.Category category) {
        try {
            List<CommunityPost> posts = communityService.getPostsByCategory(category);
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/pinned")
    public ResponseEntity<List<CommunityPost>> getPinnedPosts() {
        try {
            List<CommunityPost> posts = communityService.getPinnedPosts();
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/my-posts")
    public ResponseEntity<List<CommunityPost>> getUserPosts(@AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            List<CommunityPost> posts = communityService.getUserPosts(user);
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/search")
    public ResponseEntity<List<CommunityPost>> searchPosts(@RequestParam String keyword) {
        try {
            List<CommunityPost> posts = communityService.searchPosts(keyword);
            return ResponseEntity.ok(posts);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping
    public ResponseEntity<CommunityPost> createPost(
            @Valid @RequestBody CommunityPostRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            CommunityPost post = communityService.createPost(request, user);
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<CommunityPost> getPostById(@PathVariable Long id) {
        try {
            CommunityPost post = communityService.getPostById(id);
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<CommunityPost> updatePost(
            @PathVariable Long id,
            @Valid @RequestBody CommunityPostRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            CommunityPost post = communityService.updatePost(id, request, user);
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deletePost(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            communityService.deletePost(id, user);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    @PostMapping("/{id}/like")
    public ResponseEntity<CommunityPost> likePost(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            User user = authService.getCurrentUser(userDetails.getUsername());
            CommunityPost post = communityService.likePost(id, user);
            return ResponseEntity.ok(post);
        } catch (Exception e) {
            return ResponseEntity.badRequest().build();
        }
    }
}