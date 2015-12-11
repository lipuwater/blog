---
layout: post
title: "Finding one's Github own repositories which are self-starred"
date: 2015-12-10
category: tech
tags: [python, web_crawling]
comments: true
author: nekocode
avatar: 'https://avatars1.githubusercontent.com/u/4783781?v=3&s=460'
---


## 前言
Python 一向是 Web Crawling 实践中比较热门的语言，这次我们尝试使用 **BeautifulSoup** 以及 **requests** 库来捕获某个 Github Account 下 Star 自己 Repo 的行为。

## 原理
请求某个 Github 账户的 Starred Repositories 页面，通过 BeautifulSoup 解析网页，并通过 **CSS Selector** 语法来定位页面中的 `repo` 元素，分析出所有是用户自身 Star 的仓库。

## TODO
- [ ] 多线程加速

## Usage
```
python2 finding_self_starred.py ACCOUNT_NAME
```

## 实现
```
#!/usr/bin/python
# -*- coding: utf-8 -*-
import argparse
import requests
from bs4 import BeautifulSoup
__author__ = 'nekocode'

BASE_URL = 'https://github.com'
STARRED_URL = BASE_URL + '/stars/%s'
UA = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'
HEADERS = {"User-Agent": UA}


def get_self_starred_repos(account):
    url = STARRED_URL % account
    repos = []

    while True:
        req = requests.get(url, headers=HEADERS, timeout=20)
        req.encoding = 'utf-8'
        soup = BeautifulSoup(req.text, "html.parser")

        repo_list = soup.select('.repo-list-item')
        for item in repo_list:
            repo_master = item.select('.repo-list-name .prefix')[0].text

            if account == repo_master:
                repo = dict()
                repo['name'] = "".join(item.select('.repo-list-name a')[0].text.split())
                repo['url'] = BASE_URL + item.select('.repo-list-name a')[0]['href']
                descs = item.select('.repo-list-description')
                if len(descs) > 0:
                    repo['description'] = descs[0].text.strip()
                else:
                    repo['description'] = 'No description.'
                repos.append(repo)

                print '=' * 30
                print repo['name'] + '\n' + repo['description'] + '\n' + repo['url']
                print '=' * 30 + '\n\n'

        paginations = soup.select('.pagination a')
        if len(paginations) == 0:
            break

        has_next = False
        for pagination in paginations:
            if pagination.text == 'Next':
                # 翻页
                url = pagination['href']
                has_next = True

        if not has_next:
                break

    return repos


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('account', help="Finding one's own repositories which are self-starred.", type=str)
    name = parser.parse_args().account
    get_self_starred_repos(name)
```