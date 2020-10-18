# Telegraf Configuration
#
# Telegraf is entirely plugin driven. All metrics are gathered from the
# declared inputs, and sent to the declared outputs.
#
# Plugins must be declared in here to be active.
# To deactivate a plugin, comment out the name and any variables.
#
# Use 'telegraf -config telegraf.conf -test' to see what metrics a config
# file would generate.

# Global tags can be specified here in key="value" format.
[global_tags]
  # dc = "us-east-1" # will tag all metrics with dc=us-east-1
  # rack = "1a"
  ## Environment variables can be used as tags, and throughout the config file
  # user = "$USER"


# Configuration for telegraf agent
[agent]
  ## Default data collection interval for all inputs
  interval = "10s"
  ## Rounds collection interval to 'interval'
  ## ie, if interval="10s" then always collect on :00, :10, :20, etc.
  round_interval = true

  ## Telegraf will send metrics to outputs in batches of at most
  ## metric_batch_size metrics.
  ## This controls the size of writes that Telegraf sends to output plugins.
  metric_batch_size = 1000

  ## Maximum number of unwritten metrics per output.  Increasing this value
  ## allows for longer periods of output downtime without dropping metrics at the
  ## cost of higher maximum memory usage.
  metric_buffer_limit = 10000

  ## Collection jitter is used to jitter the collection by a random amount.
  ## Each plugin will sleep for a random time within jitter before collecting.
  ## This can be used to avoid many plugins querying things like sysfs at the
  ## same time, which can have a measurable effect on the system.
  collection_jitter = "0s"

  ## Default flushing interval for all outputs. Maximum flush_interval will be
  ## flush_interval + flush_jitter
  flush_interval = "10s"
  ## Jitter the flush interval by a random amount. This is primarily to avoid
  ## large write spikes for users running a large number of telegraf instances.
  ## ie, a jitter of 5s and interval 10s means flushes will happen every 10-15s
  flush_jitter = "0s"

  ## By default or when set to "0s", precision will be set to the same
  ## timestamp order as the collection interval, with the maximum being 1s.
  ##   ie, when interval = "10s", precision will be "1s"
  ##       when interval = "250ms", precision will be "1ms"
  ## Precision will NOT be used for service inputs. It is up to each individual
  ## service input to set the timestamp at the appropriate precision.
  ## Valid time units are "ns", "us" (or "µs"), "ms", "s".
  precision = ""

  ## Log at debug level.
  # debug = false
  ## Log only error level messages.
  # quiet = false

  ## Log target controls the destination for logs and can be one of "file",
  ## "stderr" or, on Windows, "eventlog".  When set to "file", the output file
  ## is determined by the "logfile" setting.
  # logtarget = "file"

  ## Name of the file to be logged to when using the "file" logtarget.  If set to
  ## the empty string then logs are written to stderr.
  # logfile = ""

  ## The logfile will be rotated after the time interval specified.  When set
  ## to 0 no time based rotation is performed.  Logs are rotated only when
  ## written to, if there is no log activity rotation may be delayed.
  # logfile_rotation_interval = "0d"

  ## The logfile will be rotated when it becomes larger than the specified
  ## size.  When set to 0 no size based rotation is performed.
  # logfile_rotation_max_size = "0MB"

  ## Maximum number of rotated archives to keep, any older logs are deleted.
  ## If set to -1, no archives are removed.
  # logfile_rotation_max_archives = 5

  ## Override default hostname, if empty use os.Hostname()
  hostname = ""
  ## If set to true, do no set the "host" tag in the telegraf agent.
  omit_hostname = false


###############################################################################
#                            OUTPUT PLUGINS                                   #
###############################################################################


