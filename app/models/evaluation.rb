# frozen_string_literal: true

class Evaluation < ApplicationRecord
  belongs_to :service
  belongs_to :client, optional: true
  belongs_to :worker, optional: true
end
