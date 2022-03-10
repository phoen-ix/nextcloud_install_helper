#!/usr/bin/env bash
### Colors ##
ESC=$(printf '\033') RESET="$ESC[0m" BLACK="$ESC[30m" RED="$ESC[31m"
GREEN="$ESC[32m" YELLOW="$ESC[33m" BLUE="$ESC[34m" MAGENTA="$ESC[35m"
CYAN="$ESC[36m" WHITE="$ESC[37m" DEFAULT="$ESC[39m"

### Color Functions ##
greenprint() { printf "$GREEN%s$RESET\n" "$1"; }
blueprint() { printf "$BLUE%s$RESET\n" "$1"; }
redprint() { printf "$RED%s$RESET\n" "$1"; }
yellowprint() { printf "$YELLOW%s$RESET\n" "$1"; }
magentaprint() { printf "$MAGENTA%s$RESET\n" "$1"; }
cyanprint() { printf "$CYAN%s$RESET\n" "$1"; }

menuheader() {
   clear
   echo "
███╗   ██╗███████╗██╗  ██╗████████╗ ██████╗██╗      ██████╗ ██╗   ██╗██████╗
████╗  ██║██╔════╝╚██╗██╔╝╚══██╔══╝██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗
██╔██╗ ██║█████╗   ╚███╔╝    ██║   ██║     ██║     ██║   ██║██║   ██║██║  ██║
██║╚██╗██║██╔══╝   ██╔██╗    ██║   ██║     ██║     ██║   ██║██║   ██║██║  ██║
██║ ╚████║███████╗██╔╝ ██╗   ██║   ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝
╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝
Install helper 0.9"
   echo "$DISPLAY_MESSAGE"
   DISPLAY_MESSAGE=""
}

fn_bye() {
   echo "Exiting now.."
   exit 0
}

fn_fail() { DISPLAY_MESSAGE="ERROR: Unrecognized option $ans"; }

fn_wait_for_key_and_goto() {
   while [ true ]; do
      read -t 3 -n 1
      if [ $? = 0 ]; then
         "$1"
      fi
   done
}

mainmenu() {
   menuheader
   echo -ne "
$(magentaprint 'MAIN MENU')
h) Help
a) Start all steps
1) Install docker & iptables mod
2) Install Apache & certbot
3) Modify and enable ufw
4) Install Nextcloud
0) Exit
    Choose an option:  "
   read -r ans
   case $ans in
   a)
      fn_install_docker
      fn_install_apache_certbot
      fn_update_enable_ufw
      nextcloudmenu
      ;;
   1)
      fn_install_docker
      ;;
   2)
      fn_install_apache_certbot
      ;;
   3)
      fn_update_enable_ufw
      ;;
   4)
      nextcloudmenu
      ;;
   h)
      fn_main_help
      ;;
   0)
      fn_bye
      ;;
   *)
      fn_fail
      mainmenu
      ;;
   esac
}

fn_main_help() {
   clear
   echo "MAIN HELP
Attention: Only use this on a machine where you already made a backup/snapshot that you can easily rollback.

This script was created to automate and guide as much as possible through a nextcloud docker installation.
It will install and use an apache webserver on the host machine that reverse proxies to a docker nextcloud instance.
It will also configure and enable the ufw firewall.
It will start certbot.

You will need to create two DNS subdomain A entries in advance, otherwise Certbot cannot create the certificates.
For example nc.yourdomain.com and cb.yourdomain.com, one is your actual FQDN that you are going to use to reach your nextcloud,
the other one is for collabora and will redirect to your nextcloud FQDN if you visit it with your browser (you need the other domain
because other ports will be used from nextcloud and need to be on another domain as far as I know).
You can use online Services like https://dnschecker.org/ to check if your domain change is already propagated.

    ...press any key"
   fn_wait_for_key_and_goto mainmenu
}

