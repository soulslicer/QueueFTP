<?php
    
    /*  FTP UPLOADER SCRIPT BY RAAJ */
	
    //POST Info entered
    $paths=$_POST['pathserver'];
    $filep=$_FILES['userfile']['tmp_name'];
    $ftp_server=$_POST['server'];
    $ftp_user_name=$_POST['user'];
    $ftp_user_pass=$_POST['password'];
    $name=$_FILES['userfile']['name'];
    
    //Begin FTP Session
    $val = $_SESSION['pathserver'];
    $conn_id = ftp_connect($ftp_server);
    $login_result = ftp_login($conn_id, $ftp_user_name, $ftp_user_pass);
    
    // check connection and login result
    if ((!$conn_id) || (!$login_result)) {
        echo "ConnectionError ";
        echo "Attempted to connect to $ftp_server for user $ftp_user_name....";
        exit;
    } else {
        //echo "Connected to $ftp_server, for user $ftp_user_name".".....";
    }
    
    // upload the file to the path specified
    $upload = ftp_put($conn_id, $paths.'/'.$name, $filep, FTP_BINARY);
    
    // check the upload status
    if (!$upload) {
        echo "FTP upload has encountered an error for /$name";
    } else {
        echo "Success! Uploaded/$name ";
    }
    
    // close the FTP connection
    ftp_close($conn_id);	
    ?>