## Providers

| Name | Version |
|------|---------|
| local | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| admin\_email | n/a | `string` | n/a | yes |
| admins | n/a | <pre>map(object({<br>    public_keys = list(string)<br>  }))</pre> | n/a | yes |
| cluster\_domain | n/a | `string` | n/a | yes |
| cluster\_name | n/a | `string` | n/a | yes |
| cluster\_release\_channel | n/a | `string` | `"STABLE"` | no |
| cluster\_version | n/a | `string` | `"1.15"` | no |
| node\_groups\_scale | n/a | `map` | <pre>{<br>  "nfs": {<br>    "fixed_scale": 1<br>  },<br>  "service": {<br>    "fixed_scale": 3<br>  },<br>  "web": {<br>    "auto_scale": {<br>      "initial": 3,<br>      "max": 3,<br>      "min": 3<br>    }<br>  }<br>}</pre> | no |
| output\_dir | n/a | `string` | `"output"` | no |
| secret\_dir | n/a | `string` | `"secrets"` | no |
| service\_email | n/a | <pre>object({<br>    from_address = string<br>    host = string<br>    port = string<br>    user = string<br>    password = string<br>    use_tls = bool<br>  })</pre> | n/a | yes |
| yandex\_cloud\_id | n/a | `string` | n/a | yes |
| yandex\_folder\_id | n/a | `string` | n/a | yes |
| yandex\_token | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_instances | n/a |
| container\_registry\_id | n/a |
| elasticsearch\_host | n/a |
| elasticsearch\_user | n/a |
| grafana\_admin\_password | n/a |
| load\_balancer\_ip | n/a |
| prometheus\_admin\_password | n/a |

