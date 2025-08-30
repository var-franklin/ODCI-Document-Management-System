class CommentSystem {
    constructor(core) {
        this.core = core;
        this.currentlyEditing = null;
        this.replyingTo = null;
        this.replyingToData = null;
        this.currentModalPostId = null;
        this.modalOverlay = null;
        this.modal = null;
    }

    // Main function to open comments modal
    async openCommentsModal(postId) {
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return;
        
        this.currentModalPostId = postId;
        
        // Create modal if it doesn't exist
        this.createModalStructure();
        
        // Clone and display the post in modal
        this.displayPostInModal(postElement);
        
        // Load comments
        await this.loadCommentsInModal(postId);
        
        // Show modal
        this.showModal();
    }

    // Create the modal HTML structure
    createModalStructure() {
        // Remove existing modal if present
        const existingOverlay = document.getElementById('commentsModalOverlay');
        if (existingOverlay) {
            existingOverlay.remove();
        }

        const modalHTML = `
            <div class="comments-modal-overlay" id="commentsModalOverlay">
                <div class="comments-modal" id="commentsModal">
                    <div class="comments-modal-header">
                        <h3 class="comments-modal-title">Post</h3>
                        <button class="comments-modal-close" id="commentsModalClose">
                            <i class='bx bx-x'></i>
                        </button>
                    </div>
                    
                    <div class="comments-modal-content" id="commentsModalContent">
                        <div class="comments-modal-post" id="commentsModalPost">
                            <!-- Post content will be inserted here -->
                        </div>
                        
                        <div class="comments-modal-comments-section">
                            <div class="comments-modal-loading" id="commentsModalLoading" style="display: none;">
                                <div class="spinner"></div>
                                <p>Loading comments...</p>
                            </div>
                            
                            <div class="comments-modal-comments-container" id="commentsModalCommentsContainer">
                                <!-- Comments will be loaded here -->
                            </div>
                        </div>
                    </div>
                    
                    <div class="comments-modal-comment-form" id="commentsModalCommentForm">
                        <div class="modal-comment-form-wrapper">
                            <img src="assets/img/default-avatar.png" alt="Your avatar" class="modal-comment-avatar" id="modalCommentAvatar">
                            <div class="modal-comment-input-wrapper">
                                <textarea class="modal-comment-input" id="modalCommentInput" placeholder="Write a comment..." rows="1"></textarea>
                            </div>
                            <button class="modal-comment-submit" id="modalCommentSubmit" disabled>
                                <i class='bx bx-send'></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        `;

        document.body.insertAdjacentHTML('beforeend', modalHTML);
        
        // Store references
        this.modalOverlay = document.getElementById('commentsModalOverlay');
        this.modal = document.getElementById('commentsModal');
        
        // Bind events
        this.bindModalEvents();
    }

    // Bind modal events
    bindModalEvents() {
        const closeBtn = document.getElementById('commentsModalClose');
        const overlay = this.modalOverlay;
        const input = document.getElementById('modalCommentInput');
        const submitBtn = document.getElementById('modalCommentSubmit');

        // Close button
        closeBtn.addEventListener('click', () => this.closeModal());

        // Close on overlay click (not on modal click)
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) {
                this.closeModal();
            }
        });

        // ESC key to close
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape' && overlay.classList.contains('show')) {
                this.closeModal();
            }
        });

        // Input events
        input.addEventListener('input', () => {
            this.autoResizeTextarea(input);
            this.toggleSubmitButton();
        });

        input.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.submitModalComment();
            }
        });

        // Submit button
        submitBtn.addEventListener('click', () => this.submitModalComment());
    }

    // Auto-resize textarea
    autoResizeTextarea(textarea) {
        textarea.style.height = 'auto';
        textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
    }

    // Toggle submit button state
    toggleSubmitButton() {
        const input = document.getElementById('modalCommentInput');
        const submitBtn = document.getElementById('modalCommentSubmit');
        
        if (input && submitBtn) {
            const hasContent = input.value.trim().length > 0;
            submitBtn.disabled = !hasContent;
        }
    }

    // Display post content in modal
    displayPostInModal(originalPostElement) {
        const modalPost = document.getElementById('commentsModalPost');
        if (!modalPost || !originalPostElement) return;

        // Clone the post element
        const postClone = originalPostElement.cloneNode(true);
        
        // Remove any existing click handlers from actions in the clone
        const postActions = postClone.querySelectorAll('.post-action');
        postActions.forEach(action => {
            action.removeAttribute('onclick');
        });

        // Clear modal post container and add cloned content
        modalPost.innerHTML = postClone.innerHTML;

        // Re-bind all post functionality for the modal post
        this.bindModalPostActions();

        // Update user avatar in comment form
        const userAvatar = document.getElementById('composerAvatar');
        const modalAvatar = document.getElementById('modalCommentAvatar');
        if (userAvatar && modalAvatar) {
            modalAvatar.src = userAvatar.src;
        }
    }

    // FIXED: Bind post actions in modal
    bindModalPostActions() {
        const modalPost = document.getElementById('commentsModalPost');
        if (!modalPost) return;

        // Bind like functionality
        const likeBtn = modalPost.querySelector('.post-action');
        if (likeBtn && likeBtn.innerHTML.includes('bx-heart')) {
            likeBtn.addEventListener('click', async (e) => {
                e.preventDefault();
                e.stopPropagation();
                
                if (this.currentModalPostId && window.postActions) {
                    try {
                        const result = await window.postActions.toggleLike(this.currentModalPostId);
                        if (result && result.success) {
                            // Update modal post like UI
                            this.updateModalPostLikeUI(result.liked, result.like_count);
                            // Update original post like UI
                            this.updateOriginalPostLikeUI(this.currentModalPostId, result.liked, result.like_count);
                        }
                    } catch (error) {
                        console.error('Error toggling post like in modal:', error);
                    }
                } else if (typeof toggleLike === 'function') {
                    // Fallback to global function
                    toggleLike(this.currentModalPostId);
                }
            });
        }

        // Bind other post actions if needed (share, etc.)
        const allActions = modalPost.querySelectorAll('.post-action');
        allActions.forEach(action => {
            if (action.innerHTML.includes('bx-message')) {
                // Comment button - should be disabled in modal or do nothing
                action.style.pointerEvents = 'none';
                action.style.opacity = '0.6';
            }
        });
    }

    // Update modal post like UI
    updateModalPostLikeUI(liked, likeCount) {
        const modalPost = document.getElementById('commentsModalPost');
        if (!modalPost) return;

        const likeBtn = modalPost.querySelector('.post-action');
        if (likeBtn && likeBtn.innerHTML.includes('bx-heart')) {
            const icon = likeBtn.querySelector('i');
            const text = likeBtn.querySelector('span');
            
            if (icon) {
                icon.className = liked ? 'bx bxs-heart' : 'bx bx-heart';
            }
            
            if (text) {
                text.textContent = liked ? 'Liked' : 'Like';
            }
            
            likeBtn.className = liked ? 'post-action liked' : 'post-action';
        }

        // Update like count in stats
        const statsDiv = modalPost.querySelector('.post-stats');
        if (statsDiv) {
            let likeCountElement = null;
            const spans = statsDiv.querySelectorAll('span');
            spans.forEach(span => {
                if (span.innerHTML.includes('bx-heart')) {
                    likeCountElement = span;
                }
            });

            if (likeCountElement) {
                if (likeCount > 0) {
                    likeCountElement.innerHTML = `<i class='bx bx-heart'></i> ${likeCount}`;
                } else {
                    likeCountElement.remove();
                }
            } else if (likeCount > 0) {
                statsDiv.insertAdjacentHTML('afterbegin', `<span><i class='bx bx-heart'></i> ${likeCount}</span>`);
            }
        }
    }

    // Update original post like UI
    updateOriginalPostLikeUI(postId, liked, likeCount) {
        const originalPost = document.querySelector(`[data-post-id="${postId}"]`);
        if (!originalPost) return;

        const likeBtn = originalPost.querySelector('.post-action');
        if (likeBtn && likeBtn.innerHTML.includes('bx-heart')) {
            const icon = likeBtn.querySelector('i');
            const text = likeBtn.querySelector('span');
            
            if (icon) {
                icon.className = liked ? 'bx bxs-heart' : 'bx bx-heart';
            }
            
            if (text) {
                text.textContent = liked ? 'Liked' : 'Like';
            }
            
            likeBtn.className = liked ? 'post-action liked' : 'post-action';
        }

        // Update like count in original post stats
        const statsDiv = originalPost.querySelector('.post-stats');
        if (statsDiv) {
            let likeCountElement = null;
            const spans = statsDiv.querySelectorAll('span');
            spans.forEach(span => {
                if (span.innerHTML.includes('bx-heart')) {
                    likeCountElement = span;
                }
            });

            if (likeCountElement) {
                if (likeCount > 0) {
                    likeCountElement.innerHTML = `<i class='bx bx-heart'></i> ${likeCount}`;
                } else {
                    likeCountElement.remove();
                }
            } else if (likeCount > 0) {
                statsDiv.insertAdjacentHTML('afterbegin', `<span><i class='bx bx-heart'></i> ${likeCount}</span>`);
            }
        }
    }

    // Show modal with animation
    showModal() {
        if (!this.modalOverlay) return;
        
        this.modalOverlay.style.display = 'flex';
        // Force reflow
        this.modalOverlay.offsetHeight;
        this.modalOverlay.classList.add('show');
        
        // Prevent body scroll
        document.body.style.overflow = 'hidden';
        
        // Focus comment input
        setTimeout(() => {
            const input = document.getElementById('modalCommentInput');
            if (input) input.focus();
        }, 300);
    }

    // Close modal
    closeModal() {
        if (!this.modalOverlay) return;
        
        this.modalOverlay.classList.remove('show');
        
        setTimeout(() => {
            this.modalOverlay.style.display = 'none';
            // Restore body scroll
            document.body.style.overflow = '';
            
            // Clean up
            this.currentModalPostId = null;
            this.cancelReply();
            this.cancelEdit();
            
            // Clear input
            const input = document.getElementById('modalCommentInput');
            if (input) {
                input.value = '';
                this.autoResizeTextarea(input);
            }
            this.toggleSubmitButton();
            
        }, 300);
    }

    // Load comments in modal
    async loadCommentsInModal(postId) {
        const loadingDiv = document.getElementById('commentsModalLoading');
        const container = document.getElementById('commentsModalCommentsContainer');

        if (loadingDiv) loadingDiv.style.display = 'block';
        if (container) container.innerHTML = '';

        try {
            const response = await fetch(`/ODCI/social_feed/api/get_comments.php?post_id=${postId}&limit=50`);

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
                this.renderCommentsInModal(container, data.comments);
            } else {
                this.showModalError(container, data.message || 'Failed to load comments');
            }
        } catch (error) {
            console.error('Error loading comments:', error);
            this.showModalError(container, error.message);
        } finally {
            if (loadingDiv) loadingDiv.style.display = 'none';
        }
    }

    // Render comments in modal
    renderCommentsInModal(container, comments) {
        container.innerHTML = '';

        if (comments.length === 0) {
            container.innerHTML = `
                <div class="comments-modal-empty">
                    <i class='bx bx-message-dots'></i>
                    <h3>No comments yet</h3>
                    <p>Be the first to share what you think!</p>
                </div>
            `;
            return;
        }

        comments.forEach(comment => {
            const commentElement = this.createModalCommentElement(comment);
            container.appendChild(commentElement);

            // Add replies if they exist
            if (comment.replies && comment.replies.length > 0) {
                const repliesContainer = document.createElement('div');
                repliesContainer.className = 'modal-replies-container';

                comment.replies.forEach(reply => {
                    const replyElement = this.createModalCommentElement(reply, true, comment.commenter_full_name);
                    repliesContainer.appendChild(replyElement);
                });

                container.appendChild(repliesContainer);
            }
        });
    }

    // Create comment element for modal
    createModalCommentElement(comment, isReply = false, parentAuthor = null) {
        const commentDiv = document.createElement('div');
        commentDiv.className = 'modal-comment' + (isReply ? ' modal-comment-reply' : '');
        commentDiv.dataset.commentId = comment.id;

        const timeAgo = window.utils ? window.utils.getTimeAgo(comment.created_at) : 'recently';
        const editedText = comment.is_edited ?
            '<span style="color: var(--text-secondary); font-size: 11px; margin-left: 8px;">(edited)</span>' : '';

        // Create action buttons
        const actions = [];
        actions.push(`<span class="comment-action" onclick="window.commentSystem.startModalReply(${comment.id})">Reply</span>`);

        // FIXED: Check if current user can edit this comment
        if (this.canEditComment(comment)) {
            actions.push(`<span class="comment-action" onclick="window.commentSystem.startModalEdit(${comment.id})">Edit</span>`);
            actions.push(`<span class="comment-action" onclick="window.commentSystem.deleteModalComment(${comment.id})">Delete</span>`);
        }

        const likeText = comment.user_liked ? 'Unlike' : 'Like';
        const likeCount = comment.like_count > 0 ? ` · ${comment.like_count}` : '';
        actions.push(`<span class="comment-action comment-like-btn" onclick="window.commentSystem.toggleModalCommentLike(${comment.id})">${likeText}${likeCount}</span>`);

        commentDiv.innerHTML = `
            <img src="${comment.profile_image || 'assets/img/default-avatar.png'}" 
                alt="${comment.commenter_full_name}" class="comment-avatar">
            <div class="comment-content">
                <div class="comment-header">
                    <span class="comment-author">${comment.commenter_full_name}</span>
                    <span class="comment-time">${timeAgo}</span>
                    ${editedText}
                </div>
                <div class="comment-text" ${this.canEditComment(comment) ? `id="commentText${comment.id}"` : ''}>${this.escapeHtml(comment.content)}</div>
                <div class="comment-actions">
                    ${actions.join(' · ')}
                </div>
            </div>
        `;

        return commentDiv;
    }

    // FIXED: Check if user can edit comment
    canEditComment(comment) {
        // Check if we have access to current user info
        if (window.socialFeedCore && window.socialFeedCore.currentUser) {
            const currentUser = window.socialFeedCore.currentUser;
            return comment.user_id == currentUser.id || 
                   ['admin', 'super_admin'].includes(currentUser.role);
        }
        
        // Fallback: try to get from session or global
        if (window.currentUserId) {
            return comment.user_id == window.currentUserId;
        }
        
        // If we can't determine, don't show edit options
        return false;
    }

    // Show modal error
    showModalError(container, message = 'Error loading comments') {
        if (container) {
            container.innerHTML = `
                <div class="comments-modal-empty">
                    <i class='bx bx-error'></i>
                    <h3>Error</h3>
                    <p>${message}</p>
                </div>
            `;
        }
    }

    // Submit comment from modal
    async submitModalComment() {
        if (!this.currentModalPostId) return;

        const input = document.getElementById('modalCommentInput');
        if (!input) return;

        const content = input.value.trim();
        if (!content) {
            this.showNotification('Please enter a comment', 'warning');
            return;
        }

        // Handle edit mode
        if (this.currentlyEditing) {
            await this.submitModalEdit(content);
            return;
        }

        const submitButton = document.getElementById('modalCommentSubmit');
        const originalHTML = submitButton ? submitButton.innerHTML : '';
        
        if (submitButton) {
            submitButton.innerHTML = '<div class="spinner"></div>';
            submitButton.disabled = true;
        }

        try {
            const requestData = {
                post_id: this.currentModalPostId,
                content: content
            };

            // Handle reply
            if (this.replyingTo) {
                requestData.parent_comment_id = this.replyingTo;
            }

            const response = await fetch('/ODCI/social_feed/api/add_comment.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify(requestData)
            });

            const responseText = await response.text();

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${responseText}`);
            }

            let result;
            try {
                result = JSON.parse(responseText);
            } catch (parseError) {
                throw new Error('Invalid JSON response');
            }

            if (result.success) {
                input.value = '';
                this.autoResizeTextarea(input);
                this.cancelReply();

                // Update comment count in original post
                if (result.actual_comment_count !== undefined) {
                    this.updateCommentCountFromServer(this.currentModalPostId, result.actual_comment_count);
                }

                // Reload comments
                await this.loadCommentsInModal(this.currentModalPostId);
                
                this.showNotification(result.message || 'Comment added successfully!', 'success');
            } else {
                throw new Error(result.message || 'Failed to add comment');
            }
        } catch (error) {
            console.error('Error adding comment:', error);
            this.showNotification(error.message || 'Error adding comment', 'error');
        } finally {
            if (submitButton) {
                submitButton.innerHTML = originalHTML;
            }
            this.toggleSubmitButton();
        }
    }

    // Start reply in modal
    startModalReply(commentId) {
        this.cancelEdit();
        this.cancelReply();
        
        const commentElement = document.querySelector(`#commentsModalCommentsContainer [data-comment-id="${commentId}"]`);
        if (!commentElement) return;
        
        const authorElement = commentElement.querySelector('.comment-author');
        const authorName = authorElement ? authorElement.textContent : 'Unknown User';
        
        this.replyingTo = commentId;
        this.replyingToData = {
            id: commentId,
            authorName: authorName
        };
        
        commentElement.classList.add('replying-to');
        this.showModalReplyIndicator(authorName, commentId);
        
        const input = document.getElementById('modalCommentInput');
        if (input) {
            input.placeholder = `Replying to ${authorName}...`;
            input.focus();
        }
    }

    // Show reply indicator in modal
    showModalReplyIndicator(authorName, commentId) {
        const existingIndicator = document.getElementById('modalReplyIndicator');
        if (existingIndicator) {
            existingIndicator.remove();
        }

        const indicator = document.createElement('div');
        indicator.id = 'modalReplyIndicator';
        indicator.className = 'modal-reply-indicator';
        indicator.innerHTML = `
            <i class='bx bx-reply'></i>
            <span>Replying to <strong>${authorName}</strong></span>
            <button type="button" class="modal-reply-cancel" onclick="window.commentSystem.cancelReply()">
                <i class='bx bx-x'></i>
            </button>
        `;

        const commentForm = document.getElementById('commentsModalCommentForm');
        if (commentForm) {
            commentForm.parentNode.insertBefore(indicator, commentForm);
        }
    }

    // Cancel reply
    cancelReply() {
        if (!this.replyingTo) return;
        
        const replyIndicator = document.getElementById('modalReplyIndicator');
        if (replyIndicator) {
            replyIndicator.remove();
        }
        
        const commentElement = document.querySelector(`#commentsModalCommentsContainer [data-comment-id="${this.replyingTo}"]`);
        if (commentElement) {
            commentElement.classList.remove('replying-to');
        }
        
        const input = document.getElementById('modalCommentInput');
        if (input) {
            input.placeholder = 'Write a comment...';
        }
        
        this.replyingTo = null;
        this.replyingToData = null;
    }

    // IMPLEMENTED: Start edit in modal
    startModalEdit(commentId) {
        this.cancelReply();
        this.cancelEdit();
        
        const commentElement = document.querySelector(`#commentsModalCommentsContainer [data-comment-id="${commentId}"]`);
        if (!commentElement) return;
        
        const commentTextElement = commentElement.querySelector(`#commentText${commentId}`);
        if (!commentTextElement) return;
        
        const currentContent = commentTextElement.textContent.trim();
        
        this.currentlyEditing = commentId;
        
        // Show edit indicator
        this.showModalEditIndicator(commentId);
        
        // Set input to edit mode
        const input = document.getElementById('modalCommentInput');
        if (input) {
            input.value = currentContent;
            input.placeholder = 'Edit your comment...';
            input.focus();
            this.autoResizeTextarea(input);
        }
        
        this.toggleSubmitButton();
    }

    // Show edit indicator in modal
    showModalEditIndicator(commentId) {
        const existingIndicator = document.getElementById('modalEditIndicator');
        if (existingIndicator) {
            existingIndicator.remove();
        }

        const indicator = document.createElement('div');
        indicator.id = 'modalEditIndicator';
        indicator.className = 'modal-reply-indicator'; // Reuse styling
        indicator.innerHTML = `
            <i class='bx bx-edit'></i>
            <span>Editing comment</span>
            <button type="button" class="modal-reply-cancel" onclick="window.commentSystem.cancelEdit()">
                <i class='bx bx-x'></i>
            </button>
        `;

        const commentForm = document.getElementById('commentsModalCommentForm');
        if (commentForm) {
            commentForm.parentNode.insertBefore(indicator, commentForm);
        }
    }

    // Cancel edit
    cancelEdit() {
        if (!this.currentlyEditing) return;
        
        const editIndicator = document.getElementById('modalEditIndicator');
        if (editIndicator) {
            editIndicator.remove();
        }
        
        const input = document.getElementById('modalCommentInput');
        if (input) {
            input.value = '';
            input.placeholder = 'Write a comment...';
            this.autoResizeTextarea(input);
        }
        
        this.currentlyEditing = null;
        this.toggleSubmitButton();
    }

    // Submit edit in modal
    async submitModalEdit(content) {
        if (!this.currentlyEditing || !content.trim()) {
            return;
        }

        const submitButton = document.getElementById('modalCommentSubmit');
        const originalHTML = submitButton ? submitButton.innerHTML : '';
        
        if (submitButton) {
            submitButton.innerHTML = '<div class="spinner"></div>';
            submitButton.disabled = true;
        }

        try {
            const response = await fetch('/ODCI/social_feed/api/edit_comment.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({
                    comment_id: this.currentlyEditing,
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
                throw new Error('Invalid JSON response');
            }

            if (result.success) {
                const input = document.getElementById('modalCommentInput');
                if (input) {
                    input.value = '';
                    this.autoResizeTextarea(input);
                }

                this.cancelEdit();

                // Reload comments to show updated content
                await this.loadCommentsInModal(this.currentModalPostId);
                
                this.showNotification(result.message || 'Comment updated successfully!', 'success');
            } else {
                throw new Error(result.message || 'Failed to update comment');
            }
        } catch (error) {
            console.error('Error updating comment:', error);
            this.showNotification(error.message || 'Error updating comment', 'error');
        } finally {
            if (submitButton) {
                submitButton.innerHTML = originalHTML;
            }
            this.toggleSubmitButton();
        }
    }

    async deleteModalComment(commentId) {
        if (!confirm('Are you sure you want to delete this comment?')) return;
        
        try {
            const response = await fetch('/ODCI/social_feed/api/delete_comment.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ comment_id: commentId })
            });
            
            const result = await response.json();
            
            if (result.success) {
                // Update comment count in original post
                if (result.post_id) {
                    const currentCount = this.getCurrentCommentCount(result.post_id);
                    this.updateCommentCountFromServer(result.post_id, Math.max(0, currentCount - 1));
                }
                
                if (this.currentModalPostId) {
                    await this.loadCommentsInModal(this.currentModalPostId);
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

    async toggleModalCommentLike(commentId) {
        try {
            const response = await fetch('/ODCI/social_feed/api/toggle_like.php', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json'
                },
                body: JSON.stringify({ comment_id: commentId })
            });
            
            const result = await response.json();
            
            if (result.success) {
                this.updateModalCommentLikeUI(commentId, result.liked, result.like_count || 0);
            } else {
                throw new Error(result.message || 'Failed to toggle like');
            }
        } catch (error) {
            console.error('Error toggling comment like:', error);
            this.showNotification(error.message || 'Error toggling like', 'error');
        }
    }

    updateModalCommentLikeUI(commentId, liked, likeCount) {
        const commentElement = document.querySelector(`#commentsModalCommentsContainer [data-comment-id="${commentId}"]`);
        if (!commentElement) return;

        const likeAction = commentElement.querySelector('.comment-like-btn');
        if (likeAction) {
            const likeText = liked ? 'Unlike' : 'Like';
            const countDisplay = likeCount > 0 ? ` · ${likeCount}` : '';
            likeAction.textContent = `${likeText}${countDisplay}`;
        }
    }

    // Get current comment count from DOM
    getCurrentCommentCount(postId) {
        const postElement = document.querySelector(`[data-post-id="${postId}"]`);
        if (!postElement) return 0;

        const statsDiv = postElement.querySelector('.post-stats');
        if (!statsDiv) return 0;

        const spans = statsDiv.querySelectorAll('span');
        for (let span of spans) {
            if (span.innerHTML.includes('bx-message')) {
                const match = span.textContent.match(/\d+/);
                return match ? parseInt(match[0]) : 0;
            }
        }
        return 0;
    }

    // Keep existing utility and legacy functions
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

        if (commentCountElement) {
            if (serverCount > 0) {
                commentCountElement.innerHTML = `<i class='bx bx-message'></i> ${serverCount}`;
            } else {
                commentCountElement.remove();
            }
        } else if (serverCount > 0) {
            statsDiv.insertAdjacentHTML('beforeend', `<span><i class='bx bx-message'></i> ${serverCount}</span>`);
        }
    }

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
        }
    }

    // Legacy compatibility - redirect to modal
    async toggleComments(postId) {
        await this.openCommentsModal(postId);
    }

    async addComment(postId) {
        await this.openCommentsModal(postId);
    }

    handleCommentKeyPress(event, postId) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.openCommentsModal(postId);
        }
    }

    // Placeholder for compatibility
    startReply() { /* Deprecated - using modal */ }
    submitReplyFromPanel() { return false; }
    startEdit() { /* Deprecated - using modal */ }
    submitEdit() { /* Deprecated - using modal */ }
    deleteComment() { /* Deprecated - using modal */ }
    toggleCommentLike() { /* Deprecated - using modal */ }
    showReplyIndicator() { /* Deprecated - using modal */ }
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