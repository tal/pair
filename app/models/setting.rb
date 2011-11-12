class Setting
  include Mongoid::Document
  field :_id, type:String
  field :value
  class << self
  private
    def set_method name, opts
      singleton_class.send :define_method, "#{name}_obj" do
        unless s = where(_id:name).first
          s = new(_id:name)
          s[:value] = opts[:default]
          s.save
        end

        s
      end

      singleton_class.send :define_method, name do
        send("#{name}_obj")[:value]
      end

      singleton_class.send :define_method, "#{name}=" do |val|
        s = send("#{name}_obj")
        s[:value] = val
        s.save!
        s
      end
    end

    def array name, opts={}
      name = name.to_s
      opts |= {default:[]}
      
      set_method name, opts
    end

  public
    def featured_questions
      ItemGroup.all_in(_id: featured_question_ids).all
    end
  end

  array :featured_question_ids

end
