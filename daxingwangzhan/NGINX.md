# NGINX

## NGINX基础

### 一、nginx优势

​	Nginx (engine x) 是一个高性能的HTTP(解决C10k的问题)和反向代理服务器，也是一个IMAP/POP3/SMTP服务器。

高并发、IO多路复用、epoll、异步、非阻塞

### 二、nginx安装部署

​	版本：Mainline version： 主线版，即开发版

​				Stable version： 最新稳定版，生产环境上建议使用的版本

​				Legacy versions： 遗留的老版本的稳定版

​	yum源：官网示范操作：Pre-Built Packages或者下载yum包

​	检查selinux和防火墙

​	nginx -V检测nginx版本及配置文件

### 三、nginx配置文件

​		rpm -ql nginx   --- 查看nginx所有文件

```shell
/etc/logrotate.d/nginx  #日志轮转
/etc/nginx/nginx.conf   #总配置文件
/etc/nginx/conf.d       # 子配置文件夹
/etc/nginx/conf.d/default.conf	# 默认的网站配置文件
/etc/nginx/fastcgi_params 		#动态网站模块文件-python，php所需的相关变量
/etc/nginx/koi-utf				#字符集，文件编码
/etc/nginx/mime.types   #文件关联程序-网站文件类型 和 相关处理程序
/etc/nginx/modules 		#模块文件夹。第三方模块

/etc/sysconfig/nginx
	# Configuration file for the nginx service.
	NGINX=/usr/sbin/nginx
	CONFFILE=/etc/nginx/nginx.conf

/etc/sysconfig/nginx-debug
	# Configuration file for the nginx-debug service.
	NGINX=/usr/sbin/nginx-debug
	CONFFILE=/etc/nginx/nginx.conf
	LOCKFILE=/var/lock/subsys/nginx-debug
	
/usr/lib/systemd/system/nginx-debug.service		#nginx调试程序启动脚本
/usr/lib/systemd/system/nginx.service systemctl  # 服务脚本。
/usr/sbin/nginx 		#主程序
/usr/sbin/nginx-debug	#nginx调试程序
/usr/share/doc/nginx-1.12.1 # 文档
/usr/share/man/man8/nginx.8.gz # man 手册
/usr/share/nginx/html/index.html # 默认主页

/var/cache/nginx  # 缓存各种
	 ls /var/cache/nginx/
	 	client_temp fastcgi_temp proxy_temp scgi_temp uwsgi_temp

/var/log/nginx  #日志文件夹
	ls /var/log/nginx/
		access.log error.log
		
/usr/lib64/nginx		#Nginx模块目录
```

### 四、基本配置

```shell
1、主配置文件
vim /etc/nginx/nginx.conf
#1）CoreModule 核心模块  (进程数等)
#2）EventsModule 事件驱动模块（工作模式等）
#3）HttpCoreModule        http内核模块（文档程序类型，配置文件等）

  1 user  nginx;						#运行nginx程序的独立账号
  2 worker_processes  1;				#启动的worker进程数量（与CPU数量一致或auto）
  3 
  4 error_log  /var/log/nginx/error.log warn; 	#错误日志存放位置
  5 pid        /var/run/nginx.pid;				#nginx运行的pid
  6 
  7 
  8 events {           			  				 #事件
  9     worker_connections  1024;					# //每个worker进程允许处理的最大连接数，例如10240，65535
  		use epoll; 					#事件驱动模型epoll【默认】
 10 }   
 11 
 12 
 13 http {
 14     include       /etc/nginx/mime.types;		#文档和程序的关联记录
 15     default_type  application/octet-stream;		#字节流处理方式
 16     
 17     log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
 18                       '$status $body_bytes_sent "$http_referer" '
 19                       '"$http_user_agent" "$http_x_forwarded_for"';
 20                        #日志格式，可自行定义
 21     access_log  /var/log/nginx/access.log  main;
 22     
 23     sendfile        on;#优化参数
    	#高效传输文件的模式：Nginx高级篇sendfile配置---sendfile: 设置为on表示启动高效传输文件的模式。sendfile可以让Nginx在传输文件时直接在磁盘和tcp socket之间传输数据。如果这个参数不开启，会先在用户空间（Nginx进程空间）申请一个buffer，用read函数把数据从磁盘读到cache，再从cache读取到用户空间的buffer，再用write函数把数据从用户空间的buffer写入到内核的buffer，最后到tcp socket。开启这个参数后可以让数据不用经过用户buffer。
 24     #tcp_nopush     on; 		#优化参数---也就是说tcp_nopush = on 会设置调用tcp_cork方法，这个也是默认的，结果就是数据包不会马上传送出去，等到数据包最大时，一次性的传输出去，这样有助于解决网络堵塞。
 25     
 26     keepalive_timeout  65; 		#优化参数---长连接
 27     
 28     #gzip  on;					#压缩参数
 29     
 30     include /etc/nginx/conf.d/*.conf;	#包含子配置文件夹--创建虚拟主机文件
 31 }   
```

