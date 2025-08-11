<?php
// Simple viewer for collected emails
// Access this at: https://ufobeep.com/view-emails.php?token=ufobeep2024

// Simple authentication
if (!isset($_GET['token']) || $_GET['token'] !== 'ufobeep2024') {
    http_response_code(403);
    die('Unauthorized');
}

// Read the email file
$storage_file = __DIR__ . '/email-signups.txt';

if (!file_exists($storage_file)) {
    die('No signups yet.');
}

// Read and parse emails
$lines = file($storage_file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
$emails = [];

foreach ($lines as $line) {
    $parts = explode("\t", $line);
    if (count($parts) >= 2) {
        $emails[] = [
            'timestamp' => $parts[0],
            'email' => $parts[1],
            'user_agent' => isset($parts[2]) ? $parts[2] : 'Unknown'
        ];
    }
}

// Display as simple HTML table
?>
<!DOCTYPE html>
<html>
<head>
    <title>UFOBeep Email Signups</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1a1a1a; color: #fff; }
        table { border-collapse: collapse; width: 100%; max-width: 800px; margin: 0 auto; }
        th, td { border: 1px solid #444; padding: 10px; text-align: left; }
        th { background: #2563eb; }
        h1 { text-align: center; color: #2563eb; }
        .stats { text-align: center; margin: 20px 0; font-size: 18px; }
    </style>
</head>
<body>
    <h1>UFOBeep Email Signups</h1>
    <div class="stats">Total signups: <?php echo count($emails); ?></div>
    
    <table>
        <thead>
            <tr>
                <th>Timestamp</th>
                <th>Email</th>
                <th>User Agent</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach (array_reverse($emails) as $entry): ?>
            <tr>
                <td><?php echo htmlspecialchars($entry['timestamp']); ?></td>
                <td><?php echo htmlspecialchars($entry['email']); ?></td>
                <td><?php echo htmlspecialchars(substr($entry['user_agent'], 0, 50)); ?>...</td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
    
    <div style="text-align: center; margin-top: 40px;">
        <a href="/email-signups.txt" download style="color: #2563eb;">Download raw file</a>
    </div>
</body>
</html>