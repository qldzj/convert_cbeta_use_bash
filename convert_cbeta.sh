#!/bin/bash
allFiles() {
for pathfile in $1/*
do
if [ -d $pathfile ]; then
allFiles $pathfile
else
#echo $pathfile
# pathfile=/dev/shm/T10/T10n0279_079.xml
# beg=beg0106004

#songwit=#"$(cat $pathfile|grep witness|grep 宋|awk -F "\"" '{print($2)}')"
mingwit=#"$(cat $pathfile|grep witness|grep 明|awk -F "\"" '{print($2)}')"
yuanwit=#"$(cat $pathfile|grep witness|grep 元|awk -F "\"" '{print($2)}')"
if echo "$mingwit"|grep -q "wit";then
	if echo "$yuanwit"|grep -q "wit";then
cat $pathfile |grep -n '#beg'|grep -v type=\"cf1\"|grep -v choice|awk -F from '{print($2)}'|awk -F \" '{print($2)}'|awk -F '#' '{print($2)}' |awk ' !x[$0]++' >allbeg.txt
#排序cat $pathfile |grep -n '#beg'|grep -v type=\"cf1\"|grep -v choice|awk -F from '{print($2)}'|awk -F \" '{print($2)}'|awk -F '#' '{print($2)}'|sort -u>allbeg.txt
for beg in $(cat allbeg.txt)
	do
		#先替换ref方便后面获取正文  <g ref="#CB00626">
		for refline in $(cat $pathfile|grep -n \"\#CB|awk -F':' '{print($1)}')
			do
				#获取#CB
				cbnumber=$(cat $pathfile|sed -n "${refline}p"|sed 's/ref/\n/g'|awk -F"\"" '{print($2)}'|sed '1d')
				for n_cbnum in $cbnumber
					do
						sed -i "${refline}"s/"<g[ ]ref=\"${n_cbnum}\">"/"g_ref_start${n_cbnum}g_ref_midd"/ $pathfile
						#sed -i "${refline}"s/"g_ref_start${cbnumber}g_ref_midd"/"<g[ ]ref=\"${cbnumber}\">"/ $pathfile
						sed -i "${refline}"s/"<\/g>"/"g_ref_end"/ $pathfile
						#sed -in s/"g_ref_end"/"<\/g>"/ $pathfile
				done
			done
		yuanwit_tmp=false
		mingwit_tmp=false
		beg_to_end=$(echo $beg|sed s/beg/end/)
		beg_tmp_app=$(cat $pathfile|grep -n \#${beg}\")
		beg_tmp_txt=$(cat $pathfile|grep -n \"${beg}\")
		end_tmp_txt=$(cat $pathfile|grep -n \"${beg_to_end}\")
		line_for_beg_app=$(cat $pathfile|grep -n \#${beg}\"|grep "<app"|awk -F':' '{print($1)}')
		#line_for_end_app=$(cat $pathfile|grep -n \#${beg_to_end}\"|awk -F':' '{print($1)}')
		#获取n值
		beg_n=$(echo $beg|sed s/beg//)
		if $(echo $beg_n|grep -q "_");then
			#type="star"
			beg_n=star
		fi
		#获取所在行
		#txtforline=$(echo $beg_tmp_txt|awk -F':' '{print($1)}')
		#获取所在行
		txtforlinebeg=$(echo $beg_tmp_txt|awk -F':' '{print($1)}')
		txtforlineend=$(echo $end_tmp_txt|awk -F':' '{print($1)}')
		
		#获取beg_org内容
		#txtforbeg=$(echo $beg_tmp_txt| sed 's/\/>/\n/g'|awk -F ':' '{print($1)}'|awk -F '<' '{print($1)}'|grep -v '^$' |sed '1d'|head -n 1)
		if $(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F $beg_to_end '{print($1)}'|awk -F "xml:id" '{print($1)}'|awk -F $beg_n '{print($2)}'|grep -q inline);then
			#echo 第$txtforlinebeg行的$txtforbeg中间有inline
			txtforbeg=$(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F $beg_to_end '{print($1)}'|awk -F '>' '{print($3)}'|awk -F '<' '{print($1)}')
		else
			txtforbeg=$(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F $beg_to_end '{print($1)}'|awk -F '>' '{print($2)}'|awk -F '<' '{print($1)}')
		fi

		#获取wit内容
		if $(echo $beg_tmp_app|awk -F $beg '{print($2)}'|grep -q "/app");then
			txtforwit=$(echo $beg_tmp_app|sed 's/<rdg/\n/g'|tail -n 1|awk -F '>' '{print($2)}'|awk -F '<' '{print($1)}')
		else
			#如果app分行
			line_for_beg_app=$(echo `expr $line_for_beg_app + 1`)
			if [ $(cat $pathfile|head -n $line_for_beg_app|tail -n 1|awk -v RS="wit=" 'END {print --NR}')  -gt 0 ];then
				txtforwit=$(cat $pathfile|head -n $line_for_beg_app|tail -n 1|sed 's/<rdg/\n/g'|tail -n 1|awk -F '>' '{print($2)}'|awk -F '<' '{print($1)}')
			else
				echo "beg_app分了三行及以上，需确认"
				line_for_beg_app=$(echo `expr $line_for_beg_app + 1`)
				txtforwit=$(cat $pathfile|head -n $line_for_beg_app|tail -n 1|sed 's/<rdg/\n/g'|tail -n 1|awk -F '>' '{print($2)}'|awk -F '<' '{print($1)}')
			fi
		fi
		# if [ "$txtforwit" = "" ];then
		# 	txtforwit="EOF"
		# fi
		#判断是否有cjk扩展字体
		# if $(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F end '{print($1)}'|grep -q ref);then
		# 	echo $beg第$txtforlinebeg行有cjk扩展字体
		# 	
		# 	txtforbeg=$(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F end '{print($1)}'|awk -F '>' '{print($3)}'|awk -F '<' '{print($1)}')
		# else 
		#fi

		#获取wit值
		#wit_numb=$(echo $beg_tmp_app| sed 's/\/lem><rdg/\n/g'|wc|awk '{print($1)}')
		# if [ $(echo $beg_tmp_app|awk -F $beg '{print($2)}'|awk -v RS="<app" 'END {print --NR}')  -gt 0 ];then
		# 	echo "$pathfile $beg 校堪存在内app，需手动确认"
		# else
			if $(echo $beg_tmp_app|awk -F $beg '{print($2)}'|grep -q "/app");then
				truewit=$(echo $beg_tmp_app| sed 's/<\/lem>/\n/g'|tail -n 1|sed 's/<rdg/\n/g'|tail -n 1|awk -F wit= '{print($2)}'|awk -F \" '{print($2)}'|sed 's/ /\n/g' )
				#truewit=$(echo $beg_tmp_app|sed 's/<lem/\n/g'|awk -F"</lem>" '{print($2)}'|awk -F"wit=" '{print($2)}')
			else
				#如果app分行
				#line_for_beg_app=$(echo `expr $line_for_beg_app + 1`)\
				truewit=$(cat $pathfile| head -n $line_for_beg_app|tail -n 1|awk -F wit= '{print($2)}'|awk -F \" '{print($2)}'|sed 's/ /\n/g')
			fi
		# fi
		#根据wit值判断大藏经版本
		yuanwit_tmp=false
		mingwit_tmp=false
		for wittest in $truewit
			do
				if [ "$wittest" = "$yuanwit"  ];then
					yuanwit_tmp="true"
					#echo "$beg第$txtforlinebeg行的$txtforbeg元藏不同"
				fi
				if [ "$wittest" = "$mingwit"  ];then
					mingwit_tmp="true"
					#echo "$beg第$txtforlinebeg行的$txtforbeg明藏不同"
				fi
				# if [ "$wittest" = "#wit3"  ];then
				# 	wit3="true"
				# 	echo "$beg第$txtforlinebeg行的$txtforbeg宋藏不同"
				# fi
			done
			if [ "$yuanwit_tmp" == "true" ];then
				if [ "$mingwit_tmp" == "true" ];then

					numb_for_beg_cha=$(echo `expr $txtforlineend - $txtforlinebeg + 1 `)
					#echo "head取值numb_for_beg_cha=$numb_for_beg_cha\n"
					numbforend_todel=$(cat -n $pathfile|tail -n  +$txtforlinebeg| head -n $numb_for_beg_cha|awk '{print($1)}')
					#echo "$beg有$numb_for_beg_cha行内容"
					#echo "$beg需要删除的行数为$numbforend_todel"
						#txtforend_todel=$(echo $end_tmp_txt|awk -F $beg_to_end '{print($1)}'| sed 's/\/>/\n/g'|awk -F ':' '{print($1)}'|awk -F '<' '{print($1)}'|grep -v '^$' |sed '1d')
					#删除多余内容
					for line_del_be_start in $numbforend_todel
						do
							#echo 准备获取删除的内容
							if [ "$line_del_be_start" = "$txtforlinebeg" ];then
								#echo "head取值line_del_be_start=$line_del_be_start\n"
								txtforend_todel=$(cat $pathfile|head -n $line_del_be_start|tail -n 1|awk -F $beg '{print($2)}'|awk -F $beg_to_end '{print($1)}'|sed 's/>/\n/g'|awk -F '<' '{print($1)}'|awk '{print($1)}'|awk '{if($0!="")print}'|grep -v "\""|grep -v "$txtforbeg")
							else
								#echo "head取值line_del_be_start=$line_del_be_start\n"
								txtforend_todel=$(cat $pathfile|head -n $line_del_be_start|tail -n 1|awk -F $beg_to_end '{print($1)}'|sed 's/>/\n/g'|awk -F '<' '{print($1)}'|grep -v "\""|awk '{print($1)}'|awk '{if($0!="")print}')
							fi
							#echo "获取删除的内容结束,要删除的内容为$txtforend_todel"
							for del_beg_start in $txtforend_todel
							do
								#echo 准备删除$del_beg_start
								#echo "head取值line_del_be_start=$line_del_be_start\n"
								# if [ $(cat $pathfile|head -n $line_del_be_start|tail -n 1|awk -v RS=">${del_beg_start}" 'END {print --NR}')  -gt 1 ];then
								# 	echo  "$pathfile$beg第$del_be_start行有两个及以上的$del_beg_start待删除,需手动查看确认"
								# else
									del_tmp=$(echo $del_beg_start)
									#echo "开始删除$beg第$del_be_start行的$del_beg_start"
									sed -i "${line_del_be_start}"s/">$del_tmp"/">"/ $pathfile&&echo "$pathfile$beg第$del_be_start行的$del_beg_start删除"
								# fi
								#echo 删除$del_beg_start结束
							done
					done
					# #判断是否在同一行
					# if [ $txtforlineend = $txtforlinebeg ];then
					# 	echo $beg与$beg_to_end在同一行 > /dev/null
					# else
					# 	#echo $pathfile$beg与$beg_to_end不在同一行
						
					# #判断是否有两行相同内容
					# fi
					#替换
					if $(echo $beg_tmp_txt|awk -F $beg '{print($2)}'|awk -F $beg_to_end '{print($1)}'|awk -F "xml:id" '{print($1)}'|awk -F $beg_n '{print($2)}'|grep -q inline) ;then
							if [ $(echo $beg_tmp_txt |awk -v RS="inline\"/>${txtforbeg}" 'END {print --NR}')  -gt 1 ];then
							  echo "$pathfile$beg第$txtforlinebeg行的$txtforbeg有两个及以上相同带inline，需手动查看确认"
							else
								#echo 第$txtforlinebeg行的$txtforbeg有inline
								#echo "开始替换$beg第$txtforlinebeg行有inline的$txtforbeg"
								sed -i "${txtforlinebeg}"s/"\"inline\">${txtforbeg}"/"\"inline\">${txtforwit}"/ $pathfile&&echo "$beg第$txtforlinebeg行的$txtforbeg替换成$txtforwit"
							fi
					else
						if [ "${txtforbeg}" = "" ];then
							if [ "$beg_n" = "star" ];then
					  #echo "开始添加$beg第$txtforlinebeg行的$beg为空"
					  sed -i "${txtforlinebeg}"s/"\"$beg\"\ type=\"$beg_n\"\/>"/"\"$beg\"\ type=\"$beg_n\"\/>${txtforwit}"/ $pathfile&&echo "$beg第$txtforlinebeg行的$beg为空添加$txtforwit"
					  else
					  	#echo "开始添加$beg第$txtforlinebeg行的$beg为空"
					  	sed -i "${txtforlinebeg}"s/"\"$beg\"\ n=\"$beg_n\"\/>"/"\"$beg\"\ n=\"$beg_n\"\/>${txtforwit}"/ $pathfile&&echo "$beg第$txtforlinebeg行的$beg为空添加$txtforwit"
					  fi
							#txtforbeg="/><"
							#<anchor xml:id="beg_5e" type="star"/><anchor xml:id="end_5e"/>
							#<anchor xml:id="beg0023020" n="0023020"/>遊
							#<anchor xml:id="beg0053017" n="0053017"/>枙<anchor xml:id="end0053017"/>：欲<anchor xml:id="beg_b6" type="star"/>扼
						else
							if [ "$beg_n" = "star" ];then
								#echo "开始$beg第$txtforlinebeg行的$txtforbeg替换成$txtforwit"
								sed -i "${txtforlinebeg}"s/"\"$beg\"\ type=\"$beg_n\"\/>${txtforbeg}"/"\"$beg\"\ type=\"$beg_n\"\/>${txtforwit}"/ $pathfile&&echo "$beg第$txtforlinebeg行的$txtforbeg替换成$txtforwit"
							else
								#echo "开始$beg第$txtforlinebeg行的$txtforbeg替换成$txtforwit"
								sed -i "${txtforlinebeg}"s/"\"$beg\"\ n=\"$beg_n\"\/>${txtforbeg}"/"\"$beg\"\ n=\"$beg_n\"\/>${txtforwit}"/ $pathfile&&echo "$beg第$txtforlinebeg行的$txtforbeg替换成$txtforwit"
							fi
						fi
					fi
				fi
			fi
	done
	#CB还原
	#cb_reback_number=$(awk -v RS='#CB' 'END {print --NR}' $pathfile)
	for cb_reback_number in $(cat $pathfile|grep -n \#CB|sed 's/g_ref_midd/\n/g'|awk -F'g_ref_start' '{print($2)}'|awk '{if($0!="")print}')
		do
			#cb_reback_number
			sed -i s/"g_ref_start"/"<g ref=\""/ $pathfile
			sed -i s/"g_ref_midd"/"\">"/ $pathfile
			sed -i s/"g_ref_end"/"<\/g>"/ $pathfile
		done
fi
fi
fi
done
}

ls $HOME/Mytest/xml/>/dev/shm/ls.txt

for fider in $(cat /dev/shm/ls.txt)
do
	cp -r $HOME/Mytest/xml/$fider /dev/shm/
	testdir=/dev/shm/$fider
	allFiles $testdir
	mv /dev/shm/$fider $HOME/cbeta_python_3.6_ok/xml/
done
