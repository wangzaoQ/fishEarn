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

  static Map<String, dynamic> defaultIntAD = {
    "int_ad": [
      {
        "first_number": 0,
        "point": 0,
        "end_number": 100
      },
      {
        "first_number": 100,
        "point": 50,
        "end_number": 300
      },
      {
        "first_number": 300,
        "point": 100,
        "end_number": 500
      }
    ]
  };

  /**
   * shark_attack 鲨鱼攻击间隔 60秒
   * protect_type 1 点击防护功能 2选1 0 直接走激励广告
   */
  static Map<String, dynamic> defaultGlobalConfig = {
    "shark_attack":60,
    "protect_type":1,
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
      "prize": [0.02]
    },
    "idle_reward3": {
      "prize": [0.05]
    },
    "old_users_award": {
      "prize": [
        {
          "first_number": 0,
          "prize": [20, 30],
          "end_number": 200
        },
        {
          "first_number": 200,
          "prize": [20, 25],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [10, 20],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [10, 15],
          "end_number": 450
        },
        {
          "first_number": 450,
          "prize": [8, 10],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [1, 5],
          "end_number": 999999
        }
      ]
    },
    "cash_bubble_t": {
      "prize": [30]
    },
    "cash_bubble": {
      "prize": [
        {
          "first_number": 0,
          "prize": [10, 20],
          "end_number": 200
        },
        {
          "first_number": 200,
          "prize": [10, 15],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [5, 10],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [5, 8],
          "end_number": 450
        },
        {
          "first_number": 450,
          "prize": [3, 5],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [1, 3],
          "end_number": 999999
        }
      ]
    },
    "give_up": {
      "prize": [
        {
          "first_number": 0,
          "prize": [20, 30],
          "end_number": 200
        },
        {
          "first_number": 200,
          "prize": [20, 25],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [10, 20],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [10, 15],
          "end_number": 450
        },
        {
          "first_number": 450,
          "prize": [8, 10],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [1, 5],
          "end_number": 999999
        }
      ]
    },
    "pearl_wheel": {
      "prize": [
        {
          "first_number": 0,
          "prize": [21, 27, 28, 30],
          "end_number": 200
        },
        {
          "first_number": 200,
          "prize": [20, 22, 25, 27],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [16, 17, 18, 20],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [11, 13, 15, 16],
          "end_number": 450
        },
        {
          "first_number": 450,
          "prize": [6, 7, 8, 10],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [1, 2, 3, 5],
          "end_number": 999999
        }
      ]
    },
    "drift_bottle": {
      "prize": [
        {
          "first_number": 0,
          "prize": [27, 30],
          "end_number": 200
        },
        {
          "first_number": 200,
          "prize": [20, 27],
          "end_number": 300
        },
        {
          "first_number": 300,
          "prize": [17, 20],
          "end_number": 400
        },
        {
          "first_number": 400,
          "prize": [11, 15],
          "end_number": 450
        },
        {
          "first_number": 450,
          "prize": [6, 10],
          "end_number": 500
        },
        {
          "first_number": 500,
          "prize": [2, 5],
          "end_number": 999999
        }
      ]
    }
  };


}