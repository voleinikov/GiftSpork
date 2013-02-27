class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable 
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  has_one :profile, :dependent => :destroy

  has_many :memberships, :dependent => :destroy

  # Returns array of exchanges user is participating in
  has_many :participations, 
           :through => :memberships,
           :source => :exchange

  # Returns array of exchanges user has organized
  has_many :organized_exchanges, 
           :foreign_key => :organizer_id, 
           :class_name => "Exchange"

  # Past and present matches where user is gift buyer
  has_many :santa_matches,
           :foreign_key => :santa_id,
           :class_name => "Match",
           :dependent => :destroy

  # All the gifts this person has ever given OR has selected to give
  has_many :selected_gifts,
           :through => :santa_matches,
           :source => :gift

  # Past and present matches where user is gift recipient
  has_many :recipient_matches,
           :foreign_key => :recipient_id,
           :class_name => "Match",
           :dependent => :destroy

  # All the gifts this user has ever recieved OR is set to recieve
  has_many :recieved_gifts,
           :through => :recipient_matches,
           :source => :gift

  # Gifts a user has selected on exchanges that are still open
  def selected_gifts_on_active_exchanges
    Gift.find_by_sql("Select gifts.* FROM gifts 
                      JOIN matches ON gifts.id = matches.gift_id 
                      JOIN exchanges ON exchanges.id = matches.exchange_id 
                      JOIN memberships ON exchanges.id = memberships.exchange_id 
                      JOIN users ON users.id = memberships.user_id 
                      WHERE exchanges.match_date < :todays_date 
                      AND exchanges.exchange_date > :todays_date 
                      AND users.id = :user_id", 
                      :todays_date => Date.today, 
                      :user_id => self.id)
  end

  # Exchages that are acvite but a user has not selected a gift for
  def active_exchanges_without_gifts
    Exchange.find_by_sql("SELECT exchanges.* FROM exchanges  
                          JOIN matches ON exchanges.id = matches.exchange_id 
                          JOIN users ON matches.santa_id = users.id
                          WHERE exchanges.match_date < :todays_date 
                          AND exchanges.exchange_date > :todays_date 
                          AND users.id = :user_id 
                          AND users.id = matches.santa_id
                          AND matches.gift_id is NULL", 
                          :todays_date => Date.today, 
                          :user_id => self.id)
  end

  # Profiles of Users a person is a secret santa for on active exchanges
  def active_recipient_profiles
    Profile.find_by_sql("SELECT profiles.* 
                         FROM profiles 
                         WHERE profiles.user_id IN 
                         (
                          SELECT users.id 
                          FROM users
                          JOIN matches ON users.id = matches.recipient_id 
                          JOIN exchanges ON matches.exchange_id = exchanges.id
                          WHERE exchanges.match_date < :todays_date 
                          AND exchanges.exchange_date > :todays_date
                          AND matches.santa_id = :user_id)", 
                         :todays_date => Date.today,
                         :user_id => self.id)
  end

  # New matchings

  # New invitations

  # active organized exchanges (post-match, pre-ship)

  # active exchanges user is participating in (post match, pre-ship)
  def active_exchanges
    self.participations.where(':todays_date > match_date 
                               AND :todays_date < exchange_date', 
                               :todays_date => Date.today)
  end

  #For testing purposes because I want users for whom user has no gifts and exchanges for whom user has no gifts
  def matches_without_gifts  
    self.santa_matches.where("gift_id is NULL")
  end

  # Allows us to get exchange id's and user id's for people user is a santa for currently
  def current_santa_matches
    self.santa_matches.joins(:exchange).where("")
  end

  # finished exchanges participated in

  # upcoming organized_exchange (pre-match)

  # past gifts given
end
