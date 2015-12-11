class SubComplexEntities::Contact < Maestrano::Connector::Rails::SubComplexEntityBase

  def external?
    true
  end

  def entity_name
    'contact'
  end

  def mapper_classes
    [SubComplexEntities::ContactMapper]
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      if id = entity['AccountId']
        idmap = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'account', external_id: id, organization_id: organization.id)
        entity['AccountId'] = idmap ? idmap.connec_id : ''
      end
      SubComplexEntities::ContactMapper.denormalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      AccountId
      Salutation
      FirstName
      LastName
      Title
      Birthdate
      MailingStreet
      MailingCity
      MailingState
      MailingPostalCode
      MailingCountry
      OtherStreet
      OtherCity
      OtherState
      OtherPostalCode
      OtherCountry
      Email
      Phone
      OtherPhone
      MobilePhone
      Fax
      HomePhone
      LeadSource
    )
  end

end