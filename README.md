== 生成省市区JSON的工具

感谢  https://github.com/crazyandcoder/citypicker  这个项目．
作者 crazyandcoder 问我生成　省市区 json 的方法，所以有了本项目．

# 安装

这是个最典型的rails项目，需要：

1. 安装ruby, 使用rbenv 安装

2. 安装bundler :

```
$ gem install bundler
```

(以上两个过程，可以来这里查看详细： http://web.siwei.me/part3_rails_premier/ruby_premier.html)


3. 安装MySQL 5.0
4. clone 本项目
5. 安装全套gem:

```
$ cd area_generator
$ bundle install
```
6. 建立数据库(可以修改config/database.yml　文件中的数据库名字)：

```
$ bundle exec rake db:create
```

7. 导入地区数据

```
$ mysql -u root area_generator

mysql > source province_and_city.sql;
```

8. 运行rails:

```
$ bundle exec rails server
```

9. 打开浏览器即可：

```
http://localhost:3000/interface/areas/area_data
```

建议浏览器端安装：  jsonview, chrome插件．

## 修改文件的说明

核心的文件是　app/controllers/interface/areas_controller.rb

直接修改里面即可．

app/model/province.rb 　对应了　provinces 表
app/model/city.rb 　对应了　cities 表
app/model/town.rb 　对应了　towns 表


