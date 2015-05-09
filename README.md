README
======

Developed with:

* Ruby 2.1.4
* Rails 4.2.1
* PostgreSQL 9.3

Screenshots
===========

[Forum Index](http://i.imgur.com/5SNXbEg.png)

[Individual Forum](http://i.imgur.com/CUBIoKL.png)

[Individual Topic](http://i.imgur.com/LHEAK7L.png)

[Post New Topic](http://i.imgur.com/Ghdk0P9.png)

[Member List](http://i.imgur.com/wKgiaAF.png)

Design
======

Data Models
-----------

[Rails Model Relationship Diagram](http://i.imgur.com/dZT4LEL.png)

* User
    - has many Posts
    - belongs to many Groups
    - using Devise
    - attributes
        - username
        - email
        - password
        - birthday
        - timezone
        - photo
        - country
        - quote
        - external URLs (social networks, etc)
        - bio
        - signature (and/or flair, etc)
        - site options
    - computed attrs
        - recent posts
        - post count
        - avg posts
        - per day
        - per week

* Group
    - has many Users
    - permissions?

* Forum
    - may belong to a Forum
    - has many Topics
    - attributes
        - title
        - description
        - locked
        - hidden
    - computed attrs
        - no. of views
            - per-user
            - total

* Topic
    - belongs to a Forum
    - has many Posts
    - what happens when deleted? options:
        - entire thread is deleted
        - exported/moved to hidden archives
    - attributes
    - title
    - slug
    - locked
    - hidden
    - pinned
    - computed attrs
        - no. of views
        - no. of replies
        - last post
        - user
        - timestamp

* Post
    - belongs to a User
    - belongs to a Topic
    - what happens when deleted? options:
        - author + body is blanked out/replaced with “deleted” text
    - attributes
        - body
        - slug?
        - timestamps
        - created
        - modified


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
    - Permissions
    - Listing
    - Reputation
    - User levels (post count, etc)
    - Flavor titles

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

Going with an adjacency list for forum hierarchy

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


Tests
=====

TODO after solid groundwork is laid.