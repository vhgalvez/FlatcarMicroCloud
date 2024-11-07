# terraform-rockylinux-libvirt
Terraform to Create Rocky Linux on KVM/Libvirt

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | = 1.5.7 |
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.7.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.7.1 |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|:--------:|
| <a name="input_rocky9_cloudinit_disk"></a> [rocky9\_cloudinit\_disk](#input\_rocky9\_cloudinit\_disk) | Qcow2 cloud-init location | `any` | yes |
| <a name="input_rocky9_cloudinit_pool"></a> [rocky9\_cloudinit\_pool](#input\_rocky9\_cloudinit\_pool) | Which Pool to located cloud-init.iso | `any` | yes |
| <a name="input_rocky9_domain_memory"></a> [rocky9\_domain\_memory](#input\_rocky9\_domain\_memory) | Vm Memory | `any` | yes |
| <a name="input_rocky9_domain_name"></a> [rocky9\_domain\_name](#input\_rocky9\_domain\_name) | VM name | `any` | yes |
| <a name="input_rocky9_domain_vcpu"></a> [rocky9\_domain\_vcpu](#input\_rocky9\_domain\_vcpu) | VM Cpu count | `any` | yes |
| <a name="input_rocky9_name"></a> [rocky9\_name](#input\_rocky9\_name) | VM name | `any` | yes |
| <a name="input_rocky9_network_name"></a> [rocky9\_network\_name](#input\_rocky9\_network\_name) | VM Network name | `any` | yes |
| <a name="input_rocky9_volume_format"></a> [rocky9\_volume\_format](#input\_rocky9\_volume\_format) | Volume format .. Qcow2 | `any` | yes |
| <a name="input_rocky9_volume_name"></a> [rocky9\_volume\_name](#input\_rocky9\_volume\_name) | Qcow2 volume name | `any` | yes |
| <a name="input_rocky9_volume_pool"></a> [rocky9\_volume\_pool](#input\_rocky9\_volume\_pool) | Pool to locate VM | `any` | yes |
| <a name="input_rocky9_volume_size"></a> [rocky9\_volume\_size](#input\_rocky9\_volume\_size) | size in bytes ... equals to 30GB https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs/resources/volume#size | `any` | yes |
| <a name="input_rocky9_volume_source"></a> [rocky9\_volume\_source](#input\_rocky9\_volume\_source) | Rocky linux Qcow2 disk image | `any` | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ip"></a> [ip](#output\_ip) | Output Server IP |
<!-- END_TF_DOCS -->

## SSH-Audit

```bash

ssh-audit  -2 127.0.0.1
# general
(gen) banner: SSH-2.0-OpenSSH_8.7
(gen) software: OpenSSH 8.7
(gen) compatibility: OpenSSH 7.4+, Dropbear SSH 2018.76+
(gen) compression: enabled (zlib@openssh.com)

# security
(cve) CVE-2021-41617                        -- (CVSSv2: 7.0) privilege escalation via supplemental groups
(cve) CVE-2016-20012                        -- (CVSSv2: 5.3) enumerate usernames via challenge response

# key exchange algorithms
(kex) curve25519-sha256                     -- [info] available since OpenSSH 7.4, Dropbear SSH 2018.76
                                            `- [info] default key exchange since OpenSSH 6.4
(kex) curve25519-sha256@libssh.org          -- [info] available since OpenSSH 6.4, Dropbear SSH 2013.62
                                            `- [info] default key exchange since OpenSSH 6.4
(kex) diffie-hellman-group16-sha512         -- [info] available since OpenSSH 7.3, Dropbear SSH 2016.73
(kex) diffie-hellman-group18-sha512         -- [info] available since OpenSSH 7.3
(kex) diffie-hellman-group-exchange-sha256 (3072-bit) -- [info] available since OpenSSH 4.4
                                                      `- [info] OpenSSH's GEX fallback mechanism was triggered during testing. Very old SSH clients will still be able to create connections using a 2048-bit modulus, though modern clients will use 3072. This can only be disabled by recompiling the code (see https://github.com/openssh/openssh-portable/blob/V_9_4/dh.c#L477).

# host-key algorithms
(key) rsa-sha2-512 (4096-bit)               -- [info] available since OpenSSH 7.2
(key) rsa-sha2-256 (4096-bit)               -- [info] available since OpenSSH 7.2
(key) ssh-ed25519                           -- [info] available since OpenSSH 6.5

# encryption algorithms (ciphers)
(enc) chacha20-poly1305@openssh.com         -- [info] available since OpenSSH 6.5
                                            `- [info] default cipher since OpenSSH 6.9
(enc) aes256-gcm@openssh.com                -- [info] available since OpenSSH 6.2
(enc) aes128-gcm@openssh.com                -- [info] available since OpenSSH 6.2
(enc) aes256-ctr                            -- [info] available since OpenSSH 3.7, Dropbear SSH 0.52
(enc) aes192-ctr                            -- [info] available since OpenSSH 3.7
(enc) aes128-ctr                            -- [info] available since OpenSSH 3.7, Dropbear SSH 0.52

# message authentication code algorithms
(mac) hmac-sha2-256-etm@openssh.com         -- [info] available since OpenSSH 6.2
(mac) hmac-sha2-512-etm@openssh.com         -- [info] available since OpenSSH 6.2
(mac) umac-128-etm@openssh.com              -- [info] available since OpenSSH 6.2

# fingerprints
(fin) ssh-ed25519: SHA256:y0irEICTkwOvIP47FGEIb+/MqQ1LYgVA+Jl8IeUxY4c
(fin) ssh-rsa: SHA256:2GzmQeU6Gqqjz5yPsdv4L8HO76PlBQEhCUBvD5TWBmw

# algorithm recommendations (for OpenSSH 8.7)
(rec) +sntrup761x25519-sha512@openssh.com   -- kex algorithm to append

```




