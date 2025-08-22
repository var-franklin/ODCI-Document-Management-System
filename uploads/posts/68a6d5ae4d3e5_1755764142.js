// comment_system.js - Updated for side panel implementation

class CommentSystem {
    constructor(core) {
        this.core = core;
        this.currentlyEditing = null;
        this.replyingTo = null;
    }

    // Toggle comments section visibility - now opens side panel
    async toggleComments(postId) {
        // Find the post element to get the author name
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return;
        
        const authorElement = postElement.querySelector('.post-author-name');
        const authorName = authorElement ? authorElement.textContent : 'Unknown User';
        
        // Use global function to open comments panel
        if (window.openCommentsPanel) {
            window.openCommentsPanel(postId, authorName);
        }
    }

    // Load comments for a post (legacy function - kept for compatibility)
    async loadComments(postId) {
        const loadingDiv = document.getElementById(`commentsLoading${postId}`);
        const container = document.getElementById(`commentsContainer${postId}`);
        
        if (loadingDiv) loadingDiv.style.display = 'block';
        
        try {
            const response = await fetch(`api/get_comments.php?post_id=${postId}`);
            
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            
            const responseText = await response.text();
            let data;
            try {
                data = JSON.parse(responseText);
            } catch (parseError) {
                console.error('JSON Parse Error:', parseError);
                throw new Error('Server returned invalid response');
            }
            
            if (data.success && container) {
                this.renderComments(container, data.comments);
            } else {
                this.showCommentsError(container, data.message || 'Failed to load comments');
            }
        } catch (error) {
            console.error('Error loading comments:', error);
            this.showCommentsError(container, error.message);
        } finally {
            if (loadingDiv) loadingDiv.style.display = 'none';
        }
    }

    // Render comments in container (legacy function - kept for compatibility)
    renderComments(container, comments) {
        container.innerHTML = '';
        
        if (comments.length === 0) {
            container.innerHTML = '<p style="color: var(--text-secondary); text-align: center; padding: 20px;">No comments yet</p>';
        } else {
            comments.forEach(comment => {
                container.appendChild(this.createCommentElement(comment));
            });
        }
    }

    // Show comments error (legacy function - kept for compatibility)
    showCommentsError(container, message = 'Error loading comments') {
        if (container) {
            container.innerHTML = `<p style="color: var(--error); text-align: center; padding: 20px;">${message}</p>`;
        }
    }

    // Create comment element (legacy function - kept for compatibility)
    createCommentElement(comment) {
        const commentDiv = document.createElement('div');
        commentDiv.className = 'comment';
        commentDiv.dataset.commentId = comment.id;
        
        const timeAgo = window.utils ? window.utils.getTimeAgo(comment.created_at) : 'recently';
        const editedText = this.createEditedText(comment.is_edited);
        const actions = this.createCommentActions(comment);
        
        commentDiv.innerHTML = `
            <img src="${comment.profile_image || 'assets/img/default-avatar.png'}" 
                 alt="${comment.commenter_full_name}" class="comment-avatar">
            <div class="comment-content">
                <div class="comment-header">
                    <span class="comment-author">${comment.commenter_full_name}</span>
                    <span class="comment-time">${timeAgo}</span>
                    ${editedText}
                </div>
                <div class="comment-text">${this.escapeHtml(comment.content)}</div>
                <div class="comment-actions">
                    ${actions}
                </div>
            </div>
        `;
        
        return commentDiv;
    }

    // Create edited text for comment
    createEditedText(isEdited) {
        return isEdited ? 
            '<span style="color: var(--text-secondary); font-size: 11px;">(edited)</span>' : '';
    }

