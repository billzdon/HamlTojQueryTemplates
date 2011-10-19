class EachStatement
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/)}
  
  attr_accessor :variable
  
  def initialize(statement, options = {})
    @statement = statement
    @variable = @statement.match(/\|.*\|/).to_a.first.gsub('|', '')
  end

  def end_each(options)
    "\n" + (0...spacing(options)).inject('') {|sum, element| sum + ' '} + "{{/each}} \n"
  end
  
  def to_s(options = {})
    called_on = split('.each').first.split('-').last.strip    
    called_on.gsub!("#{obj}.", '')
    gsub!(/-.*/, "= '{{each #{called_on}}}'\n")
    @statement.to_s(options.merge({:space_reduction => HamlFile.tabulation + options[:space_reduction]}))
  end
  
  protected
  
  def method_missing(method, *args, &block)
    @statement.send(method, *args, &block)
  end
  
end