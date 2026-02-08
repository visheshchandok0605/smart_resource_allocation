class Ability
  include CanCan::Ability

  def initialize(user)
    # Handle the case where the user is not logged in (though our controllers usually catch this)
    return unless user.present?

    # Define abilities for the Admin role.
    if user.admin?
      # Admins have total control over the system.
      can :manage, :all
      
      # However, we exclude deleted resources from the default view.
      cannot :read, OfficeResource, ["deleted_at IS NOT NULL"] do |resource|
        resource.deleted_at.present?
      end
      
      # Specific permission for custom report actions.
      can :dashboard, :report
    else
      # Define abilities for the Employee role.
      
      # Employees can view all active office resources (meeting rooms, etc.).
      # Employees can view all active office resources (meeting rooms, etc.).
      can :read, OfficeResource, status: 'active', deleted_at: nil
      
      # Employees can manage ONLY their own bookings.
      # This includes creating, viewing, checking in, and canceling their own records.
      can [:create, :read, :check_in, :destroy], ResourceBooking, user_id: user.id
      
      # Employees can check availability.
      can :availability, ResourceBooking
    end
  end
end
