F3 [![Build Status](https://travis-ci.org/chenwardT/f3.svg?branch=master)](https://travis-ci.org/chenwardT/f3)
===

A Full Featured Forum created with Ruby on Rails, backed by Postgres.

Developed with:

* Ruby 2.1.4
* Rails 4.2.1
* PostgreSQL 9.3

F3 is under active development; details contained in the following sections are likely to change.

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

Infinite Forum Nesting
----------------------

Forums are structures via adjacency lists:

* Easy to add leaf nodes
* Relocation is simple
* pgsql supports WITH RECURSIVE for efficient querying

Each Forum belongs to at most 1 Forum (forum_id).
If forum_id does not exist, then it is a “top-level forum”.
If forum_id does exist, then it is a “sub-forum” that falls under the Forum with forum_id.

The Forum#index (the root forum view) presents all top-level forums and their immediate sub-forums in a table, with 1 section per top-level forum and a row per immediate sub-forum.
Sub-forums that are 3-deep (i.e. distance of 2 from top-level) are listed as text within their parent forum’s description (same row in the table, but perhaps on a 2nd line).
Forums that are 4-deep or greater not listed -- subject to change! Good forum design dictates an upper limit on depth (3-deep?).

A Forum#show displays the forum in question’s subforums as a table, if any exist.
The "subsubforums" are then listed on a single line within each subforum’s row.
