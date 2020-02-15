class User < ApplicationRecord
  has_many :microposts
  has_many :active_relationships,
           class_name: 'Relationship',
          foreign_key: :follower_id,
            dependent: :destroy

  has_many :passive_relationships,
           class_name: 'Relationship',
          foreign_key: :followed_id,
            dependent: :destroy

  has_many :following,
           through: 'active_relationships',
            source: 'followed'

  has_many :followers,
           through: 'passive_relationships',
            source: 'follower'

  has_many :posts, dependent: :destroy

  scope :search_by_keyword, -> (keyword) {
   where("users.name LIKE :keyword", keyword: "%#{sanitize_sql_like(keyword)}%") if keyword.present?
 }

  attr_accessor :remember_token

  validates :name, presence: true, length: { maximum: 50 }, unless: :uid?
  validates :user_name, presence: true, length: { maximum: 50}, unless: :uid?
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 200 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }, unless: :uid?
  has_secure_password validations: false
  validates :password, length: { minimum: 6 }, allow_nil: true, unless: :uid?
  validates :introduction,  length: { maximum: 160 }

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                              BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    self.update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    self.update_attribute(:remember_digest, nil)
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", self.following_ids, self.id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    self.active_relationships.create(followed_id: other_user.id)
  end

  # ユーザーをフォロー解除する
  def unfollow(other_user)
    self.active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    self.following.include?(other_user)
  end

  def self.find_or_create_from_auth(auth)
  provider = auth[:provider]
  uid = auth[:uid]
  name = auth[:info][:name]
  image = auth[:info][:image]

  self.find_or_create_by(provider: provider, uid: uid) do |user|
    user.username = name
    user.image_path = image
  end
end

end