nextcloudmenu() {
   echo -ne "
Before you start, be sure you have already configured two A DNS entries for your domain.
One for collabora, the other one for nextcloud. For example:
nc.yourdomain.com
cb.yourdomain.com

These entries take some time before they are known on the web.
You can check the status here https://dnschecker.org/

You also need to know your external IP address of your server (Script detected $EXTERNAL_IP).

While getting the certificates via Certbot, you need to do it for both domains you configured your dns.

$DISPLAY_MESSAGE
 0) Exit
     Confirm by typing \"start\":  "
   DISPLAY_MESSAGE=""
   read -r ans
   case $ans in
   start)
      fn_nextcloud_install_00
      fn_nextcloud_install_01
      fn_nextcloud_install_02
      fn_nextcloud_install_03
      fn_nextcloud_install_04
      fn_nextcloud_install_05
      fn_nextcloud_install_06
      fn_nextcloud_install_07
      fn_nextcloud_install_08
      fn_nextcloud_install_09
      fn_nextcloud_install_10
      sudo rm -r ./tmp
      ;;
   0)
      fn_bye
      ;;
   1)
       fn_nextcloud_install_10
       ;;
   *)
      fn_fail
      nextcloudmenu
      ;;
   esac
}

fn_nextcloud_install_00() {
   [ -d ./tmp ] && sudo rm -r ./tmp
   sudo mkdir ./tmp
   sudo cp ./template_files/* ./tmp/
}

fn_nextcloud_install_01() {
   echo "Please enter your NEXTCLOUD FQDN, example: nc.yourdomain.com"
   read USERINPUT_NEXTCLOUD_FQDN
   [ -z "$(dig +short "$USERINPUT_NEXTCLOUD_FQDN")" ] && echo "$USERINPUT_NEXTCLOUD_FQDN could not be looked up" && fn_nextcloud_install_01
   fn_print_empty_line 1
}

fn_nextcloud_install_02() {
   echo "Please enter your COLLABORA FQDN, example: cb.yourdomain.com"
   read USERINPUT_COLLABORA_FQDN
   [ -z "$(dig +short "$USERINPUT_COLLABORA_FQDN")" ] && echo "$USERINPUT_COLLABORA_FQDN could not be looked up" && fn_nextcloud_install_02
   fn_print_empty_line 1
}

fn_nextcloud_install_03() {
   echo "Enter absolute installation path for docker compose, with leading and trailing slash"
   echo "Recommended path: /opt/nextcloud-dockerized/"
   read USERINPUT_NEXTCLOUDPATH
   [ -d $USERINPUT_NEXTCLOUDPATH ] && echo "Directory $USERINPUT_NEXTCLOUDPATH exists, please use a non existent path." && fn_nextcloud_install_03
   if [[ ! $USERINPUT_NEXTCLOUDPATH == /*/ ]]; then
      echo "Path needs a leading and trailing slash"
      fn_nextcloud_install_03
   fi
}