```shell
2、默认虚拟主机配置
vim /etc/nginx/conf.d/default.conf 

  1 server {                			#默认网站配置文件
  2     listen       80;				#监听端口
  3     server_name  localhost;			#FQDN---域名
  4 
  5     #charset koi8-r;				#网页字符类型
  6     #access_log  /var/log/nginx/host.access.log  main; #日志
  7 
  8     location / {
  9         root   /usr/share/nginx/html; 	#主目录---网页代码存放目录
 10         index  index.html index.htm;	#默认主页名
 11     }
 12 
 13     #error_page  404              /404.html;	#错误页面
 14 
 15     # redirect server error pages to the static page /50x.html
 16     #
 17     error_page   500 502 503 504  /50x.html;	#错误页面
 18     location = /50x.html {						#错误页面
 19         root   /usr/share/nginx/html;			#错误页面主目录
 20     }
 21 
 22     # proxy the PHP scripts to Apache listening on 127.0.0.1:80 #代理设置
 23     #
 24     #location ~ \.php$ {
 25     #    proxy_pass   http://127.0.0.1;
 26     #}
 27 
 28     # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
 29     #
 30     #location ~ \.php$ {
 31     #    root           html;
 32     #    fastcgi_pass   127.0.0.1:9000;  		#动态网站设置
 33     #    fastcgi_index  index.php;
 34     #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
 35     #    include        fastcgi_params;
 36     #}
 37 
 38     # deny access to .htaccess files, if Apache's document root #访问控制部分
 39     # concurs with nginx's one
 40     #
 41     #location ~ /\.ht {
 42     #    deny  all;
 43     #}
 44 }
```

```shell
3、启动一个新的虚拟主机
	1）vim /etc/nginx/conf.d/xxxxx.conf    #名字不影响，一定加.conf
	2)
		server     {
		listen    80;
		server_name    xuleilinux.com;
		location / {
		root    /xuleilinux;
		index     index.html ;
				}
			}	
	3)  mkdir   /xuleilinux
		echo   xxxxx   >  /xuleilinux/index.html
	4）重启nginx
	5）windows域名解析
		C:\Windows\System32\drivers\etc\hosts
		添加域名解析
		
		#hosts文件不能保存---右键单击该文件，属性->安全->编辑（点击自己的当前用户后）->把写入权限勾起来。这样就可以了。该文件没有后缀。就叫hosts。
```

## 五、nginx 编译参数 --- nginx -V

