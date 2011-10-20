class TemplatePresenter
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/ || [:nil?].include?(m.to_sym))}
      
  def initialize(options = {:control_flow => false})
    @control_flow = options[:control_flow]
  end

  def method_missing(method, *args, &block)
    return "".send(method, *args, &block) if [:to_query, :inspect, :to_s, :to_str].include?(method.to_sym)
    # special cases
    method = (method == :class ? :klass : method)
    return InflectorExpression.new("${#{method}}") if method == :model_name
    # default
    @control_flow ? ControlFlowEmbeddedExpression.new(method.to_s) : EmbeddedExpression.new("${#{method}}")
  end
  
end