<<<<<<< HEAD
// Simple fix for comment count issue
// Only modify the addComment function to not increment count
=======
// comment-system.js
// Module for handling comments functionality
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d

class CommentSystem {
    constructor(core) {
        this.core = core;
    }

    // Toggle comments section visibility
    async toggleComments(postId) {
        const commentsSection = document.getElementById(`comments${postId}`);
        
        if (!commentsSection) return;

        if (commentsSection.style.display === 'none') {
            commentsSection.style.display = 'block';
            await this.loadComments(postId);
        } else {
            commentsSection.style.display = 'none';
        }
    }

    // Load comments for a post
    async loadComments(postId) {
        const loadingDiv = document.getElementById(`commentsLoading${postId}`);
        const container = document.getElementById(`commentsContainer${postId}`);
        
        if (loadingDiv) loadingDiv.style.display = 'block';
        
        try {
            const response = await fetch(`api/get_comments.php?post_id=${postId}`);
<<<<<<< HEAD
            
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
                // FIXED: Update count with actual server count
                this.updateCommentCountFromServer(postId, data.total_comments);
            } else {
                this.showCommentsError(container, data.message || 'Failed to load comments');
            }
        } catch (error) {
            console.error('Error loading comments:', error);
            this.showCommentsError(container, error.message);
=======
            const data = await response.json();
            
            if (data.success && container) {
                this.renderComments(container, data.comments);
            } else {
                this.showCommentsError(container);
            }
        } catch (error) {
            console.error('Error loading comments:', error);
            this.showCommentsError(container);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        } finally {
            if (loadingDiv) loadingDiv.style.display = 'none';
        }
    }

    // Render comments in container
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

    // Show comments error
