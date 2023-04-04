# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  def serialize
    super.merge('retries' => (@retries || 0) + 1)
  end

  def deserialize(job_data)
    super
    @retries = job_data['retries'].to_i
  end
end
