module Temple
  module Parsers
    class ERB
      include Mixins::Options

      ERB_PATTERN = /(<%%|%%>)|<%(==?|\#)?(.*?)?-?%>/m

      ESCAPED = {
        '<%%' => '<%',
        '%%>' => '%>',
      }.freeze

      def compile(input)
        result = [:multi]
        pos = 0
        input.scan(ERB_PATTERN) do |escaped, indicator, code|
          m = Regexp.last_match
          text = input[pos...m.begin(0)]
          pos  = m.end(0)
          result << [:static, text] if !text.empty?
          if escaped
            result << [:static, ESCAPED[escaped]]
          else
            case indicator
            when '#'
              code.count("\n").times { result << [:newline] }
            when /=/
              result << (indicator.length > 1 || !options[:auto_escape] ? [:dynamic, code] : [:escape, :dynamic, code])
            else
              result << [:block, code]
            end
          end
        end
        result << [:static, input[pos..-1]]
      end
    end
  end
end
