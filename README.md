# GoStatic

## An image generation plugin for Ruby on Rails

GoStatic uses the shell utility [wkhtmltoimage](http://code.google.com/p/wkhtmltopdf/) to serve a PDF file to a user from HTML.  In other words, rather than dealing with a PDF generation DSL of some sort, you simply write an HTML view as you would normally, then let Wicked take care of the hard stuff.

_GoStatic has been verified to work on Ruby 1.8.7 and 1.9.2; Rails 2 and Rails 3_

### Installation

First, be sure to install [wkhtmltoimage](http://code.google.com/p/wkhtmltopdf/) version 0.10.0.rc2.
This plugin relies on streams to communicate with wkhtmltoimage.

More information about [wkhtmltoimage](http://code.google.com/p/wkhtmltopdf/) could be found [here](http://madalgo.au.dk/~jakobt/wkhtmltoxdoc/wkhtmltoimage-0.10.0_rc2-doc.html).

Next:

    script/plugin install git://github.com/lleirborras/go_static.git
    script/generate go_static

or add this to your Gemfile:

    gem 'go_static'

### Basic Usage

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.png do
            render :png => "file_name"
          end
        end
      end
    end

### Advanced Usage with all available options

    class ThingsController < ApplicationController
      def show
        respond_to do |format|
          format.html
          format.png do
            render :png                            => 'file_name',
                   :disposition	                   => 'attachment'                 # default 'inline'                   
          end
        end
      end
    end

By default, it will render without a layout (:layout => false) and the template for the current controller and action.
