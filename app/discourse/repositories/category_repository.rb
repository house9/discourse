module Repositories
  module CategoryRepository

    def self.default
      Category.where(id: SiteSetting.uncategorized_category_id).first
    end

    def self.find_by_name(category_name)
      Category.where(name: category_name).first
    end

  end
end