# Configuration for sending metrics to InfluxDB
[[outputs.influxdb]]
  ## The full HTTP or UDP URL for your InfluxDB instance.
  ##
  ## Multiple URLs can be specified for a single cluster, only ONE of the
  ## urls will be written to each interval.
  # urls = ["unix:///var/run/influxdb.sock"]
  # urls = ["udp://127.0.0.1:8089"]
  urls = ["${influxdb_url}"]

  ## The target database for metrics; will be created as needed.
  ## For UDP url endpoint database needs to be configured on server side.
  database = "telegraf"

  ## The value of this tag will be used to determine the database.  If this
  ## tag is not set the 'database' option is used as the default.
  # database_tag = ""

  ## If true, the 'database_tag' will not be included in the written metric.
  # exclude_database_tag = false

  ## If true, no CREATE DATABASE queries will be sent.  Set to true when using
  ## Telegraf with a user without permissions to create databases or when the
  ## database already exists.
   skip_database_creation = true

  ## Name of existing retention policy to write to.  Empty string writes to
  ## the default retention policy.  Only takes effect when using HTTP.
  # retention_policy = ""

  ## The value of this tag will be used to determine the retention policy.  If this
  ## tag is not set the 'retention_policy' option is used as the default.
  # retention_policy_tag = ""

  ## If true, the 'retention_policy_tag' will not be included in the written metric.
  # exclude_retention_policy_tag = false

  ## Write consistency (clusters only), can be: "any", "one", "quorum", "all".
  ## Only takes effect when using HTTP.
  write_consistency = "any"

  ## Timeout for HTTP messages.
  timeout = "3s"

  ## HTTP Basic Auth
  username = "telegraf"
  password = "${influxdb_user_password}"

  ## HTTP User-Agent
  # user_agent = "telegraf"

  ## UDP payload size is the maximum packet size to send.
  # udp_payload = "512B"

  ## Optional TLS Config for use on HTTP connections.
  # tls_ca = "/etc/telegraf/ca.pem"
  # tls_cert = "/etc/telegraf/cert.pem"
  # tls_key = "/etc/telegraf/key.pem"
  ## Use TLS but skip chain & host verification
  # insecure_skip_verify = false

  ## HTTP Proxy override, if unset values the standard proxy environment
  ## variables are consulted to determine which proxy, if any, should be used.
  # http_proxy = "http://corporate.proxy:3128"

  ## Additional HTTP headers
  # http_headers = {"X-Special-Header" = "Special-Value"}

  ## HTTP Content-Encoding for write request body, can be set to "gzip" to
  ## compress body or "identity" to apply no encoding.
  # content_encoding = "identity"

  ## When true, Telegraf will output unsigned integers as unsigned values,
  ## i.e.: "42u".  You will need a version of InfluxDB supporting unsigned
  ## integer values.  Enabling this option will result in field type errors if
  ## existing data has been written.
  # influx_uint_support = false


###############################################################################
#                            PROCESSOR PLUGINS                                #
###############################################################################


# # Clone metrics and apply modifications.
# [[processors.clone]]
#   ## All modifications on inputs and aggregators can be overridden:
#   # name_override = "new_name"
#   # name_prefix = "new_name_prefix"
#   # name_suffix = "new_name_suffix"
#
#   ## Tags to be added (all values must be strings)
#   # [processors.clone.tags]
#   #   additional_tag = "tag_value"


# # Convert values to another metric value type
# [[processors.converter]]
#   ## Tags to convert
#   ##
#   ## The table key determines the target type, and the array of key-values
#   ## select the keys to convert.  The array may contain globs.
#   ##   <target-type> = [<tag-key>...]
#   [processors.converter.tags]
#     measurement = []
#     string = []
#     integer = []
#     unsigned = []
#     boolean = []
#     float = []
#
#   ## Fields to convert
#   ##
#   ## The table key determines the target type, and the array of key-values
#   ## select the keys to convert.  The array may contain globs.
#   ##   <target-type> = [<field-key>...]
#   [processors.converter.fields]
#     measurement = []
#     tag = []
#     string = []
#     integer = []
#     unsigned = []
#     boolean = []
#     float = []


# # Dates measurements, tags, and fields that pass through this filter.
# [[processors.date]]
#       ## New tag to create
#       tag_key = "month"
#
#       ## New field to create (cannot set both field_key and tag_key)
#       # field_key = "month"
#
#       ## Date format string, must be a representation of the Go "reference time"
#       ## which is "Mon Jan 2 15:04:05 -0700 MST 2006".
#       date_format = "Jan"
#
#       ## If destination is a field, date format can also be one of
#       ## "unix", "unix_ms", "unix_us", or "unix_ns", which will insert an integer field.
#       # date_format = "unix"
#
#       ## Offset duration added to the date string when writing the new tag.
#       # date_offset = "0s"
#
#       ## Timezone to use when creating the tag or field using a reference time
#       ## string.  This can be set to one of "UTC", "Local", or to a location name
#       ## in the IANA Time Zone database.
#       ##   example: timezone = "America/Los_Angeles"
#       # timezone = "UTC"


