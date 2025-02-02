module Types
  module Achievement
    NEKO_GROUPS = %i[common genre franchise author]
    NekoGroup = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*NEKO_GROUPS)

    NEKO_IDS = {
      NekoGroup[:common] => %i[
        test

        animelist

        otaku
        fujoshi
        yuuri

        tsundere
        yandere
        kuudere
        moe
        genki
        gar
        oniichan
        longshounen
        shortie

        world_masterpiece_theater
        oldfag
        sovietanime
        stop_motion
      ],
      NekoGroup[:genre] => %i[
        comedy
        romance
        fantasy
        historical
        mahou_shoujo
        dementia_psychological
        mecha
        slice_of_life
        scifi
        supernatural

        drama
        horror_thriller
        josei
        kids
        military
        mystery
        police
        space
        sports

        music
      ],
      # rubocop:disable Layout/LineLength
      NekoGroup[:franchise] => %i[
        shingeki_no_kyojin tokyo_ghoul one_punch_man sword_art_online naruto demon_slayer re_zero boku_no_hero_academia fullmetal_alchemist science_adventure nanatsu_no_taizai ao_no_exorcist overlord code_geass evangelion mob_psycho ansatsu_kyoushitsu jojo_no_kimyou_na_bouken bungou_stray_dogs danmachi haikyuu yahari_ore_no_seishun_love_comedy_wa_machigatteiru kaguya_sama tensei_shitara_slime_datta_ken hunter_x_hunter kuroko_no_basket psycho_pass fairy_tail bakemonogatari fate shokugeki_no_souma chuunibyou_demo_koi_ga_shitai bleach kamisama_hajimemashita high_school_dxd kuroshitsuji berserk hellsing durarara danganronpa darker_than_black mahouka_koukou_no_rettousei suzumiya_haruhi_no_yuuutsu k_on black_clover one_piece date_a_live quanzhi_gaoshou black_lagoon when_they_cry saiki_kusuo_no_nan ghost_in_the_shell nisekoi zero_no_tsukaima k toaru_majutsu_no_index magi bakuman puella_magi_sonico_magica grisaia ore_no_imouto gintama clannad free strike_the_blood devilman to_love_ru shingeki_no_bahamut natsume_yuujinchou mo_dao_zu_shi mushishi full_metal_panic kami_nomi_zo_shiru_sekai sora_no_otoshimono kara_no_kyoukai seitokai_yakuindomo tales_of fruits_basket blood love_live non_non_biyori junjou_romantica rurouni_kenshin ashita_no_joe quanzhi_fashi sailor_moon golden_kamuy baki initial_d pokemon working karakai_jouzu_no_takagi_san baka_to_test_to_shoukanjuu arslan_senki ushio_to_tora uta_no_prince_sama honzuki_no_gekokujou jigoku_shoujo shakugan_no_shana hibike_euphonium persona rozen_maiden xxxholic sayonara_zetsubou_sensei amagami_ss hajime_no_ippo chihayafuru hakuouki negima hoozuki_no_reitetsu dragon_ball yuru_yuri baku_tech_bakugan gundam hitori_no_shita tenchi_muyou hetalia yowamushi_pedal terra_formars garo nodame_cantabile lupin_iii utawarerumono inuyasha detective_conan macross ginga_eiyuu_densetsu eureka_seven gochuumon_wa_usagi_desu_ka little_busters ginga_tetsudou slayers dog_days brave_witches kingdom selector_spread_wixoss tiger_bunny diamond_no_ace osomatsu_san ikkitousen yozakura_quartet tsubasa black_jack koneko_no_chi minami_ke aa_megami_sama genshiken cardcaptor_sakura school_rumble slam_dunk hayate_no_gotoku jashin_chan_dropkick idolmaster sengoku_basara tennis_no_ouji_sama kiniro_no_corda gatchaman aquarion hack major teekyuu inazuma_eleven hokuto_no_ken uchuu_senkan_yamato yuu_yuu_hakusho puso_ni_comi aria bang_dream majutsushi_orphen idolish7 yu_gi_oh urusei_yatsura mahou_shoujo_lyrical_nanoha huyao_xiao_hongniang show_by_rock toriko yao_shen_ji uchuu_kyoudai doupo_cangqiong cardfight_vanguard queen_s_blade binan_koukou_chikyuu_boueibu_love senki_zesshou_symphogear marvel mobile_police_patlabor yuki_yuna_is_a_hero ookiku_furikabutte fushigi_yuugi saint_seiya guyver digimon saiyuki mai_hime ranma starmyu maria_sama city_hunter pretty_cure beyblade ad_police taiho_shichau_zo soukyuu_no_fafner saki seikai_no_senki angelique aikatsu glass_no_kamen d_c stitch tsukipro_the_animation gegege_no_kitarou atom pripara tamayura ze_tian_ji hidamari_sketch danball_senki xingchen_bian kimagure_orange_road wan_jie_xian_zong harukanaru_toki_no_naka_de sakura_taisen cutey_honey koihime_musou kindaichi_shounen_no_jikenbo futari_wa_milky_holmes votoms_finder touch captain_tsubasa cyborg transformers space_cobra ling_yu dirty_pair time_bokan el_hazard to_heart konjiki_no_gash_bell di_gi_charat mazinkaiser jigoku_sensei_nube saber_marionette_j galaxy_angel haou_daikei_ryuu_knight
      ],
      NekoGroup[:author] => %i[
        tetsurou_araki tensai_okamura mari_okada makoto_shinkai hayao_miyazaki hiroyuki_imaishi shinichiro_watanabe hiroshi_hamasaki key yasuhiro_takemoto akiyuki_shinbou takahiro_oomori gen_urobuchi hideaki_anno chiaki_kon mamoru_hosoda osamu_tezuka type_moon isao_takahata shoji_kawamori kouji_morimoto masaaki_yuasa morio_asaka satoshi_kon mamoru_oshii masamune_shirow shinji_aramaki kenji_kamiyama yoshiaki_kawajiri junichi_satou clamp go_nagai katsuhiro_otomo kenji_nakamura kouichi_mashimo kunihiko_ikuhara yoshitaka_amano osamu_dezaki rumiko_takahashi leiji_matsumoto rintaro yoshiyuki_tomino ryousuke_takahashi toshio_maeda
      ]
      # rubocop:enable Layout/LineLength
    }
    INVERTED_NEKO_IDS = NEKO_IDS.each_with_object({}) do |(group, ids), memo|
      ids.each { |id| memo[id] = NekoGroup[group] }
    end
    ORDERED_NEKO_IDS = INVERTED_NEKO_IDS.keys

    NekoId = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*ORDERED_NEKO_IDS)
  end
end
