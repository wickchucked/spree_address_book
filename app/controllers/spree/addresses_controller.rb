class Spree::AddressesController < Spree::StoreController
  helper Spree::AddressesHelper
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  load_and_authorize_resource :class => Spree::Address

  def edit
    session["user_return_to"] = request.env['HTTP_REFERER']
  end

  def update
    if @address.editable?
      if @address.update_attributes(params[:address])
        flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
      end
    else
      new_address = @address.clone
      new_address.attributes = params[:address]
      @address.update_attribute(:deleted_at, Time.now)
      if new_address.save
        flash[:notice] = I18n.t(:successfully_updated, :resource => I18n.t(:address))
      end
    end
    redirect_back_or_default(account_path)
  end

  def create
    @address.user = spree_current_user
    if @address.save
      flash[:notice] = I18n.t(:successfully_created, :resource => I18n.t(:address))
      redirect_to account_path
    else
      render :action => "new"
    end
  end

  def destroy
    @address.destroy

    flash[:notice] = I18n.t(:successfully_removed, :resource => t(:address))
    redirect_to(request.env['HTTP_REFERER'] || account_path) unless request.xhr?
  end
end
