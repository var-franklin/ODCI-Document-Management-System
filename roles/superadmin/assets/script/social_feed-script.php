<?php

// Include all manager classes
require_once __DIR__ . '/social_feed/PostManager.php';
require_once __DIR__ . '/social_feed/CommentManager.php';
require_once __DIR__ . '/social_feed/ReactionManager.php';
require_once __DIR__ . '/social_feed/MediaManager.php';
require_once __DIR__ . '/social_feed/NotificationManager.php';
require_once __DIR__ . '/social_feed/UtilityManager.php';

// Backward compatibility wrapper functions
// These functions maintain the original function names while delegating to the new classes

// --------------------------------------------------------
// POST FUNCTIONS - Backward Compatibility Wrappers
// --------------------------------------------------------

/**
 * Create a new post
 */
function createPost($pdo, $userId, $content, $contentType = 'text', $visibility = 'public', $targetDepartments = null, $targetUsers = null, $priority = 'normal', $isPinned = false)
{
    return PostManager::createPost($pdo, $userId, $content, $contentType, $visibility, $targetDepartments, $targetUsers, $priority, $isPinned);
}

/**
 * Update post
 */
function updatePost($pdo, $postId, $userId, $content, $userRole = 'user')
{
    return PostManager::updatePost($pdo, $postId, $userId, $content, $userRole);
}

/**
 * Delete post
 */
function deletePost($pdo, $postId, $userId, $userRole = 'user')
{
    return PostManager::deletePost($pdo, $postId, $userId, $userRole);
}

/**
 * Get post engagement stats
 */
function getPostStats($pdo, $postId)
{
    return PostManager::getPostStats($pdo, $postId);
}

/**
 * Search posts
 */
function searchPosts($pdo, $query, $userId, $departmentId, $limit = 20, $offset = 0)
{
    return PostManager::searchPosts($pdo, $query, $userId, $departmentId, $limit, $offset);
}

/**
 * Get trending posts
 */
function getTrendingPosts($pdo, $userId, $departmentId, $limit = 10)
{
    return PostManager::getTrendingPosts($pdo, $userId, $departmentId, $limit);
}

/**
 * Mark post as viewed
 */
function markPostAsViewed($pdo, $postId, $userId)
{
    return PostManager::markPostAsViewed($pdo, $postId, $userId);
}

// --------------------------------------------------------
// COMMENT FUNCTIONS - Backward Compatibility Wrappers
// --------------------------------------------------------

/**
 * Get post comments with pagination
 */
function getPostComments($pdo, $postId, $limit = 20, $offset = 0)
{
    return CommentManager::getPostComments($pdo, $postId, $limit, $offset);
}

/**
 * Get comment replies
 */
function getCommentReplies($pdo, $parentCommentId, $limit = 5)
{
    return CommentManager::getCommentReplies($pdo, $parentCommentId, $limit);
}

/**
 * Update comment
 */
function updateComment($pdo, $commentId, $userId, $content, $userRole = 'user')
{
    return CommentManager::updateComment($pdo, $commentId, $userId, $content, $userRole);
}

/**
 * Delete comment
 */
function deleteComment($pdo, $commentId, $userId, $userRole = 'user')
{
    return CommentManager::deleteComment($pdo, $commentId, $userId, $userRole);
}

// --------------------------------------------------------
// LIKE/REACTION FUNCTIONS - Backward Compatibility Wrappers
// --------------------------------------------------------

/**
 * Toggle like on post or comment
 */
function toggleLike($pdo, $userId, $postId = null, $commentId = null, $reactionType = 'like')
{
    return ReactionManager::toggleLike($pdo, $userId, $postId, $commentId, $reactionType);
}

/**
 * Get post/comment likes
 */
function getLikes($pdo, $postId = null, $commentId = null)
{
    return ReactionManager::getLikes($pdo, $postId, $commentId);
}

