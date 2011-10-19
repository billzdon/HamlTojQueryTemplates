class ControlFlowEmbeddedExpression
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/ || [:nil?].include?(m.to_sym))}
  
  def initialize(target)
    @target = target
  end
  
  #def method_missing(method, *args, &block)
  #  return @target.send(method, *args, &block) if [:!, :to_param, :inspect, :to_s, :to_str].include?(method.to_sym)
  #  @target = @target + ".#{method.to_s}"
  #end
  def method_missing(method, *args, &block)
    if [:to_query, :respond_to?, :is_a?, :kind_of?, :compact, :!, :to_param, :inspect, :to_s, :to_str].include?(method.to_sym)
      return @target.send(method, *args, &block)
    end
    method = (method == :class ? :klass : method)
    @target = ControlFlowEmbeddedExpression.new(@target + ".#{method.to_s}")
  end
  
end