    // Create comment actions
    createCommentActions(comment) {
        const actions = [];
        
        // Reply button
        actions.push(`<span class="comment-action" onclick="window.commentSystem.startReply(${comment.id})">Reply</span>`);
        
        // Edit and Delete buttons (only for authorized users)
        if (this.core && this.core.canEditComment(comment)) {
            actions.push(`<span class="comment-action" onclick="window.commentSystem.startEdit(${comment.id})">Edit</span>`);
            actions.push(`<span class="comment-action" onclick="window.commentSystem.deleteComment(${comment.id})">Delete</span>`);
        }
        
        // Like button with count
        const likeText = comment.user_liked ? 'Unlike' : 'Like';
        const likeCount = comment.like_count > 0 ? `(${comment.like_count})` : '';
        actions.push(`<span class="comment-action" onclick="window.commentSystem.toggleCommentLike(${comment.id})">${likeText} ${likeCount}</span>`);
        
        return actions.join('');
    }

    // Add comment - now redirects to panel if panel is open
    async addComment(postId) {
        // Check if comments panel is open for this post
        if (window.currentCommentsPostId === postId) {
            // If panel is open, use panel submission instead
            if (window.submitCommentFromPanel) {
                window.submitCommentFromPanel();
                return;
            }
        }
        
        // Legacy inline comment functionality (kept for backward compatibility)
        const input = document.querySelector(`#comments${postId} .comment-input`);
        if (!input) {
            console.error('Comment input not found for post:', postId);
            return;
        }
        
        const content = input.value.trim();
        if (!content) {
            this.showNotification('Please enter a comment', 'warning');
            return;
        }
        
        // If we're in reply mode, handle reply instead
        if (this.replyingTo) {
            await this.submitReply(this.replyingTo, content);
            this.cancelReply();
            return;
        }
        
        // Show loading state
        const addButton = input.parentElement.querySelector('.add-comment-btn') || 
                         input.parentElement.querySelector('.comment-submit');
        const originalText = addButton ? addButton.innerHTML : '';
        if (addButton) {
            addButton.innerHTML = '<div class="spinner-small"></div>';
            addButton.disabled = true;
        }
        
        try {
            const response = await fetch('api/add_comment.php', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ 
                    post_id: postId, 
                    content: content 
                })
            });
            
            const responseText = await response.text();
            
            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${responseText}`);
            }
            
            let result;
            try {
                result = JSON.parse(responseText);
            } catch (parseError) {
                console.error('JSON Parse Error:', parseError);
                throw new Error(`Invalid JSON response`);
            }
            
            if (result.success) {
                input.value = '';
                
                // Update comment count
                if (result.actual_comment_count !== undefined) {
                    this.updateCommentCountFromServer(postId, result.actual_comment_count);
                }
                
                // Reload comments to show the new comment
                await this.loadComments(postId);
                
                this.showNotification(result.message || 'Comment added successfully!', 'success');
            } else {
                throw new Error(result.message || 'Failed to add comment');
            }
        } catch (error) {
            console.error('Error adding comment:', error);
            this.showNotification(error.message || 'Error adding comment', 'error');
        } finally {
            if (addButton) {
                addButton.innerHTML = originalText;
                addButton.disabled = false;
            }
        }
    }

    // Start editing a comment
    startEdit(commentId) {
        this.cancelEdit(); // Cancel any existing edit
        this.cancelReply(); // Cancel any reply in progress
        
        // Look for comment in both legacy containers and panel
        let commentElement = document.querySelector(`.comment[data-comment-id="${commentId}"]`);
        
        // If not found in legacy containers, look in comments panel
        if (!commentElement) {
            commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
        }
        
        if (!commentElement) return;
        
        const commentText = commentElement.querySelector('.comment-text');
        const originalContent = commentText.textContent;
        
        // Replace with edit form
        commentElement.classList.add('editing');
        commentText.innerHTML = `
            <textarea class="comment-edit-textarea">${this.escapeHtml(originalContent)}</textarea>
            <div class="comment-edit-actions">
                <button class="btn-small btn-primary" onclick="window.commentSystem.submitEdit(${commentId})">Save</button>
                <button class="btn-small btn-secondary" onclick="window.commentSystem.cancelEdit()">Cancel</button>
            </div>
        `;
        
        this.currentlyEditing = commentId;
        
        // Focus the textarea
        const textarea = commentText.querySelector('textarea');
        if (textarea) {
            textarea.focus();
            textarea.setSelectionRange(textarea.value.length, textarea.value.length);
        }
    }

    // Submit edited comment
    async submitEdit(commentId) {
        // Look for comment in both legacy containers and panel
        let commentElement = document.querySelector(`.comment[data-comment-id="${commentId}"]`);
        
        if (!commentElement) {
            commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
        }
        
        if (!commentElement) return;
        
        const textarea = commentElement.querySelector('.comment-edit-textarea');
        if (!textarea) return;
        
        const newContent = textarea.value.trim();
        if (!newContent) {
            this.showNotification('Comment cannot be empty', 'warning');
            return;
        }
        
        // Show loading
        const saveButton = commentElement.querySelector('.btn-primary');
        const originalText = saveButton.textContent;
        saveButton.textContent = 'Saving...';
        saveButton.disabled = true;
        
        try {
            const response = await fetch('api/edit_comment.php', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ 
                    comment_id: commentId, 
                    content: newContent 
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Update the comment text
                const commentText = commentElement.querySelector('.comment-text');
                commentText.textContent = newContent;
                
                // Add edited indicator if not already present
                const commentHeader = commentElement.querySelector('.comment-header');
                if (commentHeader && !commentHeader.querySelector('.edited-indicator')) {
                    commentHeader.innerHTML += ' <span class="edited-indicator" style="color: var(--text-secondary); font-size: 11px;">(edited)</span>';
                }
                
                this.showNotification('Comment updated successfully', 'success');
                
                // If we're in the comments panel, reload the panel
                if (window.currentCommentsPostId && commentElement.closest('#commentsPanelContainer')) {
                    setTimeout(() => {
                        if (window.loadCommentsInPanel) {
                            window.loadCommentsInPanel(window.currentCommentsPostId);
                        }
                    }, 500);
                }
            } else {
                throw new Error(result.message || 'Failed to update comment');
            }
        } catch (error) {
            console.error('Error updating comment:', error);
            this.showNotification(error.message || 'Error updating comment', 'error');
        } finally {
            this.cancelEdit();
        }
    }

    // Cancel editing
    cancelEdit() {
        if (!this.currentlyEditing) return;
        
        // Look for comment in both legacy containers and panel
        let commentElement = document.querySelector(`.comment[data-comment-id="${this.currentlyEditing}"]`);
        
        if (!commentElement) {
            commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${this.currentlyEditing}"]`);
        }
        
        if (commentElement) {
            commentElement.classList.remove('editing');
            
            // If we're in the comments panel, reload the panel
            if (window.currentCommentsPostId && commentElement.closest('#commentsPanelContainer')) {
                if (window.loadCommentsInPanel) {
                    window.loadCommentsInPanel(window.currentCommentsPostId);
                }
            } else {
                // Restore original content for legacy containers
                const postId = this.getPostIdFromComment(this.currentlyEditing);
                if (postId) {
                    this.loadComments(postId);
                }
            }
        }
        
        this.currentlyEditing = null;
    }

    // Delete comment
    async deleteComment(commentId) {
        if (!confirm('Are you sure you want to delete this comment?')) return;
        
        try {
            const response = await fetch('api/delete_comment.php', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ comment_id: commentId })
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Update comment count if we have post ID
                if (result.post_id) {
                    this.updateCommentCountFromServer(result.post_id, result.new_count || 0);
                }
                
                // If we're in the comments panel, reload the panel
                const commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
                if (window.currentCommentsPostId && commentElement) {
                    if (window.loadCommentsInPanel) {
                        window.loadCommentsInPanel(window.currentCommentsPostId);
                    }
                } else {
                    // Legacy: Remove comment from UI or reload comments
                    const postId = this.getPostIdFromComment(commentId);
                    if (postId) {
                        await this.loadComments(postId);
                    }
                }
                
                this.showNotification('Comment deleted successfully', 'success');
            } else {
                throw new Error(result.message || 'Failed to delete comment');
            }
        } catch (error) {
            console.error('Error deleting comment:', error);
            this.showNotification(error.message || 'Error deleting comment', 'error');
        }
    }

    // Start replying to a comment
    startReply(commentId) {
        this.cancelEdit(); // Cancel any edit in progress
        this.cancelReply(); // Cancel any previous reply
        
        // Look for comment in both legacy containers and panel
        let commentElement = document.querySelector(`.comment[data-comment-id="${commentId}"]`);
        
        if (!commentElement) {
            commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
        }
        
        if (!commentElement) return;
        
        // Highlight the comment being replied to
        commentElement.classList.add('replying-to');
        
        // If we're in the comments panel, focus panel input
        if (commentElement.closest('#commentsPanelContainer')) {
            const panelInput = document.getElementById('commentsPanelInput');
            if (panelInput) {
                const authorName = commentElement.querySelector('.comment-author').textContent;
                panelInput.placeholder = `Replying to ${authorName}...`;
                panelInput.focus();
            }
        } else {
            // Legacy functionality for inline comments
            const postId = this.getPostIdFromComment(commentId);
            if (!postId) return;
            
            const commentInput = document.querySelector(`#comments${postId} .comment-input`);
            if (commentInput) {
                commentInput.placeholder = `Replying to ${commentElement.querySelector('.comment-author').textContent}...`;
                commentInput.focus();
            }
        }
        
        this.replyingTo = commentId;
    }

    // Submit reply to a comment
    async submitReply(parentCommentId, content) {
        if (!content.trim()) {
            this.showNotification('Please enter a reply', 'warning');
            return;
        }
        
        // Show loading state
        const postId = this.getPostIdFromComment(parentCommentId);
        const addButton = document.querySelector(`#comments${postId} .comment-submit`);
        const originalText = addButton ? addButton.innerHTML : '';
        if (addButton) {
            addButton.innerHTML = '<div class="spinner-small"></div>';
            addButton.disabled = true;
        }
        
        try {
            const response = await fetch('api/reply_comment.php', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ 
                    parent_comment_id: parentCommentId, 
                    content: content 
                })
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Clear input
                const commentInput = document.querySelector(`#comments${postId} .comment-input`);
                if (commentInput) commentInput.value = '';
                
                // Update comment count
                if (result.post_id) {
                    this.updateCommentCountFromServer(result.post_id, result.new_count || 0);
                }
                
                // Reload comments to show the new reply
                await this.loadComments(postId);
                
                this.showNotification('Reply added successfully', 'success');
            } else {
                throw new Error(result.message || 'Failed to add reply');
            }
        } catch (error) {
            console.error('Error adding reply:', error);
            this.showNotification(error.message || 'Error adding reply', 'error');
        } finally {
            if (addButton) {
                addButton.innerHTML = originalText;
                addButton.disabled = false;
            }
        }
    }

    // Cancel reply
    cancelReply() {
        if (!this.replyingTo) return;
        
        // Look for comment in both legacy containers and panel
        let commentElement = document.querySelector(`.comment[data-comment-id="${this.replyingTo}"]`);
        
        if (!commentElement) {
            commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${this.replyingTo}"]`);
        }
        
        if (commentElement) {
            commentElement.classList.remove('replying-to');
        }
        
        // Reset input placeholders
        if (commentElement && commentElement.closest('#commentsPanelContainer')) {
            const panelInput = document.getElementById('commentsPanelInput');
            if (panelInput) {
                panelInput.placeholder = 'Write a comment...';
            }
        } else {
            const postId = this.getPostIdFromComment(this.replyingTo);
            if (postId) {
                const commentInput = document.querySelector(`#comments${postId} .comment-input`);
                if (commentInput) {
                    commentInput.placeholder = 'Write a comment...';
                }
            }
        }
        
        this.replyingTo = null;
    }

    // Toggle comment like
    async toggleCommentLike(commentId) {
        try {
            const response = await fetch('api/toggle_like.php', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ comment_id: commentId })
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Update the like count in the UI
                this.updateCommentLikeUI(commentId, result.liked, result.like_count);
                
                // Also update in panel if it exists
                if (window.updateCommentLikeUIInPanel) {
                    window.updateCommentLikeUIInPanel(commentId, result.liked, result.like_count);
                }
            } else {
                throw new Error(result.message || 'Failed to toggle like');
            }
        } catch (error) {
            console.error('Error toggling comment like:', error);
            this.showNotification(error.message || 'Error toggling like', 'error');
        }
    }

    // Update comment like UI (legacy function)
    updateCommentLikeUI(commentId, liked, likeCount) {
        const commentElement = document.querySelector(`.comment[data-comment-id="${commentId}"]`);
        if (!commentElement) return;
        
        const likeAction = commentElement.querySelector('.comment-actions span:last-child');
        if (likeAction) {
            const likeText = liked ? 'Unlike' : 'Like';
            const countDisplay = likeCount > 0 ? `(${likeCount})` : '';
            likeAction.textContent = `${likeText} ${countDisplay}`;
        }
    }

    // Helper function to get post ID from comment (legacy function)
    getPostIdFromComment(commentId) {
        const commentsSection = document.querySelector('.comment-section[style*="display: block"]');
        if (!commentsSection) return null;
        
        const postIdMatch = commentsSection.id.match(/comments(\d+)/);
        return postIdMatch ? parseInt(postIdMatch[1]) : null;
    }

    // Helper function to load comments and update count in one go (legacy function)
    async loadCommentsAndUpdateCount(postId) {
        try {
            const response = await fetch(`api/get_comments.php?post_id=${postId}`);
            const data = await response.json();
            
            if (data.success) {
                const container = document.getElementById(`commentsContainer${postId}`);
                if (container) {
                    this.renderComments(container, data.comments);
                }
                // Update count from the same response
                this.updateCommentCountFromServer(postId, data.total_comments);
            }
        } catch (error) {
            console.error('Error loading comments and updating count:', error);
        }
    }

    // Update comment count from server response
    updateCommentCountFromServer(postId, serverCount) {
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return;

        const statsDiv = postElement.querySelector('.post-stats');
        if (!statsDiv) return;

        let commentCountElement = null;
        const spans = statsDiv.querySelectorAll('span');
        spans.forEach(span => {
            if (span.innerHTML.includes('bx-message')) {
                commentCountElement = span;
            }
        });

        // Always set to server count
        if (commentCountElement) {
            commentCountElement.innerHTML = `<i class='bx bx-message'></i> ${serverCount}`;
        } else if (serverCount > 0) {
            statsDiv.insertAdjacentHTML('beforeend', `<span><i class='bx bx-message'></i> ${serverCount}</span>`);
        }
    }

    // Handle comment keypress (legacy function)
    handleCommentKeyPress(event, postId) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.addComment(postId);
        }
    }

    // Utility function to escape HTML
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    // Show notification helper
    showNotification(message, type = 'info') {
        if (window.utils && window.utils.showNotification) {
            window.utils.showNotification(message, type);
        } else {
            console.log(`${type.toUpperCase()}: ${message}`);
            alert(message);
        }
    }
}

// Create global instance
if (typeof window !== 'undefined') {
    if (window.socialFeedCore) {
        window.commentSystem = new CommentSystem(window.socialFeedCore);
    } else {
        document.addEventListener('DOMContentLoaded', () => {
            setTimeout(() => {
                window.commentSystem = new CommentSystem(window.socialFeedCore);
            }, 100);
        });
    }
}