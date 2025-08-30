SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','user','super_admin') NOT NULL DEFAULT 'user',
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `name` varchar(100) NOT NULL,
  `mi` varchar(5) DEFAULT NULL,
  `surname` varchar(100) NOT NULL,
  `employee_id` varchar(20) DEFAULT NULL,
  `position` varchar(100) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `is_restricted` tinyint(1) DEFAULT 0,
  `profile_image` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `hire_date` date DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `failed_login_attempts` int(11) DEFAULT 0,
  `account_locked_until` datetime DEFAULT NULL,
  `email_verified` tinyint(1) DEFAULT 0,
  `email_verification_token` varchar(255) DEFAULT NULL,
  `password_reset_token` varchar(255) DEFAULT NULL,
  `password_reset_expires` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) DEFAULT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `employee_id` (`employee_id`),
  KEY `fk_user_department` (`department_id`),
  KEY `idx_email_verified` (`email_verified`),
  KEY `idx_is_approved` (`is_approved`),
  KEY `idx_role` (`role`),
  KEY `fk_user_created_by` (`created_by`),
  KEY `fk_user_approved_by` (`approved_by`),
  KEY `idx_users_last_login` (`last_login`),
  CONSTRAINT `fk_user_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_user_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` enum('file','folder','user','announcement','department','system') NOT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_action` (`action`),
  KEY `idx_resource` (`resource_type`,`resource_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_activity_logs_user_action` (`user_id`,`action`),
  CONSTRAINT `activity_logs_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `summary` varchar(500) DEFAULT NULL,
  `image_path` varchar(255) DEFAULT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `announcement_type` enum('general','department','urgent','maintenance') DEFAULT 'general',
  `target_departments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_departments`)),
  `target_roles` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_roles`)),
  `is_published` tinyint(1) DEFAULT 0,
  `published_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) NOT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `view_count` int(11) DEFAULT 0,
  `is_pinned` tinyint(1) DEFAULT 0,
  `allow_comments` tinyint(1) DEFAULT 1,
  `send_email` tinyint(1) DEFAULT 0,
  `email_sent` tinyint(1) DEFAULT 0,
  `email_sent_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `idx_is_published` (`is_published`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_priority` (`priority`),
  KEY `idx_expires_at` (`expires_at`),
  KEY `announcements_updated_by_fk` (`updated_by`),
  KEY `announcements_deleted_by_fk` (`deleted_by`),
  KEY `idx_announcements_published` (`is_published`,`published_at`),
  FULLTEXT KEY `announcement_search` (`title`,`content`,`summary`),
  CONSTRAINT `announcements_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `announcements_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `announcements_updated_by_fk` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `announcement_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `announcement_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `viewed_at` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_view` (`announcement_id`,`user_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `announcement_views_announcement_fk` FOREIGN KEY (`announcement_id`) REFERENCES `announcements` (`id`) ON DELETE CASCADE,
  CONSTRAINT `announcement_views_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_requests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tracking_code` varchar(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `document_type` enum('certificate','clearance','permit','report','form','other') NOT NULL DEFAULT 'other',
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `status` enum('pending','in_progress','under_review','completed','rejected','cancelled') DEFAULT 'pending',
  `target_department` int(11) DEFAULT NULL,
  `expected_completion` date DEFAULT NULL,
  `actual_completion` datetime DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tracking_code` (`tracking_code`),
  KEY `user_id` (`user_id`),
  KEY `target_department` (`target_department`),
  KEY `assigned_to` (`assigned_to`),
  KEY `updated_by` (`updated_by`),
  KEY `deleted_by` (`deleted_by`),
  KEY `idx_document_status` (`status`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_document_priority` (`priority`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_expected_completion` (`expected_completion`),
  KEY `idx_is_deleted` (`is_deleted`),
  FULLTEXT KEY `document_search` (`title`,`description`),
  CONSTRAINT `document_requests_assigned_to_fk` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_requests_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_requests_target_dept_fk` FOREIGN KEY (`target_department`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_requests_updated_by_fk` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_requests_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(500) NOT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_type` enum('requirement','supporting','output','other') DEFAULT 'supporting',
  `uploaded_by` int(11) NOT NULL,
  `uploaded_at` datetime DEFAULT current_timestamp(),
  `description` text DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `deleted_by` (`deleted_by`),
  KEY `idx_file_type` (`file_type`),
  KEY `idx_uploaded_at` (`uploaded_at`),
  CONSTRAINT `document_attachments_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_attachments_request_fk` FOREIGN KEY (`request_id`) REFERENCES `document_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_attachments_uploaded_by_fk` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `comment_type` enum('general','status_update','requirement','internal') DEFAULT 'general',
  `parent_comment_id` int(11) DEFAULT NULL,
  `is_internal` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_edited` tinyint(1) DEFAULT 0,
  `edited_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`),
  KEY `user_id` (`user_id`),
  KEY `parent_comment_id` (`parent_comment_id`),
  KEY `deleted_by` (`deleted_by`),
  KEY `idx_comment_type` (`comment_type`),
  KEY `idx_is_internal` (`is_internal`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `document_comments_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_comments_parent_fk` FOREIGN KEY (`parent_comment_id`) REFERENCES `document_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_comments_request_fk` FOREIGN KEY (`request_id`) REFERENCES `document_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_comments_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `faculty_document_submissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faculty_id` int(11) NOT NULL,
  `document_type` varchar(100) NOT NULL,
  `semester` varchar(50) NOT NULL,
  `academic_year` year(4) NOT NULL DEFAULT year(curdate()),
  `submitted_by` int(11) NOT NULL,
  `submitted_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_submission` (`faculty_id`,`document_type`,`semester`),
  KEY `faculty_id` (`faculty_id`),
  KEY `submitted_by` (`submitted_by`),
  KEY `idx_faculty_year_semester` (`faculty_id`,`academic_year`,`semester`),
  KEY `idx_submissions_year_semester_user` (`academic_year`,`semester`,`faculty_id`),
  KEY `idx_faculty_submissions_composite` (`faculty_id`,`document_type`,`semester`,`academic_year`),
  CONSTRAINT `faculty_document_submissions_ibfk_1` FOREIGN KEY (`faculty_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `faculty_document_submissions_ibfk_2` FOREIGN KEY (`submitted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `submission_id` int(11) NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_size` int(11) NOT NULL,
  `file_type` varchar(100) NOT NULL,
  `academic_year` year(4) DEFAULT NULL,
  `semester_period` varchar(20) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `description` text DEFAULT NULL,
  `uploaded_at` datetime NOT NULL DEFAULT current_timestamp(),
  `mime_type` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `submission_id` (`submission_id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `idx_document_files_period` (`uploaded_by`,`academic_year`,`semester_period`),
  KEY `idx_files_year_semester_type` (`academic_year`,`semester_period`,`file_type`),
  KEY `idx_document_files_submission` (`submission_id`),
  CONSTRAINT `document_files_ibfk_1` FOREIGN KEY (`submission_id`) REFERENCES `faculty_document_submissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_files_ibfk_2` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` enum('status_change','assignment','deadline','comment','completion') NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `action_url` varchar(500) DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`),
  KEY `user_id` (`user_id`),
  KEY `idx_notification_type` (`notification_type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `document_notifications_request_fk` FOREIGN KEY (`request_id`) REFERENCES `document_requests` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_notifications_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_requirements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `academic_year` year(4) NOT NULL,
  `semester` varchar(20) NOT NULL,
  `department_id` int(11) DEFAULT NULL,
  `document_type` varchar(100) NOT NULL,
  `is_required` tinyint(1) DEFAULT 1,
  `deadline_date` date DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_requirement` (`academic_year`,`semester`,`department_id`,`document_type`),
  KEY `idx_year_semester` (`academic_year`,`semester`),
  KEY `idx_department` (`department_id`),
  KEY `document_requirements_created_by_fk` (`created_by`),
  CONSTRAINT `document_requirements_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_requirements_dept_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_status_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `status` enum('pending','in_progress','under_review','completed','rejected','cancelled') NOT NULL,
  `changed_by` int(11) NOT NULL,
  `notes` text DEFAULT NULL,
  `changed_at` datetime DEFAULT current_timestamp(),
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`),
  KEY `changed_by` (`changed_by`),
  KEY `idx_status_changed_at` (`changed_at`),
  CONSTRAINT `document_status_changed_by_fk` FOREIGN KEY (`changed_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_status_request_fk` FOREIGN KEY (`request_id`) REFERENCES `document_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_submission_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faculty_id` int(11) NOT NULL,
  `document_type` varchar(100) NOT NULL,
  `semester` varchar(50) NOT NULL,
  `status` enum('submitted','not_submitted','reminder_sent','note_added') NOT NULL,
  `note` text DEFAULT NULL,
  `reminder_sent` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `faculty_id` (`faculty_id`),
  KEY `document_type` (`document_type`),
  KEY `semester` (`semester`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_name` varchar(100) NOT NULL,
  `document_type` enum('certificate','clearance','permit','report','form','other') NOT NULL,
  `template_description` text DEFAULT NULL,
  `required_fields` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`required_fields`)),
  `workflow_steps` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`workflow_steps`)),
  `estimated_completion_hours` int(11) DEFAULT 24,
  `department_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `department_id` (`department_id`),
  KEY `created_by` (`created_by`),
  KEY `updated_by` (`updated_by`),
  KEY `idx_document_type` (`document_type`),
  KEY `idx_is_active` (`is_active`),
  CONSTRAINT `document_templates_created_by_fk` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `document_templates_dept_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_templates_updated_by_fk` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `document_workflows` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  `step_number` int(11) NOT NULL,
  `step_name` varchar(100) NOT NULL,
  `step_description` text DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `assigned_department` int(11) DEFAULT NULL,
  `status` enum('pending','in_progress','completed','skipped','failed') DEFAULT 'pending',
  `started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `expected_duration_hours` int(11) DEFAULT NULL,
  `actual_duration_minutes` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `request_id` (`request_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `assigned_department` (`assigned_department`),
  KEY `idx_step_number` (`step_number`),
  KEY `idx_workflow_status` (`status`),
  CONSTRAINT `document_workflows_assigned_dept_fk` FOREIGN KEY (`assigned_department`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_workflows_assigned_to_fk` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `document_workflows_request_fk` FOREIGN KEY (`request_id`) REFERENCES `document_requests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `folders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folder_name` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `parent_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) NOT NULL DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `folder_type` enum('category','custom','system') DEFAULT 'category',
  `folder_path` varchar(500) DEFAULT NULL,
  `folder_level` int(11) DEFAULT 0,
  `is_public` tinyint(1) DEFAULT 0,
  `folder_status` enum('active','archived','hidden') DEFAULT 'active',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `folder_size` bigint(20) DEFAULT 0,
  `file_count` int(11) DEFAULT 0,
  `folder_color` varchar(7) DEFAULT '#667eea',
  `folder_icon` varchar(50) DEFAULT 'fa-folder',
  `description` text DEFAULT NULL,
  `is_system_folder` tinyint(1) DEFAULT 0,
  `folder_order` int(11) DEFAULT 0,
  `last_accessed` timestamp NULL DEFAULT NULL,
  `access_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `created_by` (`created_by`),
  KEY `parent_id` (`parent_id`),
  KEY `department_id` (`department_id`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_folder_path` (`folder_path`),
  KEY `folders_deleted_by_fk` (`deleted_by`),
  KEY `idx_folders_created_at` (`created_at`),
  KEY `idx_folder_type` (`folder_type`),
  KEY `idx_department_type` (`department_id`,`folder_type`),
  FULLTEXT KEY `folder_search` (`folder_name`),
  CONSTRAINT `folders_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `folders_department_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `folders_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `folders_parent_fk` FOREIGN KEY (`parent_id`) REFERENCES `folders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `files` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_name` varchar(255) NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `file_type` varchar(100) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_extension` varchar(10) DEFAULT NULL,
  `uploaded_by` int(11) NOT NULL,
  `folder_id` int(11) NOT NULL,
  `folder_type` enum('category','custom') DEFAULT 'category',
  `uploaded_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `file_hash` varchar(64) DEFAULT NULL,
  `download_count` int(11) DEFAULT 0,
  `last_downloaded` datetime DEFAULT NULL,
  `last_downloaded_by` int(11) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `public_token` varchar(255) DEFAULT NULL,
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `version` int(11) DEFAULT 1,
  `parent_file_id` int(11) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`tags`)),
  `description` text DEFAULT NULL,
  `thumbnail_path` varchar(255) DEFAULT NULL,
  `is_favorite` tinyint(1) DEFAULT 0,
  `expiry_date` datetime DEFAULT NULL,
  `academic_year` varchar(10) DEFAULT NULL,
  `semester` enum('first','second') NOT NULL DEFAULT 'first',
  PRIMARY KEY (`id`),
  KEY `uploaded_by` (`uploaded_by`),
  KEY `folder_id` (`folder_id`),
  KEY `parent_file_id` (`parent_file_id`),
  KEY `idx_is_deleted` (`is_deleted`),
  KEY `idx_file_type` (`file_type`),
  KEY `idx_public_token` (`public_token`),
  KEY `idx_file_hash` (`file_hash`),
  KEY `files_deleted_by_fk` (`deleted_by`),
  KEY `files_downloaded_by_fk` (`last_downloaded_by`),
  KEY `idx_files_uploaded_at` (`uploaded_at`),
  KEY `idx_files_file_type_size` (`file_type`,`file_size`),
  KEY `idx_folder_type` (`folder_type`),
  FULLTEXT KEY `file_search` (`original_name`,`description`),
  CONSTRAINT `files_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `files_downloaded_by_fk` FOREIGN KEY (`last_downloaded_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `files_ibfk_1` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `files_ibfk_2` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `files_parent_fk` FOREIGN KEY (`parent_file_id`) REFERENCES `files` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `file_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `comment` text NOT NULL,
  `parent_comment_id` int(11) DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `file_id` (`file_id`),
  KEY `user_id` (`user_id`),
  KEY `parent_comment_id` (`parent_comment_id`),
  CONSTRAINT `file_comments_file_fk` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_comments_parent_fk` FOREIGN KEY (`parent_comment_id`) REFERENCES `file_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_comments_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `file_shares` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `file_id` int(11) NOT NULL,
  `shared_by` int(11) NOT NULL,
  `shared_with` int(11) DEFAULT NULL,
  `share_token` varchar(255) NOT NULL,
  `share_type` enum('user','public','department') DEFAULT 'user',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `expires_at` datetime DEFAULT NULL,
  `password_protected` tinyint(1) DEFAULT 0,
  `share_password` varchar(255) DEFAULT NULL,
  `download_limit` int(11) DEFAULT NULL,
  `download_count` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `last_accessed` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `share_token` (`share_token`),
  KEY `file_id` (`file_id`),
  KEY `shared_by` (`shared_by`),
  KEY `shared_with` (`shared_with`),
  KEY `idx_file_shares_expires` (`expires_at`,`is_active`),
  CONSTRAINT `file_shares_file_fk` FOREIGN KEY (`file_id`) REFERENCES `files` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_shares_shared_by_fk` FOREIGN KEY (`shared_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `file_shares_shared_with_fk` FOREIGN KEY (`shared_with`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `folder_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `folder_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `department_id` int(11) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `permission_type` enum('read','write','admin') DEFAULT 'read',
  `granted_by` int(11) NOT NULL,
  `granted_at` datetime DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `folder_id` (`folder_id`),
  KEY `user_id` (`user_id`),
  KEY `department_id` (`department_id`),
  KEY `granted_by` (`granted_by`),
  CONSTRAINT `folder_permissions_department_fk` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `folder_permissions_folder_fk` FOREIGN KEY (`folder_id`) REFERENCES `folders` (`id`) ON DELETE CASCADE,
  CONSTRAINT `folder_permissions_granted_by_fk` FOREIGN KEY (`granted_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `folder_permissions_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','success','warning','error') DEFAULT 'info',
  `action_url` varchar(500) DEFAULT NULL,
  `action_text` varchar(100) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  CONSTRAINT `notifications_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `content` text NOT NULL,
  `content_type` enum('text','image','file','link','mixed') DEFAULT 'text',
  `visibility` enum('public','department','private','custom') DEFAULT 'public',
  `target_departments` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_departments`)),
  `target_users` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`target_users`)),
  `priority` enum('low','normal','high','urgent') DEFAULT 'normal',
  `is_pinned` tinyint(1) DEFAULT 0,
  `is_edited` tinyint(1) DEFAULT 0,
  `edited_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `like_count` int(11) DEFAULT 0,
  `comment_count` int(11) DEFAULT 0,
  `view_count` int(11) DEFAULT 0,
  `share_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `posts_user_fk` (`user_id`),
  KEY `posts_deleted_by_fk` (`deleted_by`),
  KEY `idx_posts_created_at` (`created_at`),
  KEY `idx_posts_visibility` (`visibility`),
  KEY `idx_posts_pinned` (`is_pinned`),
  KEY `idx_posts_deleted` (`is_deleted`),
  CONSTRAINT `posts_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `posts_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `parent_comment_id` int(11) DEFAULT NULL,
  `content` text NOT NULL,
  `is_edited` tinyint(1) DEFAULT 0,
  `edited_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0,
  `deleted_at` datetime DEFAULT NULL,
  `deleted_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `like_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `post_comments_post_fk` (`post_id`),
  KEY `post_comments_user_fk` (`user_id`),
  KEY `post_comments_parent_fk` (`parent_comment_id`),
  KEY `post_comments_deleted_by_fk` (`deleted_by`),
  KEY `idx_post_comments_created_at` (`created_at`),
  KEY `idx_post_comments_deleted` (`is_deleted`),
  CONSTRAINT `post_comments_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `post_comments_parent_fk` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_comments_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_likes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `reaction_type` enum('like','love','laugh','angry','sad','wow') DEFAULT 'like',
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_post_like` (`post_id`,`user_id`),
  UNIQUE KEY `unique_comment_like` (`comment_id`,`user_id`),
  KEY `post_likes_post_fk` (`post_id`),
  KEY `post_likes_comment_fk` (`comment_id`),
  KEY `post_likes_user_fk` (`user_id`),
  KEY `idx_post_likes_created_at` (`created_at`),
  CONSTRAINT `post_likes_comment_fk` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_likes_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_likes_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_media` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `media_type` enum('image','file','link') NOT NULL,
  `file_path` varchar(500) DEFAULT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `original_name` varchar(255) DEFAULT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `url` varchar(1000) DEFAULT NULL,
  `url_title` varchar(255) DEFAULT NULL,
  `url_description` text DEFAULT NULL,
  `url_image` varchar(500) DEFAULT NULL,
  `thumbnail_path` varchar(500) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `post_media_post_fk` (`post_id`),
  KEY `idx_post_media_type` (`media_type`),
  CONSTRAINT `post_media_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `triggered_by` int(11) NOT NULL,
  `notification_type` enum('new_post','post_comment','post_like','comment_like','comment_reply','post_mention','comment_mention') NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `post_notifications_user_fk` (`user_id`),
  KEY `post_notifications_post_fk` (`post_id`),
  KEY `post_notifications_comment_fk` (`comment_id`),
  KEY `post_notifications_triggered_by_fk` (`triggered_by`),
  KEY `idx_post_notifications_read` (`is_read`),
  KEY `idx_post_notifications_created_at` (`created_at`),
  CONSTRAINT `post_notifications_comment_fk` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_notifications_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_notifications_triggered_by_fk` FOREIGN KEY (`triggered_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_notifications_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_shares` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `share_type` enum('internal','external','copy_link') DEFAULT 'internal',
  `shared_with` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shared_with`)),
  `message` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `post_shares_post_fk` (`post_id`),
  KEY `post_shares_user_fk` (`user_id`),
  KEY `idx_post_shares_created_at` (`created_at`),
  CONSTRAINT `post_shares_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_shares_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_views` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `viewed_at` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_post_view` (`post_id`,`user_id`),
  KEY `post_views_post_fk` (`post_id`),
  KEY `post_views_user_fk` (`user_id`),
  CONSTRAINT `post_views_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `post_views_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `system_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_type` enum('string','integer','boolean','json') DEFAULT 'string',
  `description` text DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- =============
-- CREATE VIEWS
-- =============

CREATE VIEW `v_admin_submission_stats` AS 
SELECT 
    `st`.`academic_year` AS `academic_year`, 
    `st`.`semester` AS `semester`, 
    `st`.`department_code` AS `department_code`, 
    `st`.`department_name` AS `department_name`, 
    count(distinct `st`.`user_id`) AS `total_faculty`, 
    count(distinct case when `st`.`status` = 'uploaded' then concat(`st`.`user_id`,'-',`st`.`document_type`) end) AS `submitted_docs`, 
    count(distinct `st`.`document_type`) AS `required_doc_types`, 
    count(distinct `st`.`user_id`) * count(distinct `st`.`document_type`) AS `total_required_submissions`, 
    round(count(distinct case when `st`.`status` = 'uploaded' then concat(`st`.`user_id`,'-',`st`.`document_type`) end) / (count(distinct `st`.`user_id`) * count(distinct `st`.`document_type`)) * 100,2) AS `completion_percentage` 
FROM `v_submission_tracker` AS `st` 
WHERE `st`.`academic_year` is not null AND `st`.`semester` is not null 
GROUP BY `st`.`academic_year`, `st`.`semester`, `st`.`department_code`, `st`.`department_name` 
ORDER BY `st`.`academic_year` DESC, `st`.`semester` ASC, `st`.`department_name` ASC;

CREATE VIEW `v_announcements_detailed` AS 
SELECT 
    `a`.`id` AS `id`, 
    `a`.`title` AS `title`, 
    `a`.`content` AS `content`, 
    `a`.`summary` AS `summary`, 
    `a`.`image_path` AS `image_path`, 
    `a`.`priority` AS `priority`, 
    `a`.`announcement_type` AS `announcement_type`, 
    `a`.`is_published` AS `is_published`, 
    `a`.`published_at` AS `published_at`, 
    `a`.`expires_at` AS `expires_at`, 
    `a`.`view_count` AS `view_count`, 
    `a`.`is_pinned` AS `is_pinned`, 
    `a`.`created_at` AS `created_at`, 
    `creator`.`username` AS `created_by_username`, 
    concat(`creator`.`name`,' ',ifnull(concat(`creator`.`mi`,'. '),''),`creator`.`surname`) AS `creator_full_name` 
FROM (`announcements` `a` left join `users` `creator` on(`a`.`created_by` = `creator`.`id`)) 
WHERE `a`.`is_deleted` = 0;

CREATE VIEW `v_comments_detailed` AS 
SELECT 
    `c`.`id` AS `id`, 
    `c`.`post_id` AS `post_id`, 
    `c`.`user_id` AS `user_id`, 
    `c`.`parent_comment_id` AS `parent_comment_id`, 
    `c`.`content` AS `content`, 
    `c`.`is_edited` AS `is_edited`, 
    `c`.`edited_at` AS `edited_at`, 
    `c`.`is_deleted` AS `is_deleted`, 
    `c`.`deleted_at` AS `deleted_at`, 
    `c`.`deleted_by` AS `deleted_by`, 
    `c`.`created_at` AS `created_at`, 
    `c`.`updated_at` AS `updated_at`, 
    `c`.`like_count` AS `like_count`, 
    `u`.`username` AS `username`, 
    `u`.`name` AS `name`, 
    `u`.`mi` AS `mi`, 
    `u`.`surname` AS `surname`, 
    concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `commenter_full_name`, 
    `u`.`profile_image` AS `profile_image`, 
    `u`.`position` AS `position`, 
    `d`.`department_code` AS `department_code`, 
    `deleter`.`username` AS `deleted_by_username` 
FROM (((`post_comments` `c` left join `users` `u` on(`c`.`user_id` = `u`.`id`)) left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `deleter` on(`c`.`deleted_by` = `deleter`.`id`));

CREATE VIEW `v_document_requests_detailed` AS 
SELECT 
    `dr`.`id` AS `id`, 
    `dr`.`tracking_code` AS `tracking_code`, 
    `dr`.`user_id` AS `user_id`, 
    `dr`.`document_type` AS `document_type`, 
    `dr`.`title` AS `title`, 
    `dr`.`description` AS `description`, 
    `dr`.`priority` AS `priority`, 
    `dr`.`status` AS `status`, 
    `dr`.`target_department` AS `target_department`, 
    `dr`.`expected_completion` AS `expected_completion`, 
    `dr`.`actual_completion` AS `actual_completion`, 
    `dr`.`assigned_to` AS `assigned_to`, 
    `dr`.`metadata` AS `metadata`, 
    `dr`.`created_at` AS `created_at`, 
    `dr`.`updated_at` AS `updated_at`, 
    `dr`.`updated_by` AS `updated_by`, 
    `dr`.`is_deleted` AS `is_deleted`, 
    `dr`.`deleted_at` AS `deleted_at`, 
    `dr`.`deleted_by` AS `deleted_by`, 
    `u`.`username` AS `requester_name`, 
    concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `requester_full_name`, 
    `u`.`email` AS `requester_email`, 
    `ud`.`department_name` AS `requester_department`, 
    `td`.`department_name` AS `target_dept_name`, 
    `td`.`department_code` AS `target_dept_code`, 
    concat(`assigned`.`name`,' ',ifnull(concat(`assigned`.`mi`,'. '),''),`assigned`.`surname`) AS `assigned_to_name`, 
    concat(`updater`.`name`,' ',ifnull(concat(`updater`.`mi`,'. '),''),`updater`.`surname`) AS `updated_by_name`, 
    (select count(0) from `document_comments` where `document_comments`.`request_id` = `dr`.`id` and `document_comments`.`is_deleted` = 0) AS `comment_count`, 
    (select count(0) from `document_attachments` where `document_attachments`.`request_id` = `dr`.`id` and `document_attachments`.`is_deleted` = 0) AS `attachment_count` 
FROM (((((`document_requests` `dr` left join `users` `u` on(`dr`.`user_id` = `u`.`id`)) left join `departments` `ud` on(`u`.`department_id` = `ud`.`id`)) left join `departments` `td` on(`dr`.`target_department` = `td`.`id`)) left join `users` `assigned` on(`dr`.`assigned_to` = `assigned`.`id`)) left join `users` `updater` on(`dr`.`updated_by` = `updater`.`id`)) 
WHERE `dr`.`is_deleted` = 0;

CREATE VIEW `v_files_detailed` AS 
SELECT 
    `f`.`id` AS `id`, 
    `f`.`original_name` AS `original_name`, 
    `f`.`file_name` AS `file_name`, 
    `f`.`file_size` AS `file_size`, 
    `f`.`file_type` AS `file_type`, 
    `f`.`mime_type` AS `mime_type`, 
    `f`.`file_extension` AS `file_extension`, 
    `f`.`uploaded_at` AS `uploaded_at`, 
    `f`.`download_count` AS `download_count`, 
    `f`.`is_deleted` AS `is_deleted`, 
    `folder`.`folder_name` AS `folder_name`, 
    `folder`.`folder_path` AS `folder_path`, 
    `uploader`.`username` AS `uploaded_by_username`, 
    concat(`uploader`.`name`,' ',ifnull(concat(`uploader`.`mi`,'. '),''),`uploader`.`surname`) AS `uploader_full_name`, 
    `dept`.`department_code` AS `folder_department` 
FROM (((`files` `f` left join `folders` `folder` on(`f`.`folder_id` = `folder`.`id`)) left join `users` `uploader` on(`f`.`uploaded_by` = `uploader`.`id`)) left join `departments` `dept` on(`folder`.`department_id` = `dept`.`id`));

CREATE VIEW `v_folders_hierarchy` AS 
SELECT 
    `f`.`id` AS `id`, 
    `f`.`folder_name` AS `folder_name`, 
    `f`.`folder_path` AS `folder_path`, 
    `f`.`folder_level` AS `folder_level`, 
    `f`.`is_public` AS `is_public`, 
    `f`.`folder_color` AS `folder_color`, 
    `f`.`folder_icon` AS `folder_icon`, 
    `f`.`file_count` AS `file_count`, 
    `f`.`folder_size` AS `folder_size`, 
    `f`.`created_at` AS `created_at`, 
    `parent`.`folder_name` AS `parent_folder_name`, 
    `creator`.`username` AS `created_by_username`, 
    concat(`creator`.`name`,' ',ifnull(concat(`creator`.`mi`,'. '),''),`creator`.`surname`) AS `creator_full_name`, 
    `dept`.`department_code` AS `department_code`, 
    `dept`.`department_name` AS `department_name` 
FROM (((`folders` `f` left join `folders` `parent` on(`f`.`parent_id` = `parent`.`id`)) left join `users` `creator` on(`f`.`created_by` = `creator`.`id`)) left join `departments` `dept` on(`f`.`department_id` = `dept`.`id`)) 
WHERE `f`.`is_deleted` = 0;

CREATE VIEW `v_posts_detailed` AS 
SELECT 
    `p`.`id` AS `id`, 
    `p`.`user_id` AS `user_id`, 
    `p`.`content` AS `content`, 
    `p`.`content_type` AS `content_type`, 
    `p`.`visibility` AS `visibility`, 
    `p`.`target_departments` AS `target_departments`, 
    `p`.`target_users` AS `target_users`, 
    `p`.`priority` AS `priority`, 
    `p`.`is_pinned` AS `is_pinned`, 
    `p`.`is_edited` AS `is_edited`, 
    `p`.`edited_at` AS `edited_at`, 
    `p`.`is_deleted` AS `is_deleted`, 
    `p`.`deleted_at` AS `deleted_at`, 
    `p`.`deleted_by` AS `deleted_by`, 
    `p`.`created_at` AS `created_at`, 
    `p`.`updated_at` AS `updated_at`, 
    `p`.`like_count` AS `like_count`, 
    `p`.`comment_count` AS `comment_count`, 
    `p`.`view_count` AS `view_count`, 
    `p`.`share_count` AS `share_count`, 
    `u`.`username` AS `username`, 
    `u`.`name` AS `name`, 
    `u`.`mi` AS `mi`, 
    `u`.`surname` AS `surname`, 
    concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `author_full_name`, 
    `u`.`profile_image` AS `profile_image`, 
    `u`.`position` AS `position`, 
    `d`.`department_code` AS `department_code`, 
    `d`.`department_name` AS `department_name`, 
    `deleter`.`username` AS `deleted_by_username` 
FROM (((`posts` `p` left join `users` `u` on(`p`.`user_id` = `u`.`id`)) left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `deleter` on(`p`.`deleted_by` = `deleter`.`id`));

CREATE VIEW `v_submission_tracker` AS 
SELECT 
    `u`.`id` AS `user_id`, 
    `u`.`username` AS `username`, 
    `u`.`name` AS `name`, 
    `u`.`surname` AS `surname`, 
    `u`.`department_id` AS `department_id`, 
    `d`.`department_name` AS `department_name`, 
    `d`.`department_code` AS `department_code`, 
    `fds`.`academic_year` AS `academic_year`, 
    `fds`.`semester` AS `semester`, 
    `fds`.`document_type` AS `document_type`, 
    count(`df`.`id`) AS `file_count`, 
    max(`df`.`uploaded_at`) AS `latest_upload`, 
    min(`df`.`uploaded_at`) AS `first_upload`, 
    sum(`df`.`file_size`) AS `total_size`, 
    `fds`.`submitted_at` AS `submitted_at`, 
    `fds`.`submitted_by` AS `submitted_by`, 
    CASE WHEN count(`df`.`id`) > 0 THEN 'uploaded' ELSE 'not_uploaded' END AS `status` 
FROM (((`users` `u` left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `faculty_document_submissions` `fds` on(`u`.`id` = `fds`.`faculty_id`)) left join `document_files` `df` on(`fds`.`id` = `df`.`submission_id` and `df`.`file_type` = `fds`.`document_type`)) 
WHERE `u`.`role` = 'user' AND `u`.`is_approved` = 1 
GROUP BY `u`.`id`, `fds`.`academic_year`, `fds`.`semester`, `fds`.`document_type`;

CREATE VIEW `v_users_detailed` AS 
SELECT 
    `u`.`id` AS `id`, 
    `u`.`username` AS `username`, 
    `u`.`email` AS `email`, 
    `u`.`role` AS `role`, 
    `u`.`is_approved` AS `is_approved`, 
    `u`.`name` AS `name`, 
    `u`.`mi` AS `mi`, 
    `u`.`surname` AS `surname`, 
    concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `full_name`, 
    `u`.`employee_id` AS `employee_id`, 
    `u`.`position` AS `position`, 
    `u`.`is_restricted` AS `is_restricted`, 
    `u`.`last_login` AS `last_login`, 
    `u`.`created_at` AS `created_at`, 
    `d`.`department_code` AS `department_code`, 
    `d`.`department_name` AS `department_name`, 
    `approver`.`username` AS `approved_by_username`, 
    `u`.`approved_at` AS `approved_at` 
FROM ((`users` `u` left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `approver` on(`u`.`approved_by` = `approver`.`id`));

-- =============
-- CREATE TRIGGERS
-- =============

DELIMITER $

CREATE TRIGGER `tr_announcement_view_insert` AFTER INSERT ON `announcement_views` FOR EACH ROW 
BEGIN
    UPDATE announcements 
    SET view_count = (
        SELECT COUNT(*) FROM announcement_views 
        WHERE announcement_id = NEW.announcement_id
    )
    WHERE id = NEW.announcement_id;
END$

CREATE TRIGGER `tr_document_request_insert` BEFORE INSERT ON `document_requests` FOR EACH ROW 
BEGIN
    DECLARE next_id INT;
    DECLARE tracking_code VARCHAR(20);
    
    -- Generate tracking code
    SELECT AUTO_INCREMENT INTO next_id FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'document_requests';
    
    SET tracking_code = CONCAT('DOC-', DATE_FORMAT(NOW(), '%Y%m'), '-', LPAD(next_id, 4, '0'));
    SET NEW.tracking_code = tracking_code;
END$

CREATE TRIGGER `tr_document_request_log` AFTER INSERT ON `document_requests` FOR EACH ROW 
BEGIN
    INSERT INTO activity_logs (user_id, action, resource_type, resource_id, description, metadata)
    VALUES (NEW.user_id, 'create_document_request', 'document', NEW.id, 
            CONCAT('Created document request: ', NEW.title, ' (', NEW.tracking_code, ')'),
            JSON_OBJECT('tracking_code', NEW.tracking_code, 'document_type', NEW.document_type, 'priority', NEW.priority));
END$

CREATE TRIGGER `tr_document_status_log` AFTER INSERT ON `document_status_history` FOR EACH ROW 
BEGIN
    INSERT INTO activity_logs (user_id, action, resource_type, resource_id, description, metadata)
    VALUES (NEW.changed_by, 'update_document_status', 'document', NEW.request_id, 
            CONCAT('Updated document status to: ', NEW.status),
            JSON_OBJECT('new_status', NEW.status, 'notes', NEW.notes));
END$

CREATE TRIGGER `tr_file_insert_log` AFTER INSERT ON `files` FOR EACH ROW 
BEGIN
    INSERT INTO activity_logs (user_id, action, resource_type, resource_id, description, metadata)
    VALUES (NEW.uploaded_by, 'upload_file', 'file', NEW.id, 
            CONCAT('Uploaded file: ', NEW.original_name),
            JSON_OBJECT('file_size', NEW.file_size, 'file_type', NEW.file_type));
END$

CREATE TRIGGER `tr_file_insert_update_folder` AFTER INSERT ON `files` FOR EACH ROW 
BEGIN
    CALL sp_update_folder_stats(NEW.folder_id);
END$

CREATE TRIGGER `tr_file_update_folder_stats` AFTER UPDATE ON `files` FOR EACH ROW 
BEGIN
    IF OLD.is_deleted != NEW.is_deleted THEN
        CALL sp_update_folder_stats(NEW.folder_id);
    END IF;
END$

CREATE TRIGGER `update_folder_stats_on_file_delete` AFTER UPDATE ON `files` FOR EACH ROW 
BEGIN
    IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
        UPDATE folders 
        SET file_count = (SELECT COUNT(*) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
            folder_size = (SELECT COALESCE(SUM(file_size), 0) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.folder_id;
    END IF;
END$

CREATE TRIGGER `update_folder_stats_on_file_insert` AFTER INSERT ON `files` FOR EACH ROW 
BEGIN
    UPDATE folders 
    SET file_count = (SELECT COUNT(*) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
        folder_size = (SELECT COALESCE(SUM(file_size), 0) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.folder_id;
END$

CREATE TRIGGER `update_folder_stats_on_file_update` AFTER UPDATE ON `files` FOR EACH ROW 
BEGIN
    -- Update old folder if folder_id changed
    IF OLD.folder_id != NEW.folder_id THEN
        UPDATE folders 
        SET file_count = (SELECT COUNT(*) FROM files WHERE folder_id = OLD.folder_id AND is_deleted = FALSE),
            folder_size = (SELECT COALESCE(SUM(file_size), 0) FROM files WHERE folder_id = OLD.folder_id AND is_deleted = FALSE),
            updated_at = CURRENT_TIMESTAMP
        WHERE id = OLD.folder_id;
    END IF;
    
    -- Update new folder
    UPDATE folders 
    SET file_count = (SELECT COUNT(*) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
        folder_size = (SELECT COALESCE(SUM(file_size), 0) FROM files WHERE folder_id = NEW.folder_id AND is_deleted = FALSE),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.folder_id;
END$

CREATE TRIGGER `tr_post_comment_insert` AFTER INSERT ON `post_comments` FOR EACH ROW 
BEGIN
    UPDATE posts 
    SET comment_count = (
        SELECT COUNT(*) FROM post_comments 
        WHERE post_id = NEW.post_id AND is_deleted = 0
    )
    WHERE id = NEW.post_id;
END$

CREATE TRIGGER `tr_post_comment_update` AFTER UPDATE ON `post_comments` FOR EACH ROW 
BEGIN
    IF OLD.is_deleted != NEW.is_deleted THEN
        UPDATE posts 
        SET comment_count = (
            SELECT COUNT(*) FROM post_comments 
            WHERE post_id = NEW.post_id AND is_deleted = 0
        )
        WHERE id = NEW.post_id;
    END IF;
END$

CREATE TRIGGER `tr_post_like_delete` AFTER DELETE ON `post_likes` FOR EACH ROW 
BEGIN
    IF OLD.post_id IS NOT NULL THEN
        UPDATE posts 
        SET like_count = (
            SELECT COUNT(*) FROM post_likes 
            WHERE post_id = OLD.post_id
        )
        WHERE id = OLD.post_id;
    ELSEIF OLD.comment_id IS NOT NULL THEN
        UPDATE post_comments 
        SET like_count = (
            SELECT COUNT(*) FROM post_likes 
            WHERE comment_id = OLD.comment_id
        )
        WHERE id = OLD.comment_id;
    END IF;
END$

CREATE TRIGGER `tr_post_like_insert` AFTER INSERT ON `post_likes` FOR EACH ROW 
BEGIN
    IF NEW.post_id IS NOT NULL THEN
        UPDATE posts 
        SET like_count = (
            SELECT COUNT(*) FROM post_likes 
            WHERE post_id = NEW.post_id
        )
        WHERE id = NEW.post_id;
    ELSEIF NEW.comment_id IS NOT NULL THEN
        UPDATE post_comments 
        SET like_count = (
            SELECT COUNT(*) FROM post_likes 
            WHERE comment_id = NEW.comment_id
        )
        WHERE id = NEW.comment_id;
    END IF;
END$

CREATE TRIGGER `tr_post_share_insert` AFTER INSERT ON `post_shares` FOR EACH ROW 
BEGIN
    UPDATE posts 
    SET share_count = (
        SELECT COUNT(*) FROM post_shares 
        WHERE post_id = NEW.post_id
    )
    WHERE id = NEW.post_id;
END$

CREATE TRIGGER `tr_post_view_insert` AFTER INSERT ON `post_views` FOR EACH ROW 
BEGIN
    UPDATE posts 
    SET view_count = (
        SELECT COUNT(*) FROM post_views 
        WHERE post_id = NEW.post_id
    )
    WHERE id = NEW.post_id;
END$

DELIMITER ;

COMMIT;