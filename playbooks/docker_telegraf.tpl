# Telegraf Short Configuration File, you could find commentaries in ./docker_telegraf.tpl.bkp file

[global_tags]

[agent]

  interval = "10s"

  round_interval = true

  metric_batch_size = 1000

  metric_buffer_limit = 10000

  collection_jitter = "0s"

  flush_interval = "10s"

  flush_jitter = "0s"

  precision = ""

  hostname = ""

  omit_hostname = false

[[outputs.influxdb]]

  urls = ["http://${influxdb_ip}:8086"]


  database = "terraform"

  skip_database_creation = true

  write_consistency = "any"

  timeout = "3s"

  username = "telegraf"
  password = "${influxdb_user_password}"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  fielddrop = ["time_*"]
[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs"]

[[inputs.diskio]]

[[inputs.kernel]]

[[inputs.mem]]

[[inputs.processes]]

[[inputs.swap]]

[[inputs.system]]

[[inputs.net]]

[[inputs.netstat]]

[[inputs.nginx]]
  urls = ["http://nginx:8080/nginx_status"]
  response_timeout = "5s"

[[inputs.docker]]
  endpoint = "unix:///var/run/docker.sock"
  container_names = []
  timeout = "5s"
  perdevice = true
  total = false
  docker_label_include = []
  docker_label_exclude = []
