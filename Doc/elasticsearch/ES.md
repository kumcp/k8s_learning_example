## ElasticSearch

- Is a type of database (SQL exact)
- Aggregate the information/logs from others

## 1. Config

- Config is in `/usr/share/elasticsearch/config/`
- Environment variable as:

* Change to uppercase
* Add `ES_SETTING_` as prefix
* Escape `_` by `__`
* Convert `.` into `_`
  `bootstrap.memory_lock=true` -> `ES_SETTING_BOOTSTRAP_MEMORY__LOCK=true`

- Can suffix by a file with `_FILE` like `ELASTIC_PASSWORD_FILE=/run/secrets/bootstrapPassword.txt`
