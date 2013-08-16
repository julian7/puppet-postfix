# TODO

* postfix's trivial-rewrite is in chroot jail, the following mapping is
  req'd for local connect:

```
/var/run/mysqld /var/spool/postfix/var/run/mysqld bind defaults,bind 0 0
```
