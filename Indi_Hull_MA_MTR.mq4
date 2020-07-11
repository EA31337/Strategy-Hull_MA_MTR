//+++======================================================================+++
//+++                      Hull Master 22 Next MTF                         +++
//+++======================================================================+++
#property copyright   "www.forex-tsd.com && Tankk, 8 October 2018, http://forexsystemsru.com"
#property link        "https://forexsystemsru.com/threads/indikatory-sobranie-sochinenij-tankk.86203/page-7#post-1350217"

#property description "HullMA's almost eliminates the delay as a whole with improved smoothing."
#property description "It efficiently knows how to keep up with fast price changes."
#property description "The dynamics with excellent SMA smoothing for the same period."
#property version  "3.39" // Previous: "2.22"

#property indicator_chart_window
#property indicator_buffers 2
//------
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrRed  // Crimson
//------
#property indicator_width1  2
#property indicator_width2  2
//------
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
enum TFauto { OFF, /*switch OFF*/ TF1, /*+ 1 TimeFrame*/ TF2, /*+ 2 TimeFrame*/  TF3 /*+ 3 TimeFrame*/  };
enum Iterpolation { intNO, /*No interpolation*/ intLinear, /*Linear Interpolation*/ intQuad /*Quadratic Interpolation*/ };
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//

extern ENUM_TIMEFRAMES   TimeFrame  =  PERIOD_CURRENT;
extern TFauto        TimeFrameAuto  =  TF1;  //OFF;  //
extern Iterpolation    Interpolate  =  intQuad;  //true;

extern int               HMAPeriod  =  21;
extern ENUM_APPLIED_PRICE HMAPrice  =  PRICE_CLOSE;
extern double             HMASpeed  =  2.0;
extern double               HMAHot  =  1.0;
extern int                HMAShift  =  0;         // Hull shift

extern string             UniqueID  =  "";  //"Hull SupRes";
extern int             LinesNumber  =  12;
extern int              LinesShift  =  -1;
extern bool               RayRight  =  false;
extern int               LinesSize  =  2;
extern color               ColorUP  =  clrAqua;  //Blue;
extern color              ColorDN   =  clrMagenta;  //Black;

extern int               SIGNALBAR  =  1; // On which bar to signal...
extern bool          AlertsMessage  =  true,   //false,
                       AlertsSound  =  true,   //false,
                       AlertsEmail  =  false,
                      AlertsMobile  =  false;
