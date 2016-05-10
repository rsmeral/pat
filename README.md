# Project Activity Tracker

Simple extensible command line utility for aggregating events from services. Useful for tracking activity across teams and projects.

Currently supported services are *Github*, *JIRA*, *Bugzilla*, *Gitlab*, *IMAP*, and *CalDAV*.
Available formats include pretty plaintext and JSON.

**CAUTION: At this point, PAT has only a simplistic caching mechanism and will issue multiple HTTP requests per each combination of a person and service configuration every time it's invoked. It's only appropriate for sporadic personal use. The provided service configurations are not guaranteed to be comprehensive or even to return all data for the requested time period. Use with care.**

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
    -l persons|services|formats,     String
        --list                       list all configured persons, services or formats
    -q, --quiet                      no logging output
        --data-dir [path]            String
                                     path to directory with person and service configurations
```

For demonstration, one person and several services are preconfigured:
* [Github.com](http://github.com)
* [JBoss JIRA](http://issues.jboss.org)
* [Redhat Bugzilla](http://bugzilla.redhat.com)
* [GMail](http://gmail.com)
* [Google Calendar](http://calendar.google.com)

The simplest query which prints events that occurred in all services in the last week for the user `rsmeral` in plain text format, grouped by person and date:

    pat rsmeral

Query for events in the `jboss_jira` and `github_com` in the last 14 days, bypassing cache, formatting as JSON, without grouping, with all details for users `rsmeral` and `okiss`:

    pat -s jboss_jira,github_com -d 14 -f -r json -g "" -v rsmeral okiss


### Use for Team Work Tracking

One way to use `pat` is for tracking events across a team of people across several services. 

For example, imagine you have three people in the team &mdash; _Alice_, _Bob_, and _Charlie_. They all use _JIRA_ for issue tracking, but Alice and Bob contribute to repositories in _Github_, and Charlie contributes to Gitlab. The username in JIRA is the first name in lower case, however, they each use a different user name in Gitlab and Github. 

First, configure Gitlab, Github, and JIRA in the `data/service` folder. 

* Set the instance URL of Gitlab.
  
    ```yaml
    --- !ruby/object:GitlabService
    id: example_gitlab
    instance_url: https://gitlab.example.com
    ```

* If you need to see activity on private projects in Github, set the personal access token.
    
    ```yaml
    --- !ruby/object:GithubService
    id: github_com
    token: a1b2c3d4e5f6
    ```

* If you need to see activity on private projects in JIRA, set the user name and password.
  
    ```yaml
    --- !ruby/object:JiraService
    id: jboss_jira
    instance_url: https://issues.jboss.org
    api_path: /rest/api/latest
    user: dave
    password: pass123
    ```

Next, create profiles for users in `data/person`. This wouldn't be necessary if everybody used all services, and the same user name in each one.

Alice:

```yaml
--- !ruby/object:Person
id: alice
name: Alicia
service_mappings:
  jboss_jira: alice
  github_com: jabberwock
```

Bob: 

```yaml
--- !ruby/object:Person
id: bob
name: Bobby
service_mappings:
  jboss_jira: bob
  github_com: roberto
```

Charlie:

```yaml
--- !ruby/object:Person
id: charlie
name: Charles
service_mappings:
  jboss_jira: charlie
  cee_gitlab: harley
```

Now you can track the activity for this team by simply invoking:

    ./pat
    
`pat` scans the `data/person` folder, and then queries each service configured for that person in their `service_mappings`.

You can create a separate data folder with configurations for different teams, and use the `--data-dir` option to point `pat` at the correct data folder.

### Use for Personal Tracking

Even though `pat` was originally intended as a team activity tracking tool, it can be easily used to generate a personal status report.

For example, to query my own activity in Github, JIRA, Gitlab, ang GMail for the past 7 days, I'd run:

    ./pat -d 7 -s github_com,jboss_jira,example_gitlab,gmail rsmeral

The IMAP service, and the provided GMail template are perhaps only suited for personal use. You must provide a user name and a password for the mailbox, and by default it searches the Sent folder for all messages sent during the given time range.

## Configuration

All configuration files reside in `data` folder, which contains a `person` and `service` subfolders. These contain YAML representations of person and service configurations, respectively.
This program honors the _Convention over configuration_ principle and thus any queried person that is not configured is assumed to have the same username in all services. Once a person is configured, only the services listed in her `service_mappings` will be queried.

### Service configuration example
```
--- !ruby/object:JiraService
id: jboss_jira
instance_url: http://issues.jboss.org
api_path: /rest/api/latest
```
Only `id` is required. The individual properties may be different for each service. 

### User configuration
```
--- !ruby/object:Person
id: rsmeral
name: Ron Šmeral
service_mappings:
  jboss_jira: rsmeral
  github_com: rsmeral
  rh_bz: rsmeral
```
Only `id` and `name` are required.