```shell
nginx version: nginx/1.16.1               #版本号
built by gcc 4.8.5 20150623 (Red Hat 4.8.5-36) (GCC) 
built with OpenSSL 1.0.2k-fips  26 Jan 2017 
TLS SNI support enabled
configure arguments:			#配置参数./configure --help查询帮助
--prefix=/etc/nginx				#安装路径
--sbin-path=/usr/sbin/nginx		#主程序命令文件
--modules-path=/usr/lib64/nginx/modules  	#模块路径
--conf-path=/etc/nginx/nginx.conf 			#主配置文件
--error-log-path=/var/log/nginx/error.log 	#错误日志
--http-log-path=/var/log/nginx/access.log	#访问日志
--pid-path=/var/run/nginx.pid				#程序id
--lock-path=/var/run/nginx.lock 			#锁路径，防止重复启动nginx
--http-client-body-temp-path=/var/cache/nginx/client_temp 	#缓存
--http-proxy-temp-path=/var/cache/nginx/proxy_temp			#代理缓存
--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp 		#php缓存
--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp 		#python缓存
--http-scgi-temp-path=/var/cache/nginx/scgi_temp		
--user=nginx					#nginx用户
--group=nginx 					#用户组
--with-compat 					#启用动态模块兼容性
--with-file-aio 				#使用nginx的aio特性会大大提高性能，比如图片站的特点是大量的读io操作，nginx aio不用等待每次io的结果，有助于并发处理大量io和提高nginx处理效率。
#aio的优点就是能够同时提交多个io请求给内核，然后直接由内核的io调度算法去处理这些请求(directio)，这样的话，内核就有可能执行一些合并，节约了读取文件的处理时间。
#---就是异步非阻塞
--with-threads				#多线程模块
--with-http_addition_module 	#响应之前或者之后追加文本内容，比如想在站点底部追加一个js广告或者新增的css样式
--with-http_auth_request_module  	#认证模块
--with-http_dav_module				#增加上传PUT,DELETE,MKCOL:创建集合,COPY和MOVE方法)默认情况下为关闭
--with-http_flv_module				#NGINX 添加MP4、FLV视频支持模块
--with-http_gunzip_module 			# 压缩模块
--with-http_gzip_static_module
--with-http_mp4_module 				#多媒体模块
--with-http_random_index_module		#nginx显示随机首页模块
--with-http_realip_module 			#Nginx获取真实IP模块
--with-http_secure_link_module 		#Nginx安全下载模块
--with-http_slice_module 			#nginx中文文档
--with-http_ssl_module				# 安全模块
--with-http_stub_status_module 		#访问状态
--with-http_sub_module				#Nginx替换网站相应内容
--with-http_v2_module 
--with-mail							#邮件客户端
--with-mail_ssl_module
--with-stream 						#负载均衡模块。nginx从1.9.0开始，新增加了一个stream模块，用来实现四层协议的转发、代理或者负载均衡等。
--with-stream_realip_module
--with-stream_ssl_module 
--with-stream_ssl_preread_module
--with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic -fPIC' 				#CPU优化参数
--with-ld-opt='-Wl,-z,relro -Wl,-z,now -pie'  #CPU优化参数
```

```php+HTML
# 响应之前或者之后追加文本内容，比如想在站点底部追加一个js广告或者新增的css样式 
# nginx配置addition

 配置nginx.conf
server {
    listen       80;
    server_name  www.ttlsa.com;

    root /data/site/www.ttlsa.com;    

    location / {
        add_before_body /2013/10/header.html;
        add_after_body  /2013/10/footer.html;
    }
}


 测试
以下三个文件，对应请求的主体文件和add_before_body、add_after_body对应的内容
# cat /data/site/test.ttlsa.com/2013/10/20131001_add.html 
<html>
<head>
<title>I am title</title>
</head>
<body>
ngx_http_addition_module
</body>
</html>

# cat /data/site/test.ttlsa.com/2013/10/header.html 
I am header!

# cat /data/site/test.ttlsa.com/2013/10/footer.html 
footer - ttlsa

	

访问结果如下，可以看到20131001_add.html的顶部和底部分别嵌入了子请求header.html和footer的内容。
# curl test.ttlsa.com/2013/10/20131001_add.html           
I am header!
<html>
<head>
<title>I am title</title>
</head>
<body>
ngx_http_addition_module
</body>
</html>
footer - ttlsa
```

