Make after_commit callbacks fire in tests for Rails 3+ with transactional_fixtures = true.

Install
=======

    gem install test_after_commit

    # Gemfile
    gem 'test_after_commit', :group => :test

TIPS
====
 - hooks do not re-raise errors (with or without this gem)

Author
======

Inspired by https://gist.github.com/1305285

### [Contributors](https://github.com/grosser/test_after_commit/contributors)
 - [James Le Cuirot](https://github.com/chewi)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/test_after_commit.png)](https://travis-ci.org/grosser/test_after_commit)
