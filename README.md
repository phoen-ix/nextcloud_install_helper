# nextcloud_install_helper

TLDR; Script that automates as much as possible to setup a nextcloud instance in a docker container. 


Video: 
https://odysee.com/@techtips:57/nc_install_helper_v1:7
lbry://nc_install_helper_v1

Goal: Making it as easy as possible for people to setup their own cloud, chat/talk and office solution.

The script was developed and tested on a vps that had following specs:
KVM, 1 vCore, 2GB DDR4 ECC, 20 GB SSD and Ubuntu 20.04 installed.

What does it do?
First it installs Docker and Docker-Compose, it also adds 'DOCKER_OPTS="--iptables=false"' to /etc/default/docker which makes Docker respect the ufw again; 
more information on that here https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/ .

Next Step is going to install apache and certbot. After that ufw rules for ssh, apache are added and ufw is enabled.

Finally, Nextcloud is going to be installed and here is the most user interaction necessary.

You will need to have prepared in advance two dns A entries, which you want to use.
One will be your future nextcloud address, the other one is needed for collabora.

For example: 
nc.yourdomain.com the address which you are going to use to login and use your nextcloud instance.
cb.yourdomain.com address for collabora (office documents)

You need to decide where you want to install your nextcloud instance, if you don't have any preference, you can use the proposed one.
The folder you chose should not already exist.

You need to know your public IPv4 address of your server/vps. The script will try to get it and suggest it to you.

Following these inputs, the script will start certbot twice. You could create both certificates in one step by separating the domains with a space. 
For whatever reason I prefer to do it in two steps...

Follow the certification process and let certbot make all requests redirect to https (Option two).

If everything worked as designed now docker-compose should start and fetch all required images etc.

Depending on your vps/server this step may take some time.

When you can see the nextcloud webpage visiting https://nc.yourdomain.com you should confirm in the script by entering 'c'.
This will fix some permissions to the volumes; if you pressed install before confirming it will ask you to specify the database connection
and cannot continue before the permissions are corrected.

Enter your new user and a secure password (this is going to be your first user and also has admin privileges).

After that you will be asked if you want to install some recommended apps. 
I do not recommend this, as it will install the code server app which is going to need unnecessary resources because we already have collabora via a docker container.

In the web interface go to Apps in the Web Interface and install 'Talk' and 'Nextcloud Office'.

Go to Settings / Administration / Basic settings: Chose Cron for Background jobs (the script added the necessary cronjob).

Go to Settings / Administration / Talk: Enter Stun and Turn Server & Secret (the script will output the necessary info’s).

Go to Settings / Administration / Nextcloud Office: enter your collabora FQDN.

Done!



Disclaimer: I tried my best but cannot guarantee that everything will work or is completely secure. 
If you have recommendations or see security flaws please contact me, thank you.




Archives:
https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/
https://web.archive.org/web/20220207234904/https://www.techrepublic.com/article/how-to-fix-the-docker-and-ufw-security-flaw/
https://archive.ph/3k7jT
