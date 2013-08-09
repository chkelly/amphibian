amphibian
=========
[![Gem Version](https://badge.fury.io/rb/amphibian.png)](http://badge.fury.io/rb/amphibian)

Amphibian is a ruby library for accessing and interacting with an Apache mod_proxy_balancer via the web GUI created by the balancer_manager directive.

This is a continuation of the work done by Nick Stielau. (amphibian.rubyforge.org)

``` sh
bash$ irb
>> require 'amphibian'
=> true
>> amp = Amphibian::BalancerManager.new("http://example.com/balancer-manager")
>> amp.hosts
=> ["http://127.0.0.1:10000", "http://127.0.0.1:10001", "http://127.0.0.1:10002"]
>> amp.enabled_hosts
=> ["http://127.0.0.1:10001", "http://127.0.0.1:10002"]
>> amp.disabled_hosts
=> ["http://127.0.0.1:10000"]
>> amp.hosts_with_status
=> {"http://127.0.0.1:10000"=>"Dis", "http://127.0.0.1:10001"=>"Ok", "http://127.0.0.1:10002"=>"Ok"}
>> amp.enable_host("http://127.0.0.1:10000")
>> amp.enabled_hosts
=> ["http://127.0.0.1:10000","http://127.0.0.1:10001", "http://127.0.0.1:10002"]
>> amp.disabled_hosts
=> []
```
