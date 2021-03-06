ActiveAdmin.register Task do
  config.sort_order = 'datetime_desc'
	menu priority: 1, label: 'Errands'

  config.clear_action_items!

  action_item :only => :index do
      link_to "New Errand" , "/admin/tasks/new"
  end

  action_item :only => :show do
      link_to "Edit Errand" , edit_admin_task_path(task)
  end
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
permit_params :title, :datetime, :address, :contact, :details, :escrowable, :usedHour, :usedEscrow, \
                  :client_id, :provider_id, :status, :type_id, :zoom_office_id, :addrlng, :addrlat, \
                  :unit, :pick_up_address, :pick_up_addrlat, :pick_up_addrlng, :pick_up_unit, :item, \
                  :frequency, task_uploads_attributes: [:upload, :id, :_destroy, :task_id]
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

	scope "All", if: proc { true } do |tasks|
	  tasks.all
	end

	scope "Open", if: proc { true } do |tasks|
	  tasks.where(status: 'open')
	end

	scope "Close", if: proc { true } do |tasks|
	  tasks.where(status: 'close')
	end

	controller do
    def scoped_collection
      if current_admin.email == 'superadmin@zoomerrands.com'
    		end_of_association_chain.includes(:zoom_office, :client, :type, :provider)
    	else
    		office = current_admin.zoom_office
      	end_of_association_chain.includes(:zoom_office, :client, :type, :provider).where(zoom_office: office)
      end
    end
  end

  filter :client, :collection => proc {(Client.all).map{|c| [name_email(c), c.id]}}
  filter :provider, :collection => proc {(Client.all).map{|c| [name_email(c), c.id]}}
  filter :type
  filter :zoom_office, collection: proc{(ZoomOffice.all).map{|o| [o.longName, o.id]}}, if: proc{current_admin.email == 'superadmin@zoomerrands.com'}
  filter :title, as: :string
  filter :datetime, label: 'Errand Date'
  filter :address
  filter :pick_up_address
  filter :item
  filter :contact
  filter :details
  filter :escrowable
  filter :usedHour
  filter :usedEscrow
  filter :status
  # filter :city
  filter :frequency

	index :title => 'Errands' do
		selectable_column
		column :id
		column 'Errand Title' do |task|
			link_to task.title, admin_task_path(task)
		end
		column 'Errand Date', :datetime
		column 'Office' do |task|
			task.zoom_office.longName if !task.zoom_office.nil?
		end
		column "Client" do |task|
			link_to name_email(task.client), admin_client_path(task.client) \
			if !task.client.nil?
		end
		column 'Contact #', :contact
		column 'Provider' do |task|
    	link_to name_email(task.provider), admin_provider_path(task.provider) \
    	if !task.provider.nil?
    end
		column 'Type' do |task|
			task.type.name if !task.type.nil?
		end
		column 'Address', :address, sortable: false
    column :unit
    column :pick_up_address
    column :pick_up_unit
    column :item
		# column :addrlat
		# column :addrlng
		# column 'Escrow Usable', :escrowable
    column :frequency
		column 'Escrow Used', :usedEscrow
		column 'Hours Used', :usedHour
		column :status
		# column :created_at
		# column :updated_at

		actions
	end

	show  do
    attributes_table  do
      row :id
			row :title
			row :datetime
			row 'Office' do |task|
				task.zoom_office.longName
			end
			row :client do |task|
				link_to name_email(task.client), admin_client_path(task.client) \
				if !task.client.nil?
			end
			row :contact
			row 'Provider' do |task|
	    	link_to name_email(task.provider), admin_provider_path(task.provider) \
	    	if !task.provider.nil?
	    end
			row 'Type' do |task|
				task.type.name
			end
			row :address
      row :unit
			row :addrlat
			row :addrlng
      row :pick_up_address
      row :pick_up_unit
      row :pick_up_addrlat
      row :pick_up_addrlng
      row :item
			row :details
      row :frequency
			row :escrowable
			row :usedHour
			row :usedEscrow
			row :status
			row :created_at
			row :updated_at

    end

    panel "Uploads" do
      table_for task.task_uploads do
        column :upload do |task_upload|
        	link_to image_tag(task_upload.upload.url(:thumb)), task_upload.upload.url
        end
      end
    end

    active_admin_comments
  end

  increment = 15.minutes
  ss = Array.new(24.hours/increment) do |i|
    Time.at(i*increment + 0.hours).utc.strftime("%H:%M")
  end

  form do |f|
	  f.semantic_errors # shows errors on :base

	  f.inputs "Task" do          # builds an input field for every attribute
	  	f.input :title, :required => true
	  	f.input :datetime, as: :date_time_picker, datepicker_options: { allowTimes: ss }
	  	f.input :type, as: :select, multiple: false, \
	  					:collection => Type.all.map{ |type| [type.name, type.id] }, :prompt => 'Select one'
	  	f.input :client, as: :select, multiple: false, \
	  					:collection => Client.all.map{ |client| [name_email(client), client.id] }, :prompt => 'Select one'
	  	f.input :provider, as: :select, multiple: false, \
	  					:collection => Provider.all.map{ |provider| [name_email(provider), provider.id] }, :prompt => 'Select one'
	  	f.input :zoom_office, as: :select, multiple: false, \
	  					:collection => ZoomOffice.all.map{ |office| [office.longName, office.id] }, :prompt => 'Select one'
	  	f.input :address
      f.input :unit
	  	f.input :addrlat
	  	f.input :addrlng
      f.input :pick_up_address
      f.input :pick_up_unit
      f.input :item
      f.input :pick_up_addrlat
      f.input :pick_up_addrlng
			f.input :contact
			f.input :details
      f.input :frequency
			f.input :escrowable
			f.input :usedHour
			f.input :usedEscrow
			f.input :status, as: :select, collection: ['open', 'close'] , :prompt => 'Select one'

			f.inputs do
				f.has_many :task_uploads, heading: 'Uploads', allow_destroy: true  do |a|
					a.input :upload
				end
			end
	  end

	  f.actions         # adds the 'Submit' and 'Cancel' buttons
	end



end
