require 'rake'
require 'rake/tasklib'

module FoodCritic
  module Rake
    class LintTask < ::Rake::TaskLib
      attr_accessor :name, :files, :options

      def initialize(name = :foodcritic)
        @name = name
        @files = [Dir.pwd]
        @options = {}
        yield self if block_given?
        define
      end


      def define
        desc 'Lint Chef cookbooks' unless ::Rake.application.last_comment
        task(name) do
          result = FoodCritic::Linter.new.check(options.merge(default_options))
          OutputManager.new(options).output_all(result)
          abort if result.failed?
        end
      end

      private
      def default_options
        {
          fail_tags: ['correctness'], # differs to default cmd-line behaviour
          cookbook_paths: files,
          exclude_paths: ['test/**/*', 'spec/**/*', 'features/**/*'],
          chef_version: FoodCritic::Linter::DEFAULT_CHEF_VERSION
        }
      end
    end
  end
end
