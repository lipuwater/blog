## Blog of liveneeq tech team

This is the blog of liveneeq tech team. Powered by [jekyyl](http://jekyllrb.com/). Our blog url is http://blog.liveneeq.com/

#### Usage

1. fork
2. clone
3. `gem install jekyll redcarpet`
4. write your info in `_data/authors.yml`
5. write post in `_posts` dir, the name like `2015-12-08-welcome-to-jekyll.markdown`
6. `jekyll serve --trace`
7. pull request

#### Note

###### Comments

You can use [disqus comment plugin](https://disqus.com/) by add `comments: true` to post header.

###### Tags

You can use tags by add `tags: [github, github-pages, jekyll]` to post header.

###### Category

You can use category by add `category: fake` to post header.
Note: there are only three categories now. They are `tech`, `design` and `product`.

###### Author

You can use author info by add `author: flowerwrong` to post header.

###### Demo post

```
---
layout: post
title: "Simple ruby-ffi Demo"
date: 2015-12-08 14:40:42 +0800
category: tech
tags: [ruby, ruby-ffi, c, ffi]
comments: true
author: flowerwrong
---

You’ll find this post in your `_posts` directory.

def bye_bye(name)
  p "Bye bye, #{name}"
end
```

#### Deploy

It will auto deploy after you `push` commit by use with github api see [github_webhook](https://github.com/onecampus/blog/blob/master/github_webhook.rb) for more info.
