# Logstash Plugin

This is a plugin for [Logstash](https://github.com/elasticsearch/logstash).

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.

## Documentation

This plugin will allow you to store and retrive field data from logstash into a memcached instance. 
This is useful when quearying the same data multiple times against an outside source. For example, file hashs against virus total (Another plugin of mine)

To store:

```
input {
  generator {
    type => "generated"
    message => "Something to store"
    count => 1
  }
}

filter {
  memcached {
    namespace => 'test'
    host => "localhost:11211"
    key => "test"
    field => "message"
    ttl => 60
  }
}

output {
    stdout { codec => rubydebug }
}
```

To Retreive: 

```
input {
  generator {
    type => "generated"
    message => "Something else"
    count => 1
  }
}

filter {
  memcached {
    namespace => 'test'
    host => "localhost:11211"
    key => "test"
    field => "message1"
    retreive => true
  }
}

output {
    stdout { codec => rubydebug }
}
```

Putting it all together would look something like this:

```
input {
  generator {
    type => "generated"
    message => "Something to cache"
    count => 1
  }
}

filter {
  # First we try and retrieve from cache
  memcached {
    namespace => 'test'
    host => "localhost:11211"
    key => "test"
    field => "message1"
    retreive => true
  }
  if "cache_miss" in [tags] {
    # Since message1 was nil, it's not in the cache.
    # Normally, we'd add our filter here to populate the field, but this is an example :)
    memcached {
      namespace => 'test'
      host => "localhost:11211"
      key => "test"
      field => "message"
      ttl => 60
      remove_tag => "cache_miss"
    }
  }
}

output {
    stdout { codec => rubydebug }
}
```

## Need Help?

Need help? Try #logstash on freenode IRC or the logstash-users@googlegroups.com mailing list.

## Developing

### 1. Plugin Developement and Testing

#### Code
- To get started, you'll need JRuby with the Bundler gem installed.

- Create a new plugin or clone and existing from the GitHub [logstash-plugins](https://github.com/logstash-plugins) organization.

- Install dependencies
```sh
bundle install
```

#### Test

```sh
bundle exec rspec
```

The Logstash code required to run the tests/specs is specified in the `Gemfile` by the line similar to:
```ruby
gem "logstash", :github => "elasticsearch/logstash", :branch => "1.5"
```
To test against another version or a local Logstash, edit the `Gemfile` to specify an alternative location, for example:
```ruby
gem "logstash", :github => "elasticsearch/logstash", :ref => "master"
```
```ruby
gem "logstash", :path => "/your/local/logstash"
```

Then update your dependencies and run your tests:

```sh
bundle install
bundle exec rspec
```

### 2. Running your unpublished Plugin in Logstash

#### 2.1 Run in a local Logstash clone

- Edit Logstash `tools/Gemfile` and add the local plugin path, for example:
```ruby
gem "logstash-filter-awesome", :path => "/your/local/logstash-filter-awesome"
```
- Update Logstash dependencies
```sh
rake vendor:gems
```
- Run Logstash with your plugin
```sh
bin/logstash -e 'filter {awesome {}}'
```
At this point any modifications to the plugin code will be applied to this local Logstash setup. After modifying the plugin, simply rerun Logstash.

#### 2.2 Run in an installed Logstash

- Build your plugin gem
```sh
gem build logstash-filter-awesome.gemspec
```
- Install the plugin from the Logstash home
```sh
bin/plugin install /your/local/plugin/logstash-filter-awesome.gem
```
- Start Logstash and proceed to test the plugin

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to me that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elasticsearch/logstash/blob/master/CONTRIBUTING.md) file.
