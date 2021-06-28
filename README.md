# 安装及使用说明

本网盘系统运行在Windows 10 x64操作系统上。

本系统的IDE是VS Code 1.50.1，安装的扩展有`golang.go`和 `octref.vetur`。

### 网盘系统启动前的准备工作

本系统需要浏览器支持Web Assembly技术和dialog标签，经测试Firefox 87+（需将高级首选项中的dom.dialog_element.enabled设为true）和Chrome 69+的版本支持上述特性。

在安装本系统之前，操作系统需要安装以下软件：

- Node.js 10+

- MySQL 8.0.13+
- nginx 1.18.0+
- 7-Zip 1900+

建议安装的软件：

- Git for  Windows 2.16+
- Navicat 12




#### 准备数据库环境（系统运行必完成的步骤）

本系统使用的数据库名为`panmy`，在数据库管理软件（如navicat）上运行位于 ` db`  下的`db.sql`文件，运行成功后，参考下面的章节运行网盘系统的各个部分。

#### 测试用证书和域名

建议申请一个域名，以供测试使用。



### 使用PeerServer

1. 安装：

  
   ```
   npm install peer -g
   ```


2. 运行服务：

   ```
   peerjs --port 18080 --key peerjs --host 你的域名 --path /panmy --allow_discovery --sslkey 你的私钥文件地址 --sslcert 你的公钥文件地址
   ```



### 使用nginx

1. 修改nginx配置文件：

   修改nginx安装文件夹中`conf`文件夹内的`nginx.conf`文件，添加如下的`server`节点并填写相关内容。项目前端代码包括[panmy_frontend](https://github.com/tang5468484/panmy_frontend)和[panmy_mychat_frontend](https://github.com/tang5468484/panmy_mychat_frontend)。

   ```
   http {   
   	#......
       # HTTPS server
       server {
           listen       [::]:443 ssl;
           server_name  你的域名。;
   
           ssl_certificate      你的公钥文件路径;
           ssl_certificate_key  你的私钥文件路径;
   
           ssl_session_cache    shared:SSL:1m;
           ssl_session_timeout  5m;
   
           ssl_ciphers  HIGH:!aNULL:!MD5;
           ssl_prefer_server_ciphers  on;
   
           location / {
              root   网盘项目路径，例：路径/前端编译后代码;
              index  index.html index.htm;
           }
           location /mychat/ {
               root   文件互传项目路径，例：路径/前端编译后代码/;
               index  index.html index.htm;
           }
       }
   	#......
   }
   ```

2. 运行nginx：

   ```
   cd nginx安装目录
   nginx.exe
   ```

#### 其他nginx命令

- 停止运行nginx：

  ```
  cd nginx安装目录
  nginx.exe -s quit
  ```



### 使用MinIO

1. 运行MinIO：

```
minio.exe server 证书目录的绝对路径 MinIO网盘文件存储目录的绝对路径
```

2. 在浏览器中打开`https://你的域名:9000/minio/login`，输入账号名和密码（默认均为minioadmin），登录上去后，创建存储桶，存储桶名称在配置后台服务器时会用到。

### 使用网盘后台API服务器

1. 配置后台API服务器

   + 打开[panmy_backend](https://github.com/tang5468484/panmy_backend)下的`conf.json`文件配置相关信息

     ```json
     {
         "dbconf":{
             "dbusername":"数据库用户名",
             "dbpwd":"数据库用户密码",
             "dbname":"数据库名",
             "dburl":"数据库连接主机名和端口号。例：localhost:3306"
         },
         "minioconf":{
             "endpoint":"MinIO连接点。例：127.0.0.1:9000",
             "sslendpoint":"启用HTTPS的连接点，格式：域名:端口号",
             "accesskeyid":"MinIO账户ID。例：minioadmin",
             "secretaccesskey":"MinIO账户密码。例：minioadmin"
         },
         "panconf":{
             "miniopath":"MinIO网盘文件存储目录路径（包含存储桶名称）",
             "win_platform_copy":"移植到Win平台的Linux中的cp命令，例如Git for Windows中包含的cp程序",
             "win_platform_zip":["7zip的命令行版本。例：7z.exe", "a"],
             "sslcert":"公钥路径。例：cert/public.cer",
             "sslkey":"私钥路径。例：cert/private.key",
             "bucketname":"存储桶名称"
     
         }
     }
     ```


2. 运行后台API服务器

   `-s`参数表示启用HTTPS。

   ```
   cd 后台API服务器软件安装目录
   minigo.exe -s
   ```

### 打开网盘系统界面

上述步骤完成后，打开浏览器，在地址栏中输入 `https://你的域名` 打开网盘系统的前端界面，输入用户名和密码登录。数据库脚本中提供三个测试账户：

| 用户名 | 密码            | 角色     |
| ------ | --------------- | -------- |
| faye   | 123123          | 管理员   |
| wang   | 7w5NCeWa9TvK6aN | 普通用户 |
| eva    | 123456          | 普通用户 |

