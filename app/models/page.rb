require 'page_methods_module'

class Page < ActiveRecord::Base

  include PageMethodsModule

  after_initialize :init  

  has_many :page_rels, dependent: :destroy
  has_many :subpages, source: :page, through: :page_rels, conditions: [ "is_parent = 'f'" ]#, dependent: :destroy
  has_one :parent, class_name: 'PageRel', foreign_key: 'page_id', conditions: [ "is_parent = 't'" ]#, dependent: :destroy

  has_many :rels, class_name: 'PageRel', foreign_key: 'rel_id', dependent: :destroy

  validates :name, presence: true, uniqueness: true, 
    :format => { with: /\A([_A-Za-z\u0430-\u044F\u0410-\u042F\d]{,99})[A-Za-z\u0430-\u044F\u0410-\u042F\d]\Z/i } 

  validates :title, length: { maximum: 50 }, presence: true
  validates :text, length: { maximum: 350 }, presence: true

end
