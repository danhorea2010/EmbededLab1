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

// Foloseam byte, deci <= 0 == 255...
short seconds_count = 0;
short hand_dirtiness_counter = 10;
short water_time_seconds = 11;

mtype:faucet_state_types = {open, closed, cleaned};
mtype:pushing_state_types = {pushingButton, notPushingButton};

chan binary_channel = [2] of {mtype:faucet_state_types};
chan push_state         = [2] of {mtype:pushing_state_types};

active proctype Person() {

  /* init { */
  /*   if */
  /*     :: !initialised ->  atomic { */
  /*       push_state!pushingButton; */

  /*       initialised = true; */
  /*     } */
  /*   fi */
  /* } */

  // press button
  // wait for water to turn off
  // while hands are dirty push button
washingHands:{
    // If hands are dirty
    //   * if faucet is off -> push button
    //   * if faucet is on  -> hash hands (set hands_dirty to false)
   printf("initing\n");



   binary_channel?cleaned-> {
     printf("Got here")
     if
       :: hand_dirtiness_counter == 0 -> {
         hands_dirty = false;
       }
       :: hands_dirty -> {
         goto washingHands;
       }
     fi

   }

  if
    :: hands_dirty -> {
      goto washingHands;
    }
       fi

   //if
   //   :: hands_dirty ->  {

        // Aici ajunge
        //binary_channel?closed ->  {
        //  // Si aici
        //  push_state!pushingButton;
        //};
   //   }
   // fi;

    if
      :: hand_dirtiness_counter <= 0 -> atomic {
        hands_dirty = false;

      };
    fi;

    goto washingHands;
  }

}

active proctype Faucet() {
  // wait for button signal -> change state to on
  // after timer ran out -> change state to off

    //binary_channel!closed;
    seconds_count = water_time_seconds;

    //push_state?pushingButton -> {
    //  printf("ce ii aci?")
    //  binary_channel!open;
    //  printf("test\n");
    //  push_state!notPushingButton;

    //  goto watering;

watering: {
  printf("watering")
      if
        :: seconds_count > 0 -> atomic {
          seconds_count = seconds_count - 1;
          hand_dirtiness_counter = hand_dirtiness_counter - 1;
          binary_channel!cleaned;
          printf("CLEANED\n");
          goto watering;
        }
        :: {
          printf("TEST")
          if
            :: hands_dirty -> {
              seconds_count = water_time_seconds;
              goto watering;
            }
               fi
        }
      fi;
}

}
