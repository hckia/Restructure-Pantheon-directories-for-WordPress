<?php

$dir_to_redirect = '/wp-content/uploads/2023/01/';
if ($dir = stripos($_SERVER['REQUEST_URI'], $dir_to_redirect) !== false) {
	$requested_path_and_file = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
	$uriSegments = explode("/", parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

	// just need the last element in array (file name)
	$file_name = array_pop($uriSegments);
	end($uriSegments);
	$requested_dir=prev($uriSegments);

	// first letter/number is subdir mb_substr for unicode, can also use str_starts_with in php 8
	$new_sub_dir=mb_substr($file_name, 0, 1);
	$pst = new DateTimeZone('America/Los_Angeles');
	$current = new DateTime('now', $pst);

	if ( $requested_dir != $new_sub_dir ) {
	    $requested_dir=str_replace($file_name, "", $requested_path_and_file);
		  // usually $_SERVER[REQUEST_URI]
	    $new_requested_path_and_file=$requested_dir . $new_sub_dir . "/" .  $file_name;
	    $new_url = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://$_SERVER[HTTP_HOST]$new_requested_path_and_file";
	    // header wasn't working here. this'll do for now.
      retrieve_new_path($new_url);
	}
}

function retrieve_new_path($new_url) {
	$ch = curl_init($new_url);
	curl_setopt($ch, CURLOPT_NOBODY, true);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 1); //connect timeout in seconds
    curl_setopt($ch, CURLOPT_TIMEOUT, 1); //timeout in seconds
    curl_exec($ch);
    $ret_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $mime = curl_getinfo($ch, CURLINFO_CONTENT_TYPE);
    curl_close($ch);
    if($ret_code == 200) {
        // header("Cache-Control: no-cache");
        header('Content-Type: ' . $mime);
        readfile($new_url);
        exit();
    }
}
