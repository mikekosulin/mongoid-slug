# frozen_string_literal: true

require 'bundler/setup'

require 'rspec'
require 'rspec/its'
require 'uuid'
require 'active_support'
require 'active_support/deprecation'
require 'mongoid'

require File.expand_path '../lib/mongoid/slug', __dir__

module Mongoid
  module Slug
    module UuidIdStrategy
      def self.call(id)
        id =~ /\A([0-9a-fA-F]){8}-(([0-9a-fA-F]){4}-){3}([0-9a-fA-F]){12}\z/
      end
    end
  end
end

def database_id
  ENV['CI'] ? "mongoid_slug_#{Process.pid}" : 'mongoid_slug_test'
end

Mongoid.configure do |config|
  config.connect_to database_id
end

%w[models shared].each do |dir|
  Dir["./spec/#{dir}/*.rb"].sort.each { |f| require f }
end

I18n.available_locales = %i[en nl]

RSpec.configure do |c|
  c.raise_errors_for_deprecations!

  c.before(:all) do
    Mongoid.logger.level = Logger::INFO
    Mongo::Logger.logger.level = Logger::INFO
  end

  c.before(:each) do
    Author.create_indexes
    Book.create_indexes
    AuthorPolymorphic.create_indexes
    BookPolymorphic.create_indexes
    PageWithCategories.create_indexes
  end

  c.after(:each) do
    Mongoid::Clients.default.database.drop
  end
end
