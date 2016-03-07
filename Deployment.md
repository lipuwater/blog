# Deployment Configuration

Use [Travis-CI](https://travis-ci.org) to automatically test and deploy.

## How it work

With Travis-CI integrated, GitHub will notify Travis-CI when some events (new commit, new pull request, etc) occur.

Then Travis-CI will fetch the repository and execute some tasks specified in the repo's `.travis.yml` file, like test, build, and deploy.

As for deploy, we tell Travis-CI to use `rsync` to sync builded files to our blog server.

## Configurations

### Integrate Travis-CI

* Sign in Travis-CI with a GitHub account that has admin privilege of the repository

* And switch on this repository on [Travis-CI Profile](https://travis-ci.org/profile) page

* Add a `.travis.yml` file to the repo's root directory

### Server Configuration

For `rsync` to work, we should create a new user on the server and generate a pair of SSH key for Travis-CI.

Execute the following commands on the blog server (run as root, or you may need `sudo` privilege):

```
# change these variables as needed
deploy_user=deploy_user_name
deploy_dir=/path/to/deploy
nginx_user=nginx
nginx_group=nginx

mkdir $deploy_dir
chown $nginx_user:$nginx_group $deploy_dir

# use setgid to keep new files added by $deploy_user under $nginx_group group, thus readable by nginx
# $deploy_user should be in group $nginx_group
useradd -m -G $nginx_group $deploy_user
chmod 2775 $deploy_dir

mkdir /home/$deploy_user/.ssh
touch /home/$deploy_user/.ssh/authorized_keys
chown -R $deploy_user: /home/$deploy_user/.ssh
chmod 700 /home/$deploy_user/.ssh
chmod 600 /home/$deploy_user/.ssh/authorized_keys
```

Generate a pair of SSH key locally:

```
ssh-keygen -t rsa -C 'travis@blog.liveneeq.com'
```

Add public key to server's `/home/$deploy_user/.ssh/authorized_keys`, and copy private key as the repo's `./deploy/id_rsa`.

### Encrypt sensitive data

Since `.travis.yml` is visible to anyone that has access to the repository, we should encrypt sensitive data (like ssh private key).

Fortuanately, Travis-CI privide such a feature.

Install `travis` gem and login:

```
gem install travis
# Note: you must use an account that has admin privilege of the repository
travis login
```

* Encrypt deploy destination:

    ```
    travis encrypt 'deploy_to=user@server:deploy_dir'
    ```

    Paste generated string into `.travis.yml's` `env:global` section.

* Encrypt ssh private key

    ```
    travis encrypt-file .deploy/id_rsa
    ```

    Paste generated string into `.travis.yml's` `before_install` section.

    Change `--in` and `--out` params if they are not `--in .deploy/id_rsa.enc --out .deploy/id_rsa`.
