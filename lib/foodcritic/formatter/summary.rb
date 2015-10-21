module FoodCritic
  module Formatter
    # Default output showing a summary view.
    class Summary < BaseFormatter
      # Output a summary view only listing the matching rules, file and line
      # number.
      #
      # @param [Review] review The review to output.
      # @param [FixNum] status The exit code of the pass
      def review_finished(review, status = 0)
        @output.puts review.to_s
      end
    end
  end
end
