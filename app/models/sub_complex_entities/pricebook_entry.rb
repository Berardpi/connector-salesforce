class SubComplexEntities::PricebookEntry < Maestrano::Connector::Rails::SubComplexEntityBase

  def external?
    true
  end

  def entity_name
    'PricebookEntry'
  end

  def mapper_classes
    [SubComplexEntities::PricebookEntryMapper]
  end

  def map_to(name, entity)
    case name
    when 'item'
      SubComplexEntities::PricebookEntryMapper.denormalize(entity)
    else
      raise "Impossible mapping from #{self.entity_name} to #{name}"
    end
  end

  def external_attributes
    %w(
      UnitPrice
      Product2Id
      Pricebook2Id
    )
    #Pricebook2Id is not used in mapper but is used for standard pricebook filtering
  end

  # --------------------------------------------
  #             Overriden methods
  # --------------------------------------------
  def push_entities_to_connec_to(connec_client, mapped_external_entities_with_idmaps, connec_entity_name)
    Rails.logger.info "Push #{@@external_name} #{self.external_entity_name.pluralize} to Connec! #{connec_entity_name.pluralize}"
    mapped_external_entities_with_idmaps.each do |mapped_external_entity_with_idmap|
      external_entity = mapped_external_entity_with_idmap[:entity]
      idmap = mapped_external_entity_with_idmap[:idmap]

      if idmap.connec_id.blank?
        product_idmap = Maestrano::Connector::Rails::IdMap.find_by(external_id: external_entity[:Product2Id], external_entity: 'product2', organization_id: idmap.organization_id)
        raise "Trying to push a price for a non existing or not pushed product (id: #{external_entity[:Product2Id]}" unless product_idmap && !product_idmap.connec_id.blank?
        idmap.update_attributes(connec_id: product_idmap.connec_id, connec_entity: 'item')
      end

      connec_entity = self.update_entity_to_connec(connec_client, external_entity, idmap.connec_id, connec_entity_name)
      idmap.update_attributes(last_push_to_connec: Time.now)
    end
  end

  def get_external_entities(client, last_synchronization, opts={})
    entities = super(client, last_synchronization, opts)

    unless entities.empty?
      pricebook_id = Entities::Item.get_pricebook_id(client)
      entities.delete_if{|entity| entity['Pricebook2Id'] != pricebook_id}
    end
    entities
  end

end