# # Filter metrics with repeating field values
# [[processors.dedup]]
#   ## Maximum time to suppress output
#   dedup_interval = "600s"


# # Defaults sets default value(s) for specified fields that are not set on incoming metrics.
# [[processors.defaults]]
#   ## Ensures a set of fields always exists on your metric(s) with their
#   ## respective default value.
#   ## For any given field pair (key = default), if it's not set, a field
#   ## is set on the metric with the specified default.
#   ##
#   ## A field is considered not set if it is nil on the incoming metric;
#   ## or it is not nil but its value is an empty string or is a string
#   ## of one or more spaces.
#   ##   <target-field> = <value>
#   # [processors.defaults.fields]
#   #   field_1 = "bar"
#   #   time_idle = 0
#   #   is_error = true


# # Map enum values according to given table.
# [[processors.enum]]
#   [[processors.enum.mapping]]
#     ## Name of the field to map
#     field = "status"
#
#     ## Name of the tag to map
#     # tag = "status"
#
#     ## Destination tag or field to be used for the mapped value.  By default the
#     ## source tag or field is used, overwriting the original value.
#     dest = "status_code"
#
#     ## Default value to be used for all values not contained in the mapping
#     ## table.  When unset, the unmodified value for the field will be used if no
#     ## match is found.
#     # default = 0
#
#     ## Table of mappings
#     [processors.enum.mapping.value_mappings]
#       green = 1
#       amber = 2
#       red = 3


# # Run executable as long-running processor plugin
# [[processors.execd]]
#       ## Program to run as daemon
#       ## eg: command = ["/path/to/your_program", "arg1", "arg2"]
#       command = ["cat"]
#
#   ## Delay before the process is restarted after an unexpected termination
#   restart_delay = "10s"


# # Performs file path manipulations on tags and fields
# [[processors.filepath]]
#   ## Treat the tag value as a path and convert it to its last element, storing the result in a new tag
#   # [[processors.filepath.basename]]
#   #   tag = "path"
#   #   dest = "basepath"
#
#   ## Treat the field value as a path and keep all but the last element of path, typically the path's directory
#   # [[processors.filepath.dirname]]
#   #   field = "path"
#
#   ## Treat the tag value as a path, converting it to its the last element without its suffix
#   # [[processors.filepath.stem]]
#   #   tag = "path"
#
#   ## Treat the tag value as a path, converting it to the shortest path name equivalent
#   ## to path by purely lexical processing
#   # [[processors.filepath.clean]]
#   #   tag = "path"
#
#   ## Treat the tag value as a path, converting it to a relative path that is lexically
#   ## equivalent to the source path when joined to 'base_path'
#   # [[processors.filepath.rel]]
#   #   tag = "path"
#   #   base_path = "/var/log"
#
#   ## Treat the tag value as a path, replacing each separator character in path with a '/' character. Has only
#   ## effect on Windows
#   # [[processors.filepath.toslash]]
#   #   tag = "path"


