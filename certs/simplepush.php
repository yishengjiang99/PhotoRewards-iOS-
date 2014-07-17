<?php

// Put your device token here (without spaces):

$deviceToken = '0f744707bebcf74f9b7c25d48e3358945f6aa01da5ddb387462c7eaf61bbad78';

$deviceToken="3e532ad03ed311a700e9a6c4c9cd7bf7ea727ad69dc7177c394c2950ce558202";
$deviceToken='b233bb756bba8d68f960f1f1cfa753be4a2490d138765b46e3cf018e406ab3ec';
$deviceToken='b36014308f3da192e444f3e0e1f7a865270d33b3758fd2cebd26b7126bf6f56b';
$deviceToken='f812bfe24eb3ec7a7eb5ca2707ee762064b89703fdb6a34f4d6be387c0b52b36';
$passphrase = 'ckck';
$passphrase='prpr';
// Put your alert message here:
$message = "Your friend Amanda Stolpa's birthday is in 3 days!";
$message="MSFT (Microsoft Corporation) is now at 33.05. Up 1.11111% for the day";

////////////////////////////////////////////////////////////////////////////////

$ctx = stream_context_create();
stream_context_set_option($ctx, 'ssl', 'local_cert', 'PRDevCertKey.pem');
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);
// Open a connection to the APNS server
$fp = stream_socket_client(
	'ssl://gateway.sandbox.push.apple.com:2195', $err,
	$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

if (!$fp)
	exit("Failed to connect: $err $errstr" . PHP_EOL);

echo 'Connected to APNS' . PHP_EOL;

// Create the payload body
$body['aps'] = array(
	'alert' => $message,
	'sound' => 'default',
	'custom_key1'=>'hi',
	);

// Encode the payload as JSON
$payload = json_encode($body);

// Build the binary notification
$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;

// Send it to the server
$result = fwrite($fp, $msg, strlen($msg));
echo $result;
if (!$result)
	echo 'Message not delivered' . PHP_EOL;
else
	echo 'Message successfully delivered' . PHP_EOL;

// Close the connection to the server
fclose($fp);
