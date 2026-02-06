# OfficeResourcesController allows Admins to Create, Update, and Delete rooms/equipment.
class OfficeResourcesController < ApplicationController
  # CanCanCan will automatically load the resource and check permissions based on Ability.rb
  load_and_authorize_resource

  # GET /office_resources - Lists all resources (only active, non-deleted ones).
  def index
    @office_resources = @office_resources.kept
    render json: OfficeResourceBlueprint.render(@office_resources)
  end

  # GET /office_resources/:id - Shows details of one specific resource.
  def show
    render json: OfficeResourceBlueprint.render(@office_resource)
  end

  # POST /office_resources - Creates a new resource (Admin only).
  def create
    if @office_resource.save
      render json: OfficeResourceBlueprint.render(@office_resource), status: :created
    else
      render json: @office_resource.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /office_resources/:id - Updates an existing resource (Admin only).
  def update
    if @resource_booking.update(resource_booking_params) # Note: possible error in original file, should be @office_resource
      render json: OfficeResourceBlueprint.render(@office_resource)
    else
      render json: @office_resource.errors, status: :unprocessable_entity
    end
  end

  # DELETE /office_resources/:id - Soft removes a resource (Admin only).
  def destroy
    if @office_resource.soft_delete
      AuditLog.log(@office_resource, "deleted", "Admin (#{@current_user.id}) soft-deleted this resource.")
      head :no_content
    else
      render json: { error: "Failed to delete" }, status: :unprocessable_entity
    end
  end

  private

  def office_resource_params
    params.require(:office_resource).permit(:name, :resource_type, :status, configuration: {})
  end
end