# # Add a tag of the network interface name looked up over SNMP by interface number
# [[processors.ifname]]
#   ## Name of tag holding the interface number
#   # tag = "ifIndex"
#
#   ## Name of output tag where service name will be added
#   # dest = "ifName"
#
#   ## Name of tag of the SNMP agent to request the interface name from
#   # agent = "agent"
#
#   ## Timeout for each request.
#   # timeout = "5s"
#
#   ## SNMP version; can be 1, 2, or 3.
#   # version = 2
#
#   ## SNMP community string.
#   # community = "public"
#
#   ## Number of retries to attempt.
#   # retries = 3
#
#   ## The GETBULK max-repetitions parameter.
#   # max_repetitions = 10
#
#   ## SNMPv3 authentication and encryption options.
#   ##
#   ## Security Name.
#   # sec_name = "myuser"
#   ## Authentication protocol; one of "MD5", "SHA", or "".
#   # auth_protocol = "MD5"
#   ## Authentication password.
#   # auth_password = "pass"
#   ## Security Level; one of "noAuthNoPriv", "authNoPriv", or "authPriv".
#   # sec_level = "authNoPriv"
#   ## Context Name.
#   # context_name = ""
#   ## Privacy protocol used for encrypted messages; one of "DES", "AES" or "".
#   # priv_protocol = ""
#   ## Privacy password used for encrypted messages.
#   # priv_password = ""
#
#   ## max_parallel_lookups is the maximum number of SNMP requests to
#   ## make at the same time.
#   # max_parallel_lookups = 100
#
#   ## ordered controls whether or not the metrics need to stay in the
#   ## same order this plugin received them in. If false, this plugin
#   ## may change the order when data is cached.  If you need metrics to
#   ## stay in order set this to true.  keeping the metrics ordered may
#   ## be slightly slower
#   # ordered = false
#
#   ## cache_ttl is the amount of time interface names are cached for a
#   ## given agent.  After this period elapses if names are needed they
#   ## will be retrieved again.
#   # cache_ttl = "8h"


# # Apply metric modifications using override semantics.
# [[processors.override]]
#   ## All modifications on inputs and aggregators can be overridden:
#   # name_override = "new_name"
#   # name_prefix = "new_name_prefix"
#   # name_suffix = "new_name_suffix"
#
#   ## Tags to be added (all values must be strings)
#   # [processors.override.tags]
#   #   additional_tag = "tag_value"


# # Parse a value in a specified field/tag(s) and add the result in a new metric
# [[processors.parser]]
#   ## The name of the fields whose value will be parsed.
#   parse_fields = []
#
#   ## If true, incoming metrics are not emitted.
#   drop_original = false
#
#   ## If set to override, emitted metrics will be merged by overriding the
#   ## original metric using the newly parsed metrics.
#   merge = "override"
#
#   ## The dataformat to be read from files
#   ## Each data format has its own unique set of configuration options, read
#   ## more about them here:
#   ## https://github.com/influxdata/telegraf/blob/master/docs/DATA_FORMATS_INPUT.md
#   data_format = "influx"


# # Rotate a single valued metric into a multi field metric
# [[processors.pivot]]
#   ## Tag to use for naming the new field.
#   tag_key = "name"
#   ## Field to use as the value of the new field.
#   value_key = "value"


# # Given a tag of a TCP or UDP port number, add a tag of the service name looked up in the system services file
# [[processors.port_name]]
# [[processors.port_name]]
#   ## Name of tag holding the port number
#   # tag = "port"
#
#   ## Name of output tag where service name will be added
#   # dest = "service"
#
#   ## Default tcp or udp
#   # default_protocol = "tcp"


# # Print all metrics that pass through this filter.
# [[processors.printer]]


# # Transforms tag and field values with regex pattern
# [[processors.regex]]
#   ## Tag and field conversions defined in a separate sub-tables
#   # [[processors.regex.tags]]
#   #   ## Tag to change
#   #   key = "resp_code"
#   #   ## Regular expression to match on a tag value
#   #   pattern = "^(\\d)\\d\\d$"
#   #   ## Matches of the pattern will be replaced with this string.  Use ${1}
#   #   ## notation to use the text of the first submatch.
#   #   replacement = "${1}xx"
#
#   # [[processors.regex.fields]]
#   #   ## Field to change
#   #   key = "request"
#   #   ## All the power of the Go regular expressions available here
#   #   ## For example, named subgroups
#   #   pattern = "^/api(?P<method>/[\\w/]+)\\S*"
#   #   replacement = "${method}"
#   #   ## If result_key is present, a new field will be created
#   #   ## instead of changing existing field
#   #   result_key = "method"
#
#   ## Multiple conversions may be applied for one field sequentially
#   ## Let's extract one more value
#   # [[processors.regex.fields]]
#   #   key = "request"
#   #   pattern = ".*category=(\\w+).*"
#   #   replacement = "${1}"
#   #   result_key = "search_category"


