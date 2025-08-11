<?php
// Simple email collection endpoint for UFOBeep
// This file should be placed in the web root of ufobeep.com

// Allow CORS from the same domain
header('Access-Control-Allow-Origin: https://ufobeep.com');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
header('Content-Type: application/json');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
    exit();
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);
$email = isset($input['email']) ? trim($input['email']) : '';

// Validate email
if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    http_response_code(400);
    echo json_encode(['error' => 'Valid email address required']);
    exit();
}

// Define the file to store emails
$storage_file = __DIR__ . '/email-signups.txt';

// Create entry with timestamp
$entry = date('Y-m-d H:i:s') . "\t" . $email . "\t" . $_SERVER['HTTP_USER_AGENT'] . "\n";

// Append to file (creates file if it doesn't exist)
if (file_put_contents($storage_file, $entry, FILE_APPEND | LOCK_EX) !== false) {
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'message' => "Thanks! We'll notify you when the UFOBeep app is ready for download."
    ]);
} else {
    http_response_code(500);
    echo json_encode(['error' => 'Failed to save email. Please try again.']);
}
?>