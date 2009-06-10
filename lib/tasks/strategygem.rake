namespace :strategygem do

  INITIALIZABLE_MODELS=['profiles', 'default_user_and_enterprise', 'time_units_and_periods', 'pages']
  
  desc "initialize content db (initial load)"
  task :initialize_contents => :environment do |t|    
    puts "please confirm you initialize contents (type 'yes' to confirm, 'ask' to select each content or anything else to skip)"
    s_answer = $stdin.gets
    if s_answer.chomp == 'yes'
      init_all 
    elsif s_answer.chomp == 'ask'
      init_asking 
    else
      puts "initialize_contents skipped"
    end   
  end #task do
  
  def init_all 
    INITIALIZABLE_MODELS.each do |model|      
      self.send("init_#{model}")
      puts "#{model} initialized"    
    end
  end     

  def init_asking 
    INITIALIZABLE_MODELS.each do |model|
      puts "please confirm you want to initialize #{model}  (type 'yes' to confirm or anything else to skip)"
      s_answer = $stdin.gets
      if s_answer.chomp == 'yes'
        self.send("init_#{model}")
        puts "#{model} initialized"
      else
        puts "init_#{model} skipped"
       end
     end
  end

  #Initiliaze profiles
  def init_profiles    
    [
      ['master', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'N'],
      ['minimaster', 'X', 'X', 'X', 'U', 'N', 'N', 'N', 'N'],
      ['enterprise manager', 'E', 'N', 'N', 'E', 'E', 'E', 'E', 'N'],
      ['dashboard manager', 'N', 'N', 'N', 'U', 'A', 'A', 'A', 'N'],
      ['objective manager', 'N', 'N', 'N', 'U', 'N', 'O', 'O', 'N'],
    ].each do |prof|
      p = Profile.new()
      p.name = prof[0]
      p.privilege1 = prof[1]
      p.privilege2 = prof[2]
      p.privilege3 = prof[3]
      p.privilege4 = prof[4]
      p.privilege5 = prof[5]
      p.privilege6 = prof[6]
      p.privilege7 = prof[7]
      p.privilege8 = prof[8]
	  p.save!
    end
  end
  
  #Initiliaze admin user
  def init_default_user_and_enterprise
    e = Enterprise.new()
	e.name = 'MadridOnRails'
	e.alias = 'mor'
	e.css = 'default'
	e.save!
    u = User.new
    u.password = 'Str4tegyG3m'
    u.password_confirmation = 'Str4tegyG3m'
    u.first_name = 'Mor'
    u.last_name = 'Administator'
    u.email = 'admin@strategygem.com'
    u.profile= Profile.find_by_name('master')
    u.enterprise = e
    u.save!
  end

  #Initiliaze time
  def init_time_units_and_periods
  	t1 = TimeUnit.new (:name => 'dia', :adjective => 'diario', :days => 1)
  	t1.save!
  	t7 = TimeUnit.new (:name => 'semana', :adjective => 'semanal', :days => 7)
  	t7.save!
  	t31 = TimeUnit.new (:name => 'mes', :adjective => 'mensual', :days => 31)
  	t31.save!
  	per1 = Period.new (:time_unit_id => t1.id, :days => 1)
  	per1.save!
  	per7L = Period.new (:time_unit_id => t7.id, :days => 1)
  	per7L.save!
  	per7M = Period.new (:time_unit_id => t7.id, :days => 2)
  	per7M.save!
  	per7X = Period.new (:time_unit_id => t7.id, :days => 3)
  	per7X.save!
  	per7J = Period.new (:time_unit_id => t7.id, :days => 4)
  	per7J.save!
  	per7_V = Period.new (:time_unit_id => t7.id, :days => 5)
  	per7_V.save!
  	per7_S = Period.new (:time_unit_id => t7.id, :days => 6)
  	per7_S.save!
  	per7_D = Period.new (:time_unit_id => t7.id, :days => 7)
  	per7_D.save!
  	per31_1= Period.new (:time_unit_id => t31.id, :days => 1)
  	per31_1.save!
  	per31_2= Period.new (:time_unit_id => t31.id, :days => 2)
  	per31_2.save!
  	per31_3= Period.new (:time_unit_id => t31.id, :days => 3)
  	per31_3.save!
  	per31_4= Period.new (:time_unit_id => t31.id, :days => 4)
  	per31_4.save!
  	per31_5= Period.new (:time_unit_id => t31.id, :days => 5)
  	per31_5.save!
  	per31_6= Period.new (:time_unit_id => t31.id, :days => 6)
  	per31_6.save!
  	per31_7= Period.new (:time_unit_id => t31.id, :days => 7)
  	per31_7.save!
  	per31_8= Period.new (:time_unit_id => t31.id, :days => 8)
  	per31_8.save!
  	per31_9= Period.new (:time_unit_id => t31.id, :days => 9)
  	per31_9.save!
  	per31_10= Period.new (:time_unit_id => t31.id, :days => 10)
  	per31_10.save!
  	per31_11= Period.new (:time_unit_id => t31.id, :days => 11)
  	per31_11.save!
  	per31_12= Period.new (:time_unit_id => t31.id, :days => 12)
  	per31_12.save!
  	per31_13= Period.new (:time_unit_id => t31.id, :days => 13)
  	per31_13.save!
  	per31_14= Period.new (:time_unit_id => t31.id, :days => 14)
  	per31_14.save!
  	per31_15= Period.new (:time_unit_id => t31.id, :days => 15)
  	per31_15.save!
  	per31_16= Period.new (:time_unit_id => t31.id, :days => 16)
  	per31_16.save!
  	per31_17= Period.new (:time_unit_id => t31.id, :days => 17)
  	per31_17.save!
  	per31_18= Period.new (:time_unit_id => t31.id, :days => 18)
  	per31_18.save!
  	per31_19= Period.new (:time_unit_id => t31.id, :days => 19)
  	per31_19.save!
  	per31_20= Period.new (:time_unit_id => t31.id, :days => 20)
  	per31_20.save!
  	per31_21= Period.new (:time_unit_id => t31.id, :days => 21)
  	per31_21.save!
  	per31_22= Period.new (:time_unit_id => t31.id, :days => 22)
  	per31_22.save!
  	per31_23= Period.new (:time_unit_id => t31.id, :days => 23)
  	per31_23.save!
  	per31_24= Period.new (:time_unit_id => t31.id, :days => 24)
  	per31_24.save!
  	per31_25= Period.new (:time_unit_id => t31.id, :days => 25)
  	per31_25.save!
  	per31_26= Period.new (:time_unit_id => t31.id, :days => 26)
  	per31_26.save!
  	per31_27= Period.new (:time_unit_id => t31.id, :days => 27)
  	per31_27.save!
  	per31_28= Period.new (:time_unit_id => t31.id, :days => 28)
  	per31_28.save!
  	per31_29= Period.new (:time_unit_id => t31.id, :days => 29)
  	per31_29.save!
  	per31_30= Period.new (:time_unit_id => t31.id, :days => 30)
  	per31_30.save!
  	per31_31= Period.new (:time_unit_id => t31.id, :days => 31)
  	per31_31.save!
  end
  
  #Initiliaze pages
  def init_pages
    p_index = ContentPage.find_by_page_path('/index')
    p_index.page_template = 'web_public_general'
    p_index.save
    
    [['tour', 'web_public_general', nil],
     ['help', nil, 
      [['index', 'web_public_faq_list', nil],
       ['about_strategygem', nil,
        [['index', 'web_public_faq_sublist', nil],
         ['initial_idea', 'web_public_faq_detail', nil],
         ['what_is_asp', 'web_public_faq_detail', nil],
         ['can_i_see_a_demo', 'web_public_faq_detail', nil],
         ['can_i_use_outside_spain', 'web_public_faq_detail', nil],
         ['how_long_you_keep_my_data', 'web_public_faq_detail', nil]
        ]
       ],
       ['about_functionality', nil,
        [['index', 'web_public_faq_sublist', nil],
         ['what_can_i_do_if_forgot_my_access_page', 'web_public_faq_detail', nil],
         ['accepted_browsers', 'web_public_faq_detail', nil],
         ['how_do_i_see_my_scorecards', 'web_public_faq_detail', nil]
        ]
       ],
       ['about_scorecards', nil,
        [['index', 'web_public_faq_sublist', nil],
         ['what_is_a_scorecard', 'web_public_faq_detail', nil],
         ['what_is_a_perspective', 'web_public_faq_detail', nil],
         ['what_is_an_objective', 'web_public_faq_detail', nil]
        ]
       ],
      ]
     ], 
     ['about_us', 'web_public_general', nil], 
     ['contact', 'web_public_general', nil],
     ['register', 'web_public_register', nil],
     ['login', 'web_public_login', nil],
     ['forgot', 'web_public_forgot', nil]].each_with_index do |p, i|
      my_p = ContentPage.find_or_initialize_by_page_path("/#{p[0]}")
      my_p.title = p[0]
      my_p.page_template = p[1]
	    my_p.parent = p_index.parent
      my_p.position = p_index.position + i + 1
      my_p.save!
      unless p[2].blank?
        p[2].each_with_index do |p1l, j|
          my_1lp = ContentPage.find_or_initialize_by_page_path("/#{p[0]}/#{p1l[0]}")
          my_1lp.title = p1l[0]
          my_1lp.page_template = p1l[1]
    	    my_1lp.parent = my_p
          my_1lp.position = j + 1
          my_1lp.save!
          unless p1l[2].blank?
            p1l[2].each_with_index do |p2l, k|
              my_2lp = ContentPage.find_or_initialize_by_page_path("/#{p[0]}/#{p1l[0]}/#{p2l[0]}")
              my_2lp.title = p2l[0]
              my_2lp.page_template = p2l[1]
        	    my_2lp.parent = my_1lp
              my_2lp.position = k + 1
              my_2lp.save!
            end
          end
        end
      end
    end
  end
end #namespace

