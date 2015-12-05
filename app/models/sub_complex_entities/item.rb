class SubComplexEntities::Item < Maestrano::Connector::Rails::SubComplexEntityBase

  def external?
    false
  end

  def entity_name
    'item'
  end

  def mapper_classes
    [SubComplexEntities::Product2Mapper, SubComplexEntities::PricebookEntryMapper]
  end

  def map_to(name, entity)
    case name
    when 'PricebookEntry'
      SubComplexEntities::PricebookEntryMapper.normalize(entity)
    when 'Product2'
      SubComplexEntities::Product2Mapper.normalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def push_entities_to_external_to(external_client, mapped_connec_entities_with_idmaps, external_entity_name)
    if external_entity_name == 'PricebookEntry' && !mapped_connec_entities_with_idmaps.empty?
      pricebook_id = Entities::Item.get_pricebook_id(external_client)

      mapped_connec_entities_with_idmaps.each do |mapped_entity_with_idmap|
        # Product2Id and Pricebook2Id needed for creation to SF
        if mapped_entity_with_idmap[:idmap].external_id.blank?
          mapped_entity_with_idmap[:entity]['Product2Id'] = Maestrano::Connector::Rails::IdMap.find_by(external_entity: 'product2', connec_entity: 'item', connec_id: mapped_entity_with_idmap[:idmap].connec_id, organization_id: mapped_entity_with_idmap[:idmap].organization_id).external_id
          mapped_entity_with_idmap[:entity]['Pricebook2Id'] = pricebook_id
        end
      end
    end

    super(external_client, mapped_connec_entities_with_idmaps, external_entity_name)
  end

end