FactoryGirl.define do 
  
  sequence(:full_name) {|n| "Test #{n}"}
  sequence(:username) {|n| "test#{n}"}
  sequence(:email) {|n| "test#{n}@test.com"}
  
  factory :user do |f| 
    full_name
    username
    f.password "asdfasdf"
    f.password_confirmation "asdfasdf"
    f.birth_date Date.current
    email
    
    factory :no_full_name_user do |f_attr| 
      f_attr.full_name nil
    end
    
    factory :no_username_user do |f_attr| 
      f_attr.username nil
    end
    
    factory :no_password_user do |f_attr| 
      f_attr.password nil
    end
    
    factory :no_birth_date_user do |f_attr| 
      f_attr.birth_date nil
    end
    
    factory :no_email_user do |f_attr| 
      f_attr.email nil
    end
    
  end
end 