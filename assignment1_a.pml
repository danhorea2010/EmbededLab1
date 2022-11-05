// Actors: - Person
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
bool initialised = false;

byte seconds_count = 0;
byte hand_dirtiness_counter = 10;
byte water_time_seconds = 2;

mtype:faucet_state_types = {open, closed};
mtype:pushing_state_types = {pushingButton, notPushingButton};

chan binary_channel = [0] of {mtype:faucet_state_types};
chan push_state         = [0] of {mtype:pushing_state_types};

active proctype Person() {


    init123: atomic {
        if 
        :: !initialised ->  atomic {
          push_state!pushingButton;

push_state!pushingButton;
push_state!pushingButton;
push_state!pushingButton;
push_state!pushingButton;
            initialised = true;
        }
        fi
    }


	// press button
             // wait for water to turn off
             // while hands are dirty push button
    washingHands:  {
        // If hands are dirty
        //   * if faucet is off -> push button
        //   * if faucet is on  -> hash hands (set hands_dirty to false)
        if 
        :: hands_dirty ->  {

            binary_channel?closed ->  {
                push_state!pushingButton;

               

            };
        }
        fi;

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

	openingFaucet:  atomic {
					printf("test23\n");
				push_state?pushingButton -> {

					binary_channel!open;
					printf("test\n");
					push_state!notPushingButton;

					seconds_count = water_time_seconds;
					goto watering;
			   };


	watering:  {
	            	if 
		            :: seconds_count > 0 -> atomic {
                        seconds_count = seconds_count - 1;
                        hand_dirtiness_counter = hand_dirtiness_counter - 1;
printf("%d\n",hand_dirtiness_counter);
                        goto watering;
                    }
                    fi;
                    if 
                    :: seconds_count <= 0 -> atomic {
		printf("Closed channel" );
                        binary_channel!closed;
                    } 
                    fi;
	}

}
}

