# Open Hash to add our goodies
class Hash
  def transform_keys
    h = {}
    each_key do |k|
      h[yield(k)] = self[k]
    end
    h
  end

  def symbolize_keys
    transform_keys { |k| k.respond_to?(:to_sym) ? k.to_sym : k.to_s.to_sym }
  end
end