fn_nextcloud_install_04() {
   EXTERNAL_IP=$(curl -s http://ifconfig.me/)
   echo "Enter external IP address (suggested: $EXTERNAL_IP )"
   read USERINPUT_IP
   if [[ ! $USERINPUT_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Invalid IP format"
      fn_nextcloud_install_04
   fi

}

fn_nextcloud_install_05() {
   GENERATED_PW_MYSQL_ROOT=$(fn_password_generator)
   GENERATED_PW_MYSQL=$(fn_password_generator)
   GENERATED_PW_COTURN=$(fn_password_generator)
}

fn_nextcloud_install_06() {
   sed -i "s~VAR_EXTERNAL_IP~$USERINPUT_IP~g" ./tmp/env
   sed -i "s~VAR_NEXTCLOUD_FQDN~$USERINPUT_NEXTCLOUD_FQDN~g" ./tmp/env
   sed -i "s~VAR_COLLABORA_FQDN~$USERINPUT_COLLABORA_FQDN~g" ./tmp/env
   sed -i "s~VAR_MYSQL_ROOT_PW~$GENERATED_PW_MYSQL_ROOT~g" ./tmp/env
   sed -i "s~VAR_MYSQL_PW~$GENERATED_PW_MYSQL~g" ./tmp/env
   sed -i "s~VAR_COTURN_PW~$GENERATED_PW_COTURN~g" ./tmp/env
   sed -i "s~VAR_NEXTCLOUD_PATH~$USERINPUT_NEXTCLOUDPATH~g" ./tmp/env

   sed -i "s~VAR_NEXTCLOUD_FQDN~$USERINPUT_NEXTCLOUD_FQDN~g" ./tmp/nc.conf
   sed -i "s~VAR_COLLABORA_FQDN~$USERINPUT_COLLABORA_FQDN~g" ./tmp/nc.conf
   sed -i "s~VAR_NEXTCLOUD_FQDN~$USERINPUT_NEXTCLOUD_FQDN~g" ./tmp/cb.conf
   sed -i "s~VAR_COLLABORA_FQDN~$USERINPUT_COLLABORA_FQDN~g" ./tmp/cb.conf

   sudo mkdir -p "${USERINPUT_NEXTCLOUDPATH}config/"
   sudo cp ./tmp/apache2.conf "${USERINPUT_NEXTCLOUDPATH}config/apache2.conf"
   sudo cp ./tmp/docker-compose.yml "${USERINPUT_NEXTCLOUDPATH}docker-compose.yml"
   sudo cp ./tmp/env "${USERINPUT_NEXTCLOUDPATH}.env"

   sudo cp ./tmp/nc.conf /etc/apache2/sites-available/$USERINPUT_NEXTCLOUD_FQDN.conf
   sudo cp ./tmp/cb.conf /etc/apache2/sites-available/$USERINPUT_COLLABORA_FQDN.conf

   sudo a2ensite $USERINPUT_NEXTCLOUD_FQDN
   sudo a2ensite $USERINPUT_COLLABORA_FQDN
   sudo systemctl restart apache2
}

fn_nextcloud_install_07() {
   echo "*******************************"
   echo $(redprint 'The next Step will open Certbot twice')
   echo "You need to generate a certificate for both subdomains (nextcloud and collabora FQDN)"
   echo "For each domain, first enter the according number and the following step,"
   echo "let certbot create the additional entry (option 2)"
   echo "*******************************"
   sudo certbot
   sudo certbot
   echo "done..."
}

fn_nextcloud_install_08() {

   fn_print_empty_line 1
   echo "*******************************"
   echo "Now we are going to start docker-compose."
   echo "Depending on your server, this will take some time, please be patient"
   sudo docker-compose -f ${USERINPUT_NEXTCLOUDPATH}docker-compose.yml up -d
   fn_print_empty_line 1
   fn_countdown 30
   echo "You can try, if you see a nextcloud page visiting:"
   echo "(The countdown was just symbolic, it can easily take 2-5 minutes, don't panic)"
   fn_print_empty_line 1
   echo "https://$USERINPUT_NEXTCLOUD_FQDN"
   echo "*******************************"
   fn_print_empty_line 2
}

fn_nextcloud_install_09() {
   echo $(redprint "Only continue if you can see the nextcloud installation page visiting https://$USERINPUT_NEXTCLOUD_FQDN")
   echo "Confirm by typing \"c\":  "
   read -r ans
   case $ans in
   c)
      echo "continuing.."
      ;;
   *)
      fn_print_empty_line 1
      fn_nextcloud_install_09
      ;;
   esac
}

fn_nextcloud_install_10() {
   echo "Changing permissions to data and html volumes."
   sudo chown -R www-data:www-data ${USERINPUT_NEXTCLOUDPATH}volumes/data/ ${USERINPUT_NEXTCLOUDPATH}volumes/html/
   echo "Adding cronjob for nextcloud and letsencrypt"
   (sudo crontab -l ; echo "*/5 * * * * docker exec --user www-data nextcloud php -f cron.php >/dev/null 2>&1") | sudo crontab -
   (sudo crontab -l ; echo "55 5 1,15 * * certbot renew && systemctl restart apache2 >/dev/null 2>&1") | sudo crontab -
   fn_print_empty_line 2
   echo "*******************************"
   echo "Now you can continiue with the web installation:"
   echo "Enter a new user and a secure password."
   echo "This is going to be your own/first user and also have admin permissions"
   echo "(Tip: Avoid generic usernames like admin, root, etc..)"
   echo "*******************************"
   fn_print_empty_line 1
   echo "Click on mysql database, leave everything as it is and"
   echo "use following password: $GENERATED_PW_MYSQL"
   fn_print_empty_line 1
   echo "Then install (will take again some time before it finishes)"
   fn_print_empty_line 2
   echo $(redprint 'I strongly recommend NOT TO INSTALL the suggested apps!')
   echo "Because this configuration has its own collabora server which we shortly going to configure"
   echo "Installing it as app would take unneccessary resources (CPU, Space)"
   echo "(If you accidently installed the apps, don't worry you can remove it via the Webinterface/Apps)"
   fn_print_empty_line 3
   echo "Next two major things are, install the following two apps via the webinterface"
   echo "Talk, Nextcloud Office"
   fn_print_empty_line 1
   echo "*******************************"
   echo "Nextcloud Office:"
   echo "Select \"Use your own server\" and enter following url:"
   echo "https://$USERINPUT_COLLABORA_FQDN"
   echo "*******************************"
   fn_print_empty_line 3
   echo "*******************************"
   echo "Talk:"
   echo "stun server: $USERINPUT_NEXTCLOUD_FQDN:443"
   fn_print_empty_line 1
   echo "Turn server: turn und turns, $USERINPUT_NEXTCLOUD_FQDN:3478"
   echo "Coturn Secret: $GENERATED_PW_COTURN"
   echo "*******************************"
   fn_print_empty_line 2
   echo "In Settings, basic settings select Cronjob"
   fn_print_empty_line 2
   echo $(greenprint 'Nextcloud installed successfully')
   echo "Now you can try out if everything is working, add other apps, fine tune etc."
   echo "You can find all passwords and settings in the docker environment file:"
   echo "${USERINPUT_NEXTCLOUDPATH}.env"
   echo "Bye"
   fn_print_empty_line 2
}

fn_print_empty_line() {
   i=0
   while [ $i -lt $1 ]; do
      echo ""
      : $((i++))
   done
}

fn_countdown() {
   secs=$1
   while [ $secs -gt 0 ]; do
      echo -ne "$secs\033[0K\r"
      sleep 1
      : $((secs--))
   done
}

fn_password_generator() {
   tr </dev/urandom -dc '123456789abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ' | head -c32
   echo ""
}

fn_apt_autoremove_update_upgrade() {
   sudo apt autoremove -y
   sudo apt update
   sudo apt upgrade -y
}

fn_install_docker() {
   echo "installing..."
   sudo apt update
   sudo apt install ca-certificates curl gnupg lsb-release -y
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
   fn_apt_autoremove_update_upgrade
   sudo apt install docker-ce docker-ce-cli containerd.io -y
   sudo curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   echo "adding docker iptables mod"
   if grep -q "iptables=false" "/etc/default/docker"; then
      echo "DOCKER_OPTS=\"--iptables=false\"" | sudo tee -a /etc/default/docker
   fi
   echo "restart docker"
   sudo systemctl restart docker
   echo "done..."
}

fn_install_apache_certbot() {
   echo "Update Upgrade..."
   fn_apt_autoremove_update_upgrade
   echo "install apt install apache2 software-properties-common letsencrypt python3-certbot-apache"
   sudo apt install apache2 software-properties-common letsencrypt python3-certbot-apache -y
   echo "Enabling Modules.."
   sudo a2enmod ssl proxy proxy_http proxy_wstunnel rewrite headers remoteip
   echo "restarting apache2 service.."
   sudo systemctl restart apache2
   echo "done..."
}

fn_update_enable_ufw() {
   echo "adding ufw firewall rules"
   echo "add ssh rules"
   sudo ufw allow 'ssh'
   echo "add apache rules"
   sudo ufw allow 'Apache'
   echo "add http rules"
   sudo ufw allow 'http'
   echo "add https rules"
   sudo ufw allow 'https'
   echo "default allow outgoing"
   sudo ufw default allow outgoing
   echo "default deny incoming"
   sudo ufw default deny incoming
   echo "Enabling firewall..."
   sudo ufw enable
   echo "restarting ufw in case it was already enabled"
   sudo systemctl restart ufw
   echo "done..."
}

mainmenu
