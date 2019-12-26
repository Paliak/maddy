maddy(1) "maddy mail server" "maddy reference documentation"

; TITLE Introduction

# Name

maddy - Simple, fast, secure all-in-one mail server.

# Synopsis

*maddy* [options...]

# Description

Maddy is Mail Transfer agent (MTA), Mail Delivery Agent (MDA), Mail Submission
Agent (MSA), IMAP server and a set of other essential protocols/schemes
necessary to run secure email server implemented in one executable.

*Disclaimer: maddy is in early development, backward-incompatible changes
happen from time to time and bugs are waiting to eat your messages. Caveat
emptor.*

# Command line arguments

*-h, -help*
	Show help message and exit.

*-config* _path_
	Path to the configuration file. Default is /etc/maddy/maddy.conf.

*-libexec* _path_
	Path to the libexec directory. Helper executables will be searched here.
	Default is /usr/lib/maddy.

*-log* _targets..._
	Comma-separated list of logging targets. Valid values are the same as the
	'log' config directie. Affects logging before configuration parsing
	completes and after it, if the different value is not specified in the
	configuration.

*-debug*
	Enable debug log. You want to use it when reporting bugs.

# Modules

maddy is built of many small components called "modules". Each module does one
certain well-defined task. Modules can be connected to each other in arbitrary
ways to achieve wanted functionality. Default configuration file defines
set of modules that together implement typical email server stack.

To specify the module that should be used by another module for something, look
for configuration directives with "module reference" argument. Then
put the module name as an argument for it. Optionally, if referenced module
needs that, put additional arguments after the name. You can also put a
configuration block with additional directives specifing the module
configuration.

Here are some examples:

```
smtp ... {
    # Deliver messages to the 'dummy' module with the default configuration.
    deliver_to dummy

    # Deliver messages to the 'smtp_downstream' module with
    # 'tcp://127.0.0.1:1125' argument as a configuration.
    deliver_to smtp_downstream tcp://127.0.0.1:1125

    # Deliver messages to the 'queue' module with the specified configuration.
    deliver_to queue {
        target ...
        max_tries 10
    }
}
```

Additionally, module configuration can be placed in a separate named block
at the top-level and merely referenced by its name where it is needed.

Here is the example:
```
sql local_mailboxes {
    driver sqlite3
    dsn all.db
}

smtp ... {
    deliver_to &local_mailboxes
}
```

It is recommended to use this syntax for modules that are 'expensive' to
initialize such as storage backends and authentication providers.

For top-level configuration block definition, syntax is as follows:
```
module_name config_block_name... {
    module_configuration
}
```
If config_block_name is omitted, it will be the same as module_name. Multiple
names can be specified. All names must be unique.

Usual module arguments can't be specified when using this syntax, however,
modules usually provide explicit directives that allow to specify the needed
values. For example 'sql sqlite3 all.db' is equivalent to
```
sql {
    driver sqlite3
    dsn all.db
}
```

# Reference documentation conventions

## Syntax descriptions for directives

Underlined values are placeholders and should be replaced by your values.
_boolean_ is either 'yes' or 'no' string.

Ellipsis (_smth..._) means that multiple values can be specified

Multiple values listed with '|' (pipe) separator mean that any of them
can be used.

# Global directives

These directives applied for all configuration blocks that don't override it.

*Syntax*: state_dir _path_ ++
*Default*: /var/lib/maddy

The path to the state directory. This directory will be used to store all
persistent data and should be writable.

*Syntax*: runtime_dir _path_ ++
*Default*: /run/maddy

The path to the runtime directory. Used for Unix sockets and other temporary
objects. Should be writable.

*Syntax*: hostname _domain_ ++
*Default*: not specified

Internet hostname of this mail server. Typicall FQDN is used. It is recommended
to make sure domain specified here resolved to the public IP of the server.

*Syntax*: autogenerated_msg_domain _domain_ ++
*Default*: not specified

Domain that is used in From field for auto-generated messages (such as Delivery
Status Notifications).

*Syntax*: ++
    tls _cert_file_ _pkey_file_ ++
    tls self_signed ++
    tls off ++
*Default*: not specified

Default TLS certificate to use for all endpoints.

Must be present in either all endpoint modules configuration blocks or as
global directive.

Use of 'self_signed' generates temporary self-signed certificate, this useful
for testing but should be used only for it.

You can also specify other configuration options such as cipher suites and TLS
version. See TLS server configuration for details. maddy uses reasonable
cipher suites and TLS versions by default so you generally don't have to worry
about it.

*Syntax*: tls_client { ... } ++
*Default*: not specified

This is optional block that specifies various TLS-related options to use when
making outbound connections. See TLS client configuration for details on
directives that can be used in it. maddy uses reasonable cipher suites and TLS
versions by default so you generally don't have to worry about it.

*Syntax*: ++
    log _targets..._ ++
    log off ++
*Default*: stderr

Write log to one of more "targets".

The target can be one or the following:

- stderr

	Write logs to stderr.

- stderr_ts

	Write logs to stderr with timestamps.

- syslog

	Send logs to the local syslog daemon.

- _file path_

	Write (append) logs to file.

Example:
```
log syslog /var/log/maddy.log
```

*Note:* Maddy does not perform log files rotation, this is the job of the
logrotate daemon. Send SIGUSR1 to maddy process to make it reopen log files.

*Syntax*: debug _boolean_ ++
*Default*: no

Enable verbose logging for all modules. You don't need that unless you are
reporting a bug.

# Authors

Maintained by Max Mazurov <fox.cpp@disroot.org>. Project includes contributions
made by other people.

Source code is available at https://github.com/foxcpp/maddy.

# See also

*maddy-config*(5) - Detailed configuration syntax description ++
*maddy-imap*(5) - IMAP endpoint module reference ++
*maddy-smtp*(5) - SMTP & Submission endpoint module reference ++
*maddy-targets*(5) - Delivery targets reference ++
*maddy-storage*(5) - Storage modules reference ++
*maddy-auth*(5) - Authentication modules reference ++
*maddy-filters*(5) - Message filtering modules reference ++
*maddy-tls*(5) - Advanced TLS client & server configuration