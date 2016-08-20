class TenantsController < ApplicationController
  before_action :set_tenant
  
  def edit
  end 
  
  def update
    respond_to do |format|
      Tenant.transaction do
        if @tenant.update(tenant_params)
          if @tenant.plan.eql?('premium') && @tenant.plan.blank?
            @payment = Payment.new({ email: tenant_params['email'], token: params[:payment]['token'], tenant: @tenant })
            
            begin
              @payment.process
              @payment.save
            rescue Exception => e
              flash[:error] = e.message
              @payment.destroy
              @tenant.plan = 'free'
              @tenant.save
              
              redirect_to edit_tenant_path(@tenant) and return
            end
          end
          
          format.html { redirect_to edit_plan_path, notice: 'Plan was updated.' }
        else
          format.html { render :edit }
        end
      end
    end
  end
  
  def change
    @tenant = Tenant.find(params[:id])
    Tenant.set_current_tenant @tenant.id
    session[:tenant_id] = @tenant.current_tenant.id
    redirect_to home_index_path, notice: "Switched to Organization #{@tenant.name}"
  end
  
  private
  
    def set_tenant
      @tenant = Tenant.find(Tenant.current_tenant_id)
    end
    
    def tenant_params
      params.require(:tenant).permit(:name, :plan)
    end
end