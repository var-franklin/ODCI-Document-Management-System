<?php

session_start();
require_once 'google_oauth.php';

// Enable error reporting for debugging (remove in production)
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Check if authorization code is present
if (!isset($_GET['code'])) {
    // Handle error cases
    if (isset($_GET['error'])) {
        $error_description = isset($_GET['error_description']) ? $_GET['error_description'] : 'Google authentication failed';
        error_log("Google OAuth Error: " . $_GET['error'] . " - " . $error_description);
        header('Location: ../login.php?error=' . urlencode('Google authentication was cancelled or failed.'));
    } else {
        header('Location: ../login.php?error=' . urlencode('No authorization code received from Google.'));
    }
    exit();
}

try {
    // Get access token from Google
    $tokenData = GoogleOAuth::getAccessToken($_GET['code']);
    
    if (!$tokenData || !isset($tokenData['access_token'])) {
        error_log("Failed to get access token: " . json_encode($tokenData));
        header('Location: ../login.php?error=' . urlencode('Failed to get access token from Google.'));
        exit();
    }
    
    // Get user info from Google
    $userInfo = GoogleOAuth::getUserInfo($tokenData['access_token']);
    
    if (!$userInfo || !isset($userInfo['email'])) {
        error_log("Failed to get user info: " . json_encode($userInfo));
        header('Location: ../login.php?error=' . urlencode('Failed to get user information from Google.'));
        exit();
    }
    
    // Handle user login/registration
    $result = GoogleOAuth::handleGoogleUser($pdo, $userInfo);
    
    if ($result['success']) {
        if (isset($result['redirect'])) {
            header('Location: ' . $result['redirect']);
        } else {
            // Successful login - redirect to dashboard
            header('Location: ../../../../roles/user/dashboard.php');
        }
        exit();
    } else {
        header('Location: ../login.php?error=' . urlencode($result['message']));
        exit();
    }
    
} catch (Exception $e) {
    error_log("Google OAuth callback exception: " . $e->getMessage());
    header('Location: ../login.php?error=' . urlencode('An error occurred during Google authentication. Please try again.'));
    exit();
}
?>