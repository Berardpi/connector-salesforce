class SubComplexEntities::Lead < Maestrano::Connector::Rails::SubComplexEntityBase

  def external?
    true
  end

  def entity_name
    'lead'
  end

  def mapper_classes
    [SubComplexEntities::LeadMapper]
  end

  def map_to(name, entity, organization)
    case name
    when 'person'
      SubComplexEntities::LeadMapper.denormalize(entity).merge(is_lead: true)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      Street
      City
      State
      PostalCode
      Country
      Email
      Fax
      LeadSource
      MobilePhone
      Salutation
      FirstName
      LastName
      Phone
      Title
      Description
      Status
      ConvertedDate

    )
  end

end