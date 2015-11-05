class SynchronizationJobOld

  def perform
    Rails.logger.info "Start synchronizations"
    
    Organization.where("organizations.oauth_token IS NOT NULL").each do |organization|
      Rails.logger.info "Start synchronization, organization=#{organization.uid}"
      current_synchronization = Synchronization.create(organization_id: organization.id, status: 'RUNNING')
      
      begin
        last_synchronization = Synchronization.where(organization_id: organization.id, status: 'SUCCESS').order(updated_at: :desc).first

        salesforce_accounts = salesforce_accounts(organization, last_synchronization)
        connec_organizations = connec_organizations(organization, last_synchronization)

        salesforce_accounts.each do |salesforce_account|
          idmap = IdMap.find_or_create_by(salesforce_id: salesforce_account.Id, salesforce_entity: 'Account', organization_id: organization.id)
          # Entity does not exist in Connec!
          if idmap.connec_id.blank?
            connec_organization = connec_create_organization(organization, salesforce_account)
            idmap.update_attributes(connec_id: connec_organization['id'], connec_entity: 'organization')
          end
        end

        connec_organizations.each do |connec_organization|
          idmap = IdMap.find_or_create_by(connec_id: connec_organization['id'], connec_entity: 'organization', organization_id: organization.id)
          # Entity does not exist in SalesForce
          if idmap.salesforce_id.blank?
            account_id = salesforce_create_organization(organization, connec_organization)
            idmap.update_attributes(salesforce_id: account_id, salesforce_entity: 'Account')
          end
        end

        Rails.logger.info "Finished synchronization, organization=#{organization.uid}, status=success"
        current_synchronization.update_attributes(status: 'SUCCESS')
      rescue Exception => e
        Rails.logger.info "Finished synchronization, organization=#{organization.uid}, status=error, message=#{e.message} backtrace=#{e.backtrace.join("\n\t")}"
        current_synchronization.update_attributes(status: 'ERROR', message: e.message)
      end
    end
  end

  def salesforce_accounts(organization, last_synchronization)
    client = Restforce.new :oauth_token => organization.oauth_token,
      refresh_token: organization.refresh_token,
      instance_url: organization.instance_url,
      client_id: ENV['salesforce_client_id'],
      client_secret: ENV['salesforce_client_secret']

    Rails.logger.debug "Fetching SalesForce Accounts"
    if last_synchronization
      # Cannot get the get_updated query to work
      # client.get_updated('Account', last_synchronization.updated_at, Time.now)
      client.query('select Id, Name from Account ORDER BY Name')
    else
      client.query('select Id, Name from Account ORDER BY Name')
    end
  end

  def salesforce_create_organization(organization, connec_organization)
    client = Restforce.new :oauth_token => organization.oauth_token,
      refresh_token: organization.refresh_token,
      instance_url: organization.instance_url,
      client_id: ENV['salesforce_client_id'],
      client_secret: ENV['salesforce_client_secret']

    client.create('Account', Name: connec_organization['name'])
  end

  def connec_organizations(organization, last_synchronization)
    Rails.logger.debug "Fetching Connec! Organizations"

    organizations = []
    client = Maestrano::Connec::Client.new(organization.uid)

    # Fetch first page
    if last_synchronization.blank?
      response = client.get("/organizations")
    else
      query_param = URI.encode("$filter=updated_at >= #{last_synchronization.updated_at}")
      response = client.get("/organizations?#{query_param}")
    end

    response_hash = JSON.parse(response.body)
    organizations << response_hash['organizations']

    # Fetch subsequent pages
    while response_hash['pagination'] && response_hash['pagination']['next']
      # ugly way to convert https://api-connec/api/v2/group_id/organizations?next_page_params to /organizations?next_page_params
      next_page = response_hash['pagination']['next'].gsub(/^(.*)\/organizations/, '/organizations')
      response = client.get(next_page)
      response_hash = JSON.parse(response.body)
      organizations << response_hash['organizations']
    end
    
    organizations.flatten
  end

  def connec_create_organization(organization, salesforce_account)
    client = Maestrano::Connec::Client.new(organization.uid)
    response = client.post('/organizations', { organizations: { name: salesforce_account.Name} })
    JSON.parse(response.body)['organizations']
  end
end