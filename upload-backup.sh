#!/bin/sh

# パラメータの設定
# リモートホスト名（送信先）
rhostname=''
# リモートホストユーザ名（送信先のユーザ）
ruser=''
#リモートホストパスワード（送信先のユーザのパスワード）
rpasswd=*****
# メール送信先のアカウント名
mailuser=tuser
mailsubject="Notice of log backup v1"
# メール本文の初期化
mailmsg=""
#--------------------------------------
# [tar]コマンドで[var/log]のバックアップファイルを作成 バックアップファイルのパス　workspace/send_backup/

# [/var]ディレクトリに移動
cd /var
# 当日の年月日情報を取得し、結果を表示
cdate=`date +"%Y%m%d"`
echo "Today is $cdate."
# ログディレクトリを(tar)で圧縮してバックアップし、結果をlsで表示
backuppath="/workspace/send_backup"

tar cf "$backuppath/$cdate.tar" log
echo "A log backup file is created. Please confirm the following list."
ls -l -u /workspace/send_backup/${cdate}*

cd /workspace/send_backup
# バックアップファイルをリモートホストに転送し、結果を[backup.log]に保存
`scp ${cdate}_log.tar.bz2 ${ruser}@${rhostname}:~/receive_backup/` && `echo "${cdate}_log.tar.bz2 is transported 100%" > /workspace/send_backup/backup.log`
#--------------------------------------
# [mail]コマンドで、処理結果をメールで送信する
# 送信情報を確認
	sendmsg=`grep -i -o -n "100%" /workspace/send_backup/backup.log`
	if [ "${sendmsg}" != "" ]; then
	    # 送信率が[100%]であれば、バックアップが成功したメールを送信
	    mailmsg="The log backup file transfer was successful. The file name is ${cdate}_log.tar.bz2 ."
	else
    	mailmsg="An unexpected error has occurred."
    fi
	    # 送信率が[100%]ではない場合は、予期せぬエラーが発生したメールを送信
# 実行結果をメールで送信
echo "${cdate}, ${mailmsg}" | mail -s "${cdate}_${mailsubject}" "${mailuser}"
echo "An email is sent to ${mailuser}. The file name is ${cdate}_log.tar.bz2 ."
