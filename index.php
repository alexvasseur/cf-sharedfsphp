<?php

echo "Cloud Foundry - PHP - Shared file system SSHFS FUSE";
echo "<br/>";
echo getenv("CF_INSTANCE_ADDR");
echo "<br/>";
echo getenv("CF_INSTANCE_IP");
echo "<br/>";


$vcap_services = json_decode($_ENV["VCAP_SERVICES"]);
var_dump($$vcap_services);

echo "<br/>ls /home/vcap/sshfs";
exec("ls /home/vcap/sshfs", $output);
foreach ($output as $line) {
  echo "$line<br/>";
}
echo "<br/>df -h";
exec("df -h", $output);
foreach ($output as $line) {
  echo "$line<br/>";
}

?>
