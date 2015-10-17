
# Load all core formatters
Dir.glob(File.dirname(__FILE__) + '/formatter/*.rb') { |file| require_relative file}

module FoodCritic
  # Reporting manager class
  class Report
    attr_accessor :options

    # Create a new instance
    #
    # @param [Hash] options The configuration options
    def initialize(options)
      @options = options
    end

    # Perform the reporting
    #
    # @param [Review] review The review objects with the results to report on 
    def report(review)
      if review.is_a? Review then
        formatter = load_formatter(@options)
        formatter.destination = @options[:formatter_dest]
        formatter.output(review)
      else
        puts review.to_s
      end
    end

    private
    
    # Load the printer
    def load_formatter(options)
      if options.has_key?(:require) then
        begin
          require options[:require]
        rescue
          raise "unable to require #{options[:require]}"
          fail
        end
      end
      if options[:formatter] then
        unless options[:formatter].include?('::')
          options[:formatter] = 'FoodCritic::Formatter::' + options[:formatter]
        end
        begin
          formatter = options[:formatter].split('::').map do |word|
            @last = @last ? @last : Object
            @last = @last.const_get(word)
          end.last.new
        rescue
          raise "Unable to create instance of formatter #{options[:formatter]}"
        end
        if ! (formatter.respond_to?(:output) && formatter.respond_to?(:destination=)) then
          raise "#{options[:formatter]} is not a formatter!"
        end
      elsif options.has_key?(:context) && @options[:context] then
        # Handle deprecated -C option
        formatter = Formatter::Context.new
      else
        # Handle default formatter
        formatter = Formatter::Summary.new
      end
      formatter
    end

  end
end
