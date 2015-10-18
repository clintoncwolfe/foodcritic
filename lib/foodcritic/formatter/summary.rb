module FoodCritic
  module Formatter
    # Default output showing a summary view.
    class Summary < BaseFormatter
      # Output a summary view only listing the matching rules, file and line
      # number.
      #
      # @param [Review] review The review to output.
      def review_finished(review)
        @output.puts review.to_s
      end
    end
  end
end
