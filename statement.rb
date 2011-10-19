class Statement
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/ || m == :nil?)}
  
  attr_accessor :children, :parent, :target, :obj
  
  def initialize(target, options = {})
    @target = target
    @children = options[:children] || []
    @parent = options[:parent]
    @obj = options[:with]
  end
  
  def parent(target_spacing = nil)
     return @parent if target_spacing.nil?
     target_parent = self
     target_parent = target_parent.parent until target_parent.spacing == target_spacing
     target_parent
  end

  # no memoization because this could change  
  def spacing(options = {:space_reduction => 0})
    @spacing = length - lstrip.length# - options[:space_reduction]
  end
  
  def if_statement?
    @if_statement ||= (matches = match(/^[ ]*(-[ ]*if)/).to_a and matches.first)
  end
  
  def else_statement?
    @else_statement ||= (matches = match(/^[ ]*(-[ ]*else)/).to_a and matches.first)
  end
  
  def elsif_statement?
    @elsif_statement ||= (matches = match(/^[ ]*(-[ ]*elsif)/).to_a and matches.first)
  end
  
  def each_statement?
    @each_statement ||= (matches = match(/^[ ]*(-.*each)/).to_a and matches.first)
  end
  
  def template_render(options = {:space_reduction => 0})
    # need more robust logic for this each block variable substitute, this shouldn't be in template_render
    if options[:variable] && (elsif_statement? || if_statement?)
      @target.gsub!(" #{options[:variable].to_s}", "'$value'")
    elsif options[:variable]
      @target.gsub!(" #{options[:variable].to_s}", " '${$value}'")
    end
    
    @target = self[options[:space_reduction]..-1]
    return special_statement.to_s(options) if special_statement
    to_s(options)
  end
  
  def special_statement
    @special_statement ||= begin
      special = IfStatement.new(self) if if_statement?
      special ||= ElseStatement.new(self) if else_statement?
      special ||= ElsifStatement.new(self) if elsif_statement?
      special ||= EachStatement.new(self) if each_statement?
      special
    end
  end
  
  def next_sibling(child)
    index = children.index(child) + 1
    children[index] unless index > children.length
  end
  
  def to_s(options = {})
    options[:variable] = special_statement.variable if each_statement? && !options.has_key?(:variable)
    string = children.reduce(@target.to_s) do |sum, child| 
      sum << child.template_render(options)
    end
    next_sibling = parent.next_sibling(self)
    return string if special_statement.nil?
    return string << special_statement.end_each(options) if each_statement?
    # if we have a next sibbling that's an else or elsif, continue
    # if we have no next sibbling or the next sibbling isn't a continuation of this if, return the end if
    (next_sibling && (next_sibling.else_statement? || next_sibling.elsif_statement?)) ? string : string << special_statement.end_if(options)
  end
  
  def last_character
    index("\n") || length - 1
  end
  
  protected
  
  def method_missing(method, *args, &block)
    @target.send(method, *args, &block)
  end
  
end