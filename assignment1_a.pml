//Actors:      - Person
//              - Faucet
// state   - initial state (off)
//            - on
//  signal - open
//              - close
//              - pushed
// one channel for open/close
// one for pushed

// hands are dirty by default
// LTS formulas
// 1. If button is pressed -> faucet will be turned on
// 2. if hands are dirty -> button will be pressed
// 3. if hands are not dirty -> faucet is off
bool hands_dirty = true;
bool faucet_active = true;

// Foloseam byte, deci <= 0 == 255...
short seconds_count = 0;
short hand_dirtiness_counter = 10;
short water_time_seconds = 11;

mtype:faucet_state_types = {open, cleaned};

chan binary_channel = [1] of {mtype:faucet_state_types};

active proctype Person() {
washingHands: atomic {
  printf("initing\n");

  if
    :: hands_dirty == 1 && faucet_active == true -> {
      if
        :: binary_channel?cleaned-> {
          if
            :: hand_dirtiness_counter <= 0 && hands_dirty == 1 -> {
              hands_dirty = false;
            }
            :: hands_dirty -> {
              goto hands_cleaned;
            }
          fi
          goto end;
        }
      fi
    }
  fi

  hands_cleaned : atomic {
    if
      :: hands_dirty == 1 && faucet_active -> {
        goto washingHands;
      }
         fi
  }

end:

}

}

active proctype Faucet() {
  atomic { seconds_count = water_time_seconds;};

watering:{

  if
    :: seconds_count > 0 && hands_dirty == 1 -> atomic {
      seconds_count = seconds_count - 1;
      hand_dirtiness_counter = hand_dirtiness_counter - 1;
      binary_channel!cleaned;
      goto watering;
    }
    :: else -> atomic {
      faucet_active = false;

    }
  fi;
}



}
