# Liveneeq techblog

Source code of [liveneeq's techblog](http://blog.liveneeq.com).

It's powered by [Jekyll](http://jekyllrb.com/).

## Running locally

Requirement:

* Ruby 2.0+
* Gems: `jekyll`, `redcarpet`

```shell
git clone https://github.com/onecampus/blog
cd blog

# use jekyll built-in server
jekyll serve

# build. You can then use any server to serve static files in _site directory
jekyll build

# build in production mode
JEKYLL_ENV=production jekyll build
```

For more usage of `jekyll`, refer to [Jekyll Documentation](http://jekyllrb.com/docs/home/).

## Write post

1. fork the repository
1. add your author info to `_data/authors.yml`
1. add a post file to `_posts`, names it like "2015-12-08-welcome-to-jekyll.md"
1. commit
1. create a pull request

See the former section if you want to preview the post.

### Author Info

Author info is saved in `_data/authors.yml`.

You must specify avatar, job, intro fields.

Optionally, you can specify your github, twitter, facebook, lofter, zhihu accounts.

__If you don't have any of these accounts, delete that field instead of leave it empty__

Add `author: name`(name is the key in `_data/authors.yml`) to the beginning of the post file to declare its author.

__Recommend: push your avatar image file to `blog/assets/avatars`__.


### Comments

[Disqus comment](https://disqus.com/) is integrated.

If you want to disable comments, add `disable_comments: true` to the beginning of the post file.

__Comments is only activated in production mode__.

### Tags

Add `tags: [tag1, tag2]` to the beginning of the post file.

You can have as many tags as you want.

### Category

Add `category: tech` to the beginning of the post file.

Any post should belong to one of the following categories: tech, design, product.

## Deploy

It will be automatically deployed after the master branch of [onecampus/blog](https://github.com/onecampus/blog) is updated.

The auto deployment makes use of [GitHub Webhooks](https://developer.github.com/webhooks/).
