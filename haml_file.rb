#Dir[File.dirname(__FILE__) + "/**/*.rb"].each do |file| require file end

class HamlFile
  instance_methods.each { |m| undef_method m unless (m =~ /(^__|^send$|^object_id$)/)}
  require 'haml'

  attr_accessor :children
  
  def self.tabulation; 2 end
  
  def initialize(filename, options = {})
    @file = File.open(filename)
    @options = options
    @children = []
    @scope = options[:scope] || self
  end
  
  def render_js_template(options = {})
    statements! # setup
    inlined_haml = children.reduce("") do |sum, child| 
      sum << child.template_render
    end 
    #puts inlined_haml
    template = scrub_template(Haml::Engine.new(inlined_haml).render(@scope, @options[:with] => TemplatePresenter.new, "#{@options[:with].to_s}_control_flow".to_sym => TemplatePresenter.new(:control_flow => true)))
  end
  
  def scrub_template(template)
    # id and klass often need referencing within a render that will url encode them so we replace those here
    # unless the user has specified that we should keep these encoded
    @options[:encode] ? template : template.gsub('%7Bid%7D', '{id}').gsub('%24%7Bklass%7D', '${klass}')
  end
    
  def statements
    @statements ||= begin 
      last_element = nil
      reduce([]) do |sum, line|
        if ["\n", ""].include?(line.strip) 
          sum
        else
          statement = Statement.new(line, :with => @options[:with]) 
          if (statement.spacing.zero? || last_element.nil?)
            statement.parent = self
          else
            statement.parent = (last_element.spacing < statement.spacing ? last_element : last_element.parent(statement.spacing - HamlFile.tabulation))
          end
          statement.parent.children << statement
          sum << (last_element = statement)
        end
      end
    end
  end
  
  def next_sibling(child)
    index = children.index(child) + 1
    children[index] unless index > children.length
  end
  
  alias_method :statements!, :statements
  
  protected
  
  def method_missing(method, *args, &block)
    @file.send(method, *args, &block)
  end
  
end

#puts HamlFile.new("/Users/billzdon/code/patch/app/views/admin/content_module_guides/_template_styles.html.haml", :with => :content_module_guide).render_js_template