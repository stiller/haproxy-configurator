haproxy-configurator
====================

Example script to configure HAProxy to dynamically route a set of domains which can be fetched from a remote server.

Configure
---

Create a file called proxyconf.yml in the /root directory of your server like this:

```yaml
---
statuser: my_stats_user
statpassword: my_stats_pw
url: https://example.com/domains.json
user: proxy
password: demo
v2:
  ip: ip.of.old.sites.app
v3:
  ip: ip.of.new.sites.app
```

Use
---
From the command line:
```
sudo ruby haproxy_config.rb
```
From another script

```ruby
require 'haproxy_config.rb'
pc = HAProxyConfig.new
pc.fetch
pc.render
pc.write
# Or chain all together
HAProxyConfig.new.fetch.render.write
```
This replaces your existing /etc/haproxy/haproxy.cfg. A backup is created as haproxy.bk
