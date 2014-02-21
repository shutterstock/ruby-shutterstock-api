ruby-shutterstock-api

## Description

This client provides an easy way to interact with the [Shutterstock, Inc. API](http://api.shutterstock.com) which gives you access to millions of photos, illustrations and footage clips. You will need an API username and key from Shutterstock with the appropriate permissions in order to use this client.

The API operations are done within the context of a specific user/account. Below are some examples of how to use the API client.

## Installation

The Shutterstock API client can be installed as follows - .

```sh
git clone "git@github.com:shutterstock/ruby-shutterstock-api.git"
cd shutterstock-ruby-api-client
gem build shutterstock-client.gemspec
gem install shutterstock-client-0.0.1.gem
```

## Configuration

Configuration is done through call to the `ShutterstockAPI::Client` singleton.
The block is mandatory and if not passed, an ArgumentError will be thrown.
All subsequent calls will use these configuration options.

```ruby
require 'shutterstock-client'

ShutterstockAPI::Client.instance.configure do |config|
  config.api_username = "api_username"
  config.api_key = "sshhhhh secret"
  config.username = "username"
  config.password = "secret"
end
```

Note: This Shutterstock API client only supports basic authentication at the moment. Please see our [API documentation](http://api.shutterstock.com/) for more information.

# Customer

```ruby
customer = ShutterstockAPI::Customer.find(username: "username")    # gets a currently authenticated customer object
customer.lightboxes                               # array of current lightboxes
customer.lightboxes[0]                            # get the first lightbox object
customer.downloads                                # get downloads has, keyed on subscription id

# metadata
customer.account_id
```

# Lightbox

```ruby
lightbox = ShutterstockAPI::Lightbox.find(21722255)                  # get a lightbox object
lightbox.images                                     # array of images

# metadata
lightbox.confirmed?                                 # true
lightbox.name                                       # name of lightbox

## Create Lightbox
new_lightbox = ShutterstockAPI::Lightbox.create({username: "username", lightbox_name: "mynewlightbox"})

## Update Lightbox
ShutterstockAPI::Lightbox.update({id: 24349781, lightbox_name: "updatename"})

## Destroy Lightbox
ShutterstockAPI::Lightbox.destroy(id: 24349781)

## Add Image to Lightbox
ShutterstockAPI::Lightbox.add_image({lightbox_id: 123456, image_id: 987654321})
OR
lightbox = ShutterstockAPI::Lightbox.find(123456)
lightbox.add_image(image_id: 987654321)

## Add Image to Lightbox
ShutterstockAPI::Lightbox.remove_image({lightbox_id: 123456, image_id: 987654321})
OR
lightbox = ShutterstockAPI::Lightbox.find(123456)
lightbox.remove_image(image_id: 987654321)
```

# Image

```ruby
image = ShutterstockAPI::Image.find(id: 118139110)
image.sizes
image.sizes["preview"]
image.keywords

ShutterstockAPI::Image.find_similar(118139110, {:page_number => 2, :sort_order => 'random'})
image.find_similar[0]                 # the most similar image
image.find_similar.total_count        # count of similar images

purple_cats = ShutterstockAPI::Image.search("purple cat", {:page_number => 2, :sort_order => 'random'})
purple_cats[0].find_similar.total_count

```

# Tests
There are 2 ways to run the tests -

To run the tests using mocked responses, use
```ruby
rspec spec/
```

To run the tests using making real API requests, use
```ruby
VCR_OFF=1 SSTK_API_USERNAME='basicauthusername' SSTK_API_KEY='basicauthkey' SSTK_USERNAME='testuser' SSTK_PASSWORD='testpassword' rspec spec/
```
While using this method, use valid usernames and tokens otherwise it will result in broken tests

## Automation
If you would like to automatically run tests when files are chaged, run `bundle exec guard`.
This will monitor `lib` and `spec` and will run the appropriate tests.
You will want to run this in another terminal so you can switch to it upon saving a file to see the test results.
After a test runs, hit `ENTER` to re-run all tests.

# Style
We try to follow the [Github Styleguide][1] as much as possible.
To make this easier, there is a tool called `rubocop`.

You can invoke it via `rake rubocop` or run `rubocop --help` for more options.


[1]: https://github.com/styleguide/ruby
