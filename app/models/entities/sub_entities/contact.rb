class Entities::SubEntities::Contact < Maestrano::Connector::Rails::SubEntityBase

  def self.external?
    true
  end

  def self.entity_name
    'contact'
  end

  def self.references
    {
      'person' => [{reference_class: Entities::Organization, connec_field: 'organization_id', external_field: 'AccountId'}]
    }
  end

  def self.mapper_classes
    {
      'person' => Entities::SubEntities::ContactMapper
    }
  end


  def self.object_name_from_external_entity_hash(entity)
    "#{entity['FirstName']} #{entity['LastName']}"
  end

end