## 六、Nginx log日志

### 1、日志模块

```shell
ngx_http_log_module     #日志模块
log_format				#日志格式
access_log				#访问日志
error_log				#错误日志
open_log_file_cache		#日志缓存
```



### 2、日志指令

```shell
#了解

open_log_file_cache  max=N [inactive=time]  [mim_uses=N]  [valid=time]  | off

该指令默认是禁止的，等同于:
open_log_file_cache off;

open_log_file_cache 指令的各项参数说明如下:
max: 设置缓存中的最大文件描述符数量。如果超过设置的最大文件描述符数量，则采用  LRU (Least Recently Used) 算法清除"较不常使用的文件描述符"。  LRU (Least Recently Used) 算 法的基本概念是:当内存缓冲区剩余的可用空间不够时，缓冲区尽可能地先保留使用者最常使用 的数据，将最近未使用的数据移出内存，腾出空间来加载另外的数据。

inactive:  设置一个时间，如果在设置的时间内没有使用此文件描述符，则自动删除此描述符。 此参数为可选参数，默认的时间为 10 秒钟。

min_uses: 在参数 inactive 指定的时间范围内，如果日志文件超过被使用的次数，则将该日 志文件的描述符记入缓存。默认次数为 1。

valid: 设置多长时间检查一次，看一看变量指定的日志文件路径与文件名是否仍然存在。默 认时间为 60秒。
off: 禁止使用缓存。

open_log_file_cache  指令的设置示例如下:
open_log_file_cache  max=1000  inactive=20s  min_uses=2  valid=1m; 
```

### 3、日志格式和命令

```shell
#Nginx有非常灵活的日志记录模式。每个级别的配置可以有各自独立的访问日志。日志格式通过log_format命令定义。

#语法---name 表示格式名称---string 表示定义的格式
Syntax: log_format name [escape=default|json] string ...;

#默认值
Default: log_format combined "...";
log_format 有默认的无需设置的combined日志格式，相当于apache的combined日志格式

#Context: http     context ---- 环境
	#网站代理LB --- 例如代理服务器的日志格式就不同
		如果Nginx位于负载均衡器，squid，nginx反向代理之后，web服务器无法直接获取到客户端真实的IP地址。
$remote_addr获取的是反向代理的IP地址。反向代理服务器在转发请求的http头信息中，可以增加X-Forwarded-For信息，
用来记录客户端IP地址和客户端请求的服务器地址。
			nginx代理日志格式如下：
				log_format porxy '$http_x_forwarded_for - $remote_user [$time_local] ' ' "$request" $status $body_bytes_sent ' ' "$http_referer" "$http_user_agent" ';
				
#定义设置位置
	vim /etc/nginx/nginx.conf
	
	log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;	
```



```shell
#总有404提示

favicon.ico 文件是浏览器收藏网址时显示的图标，当第一次访问页面时，浏览器会自动发起请求获取页面的favicon.ico文件。当/favicon.ico文件不存在时，服务器会记录404日志。

    127.0.0.1 - - [26/Jul/2015:22:25:07 +0800] “GET /favicon.ico HTTP/1.1” 404 168 “-” “Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:36.0) Gecko/20100101 Firefox/36.0” “-”
    127.0.0.1 - - [26/Jul/2015:22:25:07 +0800] “GET /favicon.ico HTTP/1.1” 404 168 “-” “Mozilla/5.0 (Macintosh; Intel Mac OS X 10.10; rv:36.0) Gecko/20100101 Firefox/36.0” “-“


当一个站点没有设置favicon.ico时，access.log会记录了大量favicon.ico 404信息。

这样有两个缺点：
1.使access.log文件变大，记录很多没有用的数据。
2.因为大部分是favicon.ico 404信息，当要查看信息时，会影响搜寻效率。

解决方法如下：
在nginx的配置中加入

location = /favicon.ico {
  log_not_found off;
  access_log off;
}


以上配置说明：
location = /favicon.ico 表示当访问/favicon.ico时，
log_not_found off 关闭日志
access_log off 不记录在access.log

完整配置如下：

server {
  listen        80;
  server_name   fdipzone.com;
  root          /Users/fdipzone/home;

  access_log /var/log/nginx/access.log main;
  error_log /var/log/nginx/error.log debug;

  location = /favicon.ico {
    log_not_found off;
    access_log off;
  }

  location / {
    index  index.html index.htm index.php;
    include      /usr/local/etc/nginx/conf.d/php-fpm;
  }
}
```



