#! /bin/bash

############################
# DB optimizer for RSYSLOG #
############################


DBUSER="dbuser"
DBPASS="dbpass"
log="/your_dir/db_clear.log"


mysql -u $dbuser -p$dbpass -D Syslog -e "DELETE FROM SystemEvents WHERE ReceivedAt < (DATE_SUB(NOW(), INTERVAL 90 DAY))";
systemctl stop rsyslog.service
sleep 10
start_time=$(date)
used_before=$(du -sm /var/lib/mysql | awk '{print$1}')
echo "!!!!! START $start_time START !!!!!" > $log
echo -e "----- USED MEMO BEFORE - $used_before Mb -----\n+++++ start OPTIMIZE +++++" >> $log
mysqlcheck -u $dbuser -p$dbpass --all-databases -o >> $log
#echo "+++++ start REPAIR +++++" >> $log
#mysqlcheck -u $dbuser -p$dbpass --all-databases --auto-repair >> $log
sleep 10
systemctl start rsyslog.service
used_after=$(du -sm /var/lib/mysql | awk '{print$1}')
echo "----- USED MEMO AFTER - $used_after Mb -----" >> $log
cleared_memo=$(($used_before - $used_after))
end_time=$(date)
echo -e "!!!!! END $end_time END !!!!!\n===== $cleared_memo Mb CLEARED =====" >> $log
exit 0
