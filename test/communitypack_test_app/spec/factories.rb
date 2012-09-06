FactoryGirl.define do

  factory :book do
    title "Journey to Ixtlan"
  end

  factory :author do
    first_name "MyString"
    last_name "MyString"
  end
  
  factory :node do
    title "Some node"
  end
end
