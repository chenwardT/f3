F3 [![Build Status](https://travis-ci.org/chenwardT/f3.svg?branch=master)](https://travis-ci.org/chenwardT/f3)
===

A Full Featured Forum created with Ruby on Rails, backed by Postgres.

Developed with:

* Ruby 2.1.4
* Rails 4.2
* PostgreSQL 9.4

F3 is under active development; details contained in the following sections are likely to change.

Setup
=====

In the project root directory: 

    bundle install
    
A configuration file, `config/application.yml` must be created prior to performing the database
setup and must contain the following fields (values are examples and should be changed to meet
your settings):

    SECRET_KEY_BASE: "5d5f8974df82fe558a16b5fb6586e2eb4c045715ae49a7a10c0ff056350a7923dc761e3e80e5381498a1b235bd9ad0f2b66573f5cee455c60f7f6e0c50e8d1cc"
    SECRET_KEY_BASE_STAGING: "c6885894de9ca7281baa0fbee8adc736631afac5c742961f2e359e7f344801338d1c3e08f27a170350d8278f73c01459beffa7be27c52184d911ab673c02a1a6"
    DB_USER: "postgres_username"
    DB_PASS: "your_password"
    F3_EMAIL: "email@example.com"
    F3_EMAIL_PASS: "your_email_password"
    
`SECRET_KEY_BASE` values can be generated via:

    rake secret
    
`DB_USER` and `DB_PASS` are the login credentials for the Postgres account that will access your database.

`F3_EMAIL` and `F3_EMAIL_PASS` are the login credentials for the mailer; signup confirmation emails, etc
will be sent from this address.

Once your Postgres server is able to be connected to:

    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    
A script for (re)setting the dev database is provided in `bin/reset_dev_db`.

Do note that seed file contains "demo" data in addition to data that must be preloaded for F3 to operate,
such as a default _guest_ group that non-logged in users will be added to.

Screenshots
===========

[Forum Index](http://i.imgur.com/beCt7Su.png)

[Forum Show](http://i.imgur.com/Jd4OVUz.png)

[Topic View](http://i.imgur.com/ByvcnNc.png)

[User Profile View](http://i.imgur.com/WBs2RZ0.png)

[Merging Posts](http://i.imgur.com/xBZmVxV.png)

**Admin Site**

[View Forum Permissions](http://i.imgur.com/EyDrYKu.png)

[Edit Group](http://i.imgur.com/kHLFsto.png)

Tests
=====

Specs are written with mintest-rails and require factory_girl.

To run tests:

`bundle exec rake test`

Features
========

* Categories/Forums
    - CRUD
    - Hiding
    - Locking
    - Archiving
    - Infinite nesting of forums

* Topics
    - CRUD
    - Locking
    - Hiding
    - Pinning
    - Blocking new topics
        - via lock
        - via permissions

* Posts
    - CRUD
    - Blocking replies
        - via lock
        - via permissions

* Rich Text
    - Editor/Input
    - Pluggable formatters?
    - Emoji

* Users
    - Reputation system
    - User levels (post count, etc)
    - Flavor titles
    
* Usergroups
    - Global permissions
    - Forum-specific permissions w/support for inheritance

* Auditing
    - History of user actions

* Search
    - By user
    - By content

* Optimization
    - Caching
        - Rails-based
            - Page
            - Action
            - Fragment
            - Low-level
            - SQL
        - DB-backed
            - add'l columns for expensive attrs (e.g. page view counter)

Implementation
==============

Authentication
--------------

User authentication is performed by [Devise](https://github.com/plataformatec/devise), with support for guest users (not logged in).

Group Permissions
-----------------

User authorization is achieved with [Pundit](https://github.com/elabs/pundit).

A pessimistic group-based permission system is in place that allows specifying permissions at the group and forum levels with support for inheritance.
Any forum may inherit permissions from its parent. If a forum has no parent (i.e. it is a root forum) it may inherit from the group-wide permission set.

Administration
--------------

An administration panel is made available using [Active Admin](https://github.com/activeadmin/activeadmin).
It allows for CRUD operations on objects that are not well suited for editing via the inline moderation tools, such as editing permissions, creating groups, etc.

Auditing
--------

Actions performed on database-backed objects are logged via [PaperTrail](https://github.com/airblade/paper_trail).
The acting user, IP and user-agent are all logged. The object and changes performed on it are serialized as JSON (JSONB column type in postgres).

Infinite Forum Nesting
----------------------

Forums are structured via adjacency lists:

* Easy to add leaf nodes
* Relocation is simple - just change the forum's forum_id to point to a new parent forum
* pgsql supports WITH RECURSIVE for efficient querying