### 4、访问日志和错误日志

```shell
access_log & error_log

#某条日志记录
192.168.100.254 - - [17/Dec/2017:14:45:59 +0800] "GET /nginx-logo.png HTTP/1.1" 200 368 "http://192.168.100.10/" "Mozilla/5.0 (Windows NT 6.1; WOW64; rv:57.0) Gecko/20100101 Firefox/57.0" "-"

 '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

192. 远程主机IP -   -用户  时间  get用户操作：获得下载，post提交   /nginx：访问资源的地址
HTTP/1.1:http版本  200：状态码  368：访问资源获取的大小（字节）  “http：// :引自哪个链接
 Mozilla：用户使用的浏览器版本，客户端系统类型   -：远程主机端IP地址  
```



```shell
#个性化404设置
1）修改主配置文件
server{

        error_page 404 /404.html;
            location = /404.html {
                root            /xuleilinux;
        }
}

2）systemctl restart nginx
3）vim /xuleilinux/404.html  #创建错误反馈页面
4）访问404页面
```



## 5、日志轮转/切割

```shell
#Nginx安装默认启动日志轮转
[root@mycat nginx]# rpm -ql nginx | grep log
/etc/logrotate.d/nginx
/var/log/nginx

#原理
进行日志轮转时，程序会将老的日志文件进行重命名，生成新的access.log，此时要重新启动程序，获取新的日志文件的pid，不然还会写入旧的日志文件。ls xxx -l -i  查看pid

#日志轮转配置文件
 vim /etc/logrotate.d/nginx 

/var/log/nginx/*.log {     			#待切割的日志
        daily		#切割频率
        missingok	#丢失不提示
        rotate 52	#保留份数
        compress	#压缩				
        delaycompress	#延迟压缩
        notifempty	#空文件不轮转
        create 640 nginx adm	#轮转后，创建新文件为权限640属主属组
        sharedscripts			#轮转后脚本
        size = 100M 	#达到100M轮转
        minsize 1M		#最小达到1M才轮转
        postrotate
                if [ -f /var/run/nginx.pid ]; then
                        kill -USR1 `cat /var/run/nginx.pid`
                fi
                #USR1亦通常被用来告知应用程序重载配置文件；例如，向Apache HTTP服务器发送一个USR1信号将导致以下步骤的发生：停止接受新的连接，等待当前连接停止，重新载入配置文件，重新打开日志文件，重启服务器，从而实现相对平滑的不关机的更改。
        endscript
}

#立即进行日志轮转操作
 /usr/sbin/logrotate -s /var/lib/logrotate/logrotate.status /etc/logrotate.conf
 
 
#切割原理
1、cron每小时唤醒一次anacron ---vim /etc/cron.hourly/0anacron access_log/error_log
2、anacrontab 以天、周、月循环 --- vim /etc/anacrontab access.log/error_log
3、天循环 --- vim /etc/cron.daily/logrotate access.log/error_log
4、anacron 当天的时间戳 --- vim /var/spool/anacron/cron.daily access.log/error_log
5、anacron 循环后的时间戳--- vim /var/lib/logrotate/logrotate.status access.log/error_log ---- 根据该时间确定是否轮转。
```



