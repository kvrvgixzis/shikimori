class DropReviewViewing < ActiveRecord::Migration[5.2]
  def change
    drop_table "review_viewings", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.integer "viewed_id", null: false
      t.index ["user_id", "viewed_id"], name: "index_review_viewings_on_user_id_and_viewed_id", unique: true
      t.index ["viewed_id"], name: "index_review_viewings_on_viewed_id"
    end
  end
end
