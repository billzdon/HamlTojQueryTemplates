class IfStatement
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/)}
  
  def initialize(statement, options = {})
    @statement = statement
  end
  
  def end_if(options = {:space_reduction => 0})
    "\n" + (0...spacing(options)).inject('') {|sum, element| sum + ' '} + "{{/if}} \n"
  end
  
  def to_s(options = {})
    @statement.gsub!(/(-[ ]*if)/, "= '{{if ' + ")
    @statement.gsub!(/[ ]+(#{@statement.obj})\./, "#{@statement.obj}_control_flow.")
    @statement.gsub!('==', "+ ' == ' +")
    @statement.target = insert(last_character, " + '}}'")
    @statement.to_s(options.merge({:space_reduction => HamlFile.tabulation + options[:space_reduction]}))
  end
  
  protected
  
  def method_missing(method, *args, &block)
    @statement.send(method, *args, &block)
  end
  
end