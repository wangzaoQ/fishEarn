class CashConfig {

  static Map<String, dynamic> defaultTask = {
    "task1": [
      {
        "defend": 5,
        "feed": 5
      }
    ],
    "task2": [
      {
        "bubbles": 5,
        "spins": 10
      }
    ],
    "task3": [
      {
        "login": 2,
        "feed": 5
      }
    ],
    "task4": [
      {
        "bubbles": 5,
        "spins": 10
      }
    ],
    "task5": [
      {
        "login": 3,
        "defend": 5
      }
    ]
  };


  static Map<String, dynamic> defaultRank = {
    "queue": [
      {
        "m_m": [5, 8],
        "s_s": [25, 35]
      }
    ]
  };

  static Map<String, dynamic> defaultIntAD =
  {
    "int_ad": [
      {
        "first_number": 0,
        "point": 0,
        "end_number": 400
      },
      {
        "first_number": 400,
        "point": 50,
        "end_number": 500
      },
      {
        "first_number": 500,
        "point": 100,
        "end_number": 9999
      }
    ]
  }
  ;

  /**
   * shark_attack 鲨鱼攻击间隔 60秒
   * protect_type 1 点击防护功能 2选1   0 直接走激励广告
   * unlimited_time 无限点击珍珠弹窗时间
   */
  static Map<String, dynamic> defaultGlobalConfig = {
    "shark_attack":60,
    "protect_type":1,
    "unlimited_time":100,
    "level_1_2":10,
    "level_2_3":20,
  };

  static Map<String, dynamic> defaultReward =//idle_reward2 2级挂机美秒金额
//idle_reward3 3级挂机美秒金额
//old_users_award 老用户离线奖励弹窗奖励
//cash_bubble_t 现金泡泡时间
//cash_bubble 现金泡泡
//give_up 升级奖励
//pearl_wheel 贝壳转盘奖金配置
//drift_bottle 漂流瓶现金奖励
  {
    "idle_reward2": {
      "prize": [
        0.08
      ]
    },
    "idle_reward3": {
      "prize": [
        0.1
      ]
    },
    "old_users_award": {
      "prize": [
        {
          "first_number": 0,
          "prize": [
            10,
            15
          ],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [
            8,
            10
          ],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [
            5,
            8
          ],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [
            3,
            5
          ],
          "end_number": 999999
        }
      ]
    },
    "cash_bubble_t": {
      "prize": [
        5
      ]
    },
    "cash_bubble": {
      "prize": [
        {
          "first_number": 0,
          "prize": [
            10,
            15
          ],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [
            8,
            12
          ],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [
            5,
            8
          ],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [
            2,
            4
          ],
          "end_number": 999999
        }
      ]
    },
    "pearl_wheel": {
      "prize": [
        {
          "first_number": 0,
          "prize": [
            10,
            11,
            12,
            13
          ],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [
            8,
            9,
            10,
            11
          ],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [
            6,
            7,
            8,
            9
          ],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [
            3,
            4,
            5,
            6
          ],
          "end_number": 999999
        }
      ]
    },
    "drift_bottle": {
      "prize": [
        {
          "first_number": 0,
          "prize": [
            10,
            12
          ],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [
            8,
            10
          ],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [
            5,
            8
          ],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [
            2,
            5
          ],
          "end_number": 999999
        }
      ]
    }
  };


}