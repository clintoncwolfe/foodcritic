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
      # @param [FixNum] status The exit code of the pass
      #
      # @return [void]
      def review_finished(review, status = 0)
      end

      # @api public
      #
      # Invoked after the FoodCritic review is aborted;
      #  the review is just a string.  May also be called
      #  when --version is called.
      #
      # @param review_string [String]
      #   Some kind of error or usage string.
      # @param [FixNum] status The exit code of the pass
      #
      # @return [void]
      def review_aborted(review_string, status = 0)
        output.puts review_string
      end
      
    end
  end
end
