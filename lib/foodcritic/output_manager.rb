require 'fileutils'

# Load all core formatters
Dir.glob(File.dirname(__FILE__) + '/formatter/*.rb') { |file| require_relative file}

module FoodCritic
  # Reporting manager class
  class OutputManager
    attr_accessor :options

    # Create a new instance
    #
    # @param [Hash] options The configuration options from CLI invocation
    def initialize(options)
      @options = options
      do_requires
    end


    def validate_formatters

      # If no formatters supplied, default to Summary.  This should probably be somewhere else.
      options[:formatters] << 'Summary' if options[:formatters].empty?

      # If no destinations supplied, assume stdout.
      options[:formatter_destinations] << '-' if options[:formatter_destinations].empty?
      
      # Must have exactly the same number of dests as formatters.
      return false unless options[:formatter_destinations].length == options[:formatters].length

      # OK, try to instantiate each requested formatter.
      options[:formatters].each do |formatter_name|
        # Hrm, throws exception on fail.
        instantiate_formatter(formatter_name)
      end

      return true
    end

    
    # Perform all output, using the Review
    #
    # @param [Review] review The review objects with the results to report on
    # @param [FixNum] status The exit code of the pass
    def output_all(review, status = 0)

      # Walk pairwise through the formatters and destinations
      for i in 0 .. options[:formatters].length - 1

        dest = options[:formatter_destinations][i]
        if dest.respond_to? :puts then
          dest = dest
        elsif dest == '-' then
          dest = $stdout
        else
          FileUtils.mkdir_p(File.dirname(dest))
          dest = File.open(dest, 'w')
        end
        
        formatter = instantiate_formatter(options[:formatters][i], dest)

        if review.is_a? Review then
          formatter.review_finished(review, status)
        else
          formatter.review_aborted(review.to_s, status)
        end
          
        dest.close
      end
    end

    private

    def do_requires
      if options.has_key?(:require) then
        begin
          require options[:require]
        rescue
          raise "unable to require #{options[:require]}"
          fail
        end
      end
    end
    
    # instantiate a formatter
    def instantiate_formatter(formatter_name, io = $stdout)
      unless formatter_name.include?('::')
        formatter_name = 'FoodCritic::Formatter::' + formatter_name
      end
      begin
        formatter = formatter_name.split('::').map do |word|
          @last = @last ? @last : Object
          @last = @last.const_get(word)
        end.last.new(io)
      rescue
        raise "Unable to create instance of formatter #{formatter_name}"
      end
      if ! (formatter.respond_to?(:review_finished)) then
        raise "#{formatter_name} is not a formatter!"
      end
      formatter
    end

  end
end
