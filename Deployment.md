# Deployment

Use [Travis-CI](https://travis-ci.org) to auto test and deploy

## Encrypt sensitive data

```
travis encrypt-file .deploy/id_rsa

travis encrypt 'deploy_to=user@server:deploy_dir'
```

## Server Configuration

```
user=deploy_user_name
deploy_dir=/path/to/deploy
nginx_user=nginx

mkdir $deploy_dir
chown $nginx_user: $deploy_dir
# using setgid to keep new files under nginx user's group, thus readable by nginx
chmod 2775 $deploy_dir

useradd -m -G $nginx_user $user
mkdir /home/$user/.ssh
touch /home/$user/.ssh/authorized_keys
chown -R $user: /home/$user/.ssh
chmod 700 /home/$user/.ssh
chmod 600 /home/$user/.ssh/authorized_keys
```

Add ssh key to `/home/$user/.ssh/authorized_keys`
