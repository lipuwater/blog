# Lipuwater techblog

[![Travis CI](https://travis-ci.org/onecampus/blog.svg)](https://travis-ci.org/onecampus/blog)

Source code of [lipuwater's techblog](http://blog.lipuwater.com).

It's powered by [Jekyll](http://jekyllrb.com/).

## Running locally

Requirement:

* Ruby 2.4+
* Bundler: 1.16+

```shell
git clone git@github.com:lipuwater/blog.git
cd blog

# install dependencies
bundle install

# use jekyll built-in server
jekyll serve

# build. You can then use any server to serve static files in _site directory
jekyll build

# build in production mode
JEKYLL_ENV=production jekyll build

# validate generated html files
bundle exec htmlproof ./_site --empty-alt-ignore --disable-external
```

For more usage of `jekyll`, refer to [Jekyll Documentation](http://jekyllrb.com/docs/home/).

## Write post

1. Fork the repository, and create a personal branch based on upstream/master (upstream here means liveneeq's official repository) to work on
1. Add your author info to `_data/authors.yml`
1. Add a post file to `_posts`, names it like "2015-12-08-welcome-to-jekyll.md"
1. Commit and push to your repository
1. Create a pull request to upstream/master
1. (Optional) Delete the personal branch after your pull request is accepted

__Note:__

* Only fast-forward mergable pull requests should be accepted, so [rebase](https://git-scm.com/book/en/v2/Git-Branching-Rebasing) may be needed
* Squashing your commits before creating a pull request is strongly encouraged
* Every pull request will be automatically tested by [Travis-CI](https://travis-ci.org). Of course failed pull requests won't be accepted

Whenever upstream/master is updated, the blog will be automatically deployed, and you can see your post in the [blog site](http://blog.liveneeq.com).

See the former section if you want to test or preview your post locally.

### Author Info

Author info is saved in `_data/authors.yml`.

You must specify avatar, job, intro fields.

Optionally, you can specify your github, twitter, facebook, lofter, zhihu accounts.

__If you don't have any of these accounts, delete that field instead of leave it empty__

Add `author: name`(name is the key in `_data/authors.yml`) to the beginning of the post file to declare its author.

For security and availability reasons, it is recommended to save your avatar in `assets/avatars` instead of using foreign resource.

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

### Content

Write your post content with [Github Flavored Markdown](https://help.github.com/articles/github-flavored-markdown/).

If you need to use images or other assets, save then in assets/. Create sub-directory if necessary.
