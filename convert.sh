#!/bin/bash
#cat $1 | sed -e  > tmp_file
#mv tmp_file $1
cp $1 tmp_file

perl -i~ -0777 -pe "s/#property.+indicator_buffers.+$//gm" tmp_file
perl -i~ -0777 -pe "s/(.+?)IndicatorBuffers\s*\(([0-9]+)\)\s*;(.+?)/#property indicator_buffers \2\n#define indicator_buffers \2\n\1\3/gms" tmp_file
perl -i~ -0777 -pe "s/(int)\s+init.+?{/\1 OnInit() {/gms" tmp_file
if grep -q Time tmp_file; then
	echo -e "#include <EA31337-classes/DateTime.mqh>\n$(cat tmp_file)" > tmp_file
	perl -i~ -0777 -pe "s/TimeToStr\s*\(/DateTime::TimeToStr(/gms" tmp_file;
fi
if grep -q iMA tmp_file; then
  echo -e "#include <EA31337-classes/Indicators/Indi_MA.mqh>\n$(cat tmp_file)" > tmp_file
  perl -i~ -0777 -pe "s/iMA\s*\(/Indi_MA::iMA(/gms" tmp_file
  perl -i~ -0777 -pe "s/iMAOnArray\s*\(/Indi_MA::iMAOnArray(/gms" tmp_file;
fi
separated="[\\(\\s\\,\\[\\{<>=]+"
echo $separated
perl -i~ -0777 -pe "s/(${separated})Bars/\1Bars(_Symbol, _Period)/gms" tmp_file
perl -i~ -0777 -pe "s/(${separated})IndicatorCounted\s*\(\s*\)/\1(prev_calculated>0 ? prev_calculated-1 : 0)/gms" tmp_file
perl -i~ -0777 -pe "s/(int)\s+start\s*\(\s*\)/
#ifdef __MQL4__
  int __tick_count = 0;

  \1 start () {

    return OnCalculate(rates_total, prev_calculated, begin, price);
  }
#endif

  int OnCalculate (const int rates_total, const int prev_calculated, const int begin, const double& price[])
/gms" tmp_file

perl -i~ -0777 -pe "s/(.+?)/#include \"MT4to5.mq5\"\n\n\1/m" tmp_file

mv tmp_file converted.mq5