// --------------------------------------------------------
// MEDIA ATTACHMENT FUNCTIONS - Backward Compatibility Wrappers
// --------------------------------------------------------

/**
 * Add media attachment to post
 */
function addPostMedia($pdo, $postId, $mediaType, $filePath = null, $fileName = null, $originalName = null, $fileSize = null, $mimeType = null, $url = null, $urlTitle = null, $urlDescription = null, $sortOrder = 0)
{
    return MediaManager::addPostMedia($pdo, $postId, $mediaType, $filePath, $fileName, $originalName, $fileSize, $mimeType, $url, $urlTitle, $urlDescription, $sortOrder);
}

/**
 * Get post media attachments
 */
function getPostMedia($pdo, $postId)
{
    return MediaManager::getPostMedia($pdo, $postId);
}

// --------------------------------------------------------
// NOTIFICATION FUNCTIONS - Backward Compatibility Wrappers
// --------------------------------------------------------

/**
 * Send post notifications to followers/department members
 */
function sendPostNotifications($pdo, $postId, $authorId, $type = 'new_post')
{
    return NotificationManager::sendPostNotifications($pdo, $postId, $authorId, $type);
}

/**
 * Send department-specific post notifications
 */
function sendDepartmentPostNotifications($pdo, $postId, $authorId, $targetDepartments)
{
    return NotificationManager::sendDepartmentPostNotifications($pdo, $postId, $authorId, $targetDepartments);
}

/**
 * Send custom post notifications to specific users
 */