### 6、日志分析

结合shell和python语句



FD句柄

网址不一样，分开存放日志？？？？？

`反引号   优先引号内     2> 错误输出重定向   || 前面没干完 干后面



## 七、NginxWEB模块

### 1、连接状态

```shell
stub_status_module  #展示用户和nginx链接数量信息

nginx -V 2>&1 | grep stub_status #查询模块是否安装
	--with-http_stub_status_module

1、配置状态模块
	vim /etc/nginx/conf.d/default.conf 
		server{   			#写在server里面
		location /nginx_status{
		stub_status;
		allow all;
		}
		}
2、重启服务

3、访问默认站点状态模块---http://xxx.xxxx.xxxx.xxx/nginx_status

4、




​```






```

## 八、http协议





## 九、Nginx代理及缓存

### 1、代理

```shell
1、正向代理
	内网客户机通过代理访问互联网，通常要设置代理服务器地址及端口---squid

2、反向代理
	外网用户通过代理访问内网服务器---nginx反向代理

3、正反向代理的区别
	正向代理指的是内网用户为了访问外网资源，不能直接越过防火墙，只能通过正向代理服务器，由代理服务器代替自己访问网络资源，内网用户将要访问的资源请求发给代理，代理将请求发送出去，在代理收到响应时次将响应反馈给内网用户。
	反向代理指的是外网用户想访问内网的服务器，内网的服务器为了更高效的将自己的数据发送给客户机，在与客户机的连接之间增加了反向代理，客户机在访问资源时访问的其实是反向代理；如果代理有客户机想要的资源，代理会直接将自己的资源发送给客户机，如果没有代理会代替客户机向服务器发送请求，服务器响应发给代理，代理再将资源发给客户机，并将资源进行一定时间的保留，方便下次有用户访问时不用再次向服务器请求。----里面反向代理添加了缓存的功能。
	
	正向代理相当于所有内网客户机的代表，你想获取外边的数据？想要什么告诉我，我替你去寻找再告诉你。
	反向代理相当于所有内网服务器的代表，外边客户机想获取服务器的数据？想要什么找我，我有就给你，没有我替你去管服务器要。
```

### 2、反向代理

