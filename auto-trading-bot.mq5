//+------------------------------------------------------------------+
//|                                             auto-trading-bot.mq5 |
//|                           Copyright 2018-2019, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018-2019, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"
#property version   "1.00"
//--- input parameters
input double      default_stop_loss;
input double      default_pips;

#include<Trade\Trade.mqh>
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(60);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
   
  }
  
  /*
  Recognizing candle patterns
  */
  
   enum TYPE_CANDLESTICK
  {
   CAND_NONE,  //Unrecognized
   CAND_MARIBOZU, //Marubozu
   CAND_MARIBOZU_LONG,  //Marubozu long
   CAND_DOJI,  //Doji
   CAND_SPIN_TOP,   //Spinning Top
   CAND_HAMMER,   //Hammer
   CAND_INVERT_HAMMER,  //Reverse hammer
   CAND_LONG,  //Long
   CAND_SHORT, //Short
   CAND_STAR   //Star
  };
  
  enum TYPE_TREND
  {
   UPPER, //Upward
   DOWN, //Downward
   LATERAL  //lateral
  };
  
  struct CANDLE_STRUCTURE
  {
   double         open, high, low, close; //OHLC
   datetime       time; //Time
   TYPE_TREND     trend; //Trend
   bool           bull; //Bull candlestick
   double         bodysize; //Body size
   TYPE_CANDLESTICK  type; //Type of candlestick
  };
  
  
  bool RecognizeCandle(string symbol, ENUM_TIMEFRAMES period, datetime time, int aver_period, CANDLE_STRUCTURE &res)
  {
  
   MqlRates rt[];
   //---Get type of pervious candlesticks
   if(CopyRates(symbol, period,time,aver_period+1,rt) < aver_period)
   {
      return(false);
   }
   
   res.open=rt[aver_period].open;
   res.high=rt[aver_period].high;
   res.low=rt[aver_period].low;
   res.close=rt[aver_period].close;
   res.time=rt[aver_period].time;
   
   //--- Define the trend direction MA=(C1+C2+…+Cn)/N, where C – close prices, N – number of bars.
   double aver=0;
   
   for(int i=0; i<aver_period;i++)
   {
      aver+=rt[i].close;
   }
   
   aver=aver/aver_period;
   
   if(aver<res.close) res.trend=UPPER;
   if(aver>res.close) res.trend=DOWN;
   if(aver==res.close) res.trend-=LATERAL;
   
   //--- Define if it is bullish or bearish
   res.bull=res.open<res.close;
   
   //--- Get the absolute value of the candlestick body size
   res.bodysize=MathAbs(res.open-res.close);
   
   //--- Get the size of shadows
   double shade_low=res.close-res.low;
   double shade_high=res.high-res.open;
   
   if(res.bull)
   {
      shade_low=res.open-res.low;
      shade_high=res.high-res.close;
   }
   double HL=res.high-res.low;
   
   //--- Calculate the average body size of previous candlesticks
   double sum=0;
   for(int i=1;i<=aver_period;i++)
   {
      sum=sum+MathAbs(rt[i].open-rt[i].close);
   }
   
   sum=sum/aver_period;
   
   //--- long candlestick : (Body) > (average body of the last five days) *1.3
   if(res.bodysize > sum*1.3) res.type = CAND_LONG;
   
   //-- short candlestick :  (Body) > (average body of the last X days) *0.5  
   if(res.bodysize<sum*0.5) res.type=CAND_SHORT;
   
   // doji : (Dodji body) < (range from the highest to the lowest prices) * 0.03
   if(res.bodysize<HL*0.03) res.type=CAND_DOJI;
   
   //--- maribozu : (lower shadow) < (body) * 0.03 or (upper shadow) < (body) * 0.03
   if((shade_low<res.bodysize*0.01 || shade_high<res.bodysize*0.01) && res.bodysize>0)
     {
      if(res.type==CAND_LONG)
         res.type=CAND_MARIBOZU_LONG;
      else
         res.type=CAND_MARIBOZU;
     }
  
   //--- hammer : (lower shadow)<(body)*0.1 and (upper shadow)> (body)*2
   if(shade_low>res.bodysize*2 && shade_high<res.bodysize*0.1) res.type=CAND_HAMMER;
  
   //--- invert hammer : (lower shadow) > ((lower shadow)<(body)*0.1 and (upper shadow)> (body)*2
   if(shade_low<res.bodysize*0.1 && shade_high>res.bodysize*2) res.type=CAND_INVERT_HAMMER;
   
   //--- spinning top : (lower shadow) > (body) and (upper shadow) > (body)
   if(res.type==CAND_SHORT && shade_low>res.bodysize && shade_high>res.bodysize) res.type=CAND_SPIN_TOP;
   
   ArrayFree(rt);
   return(true);
  
  }
  
  
  
  /*
  
  void OpenBuyOrder()
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_BUY;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = 50;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
   void OpenSellOrder(double Ask)
  {
    MqlTradeRequest myRequest;
    MqlTradeResult myResult;
    
    
    
    myRequest.action = TRADE_ACTION_DEAL;
    myRequest.type = ORDER_TYPE_SELL;
    myRequest.symbol = _Symbol;
    myRequest.volume = default_pips;
    myRequest.type_filling = ORDER_FILLING_FOK;
    myRequest.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    myRequest.tp = (_Point * 30) + Ask ;
    myRequest.sl = 0;
    myRequest.deviation = 50;
    OrderSend(myRequest,myResult);   
    
  }
  */
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   double ask = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK),_Digits);
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   //Create arrays for several prices
   
   double myMovingAverageArray1[], myMovingAverageArray2[];
   
   //define the properties of the Moving Average 1
   int movingAverageDefination1 = iMA(_Symbol, _Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //define the properties of the Moving Average 2
   int movingAverageDefination2 = iMA(_Symbol, _Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //Sorting the price array 1 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray1, true);
   
   //Sorting the price array 2 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray2, true);
   
   //Defined MA1, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination1,0,0,3,myMovingAverageArray1);
   
   //Defined MA2, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination2,0,0,3,myMovingAverageArray2);
   
   //Check if the 20 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] > myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] < myMovingAverageArray2[1]) )
   {
      
      trade.Buy(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating Buy");
      
      Print("BUY!!!!!");
      
      
   }
   
   //Check if the 50 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] < myMovingAverageArray2[0]) 
   && ( myMovingAverageArray1[1] > myMovingAverageArray2[1]) )
   {
      trade.Sell(0.01,_Symbol,ask,(ask - 100 * _Point),(ask + 1000 * _Point),"Initiating SELL");
      
       Print("SELL!!!!!");
   }
   
   
   
   
  } //End of onTick()
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
//---
   
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
//---
   
  }
//+------------------------------------------------------------------+