# # Rename measurements, tags, and fields that pass through this filter.
# [[processors.rename]]


# # ReverseDNS does a reverse lookup on IP addresses to retrieve the DNS name
# [[processors.reverse_dns]]
#   ## For optimal performance, you may want to limit which metrics are passed to this
#   ## processor. eg:
#   ## namepass = ["my_metric_*"]
#
#   ## cache_ttl is how long the dns entries should stay cached for.
#   ## generally longer is better, but if you expect a large number of diverse lookups
#   ## you'll want to consider memory use.
#   cache_ttl = "24h"
#
#   ## lookup_timeout is how long should you wait for a single dns request to repsond.
#   ## this is also the maximum acceptable latency for a metric travelling through
#   ## the reverse_dns processor. After lookup_timeout is exceeded, a metric will
#   ## be passed on unaltered.
#   ## multiple simultaneous resolution requests for the same IP will only make a
#   ## single rDNS request, and they will all wait for the answer for this long.
#   lookup_timeout = "3s"
#
#   ## max_parallel_lookups is the maximum number of dns requests to be in flight
#   ## at the same time. Requesting hitting cached values do not count against this
#   ## total, and neither do mulptiple requests for the same IP.
#   ## It's probably best to keep this number fairly low.
#   max_parallel_lookups = 10
#
#   ## ordered controls whether or not the metrics need to stay in the same order
#   ## this plugin received them in. If false, this plugin will change the order
#   ## with requests hitting cached results moving through immediately and not
#   ## waiting on slower lookups. This may cause issues for you if you are
#   ## depending on the order of metrics staying the same. If so, set this to true.
#   ## keeping the metrics ordered may be slightly slower.
#   ordered = false
#
#   [[processors.reverse_dns.lookup]]
#     ## get the ip from the field "source_ip", and put the result in the field "source_name"
#     field = "source_ip"
#     dest = "source_name"
#
#   [[processors.reverse_dns.lookup]]
#     ## get the ip from the tag "destination_ip", and put the result in the tag
#     ## "destination_name".
#     tag = "destination_ip"
#     dest = "destination_name"
#
#     ## If you would prefer destination_name to be a field instead, you can use a
#     ## processors.converter after this one, specifying the order attribute.


# # Add the S2 Cell ID as a tag based on latitude and longitude fields
# [[processors.s2geo]]
#   ## The name of the lat and lon fields containing WGS-84 latitude and
#   ## longitude in decimal degrees.
#   # lat_field = "lat"
#   # lon_field = "lon"
#
#   ## New tag to create
#   # tag_key = "s2_cell_id"
#
#   ## Cell level (see https://s2geometry.io/resources/s2cell_statistics.html)
#   # cell_level = 9


# # Process metrics using a Starlark script
# [[processors.starlark]]
#   ## The Starlark source can be set as a string in this configuration file, or
#   ## by referencing a file containing the script.  Only one source or script
#   ## should be set at once.
#   ##
#   ## Source of the Starlark script.
#   source = '''
# def apply(metric):
#       return metric
# '''
#
#   ## File containing a Starlark script.
#   # script = "/usr/local/bin/myscript.star"


# # Perform string processing on tags, fields, and measurements
# [[processors.strings]]
#   ## Convert a tag value to uppercase
#   # [[processors.strings.uppercase]]
#   #   tag = "method"
#
#   ## Convert a field value to lowercase and store in a new field
#   # [[processors.strings.lowercase]]
#   #   field = "uri_stem"
#   #   dest = "uri_stem_normalised"
#
#   ## Convert a field value to titlecase
#   # [[processors.strings.titlecase]]
#   #   field = "status"
#
#   ## Trim leading and trailing whitespace using the default cutset
#   # [[processors.strings.trim]]
#   #   field = "message"
#
#   ## Trim leading characters in cutset
#   # [[processors.strings.trim_left]]
#   #   field = "message"
#   #   cutset = "\t"
#
#   ## Trim trailing characters in cutset
#   # [[processors.strings.trim_right]]
#   #   field = "message"
#   #   cutset = "\r\n"
#
#   ## Trim the given prefix from the field
#   # [[processors.strings.trim_prefix]]
#   #   field = "my_value"
#   #   prefix = "my_"
#
#   ## Trim the given suffix from the field
#   # [[processors.strings.trim_suffix]]
#   #   field = "read_count"
#   #   suffix = "_count"
#
#   ## Replace all non-overlapping instances of old with new
#   # [[processors.strings.replace]]
#   #   measurement = "*"
#   #   old = ":"
#   #   new = "_"
#
#   ## Trims strings based on width
#   # [[processors.strings.left]]
#   #   field = "message"
#   #   width = 10
#
#   ## Decode a base64 encoded utf-8 string
#   # [[processors.strings.base64decode]]
#   #   field = "message"


