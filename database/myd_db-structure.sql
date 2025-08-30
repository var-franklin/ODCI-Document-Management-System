SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `activity_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `resource_type` enum('file','folder','user','announcement','department','system') NOT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `type` enum('info','success','warning','error') DEFAULT 'info',
  `action_url` varchar(500) DEFAULT NULL,
  `action_text` varchar(100) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `expires_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `posts` (
  `id` int(11) NOT NULL,
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
  `share_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_comments` (
  `id` int(11) NOT NULL,
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
  `like_count` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$
CREATE TRIGGER `tr_post_comment_insert` AFTER INSERT ON `post_comments` FOR EACH ROW BEGIN
    UPDATE posts 
    SET comment_count = (
        SELECT COUNT(*) FROM post_comments 
        WHERE post_id = NEW.post_id AND is_deleted = 0
    )
    WHERE id = NEW.post_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_post_comment_update` AFTER UPDATE ON `post_comments` FOR EACH ROW BEGIN
    IF OLD.is_deleted != NEW.is_deleted THEN
        UPDATE posts 
        SET comment_count = (
            SELECT COUNT(*) FROM post_comments 
            WHERE post_id = NEW.post_id AND is_deleted = 0
        )
        WHERE id = NEW.post_id;
    END IF;
END
$$
DELIMITER ;

CREATE TABLE `post_likes` (
  `id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `reaction_type` enum('like','love','laugh','angry','sad','wow') DEFAULT 'like',
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$
CREATE TRIGGER `tr_post_like_delete` AFTER DELETE ON `post_likes` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tr_post_like_insert` AFTER INSERT ON `post_likes` FOR EACH ROW BEGIN
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
END
$$
DELIMITER ;

CREATE TABLE `post_media` (
  `id` int(11) NOT NULL,
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
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `post_id` int(11) DEFAULT NULL,
  `comment_id` int(11) DEFAULT NULL,
  `triggered_by` int(11) NOT NULL,
  `notification_type` enum('new_post','post_comment','post_like','comment_like','comment_reply','post_mention','comment_mention') NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `post_shares` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `share_type` enum('internal','external','copy_link') DEFAULT 'internal',
  `shared_with` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`shared_with`)),
  `message` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$
CREATE TRIGGER `tr_post_share_insert` AFTER INSERT ON `post_shares` FOR EACH ROW BEGIN
    UPDATE posts 
    SET share_count = (
        SELECT COUNT(*) FROM post_shares 
        WHERE post_id = NEW.post_id
    )
    WHERE id = NEW.post_id;
END
$$
DELIMITER ;

CREATE TABLE `post_views` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `viewed_at` datetime DEFAULT current_timestamp(),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

DELIMITER $$
CREATE TRIGGER `tr_post_view_insert` AFTER INSERT ON `post_views` FOR EACH ROW BEGIN
    UPDATE posts 
    SET view_count = (
        SELECT COUNT(*) FROM post_views 
        WHERE post_id = NEW.post_id
    )
    WHERE id = NEW.post_id;
END
$$
DELIMITER ;

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
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
  `approved_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE `v_announcements_detailed` (
`id` int(11)
,`title` varchar(255)
,`content` text
,`summary` varchar(500)
,`image_path` varchar(255)
,`priority` enum('low','normal','high','urgent')
,`announcement_type` enum('general','department','urgent','maintenance')
,`is_published` tinyint(1)
,`published_at` datetime
,`expires_at` datetime
,`view_count` int(11)
,`is_pinned` tinyint(1)
,`created_at` datetime
,`created_by_username` varchar(50)
,`creator_full_name` varchar(208)
);

CREATE TABLE `v_comments_detailed` (
`id` int(11)
,`post_id` int(11)
,`user_id` int(11)
,`parent_comment_id` int(11)
,`content` text
,`is_edited` tinyint(1)
,`edited_at` datetime
,`is_deleted` tinyint(1)
,`deleted_at` datetime
,`deleted_by` int(11)
,`created_at` datetime
,`updated_at` datetime
,`like_count` int(11)
,`username` varchar(50)
,`name` varchar(100)
,`mi` varchar(5)
,`surname` varchar(100)
,`commenter_full_name` varchar(208)
,`profile_image` varchar(255)
,`position` varchar(100)
,`department_code` varchar(10)
,`deleted_by_username` varchar(50)
);

CREATE TABLE `v_posts_detailed` (
`id` int(11)
,`user_id` int(11)
,`content` text
,`content_type` enum('text','image','file','link','mixed')
,`visibility` enum('public','department','private','custom')
,`target_departments` longtext
,`target_users` longtext
,`priority` enum('low','normal','high','urgent')
,`is_pinned` tinyint(1)
,`is_edited` tinyint(1)
,`edited_at` datetime
,`is_deleted` tinyint(1)
,`deleted_at` datetime
,`deleted_by` int(11)
,`created_at` datetime
,`updated_at` datetime
,`like_count` int(11)
,`comment_count` int(11)
,`view_count` int(11)
,`share_count` int(11)
,`username` varchar(50)
,`name` varchar(100)
,`mi` varchar(5)
,`surname` varchar(100)
,`author_full_name` varchar(208)
,`profile_image` varchar(255)
,`position` varchar(100)
,`department_code` varchar(10)
,`department_name` varchar(100)
,`deleted_by_username` varchar(50)
);

ALTER TABLE `activity_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_resource` (`resource_type`,`resource_id`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_activity_logs_user_action` (`user_id`,`action`);

ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_is_read` (`is_read`),
  ADD KEY `idx_created_at` (`created_at`);

ALTER TABLE `posts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `posts_user_fk` (`user_id`),
  ADD KEY `posts_deleted_by_fk` (`deleted_by`),
  ADD KEY `idx_posts_created_at` (`created_at`),
  ADD KEY `idx_posts_visibility` (`visibility`),
  ADD KEY `idx_posts_pinned` (`is_pinned`),
  ADD KEY `idx_posts_deleted` (`is_deleted`);

ALTER TABLE `post_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_comments_post_fk` (`post_id`),
  ADD KEY `post_comments_user_fk` (`user_id`),
  ADD KEY `post_comments_parent_fk` (`parent_comment_id`),
  ADD KEY `post_comments_deleted_by_fk` (`deleted_by`),
  ADD KEY `idx_post_comments_created_at` (`created_at`),
  ADD KEY `idx_post_comments_deleted` (`is_deleted`);

ALTER TABLE `post_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_post_like` (`post_id`,`user_id`),
  ADD UNIQUE KEY `unique_comment_like` (`comment_id`,`user_id`),
  ADD KEY `post_likes_post_fk` (`post_id`),
  ADD KEY `post_likes_comment_fk` (`comment_id`),
  ADD KEY `post_likes_user_fk` (`user_id`),
  ADD KEY `idx_post_likes_created_at` (`created_at`);

ALTER TABLE `post_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_media_post_fk` (`post_id`),
  ADD KEY `idx_post_media_type` (`media_type`);

ALTER TABLE `post_notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_notifications_user_fk` (`user_id`),
  ADD KEY `post_notifications_post_fk` (`post_id`),
  ADD KEY `post_notifications_comment_fk` (`comment_id`),
  ADD KEY `post_notifications_triggered_by_fk` (`triggered_by`),
  ADD KEY `idx_post_notifications_read` (`is_read`),
  ADD KEY `idx_post_notifications_created_at` (`created_at`);

ALTER TABLE `post_shares`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_shares_post_fk` (`post_id`),
  ADD KEY `post_shares_user_fk` (`user_id`),
  ADD KEY `idx_post_shares_created_at` (`created_at`);

ALTER TABLE `post_views`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_post_view` (`post_id`,`user_id`),
  ADD KEY `post_views_post_fk` (`post_id`),
  ADD KEY `post_views_user_fk` (`user_id`);

ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `employee_id` (`employee_id`),
  ADD KEY `fk_user_department` (`department_id`),
  ADD KEY `idx_email_verified` (`email_verified`),
  ADD KEY `idx_is_approved` (`is_approved`),
  ADD KEY `idx_role` (`role`),
  ADD KEY `fk_user_created_by` (`created_by`),
  ADD KEY `fk_user_approved_by` (`approved_by`),
  ADD KEY `idx_users_last_login` (`last_login`);

ALTER TABLE `activity_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=223;

ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

ALTER TABLE `posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

ALTER TABLE `post_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `post_likes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `post_media`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `post_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

ALTER TABLE `post_shares`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `post_views`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

DROP TABLE IF EXISTS `v_comments_detailed`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_comments_detailed`  AS SELECT `c`.`id` AS `id`, `c`.`post_id` AS `post_id`, `c`.`user_id` AS `user_id`, `c`.`parent_comment_id` AS `parent_comment_id`, `c`.`content` AS `content`, `c`.`is_edited` AS `is_edited`, `c`.`edited_at` AS `edited_at`, `c`.`is_deleted` AS `is_deleted`, `c`.`deleted_at` AS `deleted_at`, `c`.`deleted_by` AS `deleted_by`, `c`.`created_at` AS `created_at`, `c`.`updated_at` AS `updated_at`, `c`.`like_count` AS `like_count`, `u`.`username` AS `username`, `u`.`name` AS `name`, `u`.`mi` AS `mi`, `u`.`surname` AS `surname`, concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `commenter_full_name`, `u`.`profile_image` AS `profile_image`, `u`.`position` AS `position`, `d`.`department_code` AS `department_code`, `deleter`.`username` AS `deleted_by_username` FROM (((`post_comments` `c` left join `users` `u` on(`c`.`user_id` = `u`.`id`)) left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `deleter` on(`c`.`deleted_by` = `deleter`.`id`)) ;

DROP TABLE IF EXISTS `v_posts_detailed`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_posts_detailed`  AS SELECT `p`.`id` AS `id`, `p`.`user_id` AS `user_id`, `p`.`content` AS `content`, `p`.`content_type` AS `content_type`, `p`.`visibility` AS `visibility`, `p`.`target_departments` AS `target_departments`, `p`.`target_users` AS `target_users`, `p`.`priority` AS `priority`, `p`.`is_pinned` AS `is_pinned`, `p`.`is_edited` AS `is_edited`, `p`.`edited_at` AS `edited_at`, `p`.`is_deleted` AS `is_deleted`, `p`.`deleted_at` AS `deleted_at`, `p`.`deleted_by` AS `deleted_by`, `p`.`created_at` AS `created_at`, `p`.`updated_at` AS `updated_at`, `p`.`like_count` AS `like_count`, `p`.`comment_count` AS `comment_count`, `p`.`view_count` AS `view_count`, `p`.`share_count` AS `share_count`, `u`.`username` AS `username`, `u`.`name` AS `name`, `u`.`mi` AS `mi`, `u`.`surname` AS `surname`, concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `author_full_name`, `u`.`profile_image` AS `profile_image`, `u`.`position` AS `position`, `d`.`department_code` AS `department_code`, `d`.`department_name` AS `department_name`, `deleter`.`username` AS `deleted_by_username` FROM (((`posts` `p` left join `users` `u` on(`p`.`user_id` = `u`.`id`)) left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `deleter` on(`p`.`deleted_by` = `deleter`.`id`)) ;

DROP TABLE IF EXISTS `v_users_detailed`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_users_detailed`  AS SELECT `u`.`id` AS `id`, `u`.`username` AS `username`, `u`.`email` AS `email`, `u`.`role` AS `role`, `u`.`is_approved` AS `is_approved`, `u`.`name` AS `name`, `u`.`mi` AS `mi`, `u`.`surname` AS `surname`, concat(`u`.`name`,' ',ifnull(concat(`u`.`mi`,'. '),''),`u`.`surname`) AS `full_name`, `u`.`employee_id` AS `employee_id`, `u`.`position` AS `position`, `u`.`is_restricted` AS `is_restricted`, `u`.`last_login` AS `last_login`, `u`.`created_at` AS `created_at`, `d`.`department_code` AS `department_code`, `d`.`department_name` AS `department_name`, `approver`.`username` AS `approved_by_username`, `u`.`approved_at` AS `approved_at` FROM ((`users` `u` left join `departments` `d` on(`u`.`department_id` = `d`.`id`)) left join `users` `approver` on(`u`.`approved_by` = `approver`.`id`)) ;

ALTER TABLE `activity_logs`
  ADD CONSTRAINT `activity_logs_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL;

ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `posts`
  ADD CONSTRAINT `posts_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `posts_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_comments`
  ADD CONSTRAINT `post_comments_deleted_by_fk` FOREIGN KEY (`deleted_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `post_comments_parent_fk` FOREIGN KEY (`parent_comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_comments_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_comments_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_likes`
  ADD CONSTRAINT `post_likes_comment_fk` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_likes_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_likes_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_media`
  ADD CONSTRAINT `post_media_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_notifications`
  ADD CONSTRAINT `post_notifications_comment_fk` FOREIGN KEY (`comment_id`) REFERENCES `post_comments` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_notifications_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_notifications_triggered_by_fk` FOREIGN KEY (`triggered_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_notifications_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_shares`
  ADD CONSTRAINT `post_shares_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_shares_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `post_views`
  ADD CONSTRAINT `post_views_post_fk` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `post_views_user_fk` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

ALTER TABLE `users`
  ADD CONSTRAINT `fk_user_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_user_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_user_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL;
COMMIT;
