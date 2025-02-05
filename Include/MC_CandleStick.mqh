//+------------------------------------------------------------------+
//|                                               MC_CandleStick.mqh |
//|                                Copyright 2018, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"

#include<candlesticktype.mqh>
#include<Trade\Trade.mqh>

bool candleStickIndicate(datetime time_current_candle, datetime time_previous_candle, int period)
                {
                
                  //Print("Inside candleStickIndicate!");
                  
                  bool _forex=false;
                  
                  int indicator_points=0;
                    
                   if(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_CALC_MODE)==(int)SYMBOL_CALC_MODE_FOREX) _forex=true;
                        
                    CANDLE_STRUCTURE cand1;
                    
                    RecognizeCandle(_Symbol,_Period,time_current_candle,period,cand1);
                    
                    // Inverted Hammer, the bullish model
                   if(cand1.trend==DOWN && // check direction of trend
                        cand1.type==CAND_INVERT_HAMMER) // the "Inverted Hammer" check
                       {
                        Print("Inverted Hammer (Bull) Inverted Hammer");
                        //DrawSignal(prefix+"Invert Hammer the bull model"+string(objcount++),cand1,InpColorBull,comment);
                   }
                   // Hanging Man, the bearish model
                  if(cand1.trend==UPPER && // check direction of trend
                     cand1.type==CAND_HAMMER) // the "Hammer" check
                    {
                     Print("Hanging Man (Bear) Hanging Man");
                     //DrawSignal(prefix+"Hanging Man the bear model"+string(objcount++),cand1,InpColorBear,comment);
                    }
                  //------      
                  // Hammer, the bullish model
                  if(cand1.trend==DOWN && // check direction of trend
                     cand1.type==CAND_HAMMER) // the "Hammer" check
                    {
                     Print("Hammer (Bull) Hammer");
                     //DrawSignal(prefix+"Hammer, the bull model"+string(objcount++),cand1,InpColorBull,comment);
                    }
                    
                  /* Check of patters with two candlesticks */
                  
                  CANDLE_STRUCTURE cand2;
                  cand2=cand1;  
                  RecognizeCandle(_Symbol,_Period,time_previous_candle,period,cand2);
                  
                  // Shooting Star, the bearish model
                  
                  if(cand1.trend==UPPER && cand2.trend==UPPER && // check direction of trend
                     cand2.type==CAND_INVERT_HAMMER) // the "Inverted Hammer" check
                    {
                     //Print("Shooting Star (Bear) Shooting Star");
                     if(_forex)// if it's forex
                       {
                        if(cand1.close<=cand2.open) // close 1 is less than or equal to open 1
                          {
                           Print("Shooting Star the bear model");
                           indicator_points=indicator_points-2;
                           
                          }
                       }
                     else
                       {
                        if(cand1.close<cand2.open && cand1.close<cand2.close) // 2 candlestick is cut off from 1
                          {
                           //trade.Sell( candle_stick_bid ,_Symbol,ask,(ask - candle_stick_sl * _Point),(ask + candle_stick_tp * _Point),"Initiating Sell");
                           Print("Shooting Star the bear model");
                           indicator_points=indicator_points-2;
                           
                          }
                       }
                    }
      // ------      
                    // Belt Hold, the bullish
               if(cand2.trend==DOWN && cand2.bull && !cand1.bull && // check direction of trend and direction of candlestick
                  cand2.type==CAND_MARIBOZU_LONG && // the "long Maribozu" check
                  cand1.bodysize<cand2.bodysize && cand2.close<cand1.close) // body of the first candlestick is smaller than body of the second one, close price of the second candlestick is lower than the close price of the first one
                 {
                  
                  if(!_forex)// if it's not forex
                    {
                     Print("Belt Hold (Bull)Belt Hold");
                     indicator_points=indicator_points+2;
                     //DrawSignal(prefix+"Belt Hold the bull model"+string(objcount++),cand1,cand2,InpColorBull,comment);
                    }
                 }
               // Belt Hold, the bearish model
               if(cand2.trend==UPPER && !cand2.bull && cand1.bull && // check direction of trend and direction of candlestick
                  cand2.type==CAND_MARIBOZU_LONG && // the "long Maribozu" check
                  cand1.bodysize<cand2.bodysize && cand2.close>cand1.close) // body of the first candlestick is lower than body of the second one; close price of the second candlestick is higher than that of the first one
                 {
                  
                  if(!_forex)// if it's not forex
                    {
                     Print("Belt Hold (Bear)Belt Hold");
                     indicator_points=indicator_points-2;
                     //DrawSignal(prefix+"Belt Hold the bear model"+string(objcount++),cand1,cand2,InpColorBear,comment);
                    }
                 }
      //------
                 // Engulfing, the bullish model
         if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && cand2.bull && // check direction of trend and direction of candlestick
            cand1.bodysize<cand2.bodysize) // body of the third candlestick is bigger than that of the second one
           {
            //comment=_language?"Engulfing (Bull)":"Engulfing";
            if(_forex)// if it's forex
              {
               if(cand1.close>=cand2.open && cand1.open<cand2.close) // body of the first candlestick is inside of body of the second one
                 {
                  Print("Engulfing (Bull): Engulfing");
                  indicator_points=indicator_points+2;
                  
                 }
              }
            else
              {
               if(cand1.close>cand2.open && cand1.open<cand2.close) // body of the first candlestick inside of body of the second candlestick
                 {
                  indicator_points=indicator_points+2;
                  Print("Engulfing (Bull) Engulfing");
                 }
              }
           }    
           
                  // Harami Cross, the bullish model
      if(cand1.trend==DOWN && !cand1.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && cand2.type==CAND_DOJI) // check of "long" first candlestick and Doji candlestick
        {
        
         if(_forex)// if it's forex
           {
            if(cand1.close<=cand2.open && cand1.close<=cand2.close && cand1.open>cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami Cross the bull model");
               indicator_points=indicator_points+2;
              }
           }
         else
           {
            if(cand1.close<cand2.open && cand1.close<cand2.close && cand1.open>cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami Cross the bull model");
               indicator_points=indicator_points+2;
              }
           }
        }
      // Harami Cross, the bearish model
      if(cand1.trend==UPPER && cand1.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && cand2.type==CAND_DOJI) // check of "long" candlestick and Doji
        {
         
         if(_forex)// if it's forex
           {
            if(cand1.close>=cand2.open && cand1.close>=cand2.close && cand1.close>=cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami Cross the bear model");
               indicator_points=indicator_points-2;
              }
           }
         else
           {
            if(cand1.close>cand2.open && cand1.close>cand2.close && cand1.open<cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami Cross the bear model");
               indicator_points=indicator_points-2;
              }
           }
        }
        //------      
      // Harami, the bullish model
      if(cand1.trend==DOWN  &&  !cand1.bull  &&  cand2.bull &&// check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) &&  // check of "long" first candlestick
         cand2.type!=CAND_DOJI && cand1.bodysize>cand2.bodysize) // the second candlestick is not Doji and body of the first candlestick is bigger than that of the second one
        {
        
         if(_forex)// if it's forex
           {
            if(cand1.close<=cand2.open && cand1.close<=cand2.close && cand1.open>cand2.close) // body of the second candlestick is inside of body of the first candlestick
              {
               Print("Harami the bull model");
               indicator_points=indicator_points+2;
              }
           }
         else
           {
            if(cand1.close<cand2.open && cand1.close<cand2.close && cand1.open>cand2.close) // body of the second candlestick is inside of body of the first one
              {
               Print("Harami the bull model");
               indicator_points=indicator_points+2;
              }
           }
        }
      // Harami, the bearish model
      if(cand1.trend==UPPER && cand1.bull && !cand2.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG|| cand1.type==CAND_MARIBOZU_LONG) && // check of "long" first candlestick
         cand2.type!=CAND_DOJI && cand1.bodysize>cand2.bodysize) // the second candlestick is not Doji and body of the first candlestick is bigger than that of the second one
        {
         
         if(_forex)// if it's forex
           {
            if(cand1.close>=cand2.open && cand1.close>=cand2.close && cand1.close>=cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami the bear model");
               indicator_points=indicator_points-2;
              }
           }
         else
           {
            if(cand1.close>cand2.open && cand1.close>cand2.close && cand1.open<cand2.close) // Doji is inside of body of the first candlestick
              {
               Print("Harami the bear model");
               indicator_points=indicator_points-2;
              }
           }
        }
      //------ 
      // Doji Star, the bullish model
      if(cand1.trend==DOWN && !cand1.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && cand2.type==CAND_DOJI) // check first "long" candlestick and 2 doji
        {
     
         if(_forex)// if it's forex
           {
            if(cand1.close>=cand2.open) // Open price of Doji is lower or equal to close price of the first candlestick
              {
               Print("Doji Star the bull model");
               indicator_points=indicator_points+2;

              }
           }
         else
           {
            if(cand1.close>cand2.open && cand1.close>cand2.close) // Body of Doji is cut off the body of the first candlestick
              {
               Print("Doji Star the bull model");
               indicator_points=indicator_points+2;

              }
           }
        }
      // Doji Star, the bearish model
      if(cand1.trend==UPPER && cand1.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && cand2.type==CAND_DOJI) // check first "long" candlestick and 2 doji
        {
         
         if(_forex)// if it's forex
           {
            if(cand1.close<=cand2.open) // // open price of Doji is higher or equal to close price of the first candlestick
              {
               Print("Doji Star the bear model");
               indicator_points=indicator_points-2;

              }
           }
         else
           {
            if(cand1.close<cand2.open && cand1.close<cand2.close) // // body of Doji is cut off the body of the first candlestick
              {
               Print("Doji Star the bear model");
               indicator_points=indicator_points-2;

              }
           }
        }  
        //------      
      // Piercing Line, the bull model
      if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && cand2.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU_LONG) && // check of "long" candlestick
         cand2.close>(cand1.close+cand1.open)/2)// close price of the second candle is higher than the middle of the first one
        {
         
         if(_forex)// if it's forex
           {
            if(cand1.close>=cand2.open && cand2.close<=cand1.open)
              {
               Print("Piercing Line");
               indicator_points=indicator_points+2;
               
              }
           }
         else
           {
            if(cand2.open<cand1.low && cand2.close<=cand1.open) // open price of the second candle is lower than LOW price of the first one 
              {
               Print("Piercing Line");
               indicator_points=indicator_points+2;
              }
           }
        }
      // Dark Cloud Cover, the bearish model
      if(cand1.trend==UPPER && cand1.bull && cand2.trend==UPPER && !cand2.bull && // check direction and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU_LONG) && // check of "long" candlestick
         cand2.close<(cand1.close+cand1.open)/2)// close price of 2-nd candlestick is lower than the middle of the body of the 1-st one
        {
         
         if(_forex)// if it's forex
           {
            if(cand1.close<=cand2.open && cand2.close>=cand1.open)
              {
               Print("Dark Cloud Cover");
               indicator_points=indicator_points-2;
              }
           }
         else
           {
            if(cand1.high<cand2.open && cand2.close>=cand1.open)
              {
               Print("Dark Cloud Cover");
               indicator_points=indicator_points-2;

              }
           }
        }
        //------      
      // Meeting Lines the bull model / Âñòðå÷àþùèåñÿ ñâå÷è áû÷üÿ ìîäåëü
      if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && cand2.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && (cand2.type==CAND_LONG || cand2.type==CAND_MARIBOZU_LONG) && // check of "long" candlestick
         cand1.close==cand2.close && cand1.bodysize<cand2.bodysize && cand1.low>cand2.open) // close prices are equal, size of the first candlestick is smaller than that of the second one; open price of the second one is lower than minimum of the first one
        {
         
         if(!_forex)// if it's not forex
           {
            Print("Meeting Lines the bull model");
            indicator_points=indicator_points+2;
           }
        }
      // Meeting Lines, the bearish model
      if(cand1.trend==UPPER && cand1.bull && cand2.trend==UPPER && !cand2.bull && // check direction and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && // check of "long" candlestick
         cand1.close==cand2.close && cand1.bodysize<cand2.bodysize && cand1.high<cand2.open) // // close prices are equal, size of the first one is smaller than that of the second one, open price of the second one is higher than the maximum of the first one
        {

         if(!_forex)// if it's not forex
           {
            Print("Meeting Lines the bear model");
            indicator_points=indicator_points-2;
           }
        }
        //------      
      // Matching Low, the bullish model
      if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && !cand2.bull && // check direction of trend and direction of candlestick
         cand1.close==cand2.close && cand1.bodysize>cand2.bodysize) // close price are equal, size of the first one is greater than that of the second one
        {
         
         if(!_forex)// if it's not forex
           {
            Print("Matching Low the bull model");
            indicator_points=indicator_points+2;
           }
        }
      //------      
      // Homing Pigeon, the bullish model
      if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && !cand2.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && // check of "long" candlestick
         cand1.close<cand2.close  &&  cand1.open>cand2.open) // body of the second candlestick is inside of body of the first one
        {
         
         if(!_forex)// if it's not forex
           {
            Print("Homing Pigeon the bull model");
            indicator_points=indicator_points+2;
           }
        }
        
        /* Continuation Models */
 
      //------      
      // Kicking, the bull model
      if(!cand1.bull && cand2.bull && // check direction of trend and direction of candlestick
         cand1.type==CAND_MARIBOZU_LONG && cand2.type==CAND_MARIBOZU_LONG && // two maribozu
         cand1.open<cand2.open) // gap between them
        {
         
         if(!_forex)// if it's not forex
           {
            Print("Kicking the bull model");
            indicator_points=indicator_points+2;
           }
        }
      // Kicking, the bearish model
      if(cand1.bull && !cand2.bull && // check direction of trend and direction of candlestick
         cand1.type==CAND_MARIBOZU_LONG && cand2.type==CAND_MARIBOZU_LONG && // two maribozu
         cand1.open>cand2.open) // gap between them
        {
         
         if(!_forex)// if it's not forex
           {
            Print("Kicking the bear model");
            indicator_points=indicator_points-2;
           }
        }
      //------ Check of module of the neck line
      if(cand1.trend==DOWN && !cand1.bull && cand2.bull && // check direction of trend and direction of candlestick
         (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG)) // first candlesticks is "long"
        {
         // On Neck Line, the bearish model
         if(cand2.open<cand1.low && cand2.close==cand1.low) // second candlestick is opened below the first one and is closed at the minimum level of the first one
           {
            
            if(!_forex)// if it's not forex
              {
               Print("On Neck Line the bear model");
               indicator_points=indicator_points-2;
              }
           }
         else
           {
            // In Neck Line, the bear model
            if(cand1.trend==DOWN && !cand1.bull && cand2.bull && // check direction of trend and direction of candlestick
               (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && // first candlestick is "long"
               cand1.bodysize>cand2.bodysize && // body of the second candlestick is smaller than body of the first one
               cand2.open<cand1.low && cand2.close>=cand1.close && cand2.close<(cand1.close+cand1.bodysize*0.01)) // second candlestick is opened below the first one and is closed slightly higher the closing of the first one
              {
              
               if(!_forex)// if it's not forex
                 {
                  Print("In Neck Line the bear model");
                  indicator_points=indicator_points-2;
                 }
              }
            else
              {
               // Thrusting Line, the bearish model
               if(cand1.trend==DOWN && !cand1.bull && cand2.bull && // check direction of trend and direction of candlestick
                  (cand1.type==CAND_LONG || cand1.type==CAND_MARIBOZU_LONG) && // first candlestick is "long"
                  cand2.open<cand1.low && cand2.close>cand1.close && cand2.close<(cand1.open+cand1.close)/2) // the second candlestick is opened below the first one and is closed above the closing of the first one, bu below its middle
                 {
                  
                  if(!_forex)// if it's not forex
                    {
                     Print("Thrusting Line the bear model");
                     indicator_points=indicator_points-2;
                    }
                 }
              }
           }
        }
    
                  
                  return(indicator_points);
                }

