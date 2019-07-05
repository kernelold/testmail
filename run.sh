#!/bin/bash

DIR=`ls /var/www/rainloop/data/_data_* -d`
for i in $(cat /etc/postfix/virtual-mailbox-domains);
 do echo "\
imap_host = \"$i\"
imap_port = 143
imap_secure = \"TLS\"
smtp_host = \"$i\"
smtp_port = 587
smtp_secure = \"TLS\"
smtp_auth = On" > $DIR/_default_/domains/$i.ini;
done;
for domain in $(  cat /etc/postfix/virtual-mailbox-domains) ; do grep $domain /etc/hosts || echo "$(grep  $(hostname)  /etc/hosts | awk '{print $1}') $domain " >> /etc/hosts ; done

StartPostfix ()
{
    echo "=> Adding the following credentials $SASLUSER:$SASLPASS"
    echo "=> Log Key: $LOG_TOKEN"
    #$allow_networks = "";
}


# output logs to logentries.com
cat <<EOF > /etc/rsyslog.d/logentries.conf
\$template Logentries,"$LOG_TOKEN %HOSTNAME% %syslogtag%%msg%\n"
EOF


# configure things
/configure.sh

# start necessary services for operation (dovecot -F starts dovecot in the foreground to prevent container exit)
chown -R vmail:vmail /srv/vmail

# Display Postfix credentials for build testing
#
StartPostfix


# Spin everything up
#
/usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
