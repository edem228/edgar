require 'xml'
class XmlImportWorker
  include SidekiqStatus::Worker
  sidekiq_options retry: false

  def perform(account_id, subdir, xml_filename, custom_tags)
    Account.current_id = account_id
    uploader = XmlImportUploader.new(subdir)
    uploader.retrieve_from_store!(xml_filename)
    uploader.cache_stored_file!
    #at(10,"Lecture du fichier")
    imported_at = Time.zone.now.to_i

    ActiveRecord::Base.transaction do
      File.open(uploader.file.path) do |io|
        self.total = io.size
      
        at(20, "Lecture du fichier ...")

    
        xml_reader = XML::Reader.io(io)
        xml_reader.read
        raise "No valid Merci Edgar File" unless xml_reader.name == "merciedgar"
      
        while xml_reader.read do
          case xml_reader.name
            when "show-buyer", "person", "structure"
              xml_node = xml_reader.expand.to_s
              attributes = Hash.from_xml(xml_node).fetch(xml_reader.name.underscore)
              instance = Object.const_get(xml_reader.name.underscore.camelize).from_merciedgar_hash(attributes, imported_at, custom_tags)
              instance.save
              at(xml_reader.byte_consumed, "Ajout de la fiche #{instance.name}")
                
          end
          xml_reader.next
        end
      end


      File.open(uploader.file.path) do |io|
        self.total = io.size
      
        at(20, "Lecture du fichier ...")

    
        xml_reader = XML::Reader.io(io)
        xml_reader.read
        raise "No valid Merci Edgar File" unless xml_reader.name == "merciedgar"
      
        while xml_reader.read do
          case xml_reader.name
            when "venue", "festival"
              xml_node = xml_reader.expand.to_s
              attributes = Hash.from_xml(xml_node).fetch(xml_reader.name.underscore)
              instance = Object.const_get(xml_reader.name.underscore.camelize).from_merciedgar_hash(attributes, imported_at, custom_tags)
              instance.save
              at(xml_reader.byte_consumed, "Ajout de la fiche #{instance.name}")
                       
                
          end
          xml_reader.next 
        end
      end
    end

    imported_contacts = Contact.where(imported_at: imported_at)
    nb_duplicates = imported_contacts.where("duplicate_id IS NOT NULL").count
    nb_imported_contacts = imported_contacts.count
    nb_imported_contacts
    self.payload = { nb_imported_contacts: nb_imported_contacts, nb_duplicates: nb_duplicates, imported_at: imported_at }

  end
end
  