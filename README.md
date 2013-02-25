Project Activity Tracker
========================

Simple extensible command line utility for retrieving events from services. Useful for tracking activity across teams and projects.

Currently supported services are *Github*, *JIRA* and *Bugzilla*.

## Usage

```
pat [OPTIONS] PERSON [PERSON...]

Options

    -v, --verbose                    turns on long output
    -f, --force-update               bypass cache
    -h, --help                       help
    -s, --services [x,y,z]           Array
                                     comma-separated list of services to query; default: all
    -d, --days [n]                   Numeric
                                     number of past days from today to query; default: 7
    -r, --renderer [format]          String
                                     output format; fallback to plaintext if not found
    -g [person,date,service],        Array
        --group                      comma-separated list; two element permutation
                                     of person,date,service; specifies grouping of events on output
    -l persons|services|formats,     list all configured persons, services or formats
        --list
```

For demonstration, 2 persons and three services are preconfigured:
* [Github.com](http://github.com)
* [JBoss JIRA](http://issues.jboss.org)
* [Redhat Bugzilla](http://bugzilla.redhat.com)

The simplest query which prints events that occurred in all services in the last week for the user `rsmeral` in plain text format, grouped by person and date:
    pat rsmeral

Query for events in the `jboss_jira` in the last 2 weeks, bypassing cache, formatting as JSON, without grouping, with all details for users rsmeral and okiss:
    pat -s jboss_jira -d 14 -f -r json -g "" -v rsmeral okiss

## Configuration

All configuration files reside in `lib/data`, which contains a `person` and `service` subfolders. These contain YAML representations of person and service configurations, respectively.
This program honors the _Convention over configuration_ principle and thus any queried person that is not configured is assumed to have the same username in all services. Once a person is configured, only the services listed in her `service_mappings` will be queried.

A service configuration might look like the following:
```
--- !ruby/object:JiraService
id: jboss_jira
instance_url: http://issues.jboss.org
api_path: /rest/api/latest
```
The individual properties may be different for each service. 

A user configuration:
```
--- !ruby/object:Person
id: rsmeral
name: Ron Smeral
service_mappings:
  jboss_jira: rsmeral
  github_com: rsmeral
  rh_bz: rsmeral@redhat.com
```