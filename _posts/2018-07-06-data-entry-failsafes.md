---
title: "A data entry form with failsafes"
layout: post
tags: [data entry]
category: [Design]
---

I'm currently working on a large longitudinal
project as a programmer/analyst. Most of the
data are collected using paper/pencil tasks
and questionnaires and need to be entered 
into the database by student assistants.
In previous projects, this led to some
minor irritations since some assistants
occasionally entered some words with
capitalisation and others without, or they
inadvertently added a trailing space to
the entry, or used participant IDs that
didn't exist -- all small things that
cause difficulties during the analysis.

To reduce the chances of such mishaps in the current
project, I created an on-line platform that
uses HTML, JavaScript and PHP to homogenise
how research assistants can enter data and that
throws errors and warnings when they enter impossible
data. Nothing that will my name pop up at Google board
meetings, but useful enough.

Anyway, you can download a slimmed-down version
of this platform 
[here](http://taal.ch/DataEntryForm/DataEntryPlatform.zip).
The comments in the PHP files should tell you what
I try to accomplish; if something's not clear, there's
a comment section at the bottom of this page.
You'll need a webserver that supports PHP,
and you'll need to change the permissions of the `Data`
directory to `777`.

You can also check out the [demo](http://taal.ch/DataEntryForm/).
To log in, use one of the following 
e-mail addresses:
`first.assistant@university.ch`,
`second.assistant@university.ch`,
`third.assistant@university.ch`. 
(You can change the accepted e-mail addresses in `index.php`).
The password is `projectpassword`.

Then enter some data. You can only enter
data for participants you've already created an ID for,
though. For this project, the participant IDs
consist of the number 4 or 5 (= the participant's grade), followed by a dot,
followed by a two digit number between 0 and 39 (= the participant's class),
followed by a dot and another two digit number between
0 and 99. The entry for `Grade` needs to match the
first number in `ID`.

If you enter task data for a participant for whom
someone has already task data at that data collection wave,
you'll receive an error. You can override this error
by ticking the `Correct existing entry?` box at the bottom.
This doesn't overwrite the existing entry, but adds the
new entry, which is flagged as the accurate one.
During the analysis, you can then filter out data that
was later updated.

Hopefully this is of some use to some of you!