```shell
ngx_http_proxy_module

#语法

代理
Syntax: 	    proxy_pass URL;						代理的后端服务器URL
Default: 	—
Context: 	location, if in location, limit_except

缓冲区
Syntax:     proxy_buffering on | off;
Default:    proxy_buffering on;				缓冲开关
Context: 	http, server, location
proxy_buffering开启的情况下，nignx会把后端返回的内容先放到缓冲区当中，然后再返回给客户端
（边收边传，不是全部接收完再传给客户端)。

Syntax:   	proxy_buffer_size size;
Default: 	proxy_buffer_size 4k|8k;			缓冲区大小
Context: 	http, server, location

Syntax: 	    proxy_buffers number size;
Default: 	proxy_buffers 8 4k|8k;					缓冲区数量
Context: 	http, server, location

Syntax:    	proxy_busy_buffers_size size;
Default: 	proxy_busy_buffers_size 8k|16k;		忙碌的缓冲区大小，控制同时传递给客户端的buffer数量
Context: 	http, server, location

头信息
Syntax: 	    proxy_set_header field value;
Default: 	proxy_set_header Host $proxy_host;				设置真实客户端地址
                proxy_set_header Connection close;
Context: 	http, server, location

超时
Syntax: 	    proxy_connect_timeout time;
Default: 	proxy_connect_timeout 60s;					链接超时
Context: 	http, server, location

Syntax: 	    proxy_read_timeout time;
Default: 	proxy_read_timeout 60s;
Context: 	http, server, location

Syntax: 	    proxy_send_timeout time;nginx进程向fastcgi进程发送request的整个过程的超时时间
Default: 	proxy_send_timeout 60s;
Context: 	http, server, location


#buffer 工作原理

1. 所有的proxy buffer参数是作用到每一个请求的。每一个请求会安按照参数的配置获得自己的buffer。proxy buffer不是global而是per request的。

2. proxy_buffering 是为了开启response buffering of the proxied server，开启后proxy_buffers和proxy_busy_buffers_size参数才会起作用。

3. 无论proxy_buffering是否开启，proxy_buffer_size（main buffer）都是工作的，proxy_buffer_size所设置的buffer_size的作用是用来存储upstream端response的header。

4. 在proxy_buffering 开启的情况下，Nginx将会尽可能的读取所有的upstream端传输的数据到buffer，直到proxy_buffers设置的所有buffer们 被写满或者数据被读取完(EOF)。此时nginx开始向客户端传输数据，会同时传输这一整串buffer们。同时如果response的内容很大的 话，Nginx会接收并把他们写入到temp_file里去。大小由proxy_max_temp_file_size控制。如果busy的buffer 传输完了会从temp_file里面接着读数据，直到传输完毕。

5. 一旦proxy_buffers设置的buffer被写入，直到buffer里面的数据被完整的传输完（传输到客户端），这个buffer将会一直处 在busy状态，我们不能对这个buffer进行任何别的操作。所有处在busy状态的buffer size加起来不能超过proxy_busy_buffers_size，所以proxy_busy_buffers_size是用来控制同时传输到客户 端的buffer数量的。
```

### 3、Proxy缓存

```shell
ngx_http_proxy_module

#缓存类型
	#网页缓存 （公网）CDN、数据库缓存 memcache redis、网页缓存 nginx-proxy、客户端缓存 浏览器缓存
	#缓存机制，将客户机访问过的url进行哈希运算，将结果作为存储网页内容的唯一Key，存储在指定的缓存路径中，当客户机进行访问时，先进行哈希运算，匹配缓存内的Key，如果hit，将内容反馈给客户机，如果没有便向服务器请求，同时存储缓存信息。


#语法
缓存开关
Syntax: 	    proxy_cache zone | off;
Default: 	    proxy_cache off;
Context: 	http, server, location

代理缓存
Syntax: 	proxy_cache_path path [levels=levels] 			keys_zone=name:size[inactive=time] [max_size=size] 			[manager_files=number]
Default:  —
Context: http
example:proxy_cache_path /data/nginx/cache levels=1:2 keys_zone=one:10m;

缓存维度
Syntax: 	    proxy_cache_key string;  定义缓存唯一key,通过唯一key来进行hash存取，缓存文件名
Default: 	    proxy_cache_key $scheme$proxy_host$request_uri;
Context: 	http, server, location

缓存过期
Syntax: 	    proxy_cache_valid [code ...] time;
Default: 	    —
Context: 	http, server, location
proxy_cache_valid 200 302 10m;
proxy_cache_valid 404      1m;
```

### 4、配置Proxy代理和缓存

