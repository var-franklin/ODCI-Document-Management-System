<?php
require_once '../../includes/config.php';
require_once 'includes/auth_check.php';
require_once 'includes/department_config.php';

// Get current user information
$currentUser = getCurrentUser($pdo);
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Department Folders - CVSU Naic</title>
    <link href='https://unpkg.com/boxicons@2.0.9/css/boxicons.min.css' rel='stylesheet'>
    <link rel="stylesheet" href="../../assets/css/style.css">
    <link rel="stylesheet" href="assets/css/folders_style.css">
</head>
<body>
    <!-- Upload Modal -->
    <?php include 'includes/upload_modal.php'; ?>

    <!-- Sidebar -->
    <section id="sidebar">
        <a href="#" class="brand">
            <img src="../../img/cvsu-logo.png" alt="Logo" style="width: 30px; height: 30px;">
            <span class="text">ODCI</span>
        </a>
        <ul class="side-menu top">
            <li>
                <a href="dashboard.php">
                    <i class='bx bxs-dashboard'></i>
                    <span class="text">Dashboard</span>
                </a>
            </li>
            <li>
                <a href="folders.php">
                    <i class='bx bxs-file'></i>
                    <span class="text">My Files</span>
                </a>
            </li>
            <li class="active">
                <a href="folders.php">
                    <i class='bx bxs-folder'></i>
                    <span class="text">My Folders</span>
                </a>
            </li>
            <li>
                <a href="submission_tracker.php">
                    <i class='bx bxs-check-square'></i>
                    <span class="text">Submission Tracker</span>
                </a>
            </li>
        </ul>
        <ul class="side-menu">
            <li>
                <a href="profile.php">
                    <i class='bx bxs-cog'></i>
                    <span class="text">Settings</span>
                </a>
            </li>
            <li>
                <a href="../../logout.php" class="logout">
                    <i class='bx bxs-log-out-circle'></i>
                    <span class="text">Logout</span>
                </a>
            </li>
        </ul>
    </section>

    <!-- Content -->
    <section id="content">
        <!-- Navbar -->
        <nav>
            <i class='bx bx-menu'></i>
            <a href="#" class="nav-link">Categories</a>
            <form action="#">
                <div class="form-input">
                    <input type="search" placeholder="Search files..." id="globalSearch">
                    <button type="submit" class="search-btn"><i class='bx bx-search'></i></button>
                </div>
            </form>
            <input type="checkbox" id="switch-mode" hidden>
            <label for="switch-mode" class="switch-mode"></label>
            <a href="#" class="notification">
                <i class='bx bxs-bell'></i>
                <span class="num">8</span>
            </a>
            <a href="#" class="profile">
                <img src="../../img/default-avatar.png" alt="Profile">
            </a>
        </nav>

        <!-- Main Content -->
        <main>
            <div class="head-title">
                <div class="left">
                    <h1>Department Folders</h1>
                    <ul class="breadcrumb">
                        <li>
                            <a href="dashboard.php">Dashboard</a>
                        </li>
                        <li><i class='bx bx-chevron-right'></i></li>
                        <li>
                            <a class="active" href="#">Department Folders</a>
                        </li>
                    </ul>
                </div>
                <button onclick="openUploadModal()" class="upload-btn">
                    <i class='bx bxs-cloud-upload'></i>
                    <span class="text">Upload File</span>
                </button>
            </div>

            <!-- Search Section -->
            <div class="search-section">
                <div class="search-bar">
                    <input type="text" placeholder="Search across all departments..." id="departmentSearch">
                    <i class='bx bx-search'></i>
                </div>
            </div>

            <!-- Department Tree -->
            <div class="department-tree">
                <?php foreach ($departments as $code => $dept): ?>
                    <div class="department-item" data-department="<?php echo $code; ?>">
                        <div class="department-header" onclick="toggleDepartment('<?php echo $code; ?>')">
                            <div class="department-icon" style="background-color: <?php echo $dept['color']; ?>">
                                <i class='bx <?php echo $dept['icon']; ?>'></i>
                            </div>
                            <div class="department-info">
                                <div class="department-name"><?php echo htmlspecialchars($dept['name']); ?></div>
                                <div class="department-code"><?php echo $code; ?></div>
                            </div>
                            <i class='bx bx-chevron-right expand-icon' id="icon-<?php echo $code; ?>"></i>
                        </div>
                        
                        <div class="semester-content" id="content-<?php echo $code; ?>">
                            <div class="semester-tabs">
                                <button class="semester-tab active" onclick="showSemester('<?php echo $code; ?>', 'first')">
                                    <i class='bx bxs-folder'></i> First Semester
                                </button>
                                <button class="semester-tab" onclick="showSemester('<?php echo $code; ?>', 'second')">
                                    <i class='bx bxs-folder'></i> Second Semester
                                </button>
                            </div>
                            
                            <div class="files-grid" id="files-<?php echo $code; ?>-first">
                                <div class="empty-state">
                                    <i class='bx bx-folder-open empty-icon'></i>
                                    <p>No files in First Semester</p>
                                    <small>Files uploaded to this semester will appear here</small>
                                </div>
                            </div>
                            
                            <div class="files-grid" id="files-<?php echo $code; ?>-second" style="display: none;">
                                <div class="empty-state">
                                    <i class='bx bx-folder-open empty-icon'></i>
                                    <p>No files in Second Semester</p>
                                    <small>Files uploaded to this semester will appear here</small>
                                </div>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
        </main>
    </section>

    <script src="assets/js/folders_script.js"></script>
</body>
</html>