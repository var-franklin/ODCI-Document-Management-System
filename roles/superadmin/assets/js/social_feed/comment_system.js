// comment_system.js - Updated with proper reply functionality and user-friendly indicators

class CommentSystem {
    constructor(core) {
        this.core = core;
        this.currentlyEditing = null;
        this.replyingTo = null;
        this.replyingToData = null;
    }

    // Toggle comments section visibility - opens side panel
    async toggleComments(postId) {
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return;
        
        const authorElement = postElement.querySelector('.post-author-name');
        const authorName = authorElement ? authorElement.textContent : 'Unknown User';
        
        if (window.openCommentsPanel) {
            window.openCommentsPanel(postId, authorName);
        }
    }

    // Start replying to a comment
    startReply(commentId) {
        this.cancelEdit(); // Cancel any edit in progress
        this.cancelReply(); // Cancel any previous reply
        
        // Look for comment in panel
        let commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
        
        if (!commentElement) return;
        
        // Get comment author info
        const authorElement = commentElement.querySelector('.comment-author');
        const authorName = authorElement ? authorElement.textContent : 'Unknown User';
        
        // Store reply information
        this.replyingTo = commentId;
        this.replyingToData = {
            id: commentId,
            authorName: authorName
        };
        
        // Highlight the comment being replied to
        commentElement.classList.add('replying-to');
        
        // Focus panel input and show reply indicator
        const panelInput = document.getElementById('commentsPanelInput');
        if (panelInput) {
            panelInput.placeholder = `Replying to ${authorName}...`;
            panelInput.focus();
            this.showReplyIndicator(authorName, commentId);
        }
    }

    // Show reply indicator in panel
    showReplyIndicator(authorName, commentId) {
        // Remove any existing reply indicator
        const existingIndicator = document.getElementById('replyIndicator');
        if (existingIndicator) {
            existingIndicator.remove();
        }

        // Create reply indicator
        const indicator = document.createElement('div');
        indicator.id = 'replyIndicator';
        indicator.className = 'reply-indicator';
        indicator.innerHTML = `
            <div class="reply-indicator-content">
                <i class='bx bx-reply'></i>
                <span>Replying to <strong>${authorName}</strong></span>
                <button type="button" class="reply-cancel-btn" onclick="window.commentSystem.cancelReply()">
                    <i class='bx bx-x'></i>
                </button>
            </div>
        `;

        // Insert before comment form
        const commentForm = document.getElementById('commentsPanelForm');
        if (commentForm) {
            commentForm.parentNode.insertBefore(indicator, commentForm);
        }
    }

    // Cancel reply
    cancelReply() {
        if (!this.replyingTo) return;
        
        // Remove reply indicator
        const replyIndicator = document.getElementById('replyIndicator');
        if (replyIndicator) {
            replyIndicator.remove();
        }
        
        // Remove highlight from comment being replied to
        const commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${this.replyingTo}"]`);
        if (commentElement) {
            commentElement.classList.remove('replying-to');
        }
        
        // Reset input placeholder
        const panelInput = document.getElementById('commentsPanelInput');
        if (panelInput) {
            panelInput.placeholder = 'Write a comment...';
        }
        
        this.replyingTo = null;
        this.replyingToData = null;
    }

    // Submit reply from panel
    async submitReplyFromPanel(postId, content) {
        if (!this.replyingTo || !content.trim()) {
            return false;
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
                    content: content,
                    parent_comment_id: this.replyingTo
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
                // Update comment count
                if (result.actual_comment_count !== undefined) {
                    this.updateCommentCountFromServer(postId, result.actual_comment_count);
                }

                // Clear reply state
                this.cancelReply();

                // Show success message
                if (window.utils && window.utils.showNotification) {
                    window.utils.showNotification(result.message || 'Reply added successfully!', 'success');
                }

                return true;
            } else {
                throw new Error(result.message || 'Failed to add reply');
            }
        } catch (error) {
            console.error('Error adding reply:', error);
            if (window.utils && window.utils.showNotification) {
                window.utils.showNotification(error.message || 'Error adding reply', 'error');
            }
            return false;
        }
    }

    // Start editing a comment
    startEdit(commentId) {
        this.cancelEdit(); // Cancel any existing edit
        this.cancelReply(); // Cancel any reply in progress
        
        let commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
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
        let commentElement = document.querySelector(`#commentsPanelContainer .comment[data-comment-id="${commentId}"]`);
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
                this.showNotification('Comment updated successfully', 'success');
                
                // Reload the comments panel
                if (window.currentCommentsPostId && window.loadCommentsInPanel) {
                    setTimeout(() => {
                        window.loadCommentsInPanel(window.currentCommentsPostId);
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
        
        // Reload the comments panel
        if (window.currentCommentsPostId && window.loadCommentsInPanel) {
            window.loadCommentsInPanel(window.currentCommentsPostId);
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
                // Update comment count
                if (result.post_id) {
                    this.updateCommentCountFromServer(result.post_id, result.new_count || 0);
                }
                
                // Reload comments in panel
                if (window.currentCommentsPostId && window.loadCommentsInPanel) {
                    window.loadCommentsInPanel(window.currentCommentsPostId);
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

    // Utility functions
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }

    showNotification(message, type = 'info') {
        if (window.utils && window.utils.showNotification) {
            window.utils.showNotification(message, type);
        } else {
            console.log(`${type.toUpperCase()}: ${message}`);
            alert(message);
        }
    }

    // Legacy compatibility functions (kept for backward compatibility)
    async addComment(postId) {
        // Legacy function - redirects to panel if available
        if (window.currentCommentsPostId === postId && window.submitCommentFromPanel) {
            window.submitCommentFromPanel();
            return;
        }
        
        // Fallback to opening comments panel
        this.toggleComments(postId);
    }

    handleCommentKeyPress(event, postId) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.addComment(postId);
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