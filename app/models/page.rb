require 'open-uri'

class Page < ActiveRecord::Base
  after_initialize :init

  has_many :page_rels, dependent: :destroy
  has_many :subpages, source: :page, through: :page_rels, conditions: [ "is_parent = 'f'" ]#, dependent: :destroy
  has_one :parent, class_name: 'PageRel', foreign_key: 'page_id', conditions: [ "is_parent = 't'" ]#, dependent: :destroy

  has_many :rels, class_name: 'PageRel', foreign_key: 'rel_id', dependent: :destroy
#  has_many :parents_of, through: :rels_of

  validates :name, presence: true, uniqueness: true, 
    :format => { with: /\A([_A-Za-z\u0430-\u044F\u0410-\u042F\d]{,99})[A-Za-z\u0430-\u044F\u0410-\u042F\d]\Z/i } 
  validates :title, :text, presence: true
#  validates :full_path, uniqueness: true

#   attr_reader :full_path
#  attr_accessor :name, :title, :text
#  def parent=(parent_page)
#    PageRel.new(page_id: self, rel_id: parent_page, is_parent: true).save
#    PageRel.new(page_id: parent_page, rel_id: self, is_parent: false).save
#    @full_path = get_full_path(self)    
#  end
   
  # Constants

  SLASH = '/'

  # Class methods
 
  class << self
    def format_text(str)
      newstr = str.html_safe
      newstr.gsub!(/(\*\*)[^*]+(\*\*)/) {|val| "<b>"+val[2..-3]+"</b>" }
      newstr.gsub!(/(\\\\)[^\\]+(\\\\)/) {|val| "<i>"+val[2..-3]+"</i>" } 
      newstr.gsub!(/(\(\()[^\(\)]+\)\)/) do |match1|
        anchor = match1[2..-3]
        first_word = ""
        rest_words = anchor.sub(/\A\S+\s/) { |match2| first_word = match2.strip; "";  }
        if Page.find_by_path(first_word)
          "<a href=\"/#{first_word}\">"+rest_words+"</a>"
        else
          match1
        end
      end
      newstr
    end
 
    def is_relation_exists?(page, parent_page)      
      find_rels = PageRel.where("(page_id = #{page.id} and rel_id = #{parent_page.id}) or (page_id= #{parent_page.id} and rel_id=#{page.id})")
      return true if find_rels.count > 0
      false
    end

    def get_path(page, depth=0)
      result = page.name
      next_parent = page.parent.rel if page.parent    
      while next_parent 
        result = next_parent.name + SLASH + result
        break unless next_parent.parent
        next_parent = next_parent.parent.rel
      end
      result
    end

    def set_path(page, depth)
      page.path= get_path(page, depth)
    end

    def collect_path(page, depth)	
      if depth.zero?
        @path_collect = page.path
      else
        @path_collect += page.name
      end
      page.path= @path_collect.dup
      puts "Path_collect is #{@path_collect.to_s}:#{page.path} and Page: #{page.id}:#{page.name} "
      @path_collect += SLASH
    end
  
    def output(str, offset=0)
      if str.is_a?(Page)
        #if offset.zero?
        #  str = "<strong>" + str.name + "</strong><br/>"
        #else
        str = "<a href='#{str.url}'>" + str.name + '</a><br/>' if str.is_a?(Page) 
        #end
      end
      result = offset.zero? ? str : '~> ' + str.to_s  
      offset_str = '&nbsp;&nbsp;'
      offset.times { result = offset_str + result }
      puts result
      result 
    end

    def tree
      res = ""
      Page.find_all_by_is_root(true).each do |root_page|
        res += find_all_children_and_call(root_page, method(:output), 0)
      end
      res
    end    

    def find_all_children_and_call(root, callback, depth)

      return "Nil Root Came!" unless root      

#      puts "call ~facac~ pid: #{root.id}, root is leaf? #{root.is_leaf?},  depth: " + depth.to_s
      result = callback.call(root, depth).to_s
      
      return result if root.is_leaf?

      root.page_rels(true).each do |rel_page|
#         puts "PR with id: #{rel_page.id} -"
         result += find_all_children_and_call(rel_page.rel(true), callback, depth+1) unless rel_page.is_parent
      end

      result
    end

    def update_children_path_bwd(root_page)
      find_all_children_and_call(root_page, method(:set_path), 0)
    end
 
    def update_children_path_fwd(root_page)
      set_path(root_page, 0)
      find_all_children_and_call(root_page, method(:collect_path), 0)
    end

    def set_is_leaf(page)
      page.is_leaf! if page.subpages.nil? if page
    end

    def set_is_root(page)
      page.is_root! if page.parent.nil? if page
    end
  end

  # End of class methods

  # Init

  def init
    Page.set_is_root(self)
    Page.set_is_leaf(self)
#    self.save   
  end

  def tree
    Page.find_all_children_and_call(self, Page.method(:output), 0)
  end

  def parent_path
    URI::encode(is_root? ? '' : path.gsub(/\/[^\/]+\z/, ''))
  end

  def url
    URI::encode('/'+path)
  end
#  def tree(method)
#    Page.find_all_children_and_call(self, method, 0)
#  end
 
  # Setters
 
  def path=(path_str)
    puts "write #{self.id} attr full_path: #{path_str}"
    write_attribute(:path, path_str)
    save
  end

  def name=(page_name)
    write_attribute(:name, page_name)
    write_attribute(:path, page_name)
  end

  def text=(some_str)
    new_text = some_str.dup
    write_attribute(:text, some_str)
    write_attribute(:formatted_text, Page.format_text(new_text))
  end

  def unparent!

    parent(true)

    parent_rel = parent unless is_root

    rels = []
    rels.push(parent_rel) 
    rels.concat(parent_rel.rel.page_rels.find_all_by_rel_id_and_is_parent(self.id, false)) if parent_rel
    rels.each { |item| item.destroy if item }

    parent(true)
 
    Page.set_is_leaf(parent_rel.rel) if parent_rel
   
    Page.update_children_path_bwd(self)

    is_root!

    self.save

  end

  def parent!(parent_page)

    parent(true)

    self.id ||= self.save

    # Not realy, if parent 
    unless parent_page
      Page.output('Can\'t be parent of nil, use `unparent` instead!')
      return
    end

    if parent_page.id == self.id
      Page.output('Page couldn\'t be parent of yourself') 
      return
    end

    unparent! if parent && parent_page.id != self.parent.rel.id unless is_root?

    unless Page.is_relation_exists?(self,parent_page)

      PageRel.new(page_id: self.id, rel_id: parent_page.id, is_parent: true).save
      PageRel.new(page_id: parent_page.id, rel_id: self.id, is_parent: false).save

    else

      Page.output("Relation already exists!") 

    end

    parent(true)

    Page.update_children_path_bwd(self)
#    Page.update_children_full_path_fwd(self)
    #write_attribute(:full_path, Page.get_full_path(self))
    parent_page.is_not_leaf!
    is_not_root!
    
    parent_page.save
    self.save

  end
    
  # Write attributes wrap

  def is_root!
    write_attribute(:is_root, true)
  end

  def is_not_root!
    write_attribute(:is_root, false)
  end

  def is_leaf!
    write_attribute(:is_leaf, true)
  end

  def is_not_leaf!
    write_attribute(:is_leaf, false)
  end



end
