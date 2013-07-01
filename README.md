# Ruby on Rails Tutorial: Sample Application

This is the sample application for [*Ruby on Rails Tutorial: Learn Rails by Example*](http://railstutorial.org/) by [Michael Hartl](http://michaelhartl.com/).

## Set up
* If you are using RVM, set up a gemset for this project. Git will ignore .rvmrc and .ruby-(gemset|version) files.
* `cp config/app_config.yml.skel app_config.yml` and then edit the app_config.yml file with your favorite settings. Nobody else should ever see this file, so consider it your playground. Use swearwords for passwords.
* `bundle install`
* `rake db:reset`
* `rake db:populate`
* `rake db:test:prepare` (loads a set of sample data to use)