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
| yandex\_cloud\_id | n/a | `string` | n/a | yes |
| yandex\_folder\_id | n/a | `string` | n/a | yes |
| yandex\_token | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| container\_registry\_id | Created container registry ID |
| elasticsearch\_host | Elasticsearch cluster ingress host |
| elasticsearch\_user | Elasticsearch cluster user |
| grafana\_admin\_password | Grafana admin user password |
| load\_balancer\_ip | Nginx ingress load balancer ip |
| prometheus\_admin\_password | Prometheus basic-auth user password (username - prometheus) |

