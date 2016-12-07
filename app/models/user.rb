class User < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_secure_password
  after_destroy :ensure_an_admin_remains
  validates :email, uniqueness: true
  # validates :email, format: { with: /.+@.+\..{2,3}/ }

  after_destroy do |user|
    user.email != 'admin@depot.com'
  end

  before_update do |user|
    user.errors[:base] << "Cannot update admin"
    user.email != 'admin@depot.com'
  end

  after_create do |user|
    puts "runing"
    UserNotifier.created(user).deliver
  end

  private
    def ensure_an_admin_remains
      if User.count.zero?
        raise "Can't delete last user"
      end
    end
end
