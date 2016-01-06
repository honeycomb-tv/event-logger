# logger

Based on:

https://blog.logentries.com/2015/07/ditch-the-debugger-and-use-log-analysis-instead/

Log entries to a standard `name=value` format.

e.g.

    type=job name=upload_material_job job_id=2949ad19-6c2a-4aec-b097-47a81ce629d3 state=enqueued materialid=TST/TEST017/015 material_id=8410 upload_id=537

# Log Elements and Format

A log entry _must_ contain a `name` and a `state`.

Names should come from a controlled vocabulary

Valid states are:

* `enqueued` - Enqueued waiting to be started
* `started` - Process has started
* `mark` - Useful way point or event 
* `completed` - Process has completed
* `failed` - Process has failed

If available is should log the `correlation_id`.  This is used for related activities that take place across process boundaries.  For example, `archive-material` archives a new Original Master `TTB-GODD004-030.mxf` to S3 and then makes a request to the API for it to be ingested.

Once ingested jobs are enqueued for the production of the Destination Masters, Slate, Proxy and Thumbnails.

So when we put the logs together from `sky-sig-01.prod`, `hon-api-01.prod`, `hon-que-01.prod`, `hon-qtm-01.prod` and we should see something like:

    sky-sig-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=started
    hon-api-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=started
    hon-api-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=enqueued
    hon-api-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=enqueued
    hon-que-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=started
    hon-qtm-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=started
    hon-que-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=completed
    hon-qtm-01.prod correlation_id=68a0296f-0d59-4b36-ba34-48073a8e1d6b name=  state=completed

TBD - Vantage hostname and logging