class Project < ActiveRecord::Base
  belongs_to :tenant
  has_many :artifacts, dependent: :destroy
  has_many :user_projects
  has_many :users, through: :user_projects
  validates :title, uniqueness: true
  validate :free_plan_limited_to_one_project
  
  def free_plan_limited_to_one_project
    if self.new_record? && (tenant.projects.count > 0) && (tenant.plan.eql?('free'))
      errors.add(:base, "Sorry, free plans limited to one project.")
    end
  end
  
  def self.by_user_plan_and_tenant(tenant_id, user)
    tenant = Tenant.find(tenant_id)
    
    if tenant.plan.eql? 'premium'
      if user.is_admin?
        tenant.projects
      else
        user.projects.where(tenant_id: tenant.id)
      end
    else
      if user.is_admin?
        tenant.projects.order(:id).limit(1)
      else
        user.projects.where(tenant_id: tenant.id).order(:id).limit(1)
      end
    end
  end
end
