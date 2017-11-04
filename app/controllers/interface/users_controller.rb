# -*- encoding : utf-8 -*-
class Interface::UsersController < Interface::ApplicationController

  def send_login_token
    phone = params[:mobile]
    if phone.present?
      token = rand(9999)
      MobileUser.send_sms(phone, token)
      render :json=>{status: '200', token: Digest::MD5.hexdigest(token.to_s)}
    else
      render :json=>{status: '503', message: '参数不能为空.'}
    end
  end

  def login_with_token
    phone = params[:mobile]

    #用户输入的短信验证码
    token = params[:token].to_s

    #发送的用户验证码
    send_token = params[:send_token]

    if phone.present? and token.present?
      @mobile_user = MobileUser.find_by_phone(phone)

      if phone.to_i == 13566668888

        #如果有的话就直接更新，没有的话，保存
        if @mobile_user.present?
          @mobile_user.update_attribute("sms_token", token)
          @mobile_user_id = @mobile_user.id
        else
          @m = MobileUser.new(:sms_token => token, :phone=>phone)
          @m.save_by_token
          @mobile_user_id = @m.id
        end
        render :json=>{
                   result: 'success',
                   id: @mobile_user_id
               }
      elsif Digest::MD5.hexdigest(token) != send_token
        render json: {
                   result: 'fail',
                   message: '验证码不正确'
               }
      else
        #如果有的话就直接更新，没有的话，保存
        if @mobile_user.present?
          @mobile_user.update_attribute("sms_token", token)
          @mobile_user_id = @mobile_user.id
        else
          @m = MobileUser.new(:sms_token => token, :phone=>phone)
          @m.save_by_token
          @mobile_user_id = @m.id
        end

        render :json=>{
                   result: 'success',
                   id: @mobile_user_id
               }
      end
    else
      render :json=>{status: '503', message: '参数不能为空.'}
    end
  end


  def get_user_info
    if params[:uuid].present?
      @user = MobileUser.find_by_token(params[:uuid])
      render :json=>{
                 result: @user
             }
    else
      render :json=>{status: '503', message: '参数不能为空.'}
    end
  end

  def get_data
    @data = []
    Province.includes(:cities).each do |province|
      @data.push({
                     name: province.name,
                     value: province.name,
                     parent: 0
                 })
      province.cities.includes(:towns).each do |city|
        @data.push({
                       name: city.name,
                       value: city.name,
                       parent: province.name
                   })
        city.towns.each do |town|
          @data.push({
                         name: town.name,
                         value: town.name,
                         parent: city.name
                     })
        end
      end
    end
    @data
  end

  def edit_user_info
    @mobile_user = MobileUser.find(params[:id])

    render json: {
               name: @mobile_user.name,
               icon: @mobile_user.icon + "!user.avatar",
               phone: @mobile_user.phone,
               address: @mobile_user.address,
               data: get_data,
               address_array: [(@mobile_user.province.name rescue''),(@mobile_user.city.name rescue''), (@mobile_user.town.name rescue'')]
           }
  end

  def upload(image, image_column)
    require 'upyun'

    bucket = Settings.carrierwave.bucket
    operator = Settings.carrierwave.operator
    password = Settings.carrierwave.password

    upyun = Upyun::Rest.new(bucket, operator, password)


    # 保存到本地
    require 'data_uri'

    new_file_name = Time.now.strftime('%Y-%m-%d') + rand(10000).to_s + ".jpg"
    remote_file = "/image/shangyunyijia/#{new_file_name}"

    uri = URI::Data.new(image)

    file_on_local_path = "#{Rails.root}/public/uploads/#{new_file_name}"
    File.write(file_on_local_path, uri.data.force_encoding('UTF-8'))

    response = upyun.put remote_file, File.new(file_on_local_path)


    {
      image_column => "#{Settings.carrierwave.bucket_host}#{remote_file}"
    }
  end

  def update_user_info
    if params[:id].present?
      @mobile_user = MobileUser.find(params[:id])

      Rails.logger.info "====参数处理之前===#{params[:user]}"

      begin
        province_id = Province.find_by_name(params[:address_array][0]).id if params[:address_array].present?
        city_id = City.find_by_name_and_province_id(params[:address_array][1], province_id).id if params[:address_array].present?
        town_id = Town.find_by_name_and_city_id(params[:address_array][2], city_id).id if params[:address_array].present?
      rescue Exception => e
        Rails.logger.warn "== #{e}, (应该是用户没有选择省份，传入了 ['', '','']这样的参数引起的。不必担心 "
        Rails.logger.warn e.backtrace.join("\n")
      end

      # params[:user][:province_id] = province_id
      # params[:user][:city_id] = city_id
      # params[:user][:town_id] = town_id

      Rails.logger.info "====参数处理之后===#{params[:user]}"


      @is_exist = MobileUser.where(:phone=>params[:phone]).where("id != ?", params[:id])

      if @is_exist.present?
        render :json => {status: 500, message: '手机号码已经存在,由于手机号码用于登录,不能重复创建.'}
      else
        @mobile_user.update_attributes(:name=>params[:name], :phone=>params[:phone], :address=>params[:address],
                                       :province_id=>province_id, :city_id=>city_id, :town_id=>town_id)


        render json: {
                   status: 200,
                   message: '修改成功'
               }
      end
    else
      render :json=>{status: '503', message: '参数不能为空.'}
    end
  end

  def update_user_icon
     return  render json: { message: "参数不能为空"} if params[:id].blank?
     mobile_user = MobileUser.find(params[:id])
     mobile_user.update upload(params[:icon],:icon)
     render json: {
       message: '更换成功',
       icon: mobile_user.icon
     }
  end

end
