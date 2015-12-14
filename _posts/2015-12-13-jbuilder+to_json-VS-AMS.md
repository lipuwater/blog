---
title: "jbuilder + to_json VS AMS"
date: 2015-12-13
category: tech
tags: [ruby, rails, to_json, jbuilder, AMS]
author: flowerwrong
---

我们在使用 [rails](https://github.com/rails/rails) 写`api`的时候，rails本身支持多种返回格式，常用的就是`XML`和`JSON`，今天讨论的话题就是返回的`JSON`格式数据的组装问题。
一直以来我都喜欢`jbuilder`的方式，它更符合`MVC`的思想，至少是形式上的，`jbuilder`文件放在了`views`目录下，使用简单。但这些都不足以让我坚持使用它，更重要的是它自定义格式的功能，
这一点在[AMS](https://github.com/rails-api/active_model_serializers)中也能办到，但却并非自然用法。

无论是`jbuilder`还是`AMS`，面对简单model的时候我仍然觉得麻烦，通常我懒到不想写`view`，直接在控制器里面返回，渲染的工作交给控制器去完成。这个时候`to_json`就成了我的最爱。
当然，它适用于简单的数据格式，例如单modle或者简单的relation，复杂的还是得交给 `jbuilder` 来完成。

怎样选择按照个人爱好，我更推荐 `jbuilder` + `to_json` 的方式。希望你也能喜欢。

## [to_json](http://apidock.com/rails/ActiveRecord/Serialization/to_json)

rails 的 `ActiveModel` 还提供了[as_json](http://apidock.com/rails/ActiveModel/Serializers/JSON/as_json) 方法，使用类似`to_json`.

### 用法1------临时组装

```ruby
# posts_controller.rb
ActiveRecord::Base.include_root_in_json = false # 配置，可考虑设置全局
posts = Post.all
render json: posts.to_json(only: [ :id, :title ])
# render json: posts.to_json(except: [ :created_at, :updated_at ])
# render json: posts.to_json(include: :comments)
```

### 用法2------覆盖model里面的`to_json`方法

```ruby
class Post < ActiveRecord::Base
  def as_json(options)
    super({only: [:id, :title]}.merge(options))
  end
end
```

## [jbuilder](https://github.com/rails/jbuilder)

```ruby
# app/views/message/show.json.jbuilder

json.content format_content(@message.content)
json.(@message, :created_at, :updated_at)

json.author do
  json.name @message.creator.name.familiar
  json.email_address @message.creator.email_address_with_name
  json.url url_for(@message.creator, format: :json)
end

if current_user.admin?
  json.visitors calculate_visitors(@message)
end

json.comments @message.comments, :content, :created_at

json.attachments @message.attachments do |attachment|
  json.filename attachment.filename
  json.url url_for(attachment)
end
```

## [AMS](https://github.com/rails-api/active_model_serializers)

```ruby
class CommentSerializer < ActiveModel::Serializer
  attributes :name, :body

  belongs_to :post
end
```
