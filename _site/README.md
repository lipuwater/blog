## Blog of liveneeq.com

This is the blog of liveneeq tech team. Powered by [jekyyl](http://jekyllrb.com/). Our blog address is [liveneeq-blog](http://onecampus.github.io/).

#### Usage

1. fork
2. clone
3. `gem install jekyll`
4. write post in `_posts` dir, the name like `2015-12-08-welcome-to-jekyll.markdown`
5. `jekyll serve -- trace`
6. pull request

#### Note

###### Comments

You can use [disqus comment plugin](https://disqus.com/) by add `comments: true` to post header.

###### Tags

You can use tags by add 'tags: [github, github-pages, jekyll]' to post header.

###### Category

You can use category by add `category: fake` to post header.

###### Demo post

```
---
layout: post
title:  "Welcome to Jekyll!"
date:   2015-12-08 14:40:42 +0800
category: fake
tags: [github, github-pages, jekyll]
comments: true
---

You’ll find this post in your `_posts` directory.

{% highlight ruby %}
def print_hi(name)
  puts "Hi, #{name}"
end
print_hi('Tom')
#=> prints 'Hi, Tom' to STDOUT.
{% endhighlight %}
```
