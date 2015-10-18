module FoodCritic
  module Formatter
    class BaseFormatter
      attr_reader :output

      # @api public
      #
      # @param output [IO]
      #   `$stdout` or opened file
      def initialize(output)
        @output = output
      end

      # @api public
      #
      # Invoked after the FoodCritic review is finished.
      #
      # @param review [Review]
      #   the finished FoodCritic::Review object.
      #
      # @return [void]
      def review_finished(review)
      end

      # @api public
      #
      # Invoked after the FoodCritic review is aborted;
      #  the review is just a string.
      #
      # @param review_string [String]
      #   Some kind of error.
      #
      # @return [void]
      def review_aborted(review_string)
        puts review_string
      end
      
      
    end
  end
end
