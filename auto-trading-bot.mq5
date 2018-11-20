//+------------------------------------------------------------------+
//|                                             auto-trading-bot.mq5 |
//|                           Copyright 2018-2019, Umair Khan Jadoon |
//|                                        https://www.merrycode.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018-2019, Umair Khan Jadoon"
#property link      "https://www.merrycode.com"
#property version   "1.00"
//--- input parameters
input int      default_stop_loss;
input int      default_pips;
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
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //Create arrays for several prices
   
   double myMovingAverageArray1[], myMovingAverageArray2[];
   
   //define the properties of the Moving Average 1
   int movingAverageDefination1 = iMA(_Symbol, Period, 20, 0, MODE_EMA, PRICE_CLOSE);
   
   //define the properties of the Moving Average 2
   int movingAverageDefination2 = iMA(_Symbol, Period, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   //Sorting the price array 1 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray1, true);
   
   //Sorting the price array 2 for the current candle downwards
   ArraySetAsSeries(myMovingAverageArray2, true);
   
   //Defined MA1, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination1,0,0,3,myMovingAverageArray1);
   
   //Defined MA2, one line, current candle, 3 candles, store result
   CopyBuffer(movingAverageDefination2,0,0,3,myMovingAverageArray2);
   
   //Check if the 20 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] > myMovingAverageArray2[0]) && ( myMovingAverageArray1[1] < myMovingAverageArray1[1]) )
   {
      Comment("BUY");
   }
   
   //Check if the 50 candle EA is above the 50 candle EA
   if( (myMovingAverageArray1[0] < myMovingAverageArray2[0]) && ( myMovingAverageArray1[1] < myMovingAverageArray1[1]) )
   {
      Comment("SELL");
   }
   
   
   
   
   
   
   
   
   
   
   
  }
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