# # Restricts the number of tags that can pass through this filter and chooses which tags to preserve when over the limit.
# [[processors.tag_limit]]
#   ## Maximum number of tags to preserve
#   limit = 10
#
#   ## List of tags to preferentially preserve
#   keep = ["foo", "bar", "baz"]


# # Uses a Go template to create a new tag
# [[processors.template]]
#   ## Tag to set with the output of the template.
#   tag = "topic"
#
#   ## Go template used to create the tag value.  In order to ease TOML
#   ## escaping requirements, you may wish to use single quotes around the
#   ## template string.
#   template = '{{ .Tag "hostname" }}.{{ .Tag "level" }}'


# # Print all metrics that pass through this filter.
# [[processors.topk]]
#   ## How many seconds between aggregations
#   # period = 10
#
#   ## How many top metrics to return
#   # k = 10
#
#   ## Over which tags should the aggregation be done. Globs can be specified, in
#   ## which case any tag matching the glob will aggregated over. If set to an
#   ## empty list is no aggregation over tags is done
#   # group_by = ['*']
#
#   ## Over which fields are the top k are calculated
#   # fields = ["value"]
#
#   ## What aggregation to use. Options: sum, mean, min, max
#   # aggregation = "mean"
#
#   ## Instead of the top k largest metrics, return the bottom k lowest metrics
#   # bottomk = false
#
#   ## The plugin assigns each metric a GroupBy tag generated from its name and
#   ## tags. If this setting is different than "" the plugin will add a
#   ## tag (which name will be the value of this setting) to each metric with
#   ## the value of the calculated GroupBy tag. Useful for debugging
#   # add_groupby_tag = ""
#
#   ## These settings provide a way to know the position of each metric in
#   ## the top k. The 'add_rank_field' setting allows to specify for which
#   ## fields the position is required. If the list is non empty, then a field
#   ## will be added to each and every metric for each string present in this
#   ## setting. This field will contain the ranking of the group that
#   ## the metric belonged to when aggregated over that field.
#   ## The name of the field will be set to the name of the aggregation field,
#   ## suffixed with the string '_topk_rank'
#   # add_rank_fields = []
#
#   ## These settings provide a way to know what values the plugin is generating
#   ## when aggregating metrics. The 'add_aggregate_field' setting allows to
#   ## specify for which fields the final aggregation value is required. If the
#   ## list is non empty, then a field will be added to each every metric for
#   ## each field present in this setting. This field will contain
#   ## the computed aggregation for the group that the metric belonged to when
#   ## aggregated over that field.
#   ## The name of the field will be set to the name of the aggregation field,
#   ## suffixed with the string '_topk_aggregate'
#   # add_aggregate_fields = []


# # Rotate multi field metric into several single field metrics
# [[processors.unpivot]]
#   ## Tag to use for the name.
#   tag_key = "name"
#   ## Field to use for the name of the value.
#   value_key = "value"


###############################################################################
#                            AGGREGATOR PLUGINS                               #
###############################################################################


# # Keep the aggregate basicstats of each metric passing through.
# [[aggregators.basicstats]]
#   ## The period on which to flush & clear the aggregator.
#   period = "30s"
#
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = false
#
#   ## Configures which basic stats to push as fields
#   # stats = ["count", "min", "max", "mean", "stdev", "s2", "sum"]


# # Report the final metric of a series
# [[aggregators.final]]
#   ## The period on which to flush & clear the aggregator.
#   period = "30s"
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = false
#
#   ## The time that a series is not updated until considering it final.
#   series_timeout = "5m"