<<<<<<< HEAD
    showCommentsError(container, message = 'Error loading comments') {
        if (container) {
            container.innerHTML = `<p style="color: var(--red-primary); text-align: center; padding: 20px;">${message}</p>`;
=======
    showCommentsError(container) {
        if (container) {
            container.innerHTML = '<p style="color: var(--red-primary); text-align: center; padding: 20px;">Error loading comments</p>';
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        }
    }

    // Create comment element
    createCommentElement(comment) {
        const commentDiv = document.createElement('div');
        commentDiv.className = 'comment';
        commentDiv.dataset.commentId = comment.id;
        
<<<<<<< HEAD
        const timeAgo = window.utils ? window.utils.getTimeAgo(comment.created_at) : 'recently';
=======
        const timeAgo = window.utils.getTimeAgo(comment.created_at);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
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
<<<<<<< HEAD
                <div class="comment-text">${this.escapeHtml(comment.content)}</div>
=======
                <div class="comment-text">${window.utils.escapeHtml(comment.content)}</div>
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
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
<<<<<<< HEAD
        const actions = [`<span class="comment-action" onclick="window.commentSystem.replyToComment(${comment.id})">Reply</span>`];
        
        if (this.core && this.core.canEditComment(comment)) {
            actions.push(`<span class="comment-action" onclick="window.commentSystem.editComment(${comment.id})">Edit</span>`);
            actions.push(`<span class="comment-action" onclick="window.commentSystem.deleteComment(${comment.id})">Delete</span>`);
=======
        const actions = [`<span class="comment-action" onclick="replyToComment(${comment.id})">Reply</span>`];
        
        if (this.core.canEditComment(comment)) {
            actions.push(`<span class="comment-action" onclick="editComment(${comment.id})">Edit</span>`);
            actions.push(`<span class="comment-action" onclick="deleteComment(${comment.id})">Delete</span>`);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        }
        
        const likeText = comment.user_liked ? 'Unlike' : 'Like';
        const likeCount = comment.like_count > 0 ? `(${comment.like_count})` : '';
<<<<<<< HEAD
        actions.push(`<span class="comment-action" onclick="window.commentSystem.toggleCommentLike(${comment.id})">${likeText} ${likeCount}</span>`);
=======
        actions.push(`<span class="comment-action" onclick="toggleCommentLike(${comment.id})">${likeText} ${likeCount}</span>`);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        
        return actions.join('');
    }

<<<<<<< HEAD
    // FIXED: Add new comment without manual count increment
    async addComment(postId) {
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
        
        // Show loading state
        const addButton = input.parentElement.querySelector('.add-comment-btn');
        const originalText = addButton ? addButton.textContent : '';
        if (addButton) {
            addButton.textContent = 'Adding...';
            addButton.disabled = true;
        }
=======
    // Add new comment
    async addComment(postId) {
        const input = document.querySelector(`#comments${postId} .comment-input`);
        if (!input) return;
        
        const content = input.value.trim();
        if (!content) return;
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        
        try {
            const response = await fetch('api/add_comment.php', {
                method: 'POST',
<<<<<<< HEAD
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
                // FIXED: Just reload comments - this will update the count correctly
                await this.loadComments(postId);
                this.showNotification(result.message || 'Comment added successfully!', 'success');
            } else {
                throw new Error(result.message || 'Failed to add comment');
            }
        } catch (error) {
            console.error('Error adding comment:', error);
            this.showNotification(error.message || 'Error adding comment', 'error');
        } finally {
            // Restore button state
            if (addButton) {
                addButton.textContent = originalText || 'Post';
                addButton.disabled = false;
            }
        }
    }

    // FIXED: Use server count instead of incrementing
    updateCommentCountFromServer(postId, serverCount) {
=======
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ post_id: postId, content: content })
            });
            
            const result = await response.json();
            
            if (result.success) {
                input.value = '';
                await this.loadComments(postId);
                this.updateCommentCount(postId);
            } else {
                window.utils.showNotification(result.message || 'Error adding comment', 'error');
            }
        } catch (error) {
            console.error('Error adding comment:', error);
            window.utils.showNotification('Error adding comment', 'error');
        }
    }

    // Update comment count in post
    updateCommentCount(postId) {
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return;

        const statsDiv = postElement.querySelector('.post-stats');
        if (!statsDiv) return;

        let commentCountElement = null;
        
        // Find existing comment count element
        const spans = statsDiv.querySelectorAll('span');
        spans.forEach(span => {
            if (span.innerHTML.includes('bx-message')) {
                commentCountElement = span;
            }
        });
        
        if (commentCountElement) {
<<<<<<< HEAD
            commentCountElement.innerHTML = `<i class='bx bx-message'></i> ${serverCount}`;
        } else if (serverCount > 0) {
            statsDiv.insertAdjacentHTML('beforeend', `<span><i class='bx bx-message'></i> ${serverCount}</span>`);
=======
            const currentCount = parseInt(commentCountElement.textContent.match(/\d+/)?.[0] || 0);
            commentCountElement.innerHTML = `<i class='bx bx-message'></i> ${currentCount + 1}`;
        } else {
            statsDiv.insertAdjacentHTML('beforeend', `<span><i class='bx bx-message'></i> 1</span>`);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
        }
    }

    // Handle comment keypress
    handleCommentKeyPress(event, postId) {
<<<<<<< HEAD
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
=======
        if (event.key === 'Enter') {
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
            this.addComment(postId);
        }
    }

<<<<<<< HEAD
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

    // Reply to comment (placeholder)
    replyToComment(commentId) {
        console.log('Reply to comment:', commentId);
        this.showNotification('Reply feature coming soon!', 'info');
=======
    // Reply to comment (placeholder)
    replyToComment(commentId) {
        console.log('Reply to comment:', commentId);
        window.utils.showNotification('Reply feature coming soon!', 'info');
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    }

    // Edit comment (placeholder)
    editComment(commentId) {
        console.log('Edit comment:', commentId);
<<<<<<< HEAD
        this.showNotification('Edit comment feature coming soon!', 'info');
=======
        window.utils.showNotification('Edit comment feature coming soon!', 'info');
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    }

    // Delete comment (placeholder)
    deleteComment(commentId) {
        console.log('Delete comment:', commentId);
<<<<<<< HEAD
        this.showNotification('Delete comment feature coming soon!', 'info');
=======
        window.utils.showNotification('Delete comment feature coming soon!', 'info');
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    }

    // Toggle comment like (placeholder)
    toggleCommentLike(commentId) {
        console.log('Toggle comment like:', commentId);
<<<<<<< HEAD
        this.showNotification('Comment like feature coming soon!', 'info');
=======
        window.utils.showNotification('Comment like feature coming soon!', 'info');
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    }
}

// Create global instance
<<<<<<< HEAD
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
=======
window.commentSystem = new CommentSystem(window.socialFeedCore);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
