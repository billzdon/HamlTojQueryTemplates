class EmbeddedExpression
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/ || [:nil?].include?(m.to_sym))}
  
  def initialize(target)
    @target = target
  end
  
  def method_missing(method, *args, &block)
    if [:to_query, :respond_to?, :is_a?, :kind_of?, :compact, :!, :to_param, :inspect, :to_s, :to_str].include?(method.to_sym)
      #new_target = @target.send(method, *args, &block) 
      #return new_target.is_a?(String) ? (@target = new_target) : new_target
      return @target.send(method, *args, &block)
    end
    method = (method == :class ? :klass : method)
    @target = EmbeddedExpression.new(@target.gsub('}', ".#{method}}"))
  end
  
end