# # Create aggregate histograms.
# [[aggregators.histogram]]
#   ## The period in which to flush the aggregator.
#   period = "30s"
#
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = false
#
#   ## If true, the histogram will be reset on flush instead
#   ## of accumulating the results.
#   reset = false
#
#   ## Whether bucket values should be accumulated. If set to false, "gt" tag will be added.
#   ## Defaults to true.
#   cumulative = true
#
#   ## Example config that aggregates all fields of the metric.
#   # [[aggregators.histogram.config]]
#   #   ## Right borders of buckets (with +Inf implicitly added).
#   #   buckets = [0.0, 15.6, 34.5, 49.1, 71.5, 80.5, 94.5, 100.0]
#   #   ## The name of metric.
#   #   measurement_name = "cpu"
#
#   ## Example config that aggregates only specific fields of the metric.
#   # [[aggregators.histogram.config]]
#   #   ## Right borders of buckets (with +Inf implicitly added).
#   #   buckets = [0.0, 10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]
#   #   ## The name of metric.
#   #   measurement_name = "diskio"
#   #   ## The concrete fields of metric
#   #   fields = ["io_time", "read_time", "write_time"]


# # Merge metrics into multifield metrics by series key
# [[aggregators.merge]]
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = true


# # Keep the aggregate min/max of each metric passing through.
# [[aggregators.minmax]]
#   ## General Aggregator Arguments:
#   ## The period on which to flush & clear the aggregator.
#   period = "30s"
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = false


# # Count the occurrence of values in fields.
# [[aggregators.valuecounter]]
#   ## General Aggregator Arguments:
#   ## The period on which to flush & clear the aggregator.
#   period = "30s"
#   ## If true, the original metric will be dropped by the
#   ## aggregator and will not get sent to the output plugins.
#   drop_original = false
#   ## The fields for which the values will be counted
#   fields = []


###############################################################################
#                            INPUT PLUGINS                                    #
###############################################################################

[[inputs.nginx]]
  urls = ["http://localhost:8080/nginx_status"]
  response_timeout = "5s"

# Read metrics about docker containers
[[inputs.docker]]
  ## Docker Endpoint
  ##   To use TCP, set endpoint = "tcp://[ip]:[port]"
  ##   To use environment variables (ie, docker-machine), set endpoint = "ENV"
  endpoint = "unix:///var/run/docker.sock"

  ## Set to true to collect Swarm metrics(desired_replicas, running_replicas)
  gather_services = false

  ## Only collect metrics for these containers, collect all if empty
  container_names = []

  ## Set the source tag for the metrics to the container ID hostname, eg first 12 chars
  source_tag = false

  ## Containers to include and exclude. Globs accepted.
  ## Note that an empty array for both will include all containers
  container_name_include = []
  container_name_exclude = []

  ## Container states to include and exclude. Globs accepted.
  ## When empty only containers in the "running" state will be captured.
  ## example: container_state_include = ["created", "restarting", "running", "removing", "paused", "exited", "dead"]
  ## example: container_state_exclude = ["created", "restarting", "running", "removing", "paused", "exited", "dead"]
  # container_state_include = []
  # container_state_exclude = []

  ## Timeout for docker list, info, and stats commands
  timeout = "5s"

  ## Whether to report for each container per-device blkio (8:0, 8:1...) and
  ## network (eth0, eth1, ...) stats or not
  perdevice = true

  ## Whether to report for each container total blkio and network stats or not
  total = false

  ## Which environment variables should we use as a tag
  ##tag_env = ["JAVA_HOME", "HEAP_SIZE"]

  ## docker labels to include and exclude as tags.  Globs accepted.
  ## Note that an empty array for both will include all labels as tags
  docker_label_include = []
  docker_label_exclude = []

  ## Optional TLS Config
  # tls_ca = "/etc/telegraf/ca.pem"
  # tls_cert = "/etc/telegraf/cert.pem"
  # tls_key = "/etc/telegraf/key.pem"
  ## Use TLS but skip chain & host verification
  # insecure_skip_verify = false

