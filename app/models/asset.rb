class Asset < ActiveRecord::Base
  belongs_to :contentasset, :polymorphic => true
  has_attachment :storage      => :s3,
                 :max_size     => 25.megabytes
end