```shell
ngx_http_proxy_module

1、在主配置文件中添加缓存定义
  vim /etc/nginx/nginx.conf
	http{
	....
	proxy_cache_path /app/tianyun.me/cache（缓存存放路径） levels=1:2 keys_zone=proxy_cache（策略名称）:10m max_size=10g inactive=60m use_temp_path=off;
	#策略名称可自定义，与下面配置文件中策略名称对应
	
	}
2、在默认配置文件中设置代理及缓存
  vim /etc/nginx/conf.d/default.conf
		    location / {
		.....
#代理配置
		proxy_pass http://192.168.100.10:80; #代理的真实服务器
		proxy_redirect default;  #重定向，如果上方端口不是默认，向客户机反馈时反馈默认端口

		proxy_set_header Host $http_host;
		proxy_set_header   X-Real-IP $remote_addr;
		proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
#重写htpp地址，将真实的客户机地址和代理地址加入到http头部，日志第一位是代理，最后是客户机ip
		proxy_connect_timeout 30;  #面对客户机的计时器
		proxy_send_timeout 60;			#面对服务器的计时器
		proxy_read_timeout 60;       #面对服务器的计时器

		proxy_buffering on;  #缓冲区
		proxy_buffer_size 32k;	#缓冲区大小
		proxy_buffers 4 128k;
		proxy_busy_buffers_size 256k;
		proxy_max_temp_file_size 256k;
		
		
#缓存配置
		
		proxy_cache proxy_cacheee; #策略名称，与上方主配置文件一致
        proxy_cache_valid 200 304 12h;# proxy_cache_valid  200 206 304 301 302 12h; 对httpcode为200…的缓存12小时
        proxy_cache_valid any 10m;
        proxy_cache_key $host$uri$is_args$args;
        add_header Nginx-Cache "$upstream_cache_status";
proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504; #add_header：缓存命中情况如何在http头中体现---查看浏览器开发者模式可查看信息是hit还是miss，以及在nginx日志中查看---日志开始ip地址为代理ip，最后为客户机ip。		
    }

3、重启服务，进行访问观察，观察hit和miss
4、清楚缓存
	1）直接删除缓存文件
	2）通过ngx_cache_purge扩展模块清理,需要编译安装nginx
	
```



## 十、Nginx WEB架构

###  1、动态网站架构

资源文件识别---语言识别---框架识别

index.php---开源的php---Windows/Linux+nginx+php+mysql

index.py---开源python---Windows/Linux+apache+python+mysql

index.jsp---商业JAVA---windows/Linux+tomcat+JDK+Oracle

index.asp---商业c#（ see sharp ）---Windows+iis+asp.net+sql-server/oracle/mogodb



### 2、LNMP动态网站环境部署

```shell
1、关火关selinux
2、部署nginx、mysql
3、部署php
	yum install -y php-fpm php-mysql php-gd
		#php-fpm：php接收动态请求的程序
		#php-mysql:php链接mysql的程序
		#php-gd：图形库程序（GD库可以处理图片，或者生成图片）
	启动php-fpm服务
4、检测php服务是否可用
	netstat -anpt | grep 9000 #php使用9000端口
	
	vim /usr/share/nginx/html/index.php
		<?php
		phpinfo();
		?>
	#测试php页面（php基本信息）
5、增加php主页
	vim /etc/nginx/conf.d/default.conf 
		server {
		location / {
		...
		index index.php index.html;
		...
		}
		}
6、修改nginx主配置文件---启动nginx_fastcgi功能
	vim /etc/nginx/conf.d/default.conf 
		server {
		location ~ \.php$ {
		root /usr/share/nginx/html;
		fastcgi_pass 127.0.0.1:9000; #就用该地址，localhost等于127.0.0.1属于nginx将与php将与php相关的程序推送给指定ip的php来处理。是一个接口。
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
		}
		}
7、将相应php开发包放入默认网页目录内
```

### 3、fastcgi & php-fpm

```shell
1、静态网站
	nginx服务能处理的是静态元素 .html .jpg .mp4 .css
2、ngx_fastcgi_modul
	处理动态请求的接口，通过链接php-fpm处理动态请求。
3、PHP---php-fpm
	PHP-FPM(FastCGI Process Manager：FastCGI进程管理器)
是一个PHP FastCGI管理器。
PHP通过php-fpm接收前台nginx的动态访问的请求，比如向后端Mysql进行查询请求后，将查询结果返回给前台nginx。
4、PHP-MYSQL
	php连接mysql的接口程序
5、mysql

面试题：
1、什么是fastcgi
2、nginx+fastcgi运行的原理
3、LNMP的运行原理








```



~*  不区分大小写

！~*区分大小写

















