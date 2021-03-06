class WikiPolicy < ApplicationPolicy

  attr_reader :user, :wiki

  def initialize(user, wiki)
    @user = user
    @wiki = wiki
  end

   def create?
     user.present?
   end

   def update?
     #user.present? && (user.admin? or user == wiki.user)

     user.present?

   end

   def destroy?
     user.present?
     #(user.present? && user.admin?) #premium couldnt delete own wiki with this
   end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
        wikis = []
        if user.nil?  #NECESSARY
          all_wikis = scope.all
          wikis = []
          all_wikis.each do |wiki|
            if !wiki.private?
              wikis << wiki
            end
          end

        elsif user.role == 'admin'
            wikis = scope.all # if admin, show all wikis

        elsif user.role == 'premium'
            all_wikis = scope.all
            all_wikis.each do |wiki|
                if !wiki.private? || wiki.user == user || wiki.collaborating_users.include?(user)
                    wikis << wiki # if premium -> show public, own private, and collaborating wikis
                end
            end

        else # standard user
            all_wikis = scope.all
            wikis = []
            all_wikis.each do |wiki|
                if !wiki.private? || wiki.collaborating_users.include?(user)
                    wikis << wiki #if standard -> public and collaborating wikis
                end
            end
        end
        wikis # return new array
    end
end
end
