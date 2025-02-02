# frozen_string_literal: true

class UserContent::CreateBase
  extend DslAttribute
  dsl_attribute :klass

  method_object :params

  def call
    klass.transaction do
      model = klass.create params

      if model.persisted?
        model.generate_topic forum_id: Forum::HIDDEN_ID
      end

      model
    end
  end

private

  def params
    @params.merge(
      state: "Types::#{klass}::State".constantize[:unpublished]
    )
  rescue NameError
    @params
  end

  def state
    "Types::#{klass}::State".constantize[:unpublished]
  end
end
