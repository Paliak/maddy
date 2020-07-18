# rspamd

maddy has direct support for rspamd HTTP protocol. There is no need to use
milter proxy.

If rspamd is running locally, it is enough to just add `rspamd` check
with default configuration into appropriate check block:
```
checks inbound_checks {
    ...
    rspamd
}
```

You might want to disable builtin SPF, DKIM and DMARC for performance
reasons but note that at the moment, maddy will not generate
Authentication-Results field with rspamd results.

If rspamd is not running on a local machine, change api_path to point
to the "normal" worker socket:

```
checks inbound_checks {
    ...
    rspamd {
        api_path http://spam-check.example.org:11333
    }
}
```

Default mapping of rspamd action -> maddy action is as follows:

- "add header" => Quarantine
- "rewrite subject" => Quarantine
- "soft reject" => Reject with temporary error
- "reject" => Reject with permanent error
- "greylist" => Ignored

This and additional data to pass to rspamd (MTA name, settings ID, etc)
can be configured as described in
[**maddy-checks**(5)](/man/_generated_maddy-filters.5/#rspamd-check-checkrspamd).