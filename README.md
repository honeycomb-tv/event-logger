# event-logger

Log entries to a standard `JSON` format.

e.g.

    { "type": "job", "name": "upload_material_job", "job_id": "2949ad19-6c2a-4aec-b097-47a81ce629d3", "state": "enqueued", "material_id": "TST/TEST017/015" }

Based on:

[Ditch the Debugger and use Log Analysis Instead](https://blog.logentries.com/2015/07/ditch-the-debugger-and-use-log-analysis-instead/) by Matthew Skelton.

# Log Elements and Format

A log entry _must_ contain a `name` and a `state`.

Names should come from a controlled vocabulary

Valid states are:

* `enqueued` - Enqueued waiting to be started
* `started` - Process has started
* `mark` - Useful way point or event 
* `completed` - Process has completed
* `failed` - Process has failed

If available is should log the `correlation_id`.  This is used for related activities that take place across process boundaries.  

For example, `archive-material` archives a new Original Master `TTB-GODD004-030.mxf` to S3 and then makes a request to the API for it to be ingested.

Once ingested jobs are enqueued for the production of the Destination Masters, Proxy and Thumbnails before finally being delivered to Discovery and Channel 5.

So when we put the logs together from `sky-sig-01.prod`, `hon-web-01.prod`, `hon-que-01.prod`, `hon-qtm-01.prod` and we should see something like:

    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"process-new-material", "state":"started", "av-file":"TTB-GODD004-030.mxf", "sidecar":"TTB-GODD004-030.xml"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"archive-av-file-to-s3", "state":"started"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"archive-av-file-to-s3", "state":"completed", "archive-path":"s3:/path/to/file/TTB-GODD004-030.mxf"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"archive-sidecar-to-s3", "state":"started"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"archive-sidecar-to-s3", "state":"completed", "archive-path":"s3:/path/to/file/TTB-GODD004-030.xml"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"request-ingest", "state":"mark"}
    sky-sig-01.prod {"correlation_id":"68a0296f", "name":"process-new-material", "state":"completed", "av-file":"TTB-GODD004-030.mxf", "sidecar":"TTB-GODD004-030.xml"}

    hon-web-01.prod {"correlation_id":"68a0296f", "name":"ingest", "state":"enqueued", "clock":"TTB/GODD044/030"}
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"ingest", "state":"started", "clock":"TTB/GODD044/030"}
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"ingest", "state":"completed", "clock":"TTB/GODD044/030"}

    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-thumbnails", "state":"enqueued", "clock":"TTB/GODD044/030"}
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-proxies", "state":"enqueued", "clock":"TTB/GODD044/030"}
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-destination-master", "state":"enqueued", "clock":"TTB/GODD044/030", "destination":"Discovery"}
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-destination-master", "state":"enqueued", "clock":"TTB/GODD044/030", "destination":"Channel 5"}

    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-thumbnails", "state":"started", "clock":"TTB/GODD044/030"} 
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-thumbnails", "state":"completed", "clock":"TTB/GODD044/030"} 

    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-proxies", "state":"started", "clock":"TTB/GODD044/030"} 
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"make-proxies", "state":"completed", "clock":"TTB/GODD044/030"} 

    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"make-dm", "state":"started", "clock":"TTB/GODD044/030", "destination":"Discovery"}
    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"make-dm", "state":"completed", "clock":"TTB/GODD044/030", "destination":"Discovery"}

    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"make-dm", "state":"started", "clock":"TTB/GODD044/030", "destination":"Channel 5"}
    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"make-dm", "state":"completed", "clock":"TTB/GODD044/030", "destination":"Channel 5"}
    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"enqueued", "clock":"TTB/GODD044/030", "destination":"Discovery"} 
    hon-qtm-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"enqueued", "clock":"TTB/GODD044/030", "destination":"'Channel 5"} 
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"started", "clock":"TTB/GODD044/030", "destination":"Discovery"} 
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"completed", "clock":"TTB/GODD044/030", "destination":"Discovery"} 

    hon-que-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"started", "clock":"TTB/GODD044/030", "destination":"Channel 5"} 
    hon-que-01.prod {"correlation_id":"68a0296f", "name":"deliver-dm", "state":"completed", "clock":"TTB/GODD044/030", "destination":"Channel 5"}


# Usage

Include in your `Gemfile` with:

	gem 'event-logger'

Instantiate the logger e.g.:

	EventLogger.instance.logger = Logger.new(opts[:logfile] || STDOUT)
	
Then log with the `log` method e.g.:

## Mark:
	EventLogger.log(:process, name: 'ingest_material', state: 'mark', details: "ignoring: #{File.basename(mxf_file)}")
## Started:
	EventLogger.log(:process, name: 'ingest_material', state: 'started', clock_number: clock_number)
## Failed:
	EventLogger.log(:process, name: 'ingest_material', state: 'failed', details: 'cannot upload directory', severity: 'error')
## Completed:
	EventLogger.log(:process, name: 'ingest_material', state: 'completed', clock_number: clock_number, details: 'completed ingest with sidecar from s3')
