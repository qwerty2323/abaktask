require 'open-uri' 

module PageMethodsModule

  # Hook for include and extend
  def self.included(base)
    base.extend(PageClassMethods)
  end

  module PageClassMethods

    # Constants
    SLASH = '/'

    # Methods
    def format_text(str)
      newstr = str.html_safe
      newstr.gsub!(/(\*\*)[^*]+(\*\*)/) {|val| "<b>"+val[2..-3]+"</b>" }
      newstr.gsub!(/(\\\\)[^\\]+(\\\\)/) {|val| "<i>"+val[2..-3]+"</i>" }
      newstr.gsub!(/(\(\()[^\(\)]+\)\)/) do |match1|
        anchor = match1[2..-3]
        first_word = ""
        rest_words = anchor.sub(/\A\S+\s/) { |match2| first_word = match2.strip; ""; }
        if Page.find_by_path(first_word)
          "<a href=\"/#{first_word}\">"+rest_words+"</a>"
        else
          puts "fail"
          match1
        end
      end
      newstr
    end # Method format_text(...) end

    def is_relation_exists?(page, parent_page)
      find_rels = PageRel.where("(page_id = #{page.id} and rel_id = #{parent_page.id}) or (page_id= #{parent_page.id} and rel_id=#{page.id})")
      return true if find_rels.count > 0
      false
    end # Method is_relation_exists?(...) end

    def get_path(page, depth=0)
      result = page.name
      next_parent = page.parent.rel if page.parent
      while next_parent
        result = next_parent.name + SLASH + result
        break unless next_parent.parent
        next_parent = next_parent.parent.rel
      end
      result
    end # Method get_path(...) end

    def set_path(page, depth)
      page.path= get_path(page, depth)
    end # Method set_path(...) end

    def collect_path(page, depth)
      if depth.zero?
        @path_collect = page.path
      else
        @path_collect += page.name
      end
      page.path= @path_collect.dup
      puts "Path_collect is #{@path_collect.to_s}:#{page.path} and Page: #{page.id}:#{page.name} "
      @path_collect += SLASH
    end # Method collect_path(...) end

    def output(str, offset=0)

      if str.is_a?(Page)
        str = "<a href='#{str.url}'>" + str.name + '</a><br/>' if str.is_a?(Page)
      end

      result = offset.zero? ? str : '~> ' + str.to_s
      offset_str = '&nbsp;&nbsp;'
      offset.times { result = offset_str + result }
      puts result
      result
    end # Method output(...) end

    def tree
      res = ""
      Page.find_all_by_is_root(true).each do |root_page|
        res += find_all_children_and_call(root_page, method(:output), 0)
      end
      res
    end # Method tree end

    def find_all_children_and_call(root, callback, depth)

      result = callback.call(root, depth).to_s

      return result if root.is_leaf?

      root.page_rels(true).each do |rel_page|
         result += find_all_children_and_call(rel_page.rel(true), callback, depth+1) unless rel_page.is_parent
      end

      result
    end # Method find_all_children_and_call(...) end

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

  end # Module PageClassMethods
    
    # Init

    def init
      self.class.set_is_root(self)
      self.class.set_is_leaf(self)
    end

    # Helpers
 
    def tree
      self.class.find_all_children_and_call(self, Page.method(:output), 0)
    end

    def edit_url
      url + '/edit'
    end

    def add_url
      url + '/add'
    end

    def parent_url
      URI::encode(is_root? ? '/' : '/'+path.gsub(/\/[^\/]+\z/, ''))
    end

    def url
      URI::encode('/'+path)
    end
 
    # Setters

    def path=(path_str)
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
      write_attribute(:formatted_text, self.class.format_text(new_text))
    end

    # Exclamations wrap

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

    def parent!(parent_page)

      parent(true)

      self.id ||= self.save

      unless parent_page
        self.class.output('Parent can\'t be nil, use `unparent` instead!')
        return
      end

      if parent_page.id == self.id
        self.class.output('Page couldn\'t be parent of yourself')
        return
      end

      unparent! if parent && parent_page.id != self.parent.rel.id unless is_root?

      unless self.class.is_relation_exists?(self,parent_page)
        PageRel.new(page_id: self.id, rel_id: parent_page.id, is_parent: true).save
        PageRel.new(page_id: parent_page.id, rel_id: self.id, is_parent: false).save
      else
        self.class.output("Relation already exists!")
      end

      parent(true)

      self.class.update_children_path_bwd(self)
      parent_page.is_not_leaf!
      is_not_root!

      parent_page.save
      self.save

    end # Method parent!(...) end

    def unparent!

      parent(true)
  
      parent_rel = parent unless is_root

      rels = []
      rels.push(parent_rel)
      rels.concat(parent_rel.rel.page_rels.find_all_by_rel_id_and_is_parent(self.id, false)) if parent_rel
      rels.each { |item| item.destroy if item }

      parent(true)

      self.class.set_is_leaf(parent_rel.rel) if parent_rel

      self.class.update_children_path_bwd(self)

      is_root!

      save

    end # Method unparent! end


end # Module PageMethodsModule end
