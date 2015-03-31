# if RUBY_PLATFORM =~ /mswin|mingw32|windows/
#
# end

# Do not monkeypatch until RubyWMI has been loaded
if defined?(RubyWMI)
  module RubyWMI
    class Base
      # Monkeypatch to add ability to pass args
      def method_missing(name, *args)
        name = camelize(name.to_s)
        @win32ole_object.send(name, *args)
      end

      # Monkeypatch to rename IPAddress to IpAddress to properly call method
      def attributes
        if @attributes
          return @attributes
        else
          @attributes = {}
          @win32ole_object.properties_.each{ |prop|
            name  = prop.name
            name = 'IpAddress' if name == 'IPAddress'
            value = @win32ole_object.send(name)
            value = if prop.cimtype == 101 && value
              Time.parse_swbem_date_time(value)
            else
              value
            end
            @attributes[underscore(name)] = value
          }
          return @attributes
        end
      end
    end
  end
end
