class PageRel < ActiveRecord::Base
  belongs_to :page
  belongs_to :rel, class_name: "Page", foreign_key: "rel_id"
  #has_many :relations, class_name:  
end
