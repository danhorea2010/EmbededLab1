
/*
    (a) problem statement in natural language (pick actors)
    (b) Write 3 LTL formulas and check them with the JSpin model checker
   
   Whiskey dispenser
      - actors 
            - Person
            - Sensor pahar
            - Sensor bani (monede)
            - Cola dispenser
            - Whiskey dispenser

      - signals
            - Payed
            - Insert Coins 
            - PourCola
            - ColaDone
            - PourWhiskey
            - GlassFull (done)

            

*/

mtype = {payed, insertCoins, pourCola, colaDone, pourWhiskey, glassFull,done}

chan signal = [0] of {mtype}

byte amount_payed = 0;
byte amount_to_be_payed = 2;

bool glass_present = false;

active proctype Person() {
    // insert coin until payed
    
waiting: 
        // init state
        // waiting for drink  (sau before paying)


        // come back after glassFull

	printf("test");

    

    payStuff: 
        signal!insertCoins;
    


}


active proctype GlassSensor() {
    // only begin pouring after glass is inserted
    waiting: {
        signal?payed -> {
            glass_present = true;
            signal!pourCola;
        }
    }
}

active proctype MoneySensor() {
    // checks if amount_payed == amount_to_be_payed
    // ==> signals PourCola if glass is present

    waiting:  {
        signal?insertCoins -> atomic {
            // increment amount_payed;
            amount_payed++;
            if 
            :: amount_payed >= amount_to_be_payed -> {
                signal!payed;
            }
            fi;
        }
        
    }

}

active proctype ColaDispenser() {
    // react to payed and PourCola until ColaDone
    waiting: {
        signal?pourCola -> atomic {
            signal!colaDone;
        }
    }
}

active proctype WhiskeyDispenser() {
    // react to payed and pourWhiskey until GlassFull
    waiting: {
        signal?colaDone -> atomic {
            signal!pourWhiskey
        }

        signal?pourWhiskey -> atomic {
            signal!glassFull
        }
    }
}

active proctype Controller() {
    waiting: {
        signal?glassFull -> atomic {
            amount_payed = 0;
            signal!done;
        }
    }
}


