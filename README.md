# Mods

[<img src="https://secure.travis-ci.org/sul-dlss/mods.png?branch=master" alt="Build Status"/>](http://travis-ci.org/sul-dlss/mods) [![Code Climate Test Coverage](https://codeclimate.com/github/sul-dlss/mods/badges/coverage.svg)](https://codeclimate.com/github/sul-dlss/mods/coverage) [<img
src="https://gemnasium.com/sul-dlss/mods.png" alt="Dependency Status"/>](https://gemnasium.com/sul-dlss/mods) [<img
src="https://badge.fury.io/rb/mods.svg" alt="Gem Version"/>](http://badge.fury.io/rb/mods)

A Gem to parse MODS (Metadata Object Description Schema) records.  More information about MODS can be found at
[Library of Congress](http://www.loc.gov/standards/mods/registry.php).

Source code at [github](https://github.com/sul-dlss/mods/)

Generated API docs at [rubydoc.info](http://rubydoc.info/github/sul-dlss/mods/)

## Installation

Add this line to your application's Gemfile:

    gem 'mods'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mods

## Usage

Create a new Mods::Record from a url:
```ruby
foo = Mods::Record.new.from_url('http://purl.stanford.edu/bb340tm8592.mods')
```

Create a new Mods::Record from a file:
```ruby
foo = Mods::Record.new.from_file('/path/to/mods/file.xml')
```

## Contributing

1.  Fork it
2.  Create your feature branch (`git checkout -b my-new-feature`)
3.  Write code and tests.
4.  Commit your changes (`git commit -am 'Added some feature'`)
5.  Push to the branch (`git push origin my-new-feature`)
6.  Create new Pull Request

## Releases

*   (see git commit history for more recent info)
*   **2.0.1** Fixed nokogiri issue so no need to pin version number
*   **2.0.0** Pinned version of nokogiri to < 1.6.6 because of addition of
    Node#lang in 1.6.6.1 which conflicts which currently used nodes
*   **1.0.0** change jruby version in .travis to 1.7.9-d19; doesn't work with version 1.7.10
*   **0.0.23** minor bug and typo fixes
*   **0.0.22** add displayLabel and lang attributes to every element
*   **0.0.21** bug fix to check for nil values in name nodes
*   **0.0.21** Check for the possibility that name_node.display_value is nil
*   **0.0.20** added translated_value convenience method to geographicCode
    (mods.subject.geographicCode.translated_value)
*   **0.0.19** term_values and term_value method added to Record object
*   **0.0.18** <subject><temporal> cannot have subelements
*   **0.0.17** add display_value and display_value_w_date to name node; add
    personal_names_w_dates to record
*   **0.0.16** add role convenience methods (within name node)
*   **0.0.15** make namespace aware processing the default
*   **0.0.14** don't lose xml encoding in reader.normalize_mods under jruby
*   **0.0.13** really really fix removal of xsi:schemaLocation in jruby
*   **0.0.12** fix failing jruby test
*   **0.0.11** fix remove xsi:schemaLocation attribute from mods element when not using namespaces
*   **0.0.10** remove xsi:schemaLocation attribute from mods element when not using namespaces
*   **0.0.9** implement from_nk_node as way to load record object
*   **0.0.8** implement relatedItem and attributes on all simple top level elements
*   **0.0.7** implement part
*   **0.0.6** implement recordInfo, fix to work under jruby
*   **0.0.5** implement subject, change a few constants
*   **0.0.4** implement language, location, origin_info, physical_description
*   **0.0.3** use nom-xml gem and make this more nokogiri-ish; implement name,
    title, and simple top level elements with no subelements
*   **0.0.2** Set up rake tasks, publishing rdoc, and continuous integration.
*   **0.0.1** Grab the name
