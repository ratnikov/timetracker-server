module AccessibleAccessor
  def accessible_attribute?(key)
    list = (accessible_attributes - [ "" ])

    list.include?(key.to_sym) || list.include?(key.to_s)
  end
end

ActiveRecord::Base.extend AccessibleAccessor
