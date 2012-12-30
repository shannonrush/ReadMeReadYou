$(document).ready(function() {
	var options = {
		xaxis: {axisLabel: 'foo',
            	axisLabelUseCanvas: true,
            	axisLabelFontSizePixels: 20,
            	axisLabelFontFamily: 'Arial'
	        	},
        yaxis: {axisLabel: 'bar',
            	axisLabelUseCanvas: true
	        	}
    };
	$.plot($("#sentence_chart"), [
		{
		  data: sentenceData,
		  bars: {show: true}
		}
  ],{
	  yaxis:{
		  axisLabel:'Number Of Sentences',
		  axisLabelUseCanvas:true,			
		  tickDecimals: 0
	  },
	  xaxis:{
	  	  axisLabel:'Number Of Words In Sentence',
		  axisLabelFontSizePixels: 15,
		  axisLabelUseCanvas:true,
		  axisLabelPadding: 7
	  }
  }
  );
});
