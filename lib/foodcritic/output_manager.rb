
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
    def output_all(review)

      if review.is_a? Review then
        # Walk pairwise through the formatters and destinations
        for i in 0 .. options[:formatters].length - 1
          formatter = instantiate_formatter(options[:formatters][i])
          formatter.destination = options[:formatter_destinations][i] unless options[:formatter_destinations][i] == '-'
          formatter.output(review)
        end
      else
        puts review.to_s
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
    def instantiate_formatter(formatter_name)
      unless formatter_name.include?('::')
        formatter_name = 'FoodCritic::Formatter::' + formatter_name
      end
      begin
        formatter = formatter_name.split('::').map do |word|
          @last = @last ? @last : Object
          @last = @last.const_get(word)
        end.last.new
      rescue
        raise "Unable to create instance of formatter #{formatter_name}"
      end
      if ! (formatter.respond_to?(:output) && formatter.respond_to?(:destination=)) then
        raise "#{formatter_name} is not a formatter!"
      end
      formatter
    end

  end
end
