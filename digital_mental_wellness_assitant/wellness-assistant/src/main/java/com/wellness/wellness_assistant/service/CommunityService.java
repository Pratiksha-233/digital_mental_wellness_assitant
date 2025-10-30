package com.wellness.wellness_assistant.service;

import com.wellness.wellness_assistant.dto.CommunityPostRequest;
import com.wellness.wellness_assistant.model.CommunityPost;
import com.wellness.wellness_assistant.model.User;
import com.wellness.wellness_assistant.repository.CommunityPostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CommunityService {
    
    private final CommunityPostRepository communityPostRepository;
    
    public List<CommunityPost> getAllPosts() {
        return communityPostRepository.findByIsApprovedTrueOrderByCreatedAtDesc();
    }
    
    public List<CommunityPost> getPostsByCategory(CommunityPost.Category category) {
        return communityPostRepository.findByCategoryAndIsApprovedTrueOrderByCreatedAtDesc(category);
    }
    
    public List<CommunityPost> getUserPosts(User user) {
        return communityPostRepository.findByAuthorAndIsApprovedTrueOrderByCreatedAtDesc(user);
    }
    
    public List<CommunityPost> getPinnedPosts() {
        return communityPostRepository.findByIsPinnedTrueAndIsApprovedTrueOrderByCreatedAtDesc();
    }
    
    public List<CommunityPost> searchPosts(String keyword) {
        return communityPostRepository.searchByKeyword(keyword);
    }
    
    public CommunityPost createPost(CommunityPostRequest request, User author) {
        CommunityPost post = new CommunityPost();
        post.setAuthor(author);
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setCategory(request.getCategory());
        post.setIsAnonymous(request.getIsAnonymous());
        
        return communityPostRepository.save(post);
    }
    
    public CommunityPost getPostById(Long id) {
        return communityPostRepository.findById(id)
            .filter(post -> post.getIsApproved())
            .orElseThrow(() -> new RuntimeException("Community post not found"));
    }
    
    public CommunityPost updatePost(Long id, CommunityPostRequest request, User user) {
        CommunityPost post = communityPostRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getAuthor().getId().equals(user.getId())) {
            throw new RuntimeException("You can only edit your own posts");
        }
        
        post.setTitle(request.getTitle());
        post.setContent(request.getContent());
        post.setCategory(request.getCategory());
        post.setIsAnonymous(request.getIsAnonymous());
        
        return communityPostRepository.save(post);
    }
    
    public void deletePost(Long id, User user) {
        CommunityPost post = communityPostRepository.findById(id)
            .orElseThrow(() -> new RuntimeException("Post not found"));
        
        if (!post.getAuthor().getId().equals(user.getId())) {
            throw new RuntimeException("You can only delete your own posts");
        }
        
        communityPostRepository.delete(post);
    }
    
    public CommunityPost likePost(Long id, User user) {
        CommunityPost post = getPostById(id);
        post.setLikesCount(post.getLikesCount() + 1);
        return communityPostRepository.save(post);
    }
}