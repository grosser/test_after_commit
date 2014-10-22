Make after_commit callbacks fire in tests for Rails 3+ with transactional_fixtures = true.

Install
=======

    gem install test_after_commit

    # Gemfile (never include in :development !)
    gem 'test_after_commit', :group => :test

Usage
=====
Test that the methods get called or the side-effect of the methods, something like:

```Ruby
class Car < ActiveRecord::Base
  after_commit :foo, :on => :update

  def foo
    $foo = 1
  end
end

...

it "sets $foo on commit" do
  $foo.should == nil
  car.save!
  $foo.should == 1
end
```

TIPS
====
 - hooks do not re-raise errors (with or without this gem) use [after_commit_exception_notification](https://github.com/grosser/after_commit_exception_notification)

Author
======

Inspired by https://gist.github.com/1305285

### [Contributors](https://github.com/grosser/test_after_commit/contributors)
 - [James Le Cuirot](https://github.com/chewi)
 - [emirose](https://github.com/emirose)
 - [Brad Gessler](https://github.com/bradgessler)
 - [Rohan McGovern](https://github.com/rohanpm)
 - [lsylvester](https://github.com/lsylvester)
 - [Tony Novak](https://github.com/afn)
 - [Brian Palmer](https://github.com/codekitchen)

[Michael Grosser](http://grosser.it)<br/>
michael@grosser.it<br/>
License: MIT<br/>
[![Build Status](https://travis-ci.org/grosser/test_after_commit.png)](https://travis-ci.org/grosser/test_after_commit)
