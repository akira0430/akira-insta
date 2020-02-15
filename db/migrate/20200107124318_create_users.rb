class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :user_name
      t.string :email
      t.string :phone
      t.string :gender
      t.text :web_site
      t.text :introduction
      t.timestamps
    end
  end
end
