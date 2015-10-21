module FoodCritic
  module Formatter
    # Output to a file in checkstyle's xml format
    #
    # Useful with many CI environments that have support already for java checkstyle
    class CheckStyle < BaseFormatter

      # Output the checkstyle formatted xml
      # number.
      #
      # @param [Review] review The review to output.
      # @param [FixNum] status The exit code of the pass
      def review_finished(review, status = 0)
        # TODO - foodcritic deps on Nokogiri, should probably port this over 
        output.write "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<checkstyle version=\"5.0\">\n"
        review.warnings_by_file_and_line.each do |file, line|
          output.write "  <file name=\"#{file}\">\n"
          line.each do |line, violations|
            violations.each do |rule|
              severity = rule.tags.include?('correctness') ? 'error' : 'warning'
              source = rule.source.source_location.join(':') + ':RULE.' + rule.code
              output.write "    <error line=\"#{line}\" severity=\"#{severity}\" message=\"#{rule.code}: #{rule.name}\" source=\"#{source}\"/>\n"
            end
          end
          output.write "  </file>\n"
        end
        output.write '</checkstyle>'
      end

    end
  end 
end
