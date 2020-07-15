#ifdef __MQL5__

  #include <EA31337-classes/MQL4.mqh>

  extern int __tick_count;
  
  int ArrayCheckAllocateValue(double& array[], int index, int num_raise = 100) {
    if (ArraySize(array) <= index) {
      ArrayResize(array, index + num_raise);
      ArrayFill(array, index, num_raise, -1);
      return -1;
    }
    return array[index];    
  }

  bool ObjectDelete(string name) {
    return ObjectDelete(0, name);
  }
  string ObjectName(int index) {
    return ObjectName(0, index);
  }

  #define OBJPROP_TIME1 ((ENUM_OBJECT_PROPERTY_INTEGER)0)
  #define OBJPROP_PRICE1 1
  #define OBJPROP_TIME2 2
  #define OBJPROP_PRICE2 3
  #define OBJPROP_TIME3 4
  #define OBJPROP_PRICE3 5
  #define OBJPROP_COLOR ((ENUM_OBJECT_PROPERTY_INTEGER)6)
  #define OBJPROP_STYLE 7
  #define OBJPROP_WIDTH 8
  #define OBJPROP_BACK ((ENUM_OBJECT_PROPERTY_INTEGER)9)
  #define OBJPROP_FIBOLEVELS 200
  
  bool ObjectSet(string name, int index, double value) {
   switch(index)
     {
      case OBJPROP_TIME1:
         ObjectSetInteger(0,name,OBJPROP_TIME,(int)value);return(true);
      case OBJPROP_PRICE1:
         ObjectSetDouble(0,name,OBJPROP_PRICE,value);return(true);
      case OBJPROP_TIME2:
         ObjectSetInteger(0,name,OBJPROP_TIME,1,(int)value);return(true);
      case OBJPROP_PRICE2:
         ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);return(true);
      case OBJPROP_TIME3:
         ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);return(true);
      case OBJPROP_PRICE3:
         ObjectSetDouble(0,name,OBJPROP_PRICE,2,value);return(true);
      case OBJPROP_COLOR:
         ObjectSetInteger(0,name,OBJPROP_COLOR,(long)value);return(true);
      case OBJPROP_STYLE:
         ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);return(true);
      case OBJPROP_WIDTH:
         ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);return(true);
      case OBJPROP_BACK:
         ObjectSetInteger(0,name,OBJPROP_BACK,(long)value);return(true);
      case OBJPROP_RAY:
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);return(true);
      case OBJPROP_ELLIPSE:
         ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);return(true);
      case OBJPROP_SCALE:
         ObjectSetDouble(0,name,OBJPROP_SCALE,value);return(true);
      case OBJPROP_ANGLE:
         ObjectSetDouble(0,name,OBJPROP_ANGLE,value);return(true);
      case OBJPROP_ARROWCODE:
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);return(true);
      case OBJPROP_TIMEFRAMES:
         ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);return(true);
      case OBJPROP_DEVIATION:
         ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);return(true);
      case OBJPROP_FONTSIZE:
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);return(true);
      case OBJPROP_CORNER:
         ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);return(true);
      case OBJPROP_XDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);return(true);
      case OBJPROP_YDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);return(true);
      case OBJPROP_FIBOLEVELS:
         ObjectSetInteger(0,name,OBJPROP_LEVELS,(int)value);return(true);
      case OBJPROP_LEVELCOLOR:
         ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);return(true);
      case OBJPROP_LEVELSTYLE:
         ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);return(true);
      case OBJPROP_LEVELWIDTH:
         ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);return(true);

      default: return(false);
     }
   return(false);
  }
  
  int ObjectsTotal(int type = EMPTY_VALUE, int window = -1) {
    return ObjectsTotal(0, window, type);
  }

  void SetIndexEmptyValue(int index, double value) {
    PlotIndexSetDouble(index, PLOT_EMPTY_VALUE, value);
  }
  
  void SetIndexShift(int index, int shift) {
    PlotIndexSetInteger(index, PLOT_SHIFT, shift);
  }
  
  void SetIndexDrawBegin(int index, int begin) {
    PlotIndexSetInteger(index, PLOT_DRAW_BEGIN, begin);
  }

	string WindowExpertName() {
		return MQL5InfoString(MQL5_PROGRAM_NAME);
	}
	
	void IndicatorShortName(string name) {
	  IndicatorSetString(INDICATOR_SHORTNAME, name);
	}
	
	int IndicatorCounted() {
	  return __tick_count;
	}

	void SetIndexLabel(int index, string text) {
		PlotIndexSetString(index,PLOT_LABEL,text);
	}
	
  void SetIndexStyle(int index, int type, int style=EMPTY_VALUE, int width=EMPTY_VALUE, color clr=CLR_NONE)
  {
   if(width>-1)
      PlotIndexSetInteger(index,PLOT_LINE_WIDTH,width);
   if(clr!=CLR_NONE)
      PlotIndexSetInteger(index,PLOT_LINE_COLOR,clr);
   switch(type)
     {
      case 0:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_LINE);
      case 1:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_SECTION);
      case 2:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
      case 3:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_ARROW);
      case 4:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_ZIGZAG);
      case 12:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_NONE);

      default:
         PlotIndexSetInteger(index,PLOT_DRAW_TYPE,DRAW_LINE);
     }
   switch(style)
     {
      case 0:
         PlotIndexSetInteger(index,PLOT_LINE_STYLE,STYLE_SOLID);
      case 1:
         PlotIndexSetInteger(index,PLOT_LINE_STYLE,STYLE_DASH);
      case 2:
         PlotIndexSetInteger(index,PLOT_LINE_STYLE,STYLE_DOT);
      case 3:
         PlotIndexSetInteger(index,PLOT_LINE_STYLE,STYLE_DASHDOT);
      case 4:
         PlotIndexSetInteger(index,PLOT_LINE_STYLE,STYLE_DASHDOTDOT);

      default: return;
     }  
  
  }
		
#endif