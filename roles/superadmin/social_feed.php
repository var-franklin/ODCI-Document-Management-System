<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Social Feed - CVSU NAIC</title>
    <link href='https://unpkg.com/boxicons@2.0.9/css/boxicons.min.css' rel='stylesheet'>
    <!-- Component Stylesheets -->
    <link rel="stylesheet" href="assets/css/base.css?v=<?= time() ?>">
    <link rel="stylesheet" href="assets/css/sidebar.css?v=<?= time() ?>">
    <link rel="stylesheet" href="assets/css/navbar.css?v=<?= time() ?>">
    <link rel="stylesheet" href="assets/css/social_feed.css?v=<?= time() ?>">
</head>

<body>
    <!-- Sidebar Component -->
    <?php include 'components/sidebar.html'; ?>

    <!-- Content -->
    <section id="content">
        <!-- Navbar Component -->
        <?php include 'components/navbar.html'; ?>

        <!-- Main Content -->
        <main>
            <div class="head-title">
                <div class="left">
                    <h1>Social Feed</h1>
                    <ul class="breadcrumb">
                        <li><a href="#">Dashboard</a></li>
                        <li><i class='bx bx-chevron-right'></i></li>
                        <li><a class="active" href="#">Overview</a></li>
                    </ul>
                </div>
            </div>

            <div class="feed-container">
                <!-- TOP ROW - Navigation -->
                <div class="feed-navigation">
                    <div class="feed-tabs">
                        <button class="feed-tab active" data-filter="all">
                            <i class='bx bx-home'></i> All Posts
                        </button>
                        <button class="feed-tab" data-filter="my_posts">
                            <i class='bx bx-user'></i> My Posts
                        </button>
                        <button class="feed-tab" data-filter="department">
                            <i class='bx bx-buildings'></i> Departments
                        </button>
                        <button class="feed-tab" data-filter="pinned">
                            <i class='bx bx-pin'></i> Pinned
                        </button>
                    </div>
                </div>

                <!-- BOTTOM ROW - Content Area -->
                <div class="feed-content-area" id="feedContentArea">
                    <!-- LEFT COLUMN - Posts and Composer -->
                    <div class="feed-main-column">
                        <!-- Post Composer -->
                        <div class="post-composer">
                            <form id="postForm" onsubmit="createPost(event)">
                                <div class="composer-header">
                                    <img src="assets/img/default-avatar.png" alt="Your avatar" class="composer-avatar"
                                        id="composerAvatar">

                                    <div class="composer-user-info">
                                        <strong id="composerName">Loading...</strong>

                                        <div class="visibility-selector">
                                            <button type="button" class="visibility-btn" id="visibilityBtn">
                                                <i class='bx bx-globe'></i> Everyone
                                                <i class='bx bx-chevron-down'></i>
                                            </button>

                                            <div class="visibility-dropdown" id="visibilityDropdown">
                                                <div class="visibility-option" data-visibility="public">
                                                    <i class='bx bx-globe'></i>
                                                    <div>
                                                        <strong>Everyone</strong>
                                                        <div style="font-size: 12px; color: var(--text-secondary);">
                                                            Visible to all users
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="visibility-option" data-visibility="department">
                                                    <i class='bx bx-buildings'></i>
                                                    <div>
                                                        <strong>Department</strong>
                                                        <div style="font-size: 12px; color: var(--text-secondary);">
                                                            Only your department
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="visibility-option" data-visibility="custom">
                                                    <i class='bx bx-group'></i>
                                                    <div>
                                                        <strong>Specific Users</strong>
                                                        <div style="font-size: 12px; color: var(--text-secondary);">
                                                            Choose who can see
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <textarea class="composer-textarea" id="postContent"
                                    placeholder="What's happening in your department?" required></textarea>

                                <div class="composer-actions">
                                    <div class="composer-tools">
                                        <button type="button" class="composer-tool" title="Add Image"
                                            onclick="document.getElementById('imageInput').click()">
                                            <i class='bx bx-image'></i>
                                        </button>
                                        <button type="button" class="composer-tool" title="Add File"
                                            onclick="document.getElementById('fileInput').click()">
                                            <i class='bx bx-paperclip'></i>
                                        </button>
                                        <button type="button" class="composer-tool" title="Add Link"
                                            onclick="toggleLinkInput()">
                                            <i class='bx bx-link'></i>
                                        </button>
                                        <button type="button" class="composer-tool" title="Set Priority"
                                            onclick="togglePrioritySelector()">
                                            <i class='bx bx-flag'></i>
                                        </button>
                                    </div>

                                    <button type="submit" class="post-btn" id="postBtn" disabled>
                                        <i class='bx bx-send'></i> Post
                                    </button>
                                </div>

                                <!-- Hidden Inputs -->
                                <input type="file" id="imageInput" accept="image/*" multiple style="display: none;"
                                    onchange="handleImageUpload(this)">
                                <input type="file" id="fileInput" multiple style="display: none;"
                                    onchange="handleFileUpload(this)">
                                <input type="hidden" id="postVisibility" value="public">
                                <input type="hidden" id="postPriority" value="normal">
                            </form>
                        </div>

                        <!-- Posts Feed -->
                        <div class="feed-content" id="feedContent">
                            <div class="loading">
                                <div class="spinner"></div>
                                <p>Loading posts...</p>
                            </div>
                        </div>

                        <!-- Load More -->
                        <div class="load-more" id="loadMoreSection" style="display: none;">
                            <button class="load-more-btn" onclick="loadMorePosts()">
                                <i class='bx bx-refresh'></i> Load More Posts
                            </button>
                        </div>
                    </div>

                    <!-- RIGHT COLUMN - Comment Section (Initially Hidden) -->
                    <div class="feed-comments-column" id="commentsPanel">
                        <div class="comments-panel-header">
                            <div class="comments-panel-title" id="commentsPanelTitle">
                                Comments
                            </div>
                            <button class="comments-close-btn" onclick="closeCommentsPanel()" title="Close Comments">
                                <i class='bx bx-x'></i>
                            </button>
                        </div>

                        <div class="comments-panel-content">
                            <div class="comments-loading" id="commentsPanelLoading" style="display: none;">
                                <div class="loading">
                                    <div class="spinner"></div>
                                    <p>Loading comments...</p>
                                </div>
                            </div>

                            <div class="comments-container" id="commentsPanelContainer">
                                <!-- Comments will be loaded here -->
                            </div>

                            <div class="comment-form" id="commentsPanelForm" style="display: none;">
                                <img src="assets/img/default-avatar.png" alt="Your avatar" class="comment-avatar"
                                    id="commentsPanelAvatar">
                                <input type="text" class="comment-input" id="commentsPanelInput"
                                    placeholder="Write a comment..." onkeypress="handleCommentsPanelKeyPress(event)">
                                <button class="comment-submit" onclick="submitCommentFromPanel()">
                                    <i class='bx bx-send'></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </section>

    <!-- Scripts - Load in order -->
    <script src="assets/js/script.js?v=<?= time() ?>"></script>

    <!-- Social Feed Modules -->
    <script src="assets/js/social_feed/utilities.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/core.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/post_composer.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/post_renderer.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/post_actions.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/comment_system.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/media_handler.js?v=<?= time() ?>"></script>
    <script src="assets/js/social_feed/main.js?v=<?= time() ?>"></script>

    <!-- Page-specific initialization -->
    <script>
        // Global variable to track current post being commented on
        let currentCommentsPostId = null;

        // Function to open comments panel
        function openCommentsPanel(postId, postAuthor) {
            currentCommentsPostId = postId;

            // Update the panel title
            const panelTitle = document.getElementById('commentsPanelTitle');
            if (panelTitle) {
                panelTitle.textContent = `${postAuthor}'s Post`;
            }

            // Update user avatar in comment form
            const panelAvatar = document.getElementById('commentsPanelAvatar');
            const mainAvatar = document.getElementById('composerAvatar');
            if (panelAvatar && mainAvatar) {
                panelAvatar.src = mainAvatar.src;
            }

            // Show the comments panel
            const contentArea = document.getElementById('feedContentArea');
            const commentsPanel = document.getElementById('commentsPanel');
            const commentForm = document.getElementById('commentsPanelForm');

            if (contentArea && commentsPanel && commentForm) {
                contentArea.classList.add('comments-open');
                commentForm.style.display = 'flex';

                // Load comments for this post
                loadCommentsInPanel(postId);
            }
        }

        // Function to close comments panel
        function closeCommentsPanel() {
            const contentArea = document.getElementById('feedContentArea');
            const commentForm = document.getElementById('commentsPanelForm');

            if (contentArea) {
                contentArea.classList.remove('comments-open');
            }

            if (commentForm) {
                commentForm.style.display = 'none';
            }

            currentCommentsPostId = null;

            // Clear the input
            const input = document.getElementById('commentsPanelInput');
            if (input) {
                input.value = '';
            }
        }

        // Function to load comments in the panel
        async function loadCommentsInPanel(postId) {
            const loadingDiv = document.getElementById('commentsPanelLoading');
            const container = document.getElementById('commentsPanelContainer');

            if (loadingDiv) loadingDiv.style.display = 'block';
            if (container) container.innerHTML = '';

            try {
                const response = await fetch(`api/get_comments.php?post_id=${postId}&limit=50`);

                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }

                const responseText = await response.text();
                let data;
                try {
                    data = JSON.parse(responseText);
                } catch (parseError) {
                    console.error('JSON Parse Error:', parseError);
                    console.error('Response text:', responseText);
                    throw new Error('Server returned invalid response');
                }

                if (data.success && container) {
                    renderCommentsInPanel(container, data.comments);
                } else {
                    showCommentsPanelError(container, data.message || 'Failed to load comments');
                }
            } catch (error) {
                console.error('Error loading comments:', error);
                showCommentsPanelError(container, error.message);
            } finally {
                if (loadingDiv) loadingDiv.style.display = 'none';
            }
        }

        function renderCommentsInPanel(container, comments) {
            container.innerHTML = '';

            if (comments.length === 0) {
                container.innerHTML = '<div style="text-align: center; padding: 40px; color: var(--text-secondary);">No comments yet. Be the first to comment!</div>';
                return;
            }

            comments.forEach(comment => {
                // Create the main comment element
                const commentElement = createCommentElementForPanel(comment);
                container.appendChild(commentElement);

                // Add replies if they exist
                if (comment.replies && comment.replies.length > 0) {
                    const repliesContainer = document.createElement('div');
                    repliesContainer.className = 'replies-container';

                    comment.replies.forEach(reply => {
                        const replyElement = createCommentElementForPanel(reply, true, comment.commenter_full_name);
                        repliesContainer.appendChild(replyElement);
                    });

                    container.appendChild(repliesContainer);
                }
            });
        }

        // Function to create comment element for panel with reply support and parent info
        function createCommentElementForPanel(comment, isReply = false, parentAuthor = null) {
            const commentDiv = document.createElement('div');
            commentDiv.className = 'comment' + (isReply ? ' comment-reply' : '');
            commentDiv.dataset.commentId = comment.id;

            const timeAgo = window.utils ? window.utils.getTimeAgo(comment.created_at) : 'recently';
            const editedText = comment.is_edited ?
                '<span style="color: var(--text-secondary); font-size: 11px;">(edited)</span>' : '';

            // Create reply-to indicator for nested replies
            let replyToIndicator = '';
            if (isReply && parentAuthor) {
                replyToIndicator = `
                    <div class="reply-to-reply">
                        <i class='bx bx-corner-down-right'></i>
                        <span>Replying to <strong>${parentAuthor}</strong></span>
                    </div>
                `;
            }

            // Create action buttons
            const actions = [];

            // Reply button - show for both top-level comments and replies
            actions.push(`<span class="comment-action" onclick="replyToCommentFromPanel(${comment.id})">Reply</span>`);

            // Edit and Delete buttons (check permissions)
            if (window.socialFeedCore && window.socialFeedCore.canEditComment(comment)) {
                actions.push(`<span class="comment-action" onclick="editCommentFromPanel(${comment.id})">Edit</span>`);
                actions.push(`<span class="comment-action" onclick="deleteCommentFromPanel(${comment.id})">Delete</span>`);
            }

            // Like button
            const likeText = comment.user_liked ? 'Unlike' : 'Like';
            const likeCount = comment.like_count > 0 ? ` (${comment.like_count})` : '';
            actions.push(`<span class="comment-action" onclick="toggleCommentLikeFromPanel(${comment.id})">${likeText}${likeCount}</span>`);

            commentDiv.innerHTML = `
                <img src="${comment.profile_image || 'assets/img/default-avatar.png'}" 
                    alt="${comment.commenter_full_name}" class="comment-avatar">
                <div class="comment-content">
                    ${replyToIndicator}
                    <div class="comment-header">
                        <span class="comment-author">${comment.commenter_full_name}</span>
                        <span class="comment-time">${timeAgo}</span>
                        ${editedText}
                    </div>
                    <div class="comment-text">${window.utils ? window.utils.escapeHtml(comment.content) : comment.content}</div>
                    <div class="comment-actions">
                        ${actions.join('')}
                    </div>
                </div>
            `;

            return commentDiv;
        }

        // Function to show comments panel error
        function showCommentsPanelError(container, message = 'Error loading comments') {
            if (container) {
                container.innerHTML = `<div style="color: var(--error); text-align: center; padding: 40px;">${message}</div>`;
            }
        }

        // Function to handle keypress in comments panel
        function handleCommentsPanelKeyPress(event) {
            if (event.key === 'Enter' && !event.shiftKey) {
                event.preventDefault();
                submitCommentFromPanel();
            } else if (event.key === 'Escape') {
                // Cancel reply on Escape key
                if (window.commentSystem && window.commentSystem.replyingTo) {
                    window.commentSystem.cancelReply();
                }
            }
        }

        // Function to submit comment from panel
        async function submitCommentFromPanel() {
            if (!currentCommentsPostId) return;

            const input = document.getElementById('commentsPanelInput');
            if (!input) return;

            const content = input.value.trim();
            if (!content) {
                if (window.utils && window.utils.showNotification) {
                    window.utils.showNotification('Please enter a comment', 'warning');
                }
                return;
            }

            // Show loading state
            const submitButton = document.querySelector('#commentsPanelForm .comment-submit');
            const originalHTML = submitButton ? submitButton.innerHTML : '';
            if (submitButton) {
                submitButton.innerHTML = '<div class="spinner-small"></div>';
                submitButton.disabled = true;
            }

            try {
                // Prepare request data
                const requestData = {
                    post_id: currentCommentsPostId,
                    content: content
                };

                // If we're replying to a comment, add parent_comment_id
                if (window.commentSystem && window.commentSystem.replyingTo) {
                    requestData.parent_comment_id = window.commentSystem.replyingTo;

                    // Use the reply submission method
                    const success = await window.commentSystem.submitReplyFromPanel(currentCommentsPostId, content);
                    if (success) {
                        input.value = '';
                        await loadCommentsInPanel(currentCommentsPostId);
                    }
                    return;
                }

                const response = await fetch('api/add_comment.php', {
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
                    console.error('JSON Parse Error:', parseError);
                    throw new Error(`Invalid JSON response`);
                }

                if (result.success) {
                    input.value = '';

                    // Update comment count in the post
                    if (result.actual_comment_count !== undefined && window.commentSystem) {
                        window.commentSystem.updateCommentCountFromServer(currentCommentsPostId, result.actual_comment_count);
                    }

                    // Reload comments in panel
                    await loadCommentsInPanel(currentCommentsPostId);

                    if (window.utils && window.utils.showNotification) {
                        window.utils.showNotification(result.message || 'Comment added successfully!', 'success');
                    }
                } else {
                    throw new Error(result.message || 'Failed to add comment');
                }
            } catch (error) {
                console.error('Error adding comment:', error);
                if (window.utils && window.utils.showNotification) {
                    window.utils.showNotification(error.message || 'Error adding comment', 'error');
                }
            } finally {
                if (submitButton) {
                    submitButton.innerHTML = originalHTML;
                    submitButton.disabled = false;
                }
            }
        }

        // Function to reply to comment from panel
        function replyToCommentFromPanel(commentId) {
            // Cancel any existing reply
            if (window.commentSystem && window.commentSystem.replyingTo) {
                window.commentSystem.cancelReply();
            }

            // Start the reply
            if (window.commentSystem) {
                window.commentSystem.startReply(commentId);
            }

            // Focus the input
            const input = document.getElementById('commentsPanelInput');
            if (input) {
                input.focus();
            }
        }

        // Function to edit comment from panel
        function editCommentFromPanel(commentId) {
            // Use existing comment system edit functionality
            if (window.commentSystem) {
                window.commentSystem.startEdit(commentId);
            }
        }

        // Function to delete comment from panel
        async function deleteCommentFromPanel(commentId) {
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
                    if (result.post_id && window.commentSystem) {
                        window.commentSystem.updateCommentCountFromServer(result.post_id, result.new_count || 0);
                    }

                    // Reload comments in panel
                    if (currentCommentsPostId) {
                        await loadCommentsInPanel(currentCommentsPostId);
                    }

                    if (window.utils && window.utils.showNotification) {
                        window.utils.showNotification('Comment deleted successfully', 'success');
                    }
                } else {
                    throw new Error(result.message || 'Failed to delete comment');
                }
            } catch (error) {
                console.error('Error deleting comment:', error);
                if (window.utils && window.utils.showNotification) {
                    window.utils.showNotification(error.message || 'Error deleting comment', 'error');
                }
            }
        }

        // Function to toggle comment like from panel
        async function toggleCommentLikeFromPanel(commentId) {
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
                    // Update the like count in the panel UI
                    updateCommentLikeUIInPanel(commentId, result.liked, result.like_count);
                } else {
                    throw new Error(result.message || 'Failed to toggle like');
                }
            } catch (error) {
                console.error('Error toggling comment like:', error);
                if (window.utils && window.utils.showNotification) {
                    window.utils.showNotification(error.message || 'Error toggling like', 'error');
                }
            }
        }

        // Function to update comment like UI in panel
        function updateCommentLikeUIInPanel(commentId, liked, likeCount) {
            const commentElement = document.querySelector(`#commentsPanelContainer [data-comment-id="${commentId}"]`);
            if (!commentElement) return;

            const likeAction = commentElement.querySelector('.comment-actions span:last-child');
            if (likeAction) {
                const likeText = liked ? 'Unlike' : 'Like';
                const countDisplay = likeCount > 0 ? ` (${likeCount})` : '';
                likeAction.textContent = `${likeText}${countDisplay}`;
            }
        }


        // Override the original toggleComments function to use panel instead
        window.originalToggleComments = window.toggleComments;

        function toggleComments(postId) {
            // Find the post element to get the author name
            const postElement = document.querySelector(`[data-post-id="${postId}"]`);
            if (!postElement) return;

            const authorElement = postElement.querySelector('.post-author-name');
            const authorName = authorElement ? authorElement.textContent : 'Unknown User';

            // Open the comments panel instead of the inline comments
            openCommentsPanel(postId, authorName);
        }

        // Set active sidebar item and page title for social feed
        document.addEventListener('DOMContentLoaded', function () {
            // Set active sidebar item
            if (window.AppUtils) {
                window.AppUtils.setActiveSidebarItem('social_feed.php');
                window.AppUtils.updateNavbarTitle('Social Feed');
            }

            // Initialize search for social feed if needed
            const navbarSearchForm = document.getElementById('navbarSearchForm');
            if (navbarSearchForm) {
                navbarSearchForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    const searchInput = document.getElementById('navbarSearchInput');
                    if (searchInput && searchInput.value.trim()) {
                        if (window.searchPosts) {
                            window.searchPosts(e);
                        }
                    }
                });
            }
        });
    </script>
</body>

</html>