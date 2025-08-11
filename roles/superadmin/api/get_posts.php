<?php
<<<<<<< HEAD
require_once '../../../includes/auth_check.php';
require_once '../../../includes/config.php';
require_once '../assets/script/social_feed-script.php';
=======
require_once '../../../includes/config.php';
require_once '../../../includes/auth_check.php';
require_once '../assets/script/social_feed-script';
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d

header('Content-Type: application/json');

try {
    $filter = $_GET['filter'] ?? 'all';
    $page = intval($_GET['page'] ?? 0);
    $limit = intval($_GET['limit'] ?? 10);
    $offset = $page * $limit;

    $userId = $_SESSION['user_id'];
    $userRole = $_SESSION['user_role'] ?? 'user';

    // Get user's department
    $stmt = $pdo->prepare("SELECT department_id FROM users WHERE id = ?");
    $stmt->execute([$userId]);
    $userDept = $stmt->fetch();
    $departmentId = $userDept['department_id'] ?? 0;

    // Build query based on filter
    $whereConditions = ["p.is_deleted = 0"];
    $params = [];

    switch ($filter) {
        case 'my_posts':
            $whereConditions[] = "p.user_id = ?";
            $params[] = $userId;
            break;

        case 'department':
<<<<<<< HEAD
            $whereConditions[] = "(p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, ?))";
            $params[] = '"' . $departmentId . '"';
=======
            $whereConditions[] = "(p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, CAST(? AS JSON)))";
            $params[] = $departmentId;
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
            break;

        case 'pinned':
            $whereConditions[] = "p.is_pinned = 1";
            break;

        case 'trending':
            $whereConditions[] = "p.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            break;

        default: // all posts
            $whereConditions[] = "(
                p.visibility = 'public' OR
                p.user_id = ? OR
<<<<<<< HEAD
                (p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, ?)) OR
                (p.visibility = 'custom' AND JSON_CONTAINS(p.target_users, ?))
            )";
            $params = array_merge($params, [$userId, '"' . $departmentId . '"', '"' . $userId . '"']);
=======
                (p.visibility = 'department' AND JSON_CONTAINS(p.target_departments, CAST(? AS JSON))) OR
                (p.visibility = 'custom' AND JSON_CONTAINS(p.target_users, CAST(? AS JSON)))
            )";
            $params = array_merge($params, [$userId, $departmentId, $userId]);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    }

    $whereClause = implode(' AND ', $whereConditions);

    // Order by
    $orderBy = $filter === 'trending'
        ? "(p.like_count * 2 + p.comment_count * 3 + p.view_count * 0.1) DESC, p.created_at DESC"
        : "p.is_pinned DESC, p.created_at DESC";

    $query = "
        SELECT p.*, u.username, u.name, u.mi, u.surname,
               CONCAT(u.name, ' ', IFNULL(CONCAT(u.mi, '. '), ''), u.surname) as author_full_name,
               u.profile_image, u.position, u.role, d.department_code, d.department_name,
               EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = ?) as user_liked
        FROM posts p
        LEFT JOIN users u ON p.user_id = u.id
        LEFT JOIN departments d ON u.department_id = d.id
        WHERE {$whereClause}
        ORDER BY {$orderBy}
<<<<<<< HEAD
    ";

    // Build final query with LIMIT and OFFSET directly in SQL to avoid parameter issues
    $finalQuery = $query . " LIMIT {$limit} OFFSET {$offset}";

    $allParams = array_merge([$userId], $params);
    $stmt = $pdo->prepare($finalQuery);
=======
        LIMIT ? OFFSET ?
    ";

    $allParams = array_merge([$userId], $params, [$limit, $offset]);
    $stmt = $pdo->prepare($query);
>>>>>>> bc417a8a6cb2f64d0b060ad6ae263818bc40de4d
    $stmt->execute($allParams);
    $posts = $stmt->fetchAll();

    // Get media for each post
    foreach ($posts as &$post) {
        $post['media'] = getPostMedia($pdo, $post['id']);

        // Mark as viewed
        markPostAsViewed($pdo, $post['id'], $userId);

        // Update view count
        $stmt = $pdo->prepare("UPDATE posts SET view_count = view_count + 1 WHERE id = ?");
        $stmt->execute([$post['id']]);
    }

    echo json_encode([
        'success' => true,
        'posts' => $posts,
        'has_more' => count($posts) === $limit
    ]);

} catch (Exception $e) {
    error_log("Get posts error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'Error loading posts: ' . $e->getMessage()
    ]);
}
?>