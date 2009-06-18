# Fix the countries table.
#
class UpdateCountries < ActiveRecord::Migration
  
  # Number of orders array, used to fix the wrong initial values.
  NOO_ARRAY = [[[1], 4987],
    [[3], 151], [[4], 128], [[2], 121], [[5], 58], [[101], 36], [[85, 91], 21], [[52], 16],
    [[191], 14], [[173], 13], [[72, 115, 167], 10], [[164], 9], [[133, 168], 8], [[122], 7],
    [[95, 67, 92, 118, 93], 6], [[75, 29, 160, 66, 51], 4], [[136, 130, 42], 3],
    [[139, 86, 129, 161, 176, 59, 17, 7, 88, 104, 151, 192, 8, 137, 94, 223, 124, 9], 2],
    [[55, 100, 58, 225, 78, 144, 6, 18], 1]]
  
  # Ufsi array, here just to be able to be restored. 
  UFSI_ARRAY = [[1, "001"], [2, "034"], [3, "073"], [4, "012"], [5, "087"], [6, "002"], [7, "003"], [8, "004"],
    [9, "005"], [10, "006"], [11, "007"], [12, "008"], [13, "009"], [14, "010"], [15, "011"], [16, "013"],
    [17, "014"], [18, "015"], [19, "016"], [20, "017"], [21, "018"], [22, "019"], [23, "020"], [24, "021"],
    [25, "022"], [26, "023"], [27, "024"], [28, "025"], [29, "026"], [30, "027"], [31, "028"], [32, "029"],
    [33, "030"], [34, "031"], [35, "032"], [36, "033"], [37, "035"], [38, "036"], [39, "037"], [40, "038"],
    [41, "039"], [42, "040"], [43, "041"], [44, "042"], [45, "043"], [46, "044"], [47, "045"], [48, "046"],
    [49, "047"], [50, "048"], [51, "049"], [52, "050"], [53, "051"], [54, "052"], [55, "053"], [56, "054"],
    [57, "055"], [58, "056"], [59, "057"], [60, "058"], [61, "059"], [62, "060"], [63, "061"], [64, "062"],
    [65, "063"], [66, "064"], [67, "065"], [68, "066"], [69, "067"], [70, "068"], [71, "069"], [72, "070"],
    [73, "071"], [74, "072"], [75, "074"], [76, "075"], [77, "076"], [78, "077"], [79, "078"], [80, "079"],
    [81, "080"], [82, "081"], [83, "082"], [84, "083"], [85, "084"], [86, "085"], [87, "086"], [88, "088"],
    [89, "089"], [90, "090"], [91, "091"], [92, "092"], [93, "093"], [94, "094"], [95, "095"], [96, "096"],
    [97, "097"], [98, "098"], [99, "099"], [100, "100"], [101, "101"], [102, "102"], [103, "103"], [104, "104"],
    [105, "105"], [106, "106"], [107, "107"], [108, "108"], [109, "109"], [110, "110"], [111, "111"],
    [112, "112"], [113, "113"], [114, "114"], [115, "115"], [116, "116"], [117, "117"], [118, "118"],
    [119, "119"], [120, "120"], [121, "121"], [122, "122"], [123, "123"], [124, "124"], [125, "125"],
    [126, "126"], [127, "127"], [128, "128"], [129, "129"], [130, "130"], [131, "131"], [132, "132"],
    [133, "133"], [134, "134"], [135, "135"], [136, "136"], [137, "137"], [138, "138"], [139, "139"],
    [140, "140"], [141, "141"], [142, "142"], [143, "143"], [144, "144"], [145, "145"], [146, "146"],
    [147, "147"], [148, "148"], [149, "149"], [150, "150"], [151, "151"], [152, "152"], [153, "153"],
    [154, "154"], [155, "155"], [156, "156"], [157, "157"], [158, "158"], [159, "159"], [160, "160"],
    [161, "161"], [162, "162"], [163, "163"], [164, "164"], [165, "165"], [166, "166"], [167, "167"],
    [168, "168"], [169, "169"], [170, "170"], [171, "171"], [172, "172"], [173, "173"], [174, "174"],
    [175, "175"], [176, "176"], [177, "177"], [178, "178"], [179, "179"], [180, "180"], [181, "181"],
    [182, "182"], [183, "183"], [184, "184"], [185, "185"], [186, "186"], [187, "187"], [188, "188"],
    [189, "189"], [190, "190"], [191, "191"], [192, "192"], [193, "193"], [194, "194"], [195, "195"],
    [196, "196"], [197, "197"], [198, "198"], [199, "199"], [200, "200"], [201, "201"], [202, "202"],
    [203, "225"], [204, "226"], [205, "227"], [206, "229"], [207, "230"], [208, "231"], [209, "232"],
    [210, "233"], [211, "234"], [212, "235"], [213, "236"], [214, "237"], [215, "238"], [216, "239"],
    [217, "240"], [218, "241"], [219, "242"], [220, "243"], [221, "244"], [222, "245"], [223, "246"],
    [224, "247"], [225, "280"], [226, "248"], [227, "249"], [228, "250"], [229, "251"], [230, "252"],
    [231, "253"], [232, "254"], [233, "257"], [234, "258"], [235, "259"], [236, "260"], [237, "261"],
    [238, "301"], [239, "262"], [240, "263"], [241, "304"], [242, "265"], [243, "266"], [244, "267"],
    [245, "268"], [246, "305"], [247, "306"], [248, "271"], [249, "272"], [250, "310"], [251, "311"],
    [252, "275"], [253, "276"], [255, "278"], [256, "279"], [257, "300"], [258, "302"], [259, "303"],
    [260, "307"], [261, "308"], [262, "309"], [263, "312"]]

  def self.up
    remove_column :countries, :ufsi_code
    remove_column :countries, :number_of_orders
    rename_column :countries, :fedex_code, :code
    add_column :countries, :rank, :integer
    add_column :countries, :is_obsolete, :boolean, :default => false, :null => false
    
    ActiveRecord::Base.transaction do
      # New countries to add.
      Country.create(
        [
          { :code => "WS", :name => "Samoa" },
          { :code => "RS", :name => "Serbia" },
          { :code => "IM", :name => "Isle of Man" },
          { :code => "GG", :name => "Guernsey" },
          { :code => "AX", :name => "Åland Islands" },
          { :code => "CK", :name => "Cook Islands" },
          { :code => "JE", :name => "Jersey" },
          { :code => "ME", :name => "Montenegro" },
          { :code => "UM", :name => "United States Minor Outlying Islands" },
          { :code => "BL", :name => "Saint Barthélemy" },
          { :code => "MF", :name => "Saint Martin" }
        ]
      )
  
      # Update codes and/or names of some countries.
      Country.update(  3, :name => "United Kingdom")
      Country.update( 30, :name => "Virgin Islands, British")
      Country.update( 31, :name => "Brunei Darussalam")
      Country.update( 45, :name => "Congo, Republic of the")
      Country.update( 48, :name => "Côte d'Ivoire")
      Country.update( 56, :name => "Timor-Leste")
      Country.update( 63, :name => "Falkland Islands (Malvinas)")
      Country.update( 89, :name => "Iran, Islamic Republic of")
      Country.update(100, :code => "KP", :name => "Korea, North")
      Country.update(102, :name => "Lao People's Democratic Republic")
      Country.update(107, :name => "Libyan Arab Jamahiriya")
      Country.update(117, :code => "ML")
      Country.update(131, :name => "Netherlands Antilles")
      Country.update(145, :name => "Pitcairn")
      Country.update(149, :name => "Réunion")
      Country.update(151, :name => "Russian Federation")
      Country.update(153, :name => "Saint Kitts and Nevis")
      Country.update(157, :name => "Saint Vincent and the Grenadines")
      Country.update(159, :name => "Sao Tome and Principe")
      Country.update(175, :name => "Syrian Arab Republic")
      Country.update(185, :name => "Turks and Caicos Islands")
      Country.update(187, :name => "Wallis and Futuna Islands")
      Country.update(194, :name => "Vatican City State")
      Country.update(196, :name => "Viet Nam")
      Country.update(202, :name => "Korea, South")
      Country.update(205, :code => "BY", :name => "Belarus")
      Country.update(206, :name => "Georgia")
      Country.update(216, :name => "Bosnia and Herzegovina")
      Country.update(221, :name => "Slovakia")
      Country.update(229, :name => "British Indian Ocean Territory")
      Country.update(232, :name => "Cocos (Keeling) Islands")
      Country.update(235, :name => "French Southern Territories")
      Country.update(237, :name => "Heard Island and McDonald Islands")
      Country.update(241, :name => "Micronesia, Federated States of")
      Country.update(249, :code => "PR")
      Country.update(250, :name => "South Georgia and the South Sandwich Islands")
      Country.update(251, :name => "Svalbard")
      Country.update(255, :name => "Virgin Islands, U.S.")
      Country.update(257, :name => "Congo, Democratic Republic of the")
      Country.update(260, :name => "Palestinian Territory, Occupied")

      # Initializing new columns.
      Country.update_all("is_obsolete = 0")
      Country.update_all("rank = 10")

      # Old countries to make obsolete.
      [15, 17, 34, 46, 97, 113, 182, 189, 198, 199, 209, 210, 211, 212, 218, 222,
       223, 224, 225, 234, 238, 256, 258, 259, 261, 262, 263].each do |country_id|
         Country.find(country_id).update_attribute(:is_obsolete, true)
      end
      
      # Lower the rank of the countries we want to see first.
      Country.update(1, :rank => 0)
    end # transaction
  end
  
  def self.down
    add_column :countries, :ufsi_code, :string
    add_column :countries, :number_of_orders, :integer
    rename_column :countries, :code, :fedex_code
    remove_column :countries, :rank
    remove_column :countries, :is_obsolete
    
    ActiveRecord::Base.transaction do
      # Putting back old columns.
      # Put zeros at all number of orders then set those different of zero.
      Country.update_all("number_of_orders = 0")
      NOO_ARRAY.each do |a_pair|
        a_pair[0].each do |a_country_id|
          Country.update(a_country_id, :number_of_orders => a_pair[1])
        end
      end
      # Put back ufsi codes.
      UFSI_ARRAY.each do |a_pair|
        Country.update(a_pair[0], :ufsi_code => a_pair[1])
      end

      # Delete added countries.
      ["WS", "RS", "IM", "GG", "AX", "CK", "JE", "ME", "UM", "BL", "MF"].each do |country_code|
         Country.find_by_fedex_code(country_code).destroy
      end
  
      # Update codes and/or names of some countries back to original.
      Country.update(  3, :name => "Great Britian")
      Country.update( 30, :name => "British Virgin Islands")
      Country.update( 31, :name => "Brunei")
      Country.update( 45, :name => "Congo")
      Country.update( 48, :name => "Cote d'Ivoire")
      Country.update( 56, :name => "East Timor")
      Country.update( 63, :name => "Falkland Islands")
      Country.update( 89, :name => "Iran")
      Country.update(100, :fedex_code => "", :name => "Korea, Democ. Peoples Rep.")
      Country.update(102, :name => "Laos")
      Country.update(107, :name => "Libya")
      Country.update(117, :fedex_code => "MI")
      Country.update(131, :name => "Netherlands Antilies")
      Country.update(145, :name => "Pitcairn Islands")
      Country.update(149, :name => "Reunion Island")
      Country.update(151, :name => "Russia")
      Country.update(153, :name => "St. Christopher & Nevis")
      Country.update(157, :name => "St. Vincent&The Grenadines")
      Country.update(159, :name => "Sao Tome & Principe")
      Country.update(175, :name => "Syria")
      Country.update(185, :name => "Turks & Caicos Islands")
      Country.update(187, :name => "Wallis & Futuna Islands")
      Country.update(194, :name => "Vatican City")
      Country.update(196, :name => "Vietnam")
      Country.update(202, :name => "South Korea")
      Country.update(205, :fedex_code => "", :name => "Byelorussia (Belarus)")
      Country.update(206, :name => "Georgia, Republic Of")
      Country.update(216, :name => "Bosnia (Hercgovina)")
      Country.update(221, :name => "Slovak Republic")
      Country.update(229, :name => "British Indian Ocean Terri")
      Country.update(232, :name => "Cocos (keeling) Islands")
      Country.update(235, :name => "French Southern Territorie")
      Country.update(237, :name => "Heard And Mc Donald Island")
      Country.update(241, :name => "Micronesia")
      Country.update(249, :fedex_code => "US")
      Country.update(250, :name => "South Georgia And The Sout")
      Country.update(251, :name => "Svalbard And Jan Mayen Isl")
      Country.update(255, :name => "U.S. Virgin Islands")
      Country.update(257, :name => "Congo, The Democratic Republic")
      Country.update(260, :name => "Palestine")

    end # transaction
  end
end