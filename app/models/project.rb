class Project < ActiveRecord::Base
  belongs_to :tenant
  validates :title, uniqueness: true
  validate :free_plan_limited_to_one_project
  
  def free_plan_limited_to_one_project
    if self.new_record? && (tenant.projects.count > 0) && (tenant.plan.eql?('free'))
      errors.add(:base, "Sorry, free plans limited to one project.")
    end
  end
  
  def self.by_plan_and_tenant(tenant_id)
    tenant = Tenant.find(tenant_id)
    
    if tenant.plan.eql? 'premium'
      tenant.projects
    else
      tenant.projects.order(:id).limit(1)
    end
  end
end
