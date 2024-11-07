

```bash
ipa dnsrecord-add cefaslocalserver.com bootstrap --a-rec 10.17.4.27
ipa dnsrecord-add cefaslocalserver.com helper --a-rec 10.17.3.14
ipa dnsrecord-add cefaslocalserver.com master1 --a-rec 10.17.4.21
ipa dnsrecord-add cefaslocalserver.com master2 --a-rec 10.17.4.22
ipa dnsrecord-add cefaslocalserver.com master3 --a-rec 10.17.4.23
ipa dnsrecord-add cefaslocalserver.com worker1 --a-rec 10.17.4.24
ipa dnsrecord-add cefaslocalserver.com worker2 --a-rec 10.17.4.25
ipa dnsrecord-add cefaslocalserver.com worker3 --a-rec 10.17.4.26
ipa dnsrecord-add cefaslocalserver.com bastion1 --a-rec 192.168.0.20
ipa dnsrecord-add cefaslocalserver.com freeipa1 --a-rec 10.17.3.11
ipa dnsrecord-add cefaslocalserver.com load_balancer1 --a-rec 10.17.3.12
ipa dnsrecord-add cefaslocalserver.com postgresql1 --a-rec 10.17.3.1
```

```bash
ipa dnszone-add 4.17.10.in-addr.arpa.
ipa dnszone-add 3.17.10.in-addr.arpa.
ipa dnszone-add 0.168.192.in-addr.arpa.
```


```bash
ipa dnsrecord-add 4.17.10.in-addr.arpa 27 --ptr-rec bootstrap.cefaslocalserver.com
ipa dnsrecord-add 3.17.10.in-addr.arpa 14 --ptr-rec helper.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 21 --ptr-rec master1.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 22 --ptr-rec master2.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 23 --ptr-rec master3.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 24 --ptr-rec worker1.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 25 --ptr-rec worker2.cefaslocalserver.com
ipa dnsrecord-add 4.17.10.in-addr.arpa 26 --ptr-rec worker3.cefaslocalserver.com
ipa dnsrecord-add 0.168.192.in-addr.arpa 20 --ptr-rec bastion1.cefaslocalserver.com
ipa dnsrecord-add 3.17.10.in-addr.arpa 11 --ptr-rec freeipa1.cefaslocalserver.com
ipa dnsrecord-add 3.17.10.in-addr.arpa 12 --ptr-rec load_balancer1.cefaslocalserver.com
ipa dnsrecord-add 3.17.10.in-addr.arpa 1 --ptr-rec postgresql1.cefaslocalserver.com
```

