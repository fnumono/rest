ActiveAdmin.register Admin do
  permit_params :email, :password, :password_confirmation, :zoom_office_id

  menu label: 'Admins', :if => proc{ current_admin.email == 'superadmin@zoomerrands.com' }

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    column :zoom_office do |admin|
      admin.zoom_office.longName if !admin.zoom_office.nil?
    end
    actions
  end

  filter :zoom_office
  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :zoom_office, as: :select, multiple: false, \
              :collection => ZoomOffice.all.map{ |office| [office.longName, office.id] }, :prompt => 'Select one'     
    end
    f.actions
  end



end