extern string            SoundFile  =  "alert.wav";   //"news.wav";  //"expert.wav";  //   //"stops.wav"   //"alert2.wav"   //
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
double hma[], hmada[], hmadb[], work[], trend[];
int HalfPeriod, HullPeriod, MTF, LSH, SGB, MAX;
string IndikName, PREF;  bool returnBars;  datetime TimeBar=0;
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
int init()
{
   HMAPeriod  = fmax(HMAPeriod,2);
   HalfPeriod = floor(HMAPeriod/HMASpeed);
   HullPeriod = floor(sqrt(HMAPeriod*HMAHot));   MAX = HMAPeriod+HalfPeriod+HullPeriod;

      TimeFrame = fmax(TimeFrame,_Period);       LSH = -LinesShift;    SGB = SIGNALBAR;

         if (TimeFrame>_Period) MTF = TimeFrame;
         else
          {
           if (TimeFrameAuto==0) MTF=_Period;
           if (TimeFrameAuto==1) MTF=NextHigherTF(_Period);
           if (TimeFrameAuto==2) MTF=NextHigherTF(NextHigherTF(_Period));
           if (TimeFrameAuto==3) MTF=NextHigherTF(NextHigherTF(NextHigherTF(_Period)));
          }

   IndikName  = WindowExpertName();
   returnBars = MTF==-99;

   IndicatorBuffers(5);
      SetIndexBuffer(0,hma);     SetIndexLabel(0,stringMTF(MTF)+": HMA ["+(string)HMAPeriod+"*"+DoubleToStr(HMASpeed,1)+"*"+DoubleToStr(HMAHot,1)+"]");
      SetIndexBuffer(1,hmada);   SetIndexLabel(1,NULL);
      SetIndexBuffer(2,hmadb);   SetIndexLabel(2,NULL);
      SetIndexBuffer(3,trend);
      SetIndexBuffer(4,work);
//---
   for (int i=0; i<indicator_buffers; i++) //{
        SetIndexStyle(i,DRAW_LINE);
        //SetIndexShift(i,HMAShift*MTF/_Period); }

//------ "short name" for DataWindow and indicator + subwindow and/or "unique indicator name".
   IndicatorShortName(stringMTF(MTF)+": HMA M22 ["+(string)HMAPeriod+"*"+DoubleToStr(HMASpeed,1)+"*"+DoubleToStr(HMAHot,1)+"]");
   //------
   if (UniqueID!="") PREF = UniqueID;
   else PREF = stringMTF(MTF)+": HMA M22 ["+(string)HMAPeriod+"*"+DoubleToStr(HMASpeed,1)+"*"+DoubleToStr(HMAHot,1)+"]  ";
//**************************************************************************//
//------
return(0);
}
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
///void OnDeinit(const int reason)  { ObjectsDeleteAll(0,PREF,-1,-1); }
int deinit() { deleteLines();  Comment("");  return (0); }
//**************************************************************************//
void deleteLines()
{
   string name;
   for (int s=ObjectsTotal()-1; s>=0; s--) {
        name=ObjectName(s);
        if (StringSubstr(name,0,StringLen(PREF))==PREF) ObjectDelete(name); }
}
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
int start()
{
   int i, CountedBars = IndicatorCounted();
      if (CountedBars<0) return(-1);
      if (CountedBars>0) CountedBars--;
         int limit=fmin(Bars-CountedBars,Bars-1);
         if (returnBars) { hma[0] = fmin(limit+1,Bars-1); return(0); }
   //---
   for (i=0; i<5; i++) {
        SetIndexEmptyValue(i,0.0); //--- value 0 will not be displayed
        SetIndexEmptyValue(i,EMPTY_VALUE); //--- value 0 will not be displayed
        SetIndexShift(i,HMAShift*MTF/_Period); //--- setting line shift when drawing
        SetIndexDrawBegin(i,MAX*1); } //--- skip drawing the first bars
//**************************************************************************//
//**************************************************************************//

   if (MTF==_Period)  //calculateValue ||
    {
     if (trend[limit]==-1) CleanPoint(limit,hmada,hmadb);

     for (i=limit; i>=0; i--) work[i] = 2.0*iMA(NULL,0,HalfPeriod,0,MODE_LWMA,HMAPrice,i)-iMA(NULL,0,HMAPeriod,0,MODE_LWMA,HMAPrice,i);

     for (i=limit; i>=0; i--)
      {
       hma[i]   = iMAOnArray(work,0,HullPeriod,0,MODE_LWMA,i);
       hmada[i] = EMPTY_VALUE;
       hmadb[i] = EMPTY_VALUE;
       trend[i] = trend[i+1];
          if (hma[i] > hma[i+1]) trend[i] =  1;
          if (hma[i] < hma[i+1]) trend[i] = -1;
          if (trend[i] == -1) PlotPoint(i,hmada,hmadb,hma);
      }
//**************************************************************************//

     deleteLines();

     if (LinesNumber>0)
      {
       int k = 0;
       for (i=0; i<Bars && k<LinesNumber; i++)

       if (trend[i]!=trend[i+1])
        {
         string name = PREF+TimeToStr(Time[i+LSH],TIME_DATE|TIME_MINUTES);   //(string)Time[i];
         ObjectCreate(name,OBJ_TREND,0,Time[i+LSH],hma[i+LSH],Time[i+LSH]+ PERIOD_D1*60,hma[i+LSH]);
         ObjectSet(name,OBJPROP_SELECTABLE,false);
         ObjectSet(name,OBJPROP_HIDDEN,true);
         ObjectSet(name,OBJPROP_BACK,true);
         ObjectSet(name,OBJPROP_RAY_RIGHT,RayRight);
         ObjectSet(name,OBJPROP_WIDTH,LinesSize);

         if (trend[i]==1)
              ObjectSet(name,OBJPROP_COLOR,ColorUP);
         else ObjectSet(name,OBJPROP_COLOR,ColorDN);
         k++;
        }
      }
//**************************************************************************//

     if (AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
      {
       string messageUP = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  >>  HMA trend UP  >>  BUY";   /// +sufix;
       string messageDN = WindowExpertName()+":  "+_Symbol+", "+stringMTF(_Period)+"  <<  HMA trend DN  <<  SELL";   /// +sufix;
     //------
       if (TimeBar!=Time[0] &&  hma[SGB] > hma[1+SGB] && hma[1+SGB] <= hma[2+SGB]) {
           if (AlertsMessage) Alert(messageUP);
           if (AlertsEmail)   SendMail(_Symbol,messageUP);
           if (AlertsMobile)  SendNotification(messageUP);
           if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
           TimeBar=Time[0]; } //return(0);
     //------
       else
       if (TimeBar!=Time[0] &&  hma[SGB] < hma[1+SGB] && hma[1+SGB] >= hma[2+SGB]) {
           if (AlertsMessage) Alert(messageDN);
           if (AlertsEmail)   SendMail(_Symbol,messageDN);
           if (AlertsMobile)  SendNotification(messageDN);
           if (AlertsSound)   PlaySound(SoundFile);   //"stops.wav"   //"news.wav"   //"alert2.wav"  //"expert.wav"
           TimeBar=Time[0]; } //return(0);
      } // *end* Alert.
//**************************************************************************//
     return(0);
    }
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//

   limit = fmax(limit,fmin(Bars-1,iCustom(NULL,MTF,IndikName,PERIOD_CURRENT,MTF,0,0)*MTF/_Period));

   if (trend[limit]==-1) CleanPoint(limit,hmada,hmadb);

   for (i=limit; i>=0; i--)
    {
     int y = iBarShift(NULL,MTF,Time[i]);          //"calculateValue"
        trend[i] = iCustom(NULL,MTF,IndikName,PERIOD_CURRENT,MTF,Interpolate,HMAPeriod,HMAPrice,HMASpeed,HMAHot,0,UniqueID,LinesNumber,LinesShift,RayRight,LinesSize,ColorUP,ColorDN,SIGNALBAR,AlertsMessage,AlertsSound,AlertsEmail,AlertsMobile,SoundFile,0,3,y);
        hma[i]   = iCustom(NULL,MTF,IndikName,PERIOD_CURRENT,MTF,Interpolate,HMAPeriod,HMAPrice,HMASpeed,HMAHot,0,UniqueID,LinesNumber,LinesShift,RayRight,LinesSize,ColorUP,ColorDN,SIGNALBAR,AlertsMessage,AlertsSound,AlertsEmail,AlertsMobile,SoundFile,0,0,y);
        hmada[i] = EMPTY_VALUE;
        hmadb[i] = EMPTY_VALUE;
   //------  //// "new version" of mladen's  == Quadratic smoothes better...
      if (Interpolate==0 || (i>0 && y==iBarShift(NULL,MTF,Time[i-1]))) continue;
          interpolate(hma,MTF,Interpolate,i);
    } // *end of cycle*  for (i=limit; i>=0; i--)
//**************************************************************************//

   for (i=limit; i>=0; i--)  if (trend[i]==-1) PlotPoint(i,hmada,hmadb,hma);
//**************************************************************************//
//------
return(0);
}
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
//**************************************************************************//
//***                                                                      ***
//**************************************************************************//
void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
    {
     if (first[i+2] == EMPTY_VALUE) {
         first[i]   = from[i];
         first[i+1] = from[i+1];
         second[i]  = EMPTY_VALUE;
        }
     else {
        second[i]   =  from[i];
        second[i+1] =  from[i+1];
        first[i]    = EMPTY_VALUE;
       }
    }
   else
    {
     first[i]  = from[i];
     second[i] = EMPTY_VALUE;
    }
}
//**************************************************************************//
//***                   SSA on T3 SSL 4C AA MTF TT [MK]                    ***
//**************************************************************************//
void interpolate(double& target[], int interTF, int interType, int i)
{ //// Taken from Step one more Average 2-3 MTF [garry119]    ////enum Iterpolation { intNO, intLinear, intQuad };
   int bar = iBarShift(NULL,interTF,Time[i]);
   double x0=0, x1=1, x2=2, y0=0, y1=0, y2=0;
//------
   if (interType==intQuad) {
       y0 = target[i];
       y1 = target[(int)fmin(iBarShift(NULL,0,iTime(NULL,interTF,bar+0))+1,Bars-1)];
       y2 = target[(int)fmin(iBarShift(NULL,0,iTime(NULL,interTF,bar+1))+1,Bars-1)]; }
//------
   datetime time = iTime(NULL,interTF,bar);
   int n, k;
//------
   for(n=1; (i+n)<Bars && Time[i+n]>=time; n++) continue;
   for(k=1; (i+n)<Bars && (i+k)<Bars && k<n; k++)
//------
   if (interType==intQuad) {
       double x3 = (double)k/n;
       target[i+k] =  y0*(x3-x1)*(x3-x2)/(-x1*(-x2))
                    + y1*(x3-x0)*(x3-x2)/( x1*(-x1))
                    + y2*(x3-x0)*(x3-x1)/( x2*( x1)); }
//------
   else target[i+k] = target[i] + (target[i+n] - target[i])*k/n;
}
//+++======================================================================+++
//+++                    TMA Centered MACD v6 HAL MTF TT                   +++
//+++======================================================================+++
//----------------------------------------------------------------------------
// function: NextHigherTF()
// Description: Select the next higher time-frame.
//              Note: M15 and M30 both select H1 as next higher TF.
//----------------------------------------------------------------------------
int NextHigherTF(int iPeriod)
{
  if (iPeriod==0) iPeriod=_Period;
  //---
  switch(iPeriod)
   {
    case PERIOD_M1: return(PERIOD_M5);
    case PERIOD_M5: return(PERIOD_M15);
    case PERIOD_M15: return(PERIOD_M30);
    case PERIOD_M30: return(PERIOD_H1);
    case PERIOD_H1: return(PERIOD_H4);
    case PERIOD_H4: return(PERIOD_D1);
    case PERIOD_D1: return(PERIOD_W1);
    case PERIOD_W1: return(PERIOD_MN1);
    case PERIOD_MN1: return(PERIOD_MN1);
    default: return(_Period);
   }
return(_Period);
}
//+++======================================================================+++
//+++                    TMA Centered MACD v6 HAL MTF TT                   +++
//+++======================================================================+++
string stringMTF(int perMTF)
{
   if (perMTF==0)      perMTF=_Period;
   if (perMTF==1)      return("M1");
   if (perMTF==5)      return("M5");
   if (perMTF==15)     return("M15");
   if (perMTF==30)     return("M30");
   if (perMTF==60)     return("H1");
   if (perMTF==240)    return("H4");
   if (perMTF==1440)   return("D1");
   if (perMTF==10080)  return("W1");
   if (perMTF==43200)  return("MN1");
   if (perMTF== 2 || 3  || 4  || 6  || 7  || 8  || 9 ||       /// Off the beaten track Renko.
               10 || 11 || 12 || 13 || 14 || 16 || 17 || 18)  return("M"+(string)_Period);
//------
   return("Period error!");
}
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//%%%                            StochMC AA MTF TT                         %%%
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
