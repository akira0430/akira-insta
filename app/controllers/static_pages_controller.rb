class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @micropost = current_user.microposts.build
      if params[:q]
        relation = Micropost.joins(:user)
        @feed_items = relation.merge(User.search_by_keyword(params[:q]))
                        .or(relation.search_by_keyword(params[:q]))
                        .page(params[:page])
      else
        @feed_items = current_user.feed.page(params[:page])
      end
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
