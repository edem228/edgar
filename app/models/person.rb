# encoding: utf-8
# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  first_name     :string(255)
#  last_name      :string(255)
#  account_id     :integer
#  structure_id   :integer
#  structure_type :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Person < ActiveRecord::Base
  default_scope { where(:account_id => Account.current_id) }
  attr_accessible :first_name, :last_name, :people_structures_attributes, :contact_attributes, :avatar
  has_one :contact, as: :contactable, dependent: :destroy
  has_many :structures, through: :people_structures, uniq:true
  has_many :people_structures, dependent: :destroy
  has_many :relatives, dependent: :destroy
  validates_presence_of :first_name
  validates_presence_of :last_name

  accepts_nested_attributes_for :people_structures, :reject_if => :all_blank, allow_destroy: true
  accepts_nested_attributes_for :contact, :reject_if => :all_blank, allow_destroy: true

  delegate :name, :tasks, :reportings, :network_list, :custom_list, :favorite?, :contacted?, :phone_number, :email_address, :addresses, :emails, :phones, :websites, to: :contact

  mount_uploader :avatar, AvatarUploader

  before_save :set_name

  def set_name
    self.build_contact unless contact.present?
    contact.name = "#{last_name} #{first_name}" if self.changed.include?("first_name") || self.changed.include?("last_name")
  end


  def other_people_structures(user)
    self.people_structures.where("structure_id != ?", self.main_structure(user).id)
  end

  def main_people_structure(user)
    self.people_structures.where(structure_id: self.main_structure(user).id).first if self.people_structures.present?
  end

  def to_s
    [self.first_name, self.last_name].compact.join(' ')
  end

  def to_param
    [id, to_s.try(:parameterize)].compact.join('-')
  end

  def title(structure)
    structure.people_structures.where(person_id:self.id).first.title if structure.present?
  end

  def info_contact(structure)
    [self.title(structure), self.phone_number, self.email_address].compact.join(' — ')
  end

  def main_structure(user)
    if self.structures.any?
      self.relative(user).present? ? self.relative(user).structure : self.structures.first
    end
  end

  def set_main_structure(user,structure)
    rel = self.relatives.build(user: user) unless relative(user).present?
    rel.structure = structure
  end


  def main_structure?(user,structure)
    structure == self.main_structure(user)
  end

  def relative(user)
    relative = self.relatives.where(user_id: user.id).first
  end

  amoeba do
    enable
    include_field :emails
    include_field :phones
    include_field :addresses
    include_field :websites
    include_field :taggings
  end

  def my_dup
    Contact.unscoped do
      self.amoeba_dup
    end
  end

end