<<<<<<< HEAD
function sendCustomPostNotifications($pdo, $postId, $authorId, $targetUsers)
{
    return NotificationManager::sendCustomPostNotifications($pdo, $postId, $authorId, $targetUsers);
=======
function sendCustomPostNotifications($pdo, $postId, $authorId, $targetUsers) {
    try {
        $message = "You've been mentioned in a post";
        
        foreach ($targetUsers as $userId) {
            if ($userId != $authorId) {
                insertPostNotification($pdo, $userId, $postId, null, $authorId, 'new_post', $message);
            }
        }
        
        return true;
    } catch(Exception $e) {
        error_log("Send custom post notifications error: " . $e->getMessage());
        return false;
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Send comment notification
 */
<<<<<<< HEAD
function sendCommentNotification($pdo, $postId, $commentId, $commenterId, $postAuthorId)
{
    return NotificationManager::sendCommentNotification($pdo, $postId, $commentId, $commenterId, $postAuthorId);
=======
function sendCommentNotification($pdo, $postId, $commentId, $commenterId, $postAuthorId) {
    try {
        $message = "Someone commented on your post";
        return insertPostNotification($pdo, $postAuthorId, $postId, $commentId, $commenterId, 'post_comment', $message);
    } catch(Exception $e) {
        error_log("Send comment notification error: " . $e->getMessage());
        return false;
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Send reply notification
 */
<<<<<<< HEAD
function sendReplyNotification($pdo, $postId, $commentId, $replierId, $parentCommenterId)
{
    return NotificationManager::sendReplyNotification($pdo, $postId, $commentId, $replierId, $parentCommenterId);
=======
function sendReplyNotification($pdo, $postId, $commentId, $replierId, $parentCommenterId) {
    try {
        $message = "Someone replied to your comment";
        return insertPostNotification($pdo, $parentCommenterId, $postId, $commentId, $replierId, 'comment_reply', $message);
    } catch(Exception $e) {
        error_log("Send reply notification error: " . $e->getMessage());
        return false;
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Send like notification
 */
<<<<<<< HEAD
function sendLikeNotification($pdo, $postId, $commentId, $likerId, $targetUserId, $reactionType)
{
    return NotificationManager::sendLikeNotification($pdo, $postId, $commentId, $likerId, $targetUserId, $reactionType);
=======
function sendLikeNotification($pdo, $postId, $commentId, $likerId, $targetUserId, $reactionType) {
    try {
        $message = $commentId ? "Someone liked your comment" : "Someone liked your post";
        $type = $commentId ? 'comment_like' : 'post_like';
        
        return insertPostNotification($pdo, $targetUserId, $postId, $commentId, $likerId, $type, $message);
    } catch(Exception $e) {
        error_log("Send like notification error: " . $e->getMessage());
        return false;
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Insert post notification
 */
<<<<<<< HEAD
function insertPostNotification($pdo, $userId, $postId, $commentId, $triggeredBy, $type, $message)
{
    return NotificationManager::insertPostNotification($pdo, $userId, $postId, $commentId, $triggeredBy, $type, $message);
=======
function insertPostNotification($pdo, $userId, $postId, $commentId, $triggeredBy, $type, $message) {
    try {
        $stmt = $pdo->prepare("
            INSERT INTO post_notifications (user_id, post_id, comment_id, triggered_by, notification_type, message) 
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        
        return $stmt->execute([$userId, $postId, $commentId, $triggeredBy, $type, $message]);
    } catch(Exception $e) {
        error_log("Insert post notification error: " . $e->getMessage());
        return false;
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Get user's post notifications
 */
<<<<<<< HEAD
function getPostNotifications($pdo, $userId, $limit = 20, $offset = 0, $unreadOnly = false)
{
    return NotificationManager::getPostNotifications($pdo, $userId, $limit, $offset, $unreadOnly);
=======
function getPostNotifications($pdo, $userId, $limit = 20, $offset = 0, $unreadOnly = false) {
    try {
        $whereClause = "pn.user_id = ?";
        $params = [$userId];
        
        if ($unreadOnly) {
            $whereClause .= " AND pn.is_read = 0";
        }
        
        $query = "
            SELECT pn.*, 
                   trigger_user.username as trigger_username,
                   CONCAT(trigger_user.name, ' ', IFNULL(CONCAT(trigger_user.mi, '. '), ''), trigger_user.surname) as trigger_full_name,
                   trigger_user.profile_image as trigger_profile_image,
                   p.content as post_content,
                   LEFT(p.content, 100) as post_preview
            FROM post_notifications pn
            LEFT JOIN users trigger_user ON pn.triggered_by = trigger_user.id
            LEFT JOIN posts p ON pn.post_id = p.id
            WHERE {$whereClause}
            ORDER BY pn.created_at DESC
            LIMIT ? OFFSET ?
        ";
        
        array_push($params, $limit, $offset);
        
        $stmt = $pdo->prepare($query);
        $stmt->execute($params);
        
        return $stmt->fetchAll();
    } catch(Exception $e) {
        error_log("Get post notifications error: " . $e->getMessage());
        return [];
    }
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
}

/**
 * Mark notification as read
 */
<<<<<<< HEAD
function markNotificationAsRead($pdo, $notificationId, $userId)
{
    return NotificationManager::markNotificationAsRead($pdo, $notificationId, $userId);
}

// --------------------------------------------------------
// UTILITY FUNCTIONS - Backward Compatibility Wrappers
=======
function markNotificationAsRead($pdo, $notificationId, $userId) {
    try {
        $stmt = $pdo->prepare("
            UPDATE post_notifications 
            SET is_read = 1, read_at = NOW()
            WHERE id = ? AND user_id = ?
        ");
        
        return $stmt->execute([$notificationId, $userId]);
    } catch(Exception $e) {
        error_log("Mark notification as read error: " . $e->getMessage());
        return false;
    }
}

// --------------------------------------------------------
// UTILITY FUNCTIONS
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
// --------------------------------------------------------

/**
 * Format time ago
 */
<<<<<<< HEAD
function timeAgo($datetime)
{
    return UtilityManager::timeAgo($datetime);
}

?>
=======
function timeAgo($datetime) {
    $time = time() - strtotime($datetime);
    
    if ($time < 60) return 'just now';
    if ($time < 3600) return floor($time/60) . ' minutes ago';
    if ($time < 86400) return floor($time/3600) . ' hours ago';
    if ($time < 2592000) return floor($time/86400) . ' days ago';
    if ($time < 31104000) return floor($time/2592000) . ' months ago';
    
    return floor($time/31104000) . ' years ago';
}

/**
 * Get post engagement stats
 */
function getPostStats($pdo, $postId) {
    try {
        $stmt = $pdo->prepare("
            SELECT 
                like_count,
                comment_count,
                view_count,
                share_count,
                (SELECT COUNT(DISTINCT reaction_type) FROM post_likes WHERE post_id = ?) as reaction_types
            FROM posts 
            WHERE id = ?
        ");
        $stmt->execute([$postId, $postId]);
        
        return $stmt->fetch();
    } catch(Exception $e) {
        error_log("Get post stats error: " . $e->getMessage());
        return null;
    }
}

/**
 * Search posts
 */
function searchPosts($pdo, $query, $userId, $departmentId, $limit = 20, $offset = 0) {
    try {
        $searchQuery = "
            SELECT p.*, u.username, u.name, u.mi, u.surname,
                   CONCAT(u.name, ' ', IFNULL(CONCAT(u.mi, '. '), ''), u.surname) as author_full_name,
                   u.profile_image, u.position, d.department_code,
                   MATCH(p.content) AGAINST(? IN BOOLEAN MODE) as relevance,
                   EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = ?) as user_liked
            FROM posts p
            LEFT JOIN users u ON p.user_id = u.id
            LEFT JOIN departments d ON u.department_id = d.id
            WHERE p.is_deleted = 0
            AND MATCH(p.content) AGAINST(? IN BOOLEAN MODE)
            AND (
                p.visibility = 'public' OR
                p.user_id = ? OR
                (p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, CAST(? AS JSON))) OR
                (p.visibility = 'custom' AND JSON_CONTAINS(p.target_users, CAST(? AS JSON)))
            )
            ORDER BY relevance DESC, p.created_at DESC
            LIMIT ? OFFSET ?
        ";
        
        $stmt = $pdo->prepare($searchQuery);
        $stmt->execute([$query, $userId, $query, $userId, $departmentId, $userId, $limit, $offset]);
        
        return $stmt->fetchAll();
    } catch(Exception $e) {
        error_log("Search posts error: " . $e->getMessage());
        return [];
    }
}

/**
 * Get trending posts (most liked/commented in last 7 days)
 */
function getTrendingPosts($pdo, $userId, $departmentId, $limit = 10) {
    try {
        $query = "
            SELECT p.*, u.username, u.name, u.mi, u.surname,
                   CONCAT(u.name, ' ', IFNULL(CONCAT(u.mi, '. '), ''), u.surname) as author_full_name,
                   u.profile_image, u.position, d.department_code,
                   (p.like_count * 2 + p.comment_count * 3 + p.view_count * 0.1) as engagement_score,
                   EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = ?) as user_liked
            FROM posts p
            LEFT JOIN users u ON p.user_id = u.id
            LEFT JOIN departments d ON u.department_id = d.id
            WHERE p.is_deleted = 0
            AND p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            AND (
                p.visibility = 'public' OR
                p.user_id = ? OR
                (p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, CAST(? AS JSON))) OR
                (p.visibility = 'custom' AND JSON_CONTAINS(p.target_users, CAST(? AS JSON)))
            )
            ORDER BY engagement_score DESC, p.created_at DESC
            LIMIT ?
        ";
        
        $stmt = $pdo->prepare($query);
        $stmt->execute([$userId, $userId, $departmentId, $userId, $limit]);
        
        return $stmt->fetchAll();
    } catch(Exception $e) {
        error_log("Get trending posts error: " . $e->getMessage());
        return [];
    }
}

?>
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
