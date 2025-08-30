<?php
// create_folder.php - Handler for creating custom folders
require_once '../../../includes/config.php';

// Set JSON response header
header('Content-Type: application/json');

// Check if user is logged in
if (!isLoggedIn()) {
    http_response_code(401);
    echo json_encode(['success' => false, 'message' => 'Unauthorized']);
    exit();
}

$currentUser = getCurrentUser($pdo);
if (!$currentUser || !$currentUser['is_approved']) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'User not approved']);
    exit();
}

// Get user's department ID for security check
$userDepartmentId = null;
if (isset($currentUser['department_id']) && $currentUser['department_id']) {
    $userDepartmentId = $currentUser['department_id'];
} elseif (isset($currentUser['id'])) {
    try {
        $stmt = $pdo->prepare("SELECT department_id FROM users WHERE id = ?");
        $stmt->execute([$currentUser['id']]);
        $user = $stmt->fetch();
        if ($user && $user['department_id']) {
            $userDepartmentId = $user['department_id'];
        }
    } catch(Exception $e) {
        error_log("Department fetch error: " . $e->getMessage());
    }
}

if (!$userDepartmentId) {
    http_response_code(403);
    echo json_encode(['success' => false, 'message' => 'No department assigned']);
    exit();
}

try {
    // Validate input
    if (!isset($_POST['folder_name']) || !isset($_POST['department_id'])) {
        echo json_encode(['success' => false, 'message' => 'Missing required fields']);
        exit();
    }

    $folderName = trim($_POST['folder_name']);
    $folderDescription = trim($_POST['folder_description'] ?? '');
    $folderColor = $_POST['folder_color'] ?? '#3b82f6';
    $folderIcon = $_POST['folder_icon'] ?? 'bxs-folder';
    $departmentId = (int)$_POST['department_id'];

    // Validate folder name
    if (empty($folderName)) {
        echo json_encode(['success' => false, 'message' => 'Folder name is required']);
        exit();
    }

    if (strlen($folderName) > 100) {
        echo json_encode(['success' => false, 'message' => 'Folder name is too long (max 100 characters)']);
        exit();
    }

    // Validate folder name contains no special characters that could cause issues
    if (!preg_match('/^[a-zA-Z0-9\s\-_().]+$/', $folderName)) {
        echo json_encode(['success' => false, 'message' => 'Folder name contains invalid characters. Use only letters, numbers, spaces, hyphens, underscores, and parentheses.']);
        exit();
    }

    // SECURITY CHECK: User can only create folders in their own department
    if ($departmentId != $userDepartmentId) {
        http_response_code(403);
        echo json_encode(['success' => false, 'message' => 'Access denied: Can only create folders in your department']);
        exit();
    }
    
    // Validate department exists
    $stmt = $pdo->prepare("SELECT id, department_name FROM departments WHERE id = ? AND is_active = 1");
    $stmt->execute([$departmentId]);
    $department = $stmt->fetch();
    
    if (!$department) {
        echo json_encode(['success' => false, 'message' => 'Invalid department']);
        exit();
    }

    // Validate color format
    if (!preg_match('/^#[0-9a-fA-F]{6}$/', $folderColor)) {
        $folderColor = '#3b82f6'; // Default to blue if invalid
    }

    // Validate icon format
    $validIcons = ['bxs-folder', 'bxs-briefcase', 'bxs-book', 'bxs-file', 'bxs-heart', 'bxs-star', 'bxs-cog', 'bxs-shield'];
    if (!in_array($folderIcon, $validIcons)) {
        $folderIcon = 'bxs-folder'; // Default if invalid
    }

    // Check if folder name already exists in this department
    $stmt = $pdo->prepare("
        SELECT id FROM folders 
        WHERE department_id = ? AND folder_name = ? AND is_deleted = 0 AND category IS NULL
    ");
    $stmt->execute([$departmentId, $folderName]);
    
    if ($stmt->fetch()) {
        echo json_encode(['success' => false, 'message' => 'A folder with this name already exists in your department']);
        exit();
    }

    // Create the folder
    $stmt = $pdo->prepare("
        INSERT INTO folders (
            folder_name, 
            description, 
            created_by, 
            department_id, 
            folder_path, 
            folder_level,
            folder_color,
            folder_icon,
            created_at,
            file_count,
            folder_size,
            is_public
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), 0, 0, 0)
    ");
    
    $folderPath = "/departments/{$departmentId}/custom/" . sanitizeFileName($folderName);
    $folderLevel = 1; // Custom folders are level 1
    
    $result = $stmt->execute([
        $folderName,
        $folderDescription,
        $currentUser['id'],
        $departmentId,
        $folderPath,
        $folderLevel,
        $folderColor,
        $folderIcon
    ]);

    if ($result) {
        $folderId = $pdo->lastInsertId();
        
        // Create physical directory
        $physicalPath = "../../uploads/departments/" . $departmentId . "/custom/" . sanitizeFileName($folderName);
        if (!is_dir($physicalPath)) {
            if (!mkdir($physicalPath, 0755, true)) {
                // Log warning but don't fail the request
                error_log("Warning: Could not create physical directory: " . $physicalPath);
            }
        }

        echo json_encode([
            'success' => true,
            'message' => 'Folder created successfully',
            'folder' => [
                'id' => $folderId,
                'folder_name' => $folderName,
                'description' => $folderDescription,
                'folder_color' => $folderColor,
                'folder_icon' => $folderIcon,
                'department_id' => $departmentId,
                'file_count' => 0,
                'created_at' => date('Y-m-d H:i:s')
            ]
        ]);
    } else {
        throw new Exception('Failed to create folder in database');
    }

} catch (Exception $e) {
    error_log("Folder creation error: " . $e->getMessage());
    echo json_encode([
        'success' => false,
        'message' => 'An error occurred while creating the folder: ' . $e->getMessage()
    ]);
}

// Helper function to sanitize filename for directory creation
function sanitizeFileName($filename) {
    // Remove or replace problematic characters
    $sanitized = preg_replace('/[^a-zA-Z0-9\-_\.]/', '_', $filename);
    
    // Remove multiple underscores
    $sanitized = preg_replace('/_+/', '_', $sanitized);
    
    // Remove leading/trailing underscores
    $sanitized = trim($sanitized, '_');
    
    // Ensure it's not empty
    if (empty($sanitized)) {
        $sanitized = 'folder_' . time();
    }
    
    return $sanitized;
}
?>