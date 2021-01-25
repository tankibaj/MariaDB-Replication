<?php
$servername = "mariadb_master";
$username = "root";
$password = "123123";
$dbname = "foobar";


function str_random($length = 16)
{
    $pool = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return substr(str_shuffle(str_repeat($pool, $length)), 0, $length);
}


try {
  $db = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
  $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);


  //   ----------------- Create Table ----------------
//  $db->query("CREATE TABLE test (id INT UNSIGNED NOT NULL AUTO_INCREMENT, label VARCHAR(255), PRIMARY KEY(id)) ENGINE InnoDB DEFAULT CHARSET UTF8;");
//
//  echo "Table inserted successfully";


  //   ----------------- Insert ----------------
  $stmt = $db->prepare("INSERT INTO test (label) VALUES (:label)");
  $stmt->bindParam(':label', $label);

  $label = str_random();
  $stmt->execute();
//  echo "Data inserted successfully";


  //   ----------------- Update ----------------
  $stmt = $db->prepare("UPDATE test SET label = :label WHERE id = :id");
  $stmt->bindParam(':label', $label);
  $stmt->bindParam(':id', $id);

  $str_random=str_random();
  $label = "$str_random updated";
  $id = "1";
  $stmt->execute();
//  echo "Data updated successfully";

  
  //   ----------------- DELETE ----------------
//  $stmt = $db->prepare("DELETE FROM test WHERE id = :id");
//  $stmt->bindParam(':id', $id);
//
//  $id = "1";
//  $stmt->execute();
//  echo "Data deleted successfully";

  
} catch(PDOException $e) {
  echo "Error: " . $e->getMessage();
}
?>