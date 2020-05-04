class CreditCardsController < ApplicationController
  require "payjp" # PAYJPとやり取りするために、payjpをロード

  def new
    
    # すでにクレジットカード登録されている場合は、showアクションにリダイレクト
    # @card = CreditCard.where(user_id: current_user.id)
    # redirect_to credit_card_path(current_user.id) if @card.exists?
  end

  def create
    Payjp.api_key = Rails.application.credentials.dig(:payjp, :PAYJP_SECRET_KEY)

    if params["payjp_token"].blank?
      redirect_to action: "new", alert: "クレジットカードを登録できませんでした。"
    else
      customer = Payjp::Customer.create(
        card: params["payjp_token"],
        # metadata: {user_id: current_user.id}
      )
      @card = CreditCard.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
      if @card.save
        redirect_to card_path(card)
      else
        redirect_to action: "create"
      end
    end
  end

  def index
    # ログイン中のユーザーのクレジットカード登録の有無を判断
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      # 未登録なら新規登録画面に
      redirect_to action: "new" 
    else
      # 前前回credentials.yml.encに記載したAPI秘密鍵を呼び出します。
      Payjp.api_key = Rails.application.credentials.dig(:payjp, :PAYJP_SECRET_KEY)
      # ログインユーザーのクレジットカード情報からPay.jpに登録されているカスタマー情報を引き出す
      customer = Payjp::Customer.retrieve(@card.customer_id)
      # カスタマー情報からカードの情報を引き出す
      @customer_card = customer.cards.retrieve(@card.card_id)

      ##カードのアイコン表示のための定義づけ
      @card_brand = @customer_card.brand
      case @card_brand
      when "Visa"
        # 例えば、Pay.jpからとってきたカード情報の、ブランドが"Visa"だった場合は返り値として
        # (画像として登録されている)Visa.pngを返す
        @card_src = "visa.png"
      when "JCB"
        @card_src = "jcb.png"
      when "MasterCard"
        @card_src = "master.png"
      when "American Express"
        @card_src = "amex.png"
      when "Diners Club"
        @card_src = "diners.png"
      when "Discover"
        @card_src = "discover.png"
      end

      #  viewの記述を簡略化
      ## 有効期限'月'を定義
      @exp_month = @customer_card.exp_month.to_s
      ## 有効期限'年'を定義
      @exp_year = @customer_card.exp_year.to_s.slice(2,3)
    end
  end

  def destroy
    # ログイン中のユーザーのクレジットカード登録の有無を判断
    @card = CreditCard.find_by(user_id: current_user.id)
    if @card.blank?
      # 未登録なら新規登録画面に
      redirect_to action: "new"
    else
      # 前前回credentials.yml.encに記載したAPI秘密鍵を呼び出します。
      Payjp.api_key = Rails.application.credentials.dig(:payjp, :PAYJP_SECRET_KEY)
      # ログインユーザーのクレジットカード情報からPay.jpに登録されているカスタマー情報を引き出す
      customer = Payjp::Customer.retrieve(@card.customer_id)
      # そのカスタマー情報を消す
      customer.delete
      @card.delete
      # 削除が完了しているか判断
      if @card.destroy
      # 削除完了していればdestroyのビューに移行
      # destroyビューを作るのが面倒であれば、flashメッセージを入れてトップページやマイページに飛ばしてもOK

      else
        # 削除されなかった場合flashメッセージを表示させて、showのビューに移行
        redirect_to credit_card_path(current_user.id), alert: "削除できませんでした。"
      end
    end
  end
end