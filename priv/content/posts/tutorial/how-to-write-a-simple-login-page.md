---
title: "Write a Simple Login Page and Deploy it with Nginx"
date: 2020-11-29
desc: "用 HTML/CSS/JS 写一个简单的登陆界面并部署在服务器上"
tags: ["tutorial", "web", "html", "css", "jquery", "python", "flask", "nginx", "linux"]
---

最终实现的效果如下, 点[这里](http://logindemo.tunkshif.design) (~~网站还没备案, 可能上不去~~)可以体验.

![](https://i.loli.net/2020/11/29/OYVFNczXDg38dli.png)

![](https://i.loli.net/2020/11/29/onxdjUCXecNf472.png)

---

## 后端部分

服务端部署在一个 CentOS 的企鹅云上, 目前还是不太熟悉 Java Web 开发的那套东西, 用 Flask 简单实现了登录和注册这两个与数据库交互的接口, 数据库用了 MariaDB, 因为不知道为啥企鹅云的 CentOS 上没有 MySQL. 部署上采用了 Gunicorn 作为 HTTP Server, 使用 Nginx 进行反向代理.

![](https://i.loli.net/2020/11/29/N81cw4deoP5jqKu.png)

### 数据库的处理

首先在服务器上安装数据库, 先尝试了直接 `sudo yum install mysql`, 结果奇怪的是直接给我装了 `mariadb` 这个包, 尝试了下输入 `mysql` 命令但无解.

了解了下 MariaDB 是由 MySQL 的创始人创建的一个开源分支版本, 能够与 MySQL 兼容, 那就直接安装这个数据库好了.

搜了一下还需要安装 `mariadb-server` 这个包才行, 然后安装好后使用 `sudo systemctl start mariadb & sudo systemctl enable mariadb` 启用 server 服务, 之后可以用 `sudo systemctl status mariadb` 检查一下状态.

![](https://i.loli.net/2020/11/29/l8P31IaKztrmnoH.png)

然后接下来执行 `sudo mysql_secure_installation` 来进行初始化的配置, 比如设置 root 用户密码之类的.

接下来试图在本地连接一下服务端的数据库, 首先在企鹅云的控制台防火墙里把 3306 端口打开, 结果登录的时候出现了下面这样的错误

```
ERROR 1130 (00000): Host ''xxx.xx.xxx.xxx'' is not allowed to connect to this MySQL servers
```

查了一下原因好像是不能直接用 root 账户登录... 于是按照[这篇回答](https://stackoverflow.com/questions/1559955/host-xxx-xx-xxx-xxx-is-not-allowed-to-connect-to-this-mysql-server), 另外再新建了一个管理员账户

```
mysql> CREATE USER 'tunkshif'@'localhost' IDENTIFIED BY '<password>';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'tunkshif'@'localhost'
    ->     WITH GRANT OPTION;
mysql> CREATE USER 'tunkshif'@'%' IDENTIFIED BY '<password>';
mysql> GRANT ALL PRIVILEGES ON *.* TO 'tunkshif'@'%'
    ->     WITH GRANT OPTION;
```

之后用新创建的管理员账户登录就行了.

然后再新建一个名为 test 的数据库, 新建一张 users 表, 分别有三个字段: 作为主键的能够自增的 `user_id`, 存储用户名的 `user_name`, 存储密码的 `user_pwd`.

```sql
CREATE DATABASE test;
USE test;
CREATE TABLE IF NOT EXISTS `users`(
    `user_id` INT UNSIGNED AUTO_INCREMENT,
    `user_name` VARCHAR(20) NOT NULL,
    `user_pwd` VARCHAR(30) NOT NULL,
    PRIMARY KEY (`user_id`)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
```

然后数据库准备就差不多到这里结束了.

### Flask 后端编写

我们先在本地编写好后再上传到服务器, 首先新建一个虚拟环境, 安装需要的包

其中 `flask-cors` 是一个用来处理跨域请求问题的包, `mysql-connector-python` 提供了使用 python 操作数据库的接口, `gunicorn` 是一个 WSGI Server.

由于网络因素下载慢的话, 可以换用清华的镜像源, 临时使用的话只需要用 `pip install -i https://pypi.tuna.tsinghua.edu.cn/simple <package-name>` 就好了

```bash
mkdir login-demo && cd login-demo
python3 -m venv venv
source ./venv/bin/activate
pip3 install flask flask-cors mysql-connector-python gunicorn
```

然后我们的项目结构如下, `app` 包内的 `__init__.py` 文件里写 Flask 的路由部分, `config.py` 里写数据库的用户名密码什么的, `db_utils.py` 里具体写封装好的在登陆注册时会用到的对数据库进行操作的逻辑.

```
login-demo
├── app
│   ├── __init__.py
│   ├── config.py
│   └── db_utils.py
├── venv
│   ├── Include
│   ├── Lib
│   ├── Scripts
│   └── pyvenv.cfg
└── wsgi.py
```

`db_utils.py` 里具体实现了这样一些函数, `is_user_existing(username: str) -> bool` 判断用户名是否存在, `add_new_user(username: str, password: str) -> None` 用来向数据库里存储新的用户, `is_password_match(username: str, password: str) -> bool` 用来判断所提及的用户名和密码是否和数据库里面存的数据相匹配.

这里的添加用户函数里面没有预先对用户名已存在的情况进行判定, 具体判定写在了视图函数里面.

![](https://i.loli.net/2020/11/29/BnpjVyMqET4rcsf.png)

然后接下来的 `__init__.py` 里面开始具体写接口, 我们想实现的接口大致设计如下:

向 `http://xxx.xxx/api/login?username=xxx&password=xxx` 或者是 `http://xxx.xxx/api/signup?username=xxx&password=xxx` 发送 `GET/POST` 请求, 获得一个返回的 `json` 数据, 里面给出一个操作成功与否的状态码和具体的提示信息, 大概就像这样 `{ "code": 200, "msg": "Logged in successfully!" }`

所以具体写出来的 `__init__.py` 大概就像这样的

首先为了方便写了一个 `message()` 函数, 返回一个要作为相应的字典. (其实直接把这个函数写在跟路由一起好像不太好, 但再单独再起一个 `utils.py` 也不太好, 就随便写在这里算了...)

我们可以用 flask 提供的 `request.args` 来获取到用户调用 API 时传过来的参数, 再用 flask 提供的 `jsonify` 将字典转为 json 数据作为相应返回. 视图函数里面根据用户所参数的参数来作出相应.

(~~手动忽略下面那个默认的 Hello World.~~)

![](https://i.loli.net/2020/11/29/aDPG9gSQdEHVFRJ.png)

另外, 还要处理一下跨域的问题.

> 由于浏览器受同源策略的限制，在使用 `XMLHttpRequest` 对象进行跨域请求时，通常会报 `No 'Access-Control-Allow-Origin' header is present on the requested resource.` 的错误，导致请求失败。

直接用 `flask-cors` 这个库提供的 `cross_origin` 函数, 这是一个用在视图函数的装饰器.

写好了之后可以在本地运行测试一下.

## 前端部分

前端界面大致设计为一个居中的卡片样式的盒子, 里面放上标题, 表单, 按钮之类的. 另外还实现一个弹窗, 用于展示按下登录注册按钮后相应的消息. 登录注册之前先对表单中输入的用户名和密码进行验证, 然后发送 Ajax 请求给服务端, 再把返回过来的信息展示在弹窗上, 这里会用到 `JQuery` 来方便进行操作.

### 界面

界面的主体的 HTML 结构如下

```html
<div class="main">
  <div class="header">LOGIN</div>
  <form id="form" class="form">
    <input
      id="username-input"
      class="input"
      type="text"
      required
      placeholder="Username"
      name="username"
    />
    <input
      id="password-input"
      class="input"
      type="password"
      required
      placeholder="Password"
      name="password"
    />
  </form>
  <button id="login-button" class="button" onclick="login()">Login</button>
  <p class="link"><a href="signup.html">Not have an account yet?</a></p>
</div>
```

可能会比较关键的部分 CSS 如下

```css
.main {
  height: 450px; /* 指定高度 */
  width: 450px; /* 指定宽度 */
  margin: 8em auto; /* 通过设置 margin 来实现居中 */
  border-radius: 1.5em; /* 设置圆角 */
  /* offset-x | offset-y | blur-radius | spread-radius | color */
  box-shadow: 2px 2px 20px 2px rgba(0, 0, 0, 0.15); /* 设置阴影, 具体各项参数的含义见上方注释 */
}

.input {
  /* 其它与 .main 类似的属性不再说明*/
  outline: none; /* 隐藏输入框的 outline , 这个 outline 具体是啥看下面的图 */
}

.input:focus {
  /* 通过伪类设置输入框在聚焦的时候加深边框颜色 */
  border: 2px solid rgba(0, 0, 0, 0.5);
}
```

下面的左右两图分别是有无 outline 的情况下聚焦输入框的样式.

![](https://i.loli.net/2020/11/29/rmkyhJctdqjC9Y1.png)

另外是弹窗的实现, 用一个带有透明度的黑色的 `overlay` 覆盖住整个页面, 然后再在里面定义一个 `popup` 弹窗, 里面分别展示标题, 关闭按钮, 需要显示的消息. 然后整个 `overlay` 默认的 `display` 属性设置为 `none`, 等按下登陆或注册按钮后再显示.

```html
<div id="overlay" class="overlay">
  <div class="popup">
    <span id="title">TITLE</span>
    <a href="#" id="close-btn" onclick="$('#overlay').hide()">&times;</a>
    <div id="message">This is a message.</div>
  </div>
</div>
```

下面只展示比较关键的 `overlay` 和 `popup` 的样式

```css
.overlay {
  display: none; /* 默认不显示 */
  position: fixed; /* 将位置固定, 不会因其它元素变动 */
  z-index: 1; /* 设置固定元素的堆叠层级 */
  left: 0; /* 设置该元素的外边距到其所在的元素的距离为 0 */
  top: 0;
  width: 100%; /* 将该元素铺满整个页面 */
  height: 100%;
  overflow: auto; /*  对象内容超出指定宽高时出现滚动条 */
  background-color: rgba(0, 0, 0, 0.1); /* 设置颜色为带有透明度的黑色 */
}

.popup {
  width: 280px; /* 设置弹窗的宽高 */
  height: 150px;
  margin: 15% auto; /* 将弹窗居中 */
  background: #fafafa;
  border-radius: 1em;
}
```

### 逻辑

先写一个展示弹窗的函数, 将对应的元素改为传入的标题和消息, 然后将遮层展示出来. 相应的给关闭按钮绑定一个点击事件, 点击关闭按钮的时候将遮层隐藏, 这样就实现了一个~~简陋的伪~~弹窗.

```javascript
function showPopup(title, msg) {
  $("#title").text(title);
  $("#message").text(msg);
  $("#overlay").show();
}
```

在用户按下登录注册按钮, 完成提交请求之前, 先对表单内的用户名和密码进行验证.

下面用了~~从网上抄来的~~正则表达式来对用户名和密码进行检测, 用户名只能是大小写字母、短横线或是下划线, 长度必须在 3 ~ 20 之间, 密码至少必须含有大小写字母和数字, 且长度在 8 ~ 30 之间. 不符合要求的弹窗显示提示消息.

```javascript
function checkForm() {
  let userPattern = /^[a-zA-Z0-9_-]{3,20}$/;
  let pwdPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[^]{8,30}$/;
  let username = $("#username-input").val();
  let password = $("#password-input").val();

  if (!userPattern.test(username)) {
    showPopup(
      "Error",
      "User name can only be letters, dash or underline in 3 to 16 characters!"
    );
    return false;
  }
  if (!pwdPattern.test(password)) {
    showPopup(
      "Error",
      "Password must include both uppercase and lowercase letters and numbers with at least 8 characters!"
    );
    return false;
  }

  return true;
}
```

按下登录注册按钮后的事件函数逻辑相似, 只贴一个就行了.

首先对表单进行检查, 如果通过检查的话使用 Ajax 发送异步请求, 使用 `JQuery` 提供的 `ajax` 函数, 其参数是一个字典, 其中 `type` 指明请求类型, `dataType` 指明预期得到的返回数据的类型, `url` 指明目标请求链接, `success` 指明了一个请求成功后执行的回调函数, 其参数 `data` 即是返回过来的 `json` 数据.

这里的 `$("#form").serialize()` 方法是将表单中填入的数据序列化, 在写 HTML 的时候, 表单里的 `input` 元素有一个 `name` 的属性, 该方法会根据 `name` 属性的内容生成参数, 就像 `username=xxx&password=xxx` 这种格式的.

其实本来也可以直接在字典中用 `data` 来指定要传送的参数, 但试了下不知道为什么不行, 可能是因为 Flask 那里 `request.args` 的原因, 目前还是直接拼接 URL 算了.

```javascript
function login() {
  if (checkForm()) {
    $.ajax({
      type: "POST",
      dataType: "json",
      url:
        "http://logindemo.tunkshif.design/api/login?" + $("#form").serialize(),
      success: function (data) {
        showPopup("Info", data["msg"]);
      },
    });
  }
}
```

## 部署部分

### Gunicorn

网页的前后端部分都实现好了, 接下来要部署到服务器上了, 这一步反而是遇到的坑最多的地方 (=\_=||)

先配合 Nginx 部署 Flask 写的后端服务, 搜到了一篇[教程](https://medium.com/faun/deploy-flask-app-with-nginx-using-gunicorn-7fda4f50066a), 企鹅云里的这台 CentOS 也是基于 `systemed` 的发行版, 可以照着这篇教程做

先用 `scp` 把需要的文件传到服务器上, 接下来要用 service 的方式用 gunicorn 把 flask 项目跑起来, 需要编写一个 `systemed` Unit File.

```
sudo nvim /etc/systemd/system/logindemo-app.service
```

其中的 `After` 指明的是在网络服务启动完成后再启动该服务, `[Service]` 块里面, `User` 表示使用哪个用户来运行进程, 填入自己的用户名.

`Group` 这里按照描述是需要填写一个用户组的名称, 即 Nginx 运行所使用的用户组, 便于获取用户所有权进行通信, 但按照教程里面填写 `www-data` 后, 服务一直启动不起来, 查看日志提示的是该用户组不存在. 遂 `cat /etc/group` 发现的确没有 `www-data` 这个用户组. 搜索了解了一下这个用户组是干啥用的之后, 发现不同发行版这个用户组名可能不同, 有可能是 `www-data` 或者 `apache` 还有可能是 `nobody`, 看了下系统里有个 `nobody` 用户组, 填进去试了下还是跑不起来, 于是看了下 `ps aux` 发现 Nginx 是以 `nginx` 用户运行的...改成 `nginx` 之后就好了.

接着后面分别指定运行的环境, 和运行服务执行的命令等等. 注意这里我们的 Gunicorn 服务是运行在 5000 端口上的.

![](https://i.loli.net/2020/11/29/BPvYWVD9iUM1m2x.png)

写好后直接 `sudo systemctl start logindemo-app && sudo systemctl enable logindemo-app` 运行启动服务, 然后 `sudo systemctl status logindemo-app` 检查一下状态.

还可以再用 `curl` 请求测试一下, `curl http://localhost:5000/api/login?username=xxx&password=xxx`, 运行成功的话可以看到所返回的 json 数据.

### Nginx

接下来配置 Nginx, 安装过程就不再叙述, 只写一下配置的过程.

首先在网上搜出来的一些基于 Ubuntu 讲解的教程, 比如[这篇](https://medium.com/@jgefroh/a-guide-to-using-nginx-for-static-websites-d96a9d034940), 都会叫我们去 `/etc/nginx` 下面的 `sites-available` 和 `sites-enabled` 文件夹里面写配置, 这其实是为了将配置拆解开进行模块化, 但并不是所有的发行版安装来的 Nginx 都默认提供了这个给功能, 最开始配置 Nginx 的就坑在了这里...因为我用的 CentOS 里的 Nginx 默认根本不提供上面这套, 而是默认将不同的配置放在 `/etc/nginx/conf.d` 文件夹里面, 然后再在 `/etc/nginx/nginx.conf` 里面的 `http` 块里面加上 `include /etc/nginx/conf.d/*.conf`, 将自己单写的配置也包括进去.

另外注意在 `include` 语句之前加了一块 `server` 段, 表示默认访问都返回 403.

![](https://i.loli.net/2020/11/29/XyuePpj5fMY8hUJ.png)

然后开始准备写配置文件, 在之前如果有域名的话, 先去 DNS 管理里面添加一条让二级域名指向服务器公网 IP 的 A 记录, 下面将使用 `logindemo.tunkshif.design` 这个域名.

在 `/etc/nginx/conf.d` 路径里面新建一个 `logindemo.tunkshif.design.conf` 的配置文件, 同时将前端页面的所有静态资源文件放在 `/var/www/logindemo.tunkshif.design` 路径下.

服务器中的 gunicorn 服务是跑在 5000 端口上的, 而浏览器访问到的是 80 端口, 所以要实现在浏览器中通过 `logindemo.tunkshif.design` 域名能够访问到服务器上 5000 端口的服务

配置文件中的 `listen 80` 指的是监听 80 端口, `server_name` 指定域名, 表示只有通过该域名访问时该配置文件才生效, `root` 用来设置资源文件所在的根目录, `index` 指定首页, 即访问 `http://logindemo.tunkshif.design` 时展示的页面.

然后下面是两个用来匹配路径的 `location` 配置, 第一个 `location /api/` 表示通过 `http://logindemo.tunkshif.design/api/` 访问时走该条配置, 前面几行的 `set_proxy_header` 是按教程设置的请求头, 具体什么作用不清楚了... 最关键的是 `proxy_pass` 这一条配置, 表示把通过 `http://logindemo.tunkshif.design/api/` 的请求都转发到服务器的 5000 端口上, 也就是之前跑的那个 gunicorn 服务.

下面的 `location /` 匹配的是访问 HTML 页面, 即如果访问 `http://logindemo.tunkshif.design/xxx.xxx`, 会先从 `root` 指定的根目录里寻找 `xxx.xxx` 文件, 如果没找到再找有没有 `xxx.xxx/` 文件夹, 再没有的话就返回 404.

![](https://i.loli.net/2020/11/29/7jp2YeJUzMFnsxV.png)

配置好之后先运行 `sudo nginx -t` 检查下配置文件是否有错误, 没问题之后再用 `sudo systemctl restart nginx` 重启 Nginx 服务, 之后就可以在浏览器里面访问到部署好的页面辣.
