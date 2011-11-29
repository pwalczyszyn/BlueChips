package com.adobe.demo.blueChips.components
{
	import com.adobe.demo.blueChips.components.assets.AreaChartRulerInfoBackground;
	
	import flash.display.GraphicsPathCommand;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.events.ResizeEvent;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.Scroller;
	import spark.core.SpriteVisualElement;
	
	[Event(name="selectionChange", type="mx.events.FlexEvent")]
	
	public class SimpleAreaChart extends UIComponent
	{
		protected var _series:Array;
		
		protected var _xAxisField:String;
		
		protected var _yAxisField:String;
		
		protected var _rulerLabelFunction:Function;
		
		protected var _xAxisLabelFunction:Function;
		
		protected var maxValue:Number;
		
		protected var seriesChanged:Boolean = false;
		
		protected var scroller:Scroller;
		
		protected var contentGroup:Group;
		
		protected var chartSprite:SpriteVisualElement;
		
		protected var viewportGroup:Group;
		
		protected var ruler:Sprite;
		protected var rulerLabel:Label;
		protected var rulerArea:Group;
		
		protected var redrawChart:Boolean = false;
		
		protected var chartZoom:Number = 1;
		
		protected var valueLabels:Array = [];
		
		protected static const HORIZONTAL_SCALES_NUM:int = 5;
		
		protected var textFormat:TextFormat;
		
		public function SimpleAreaChart()
		{
			super();
			this.addEventListener(ResizeEvent.RESIZE, onResize);
		}
		
		private function onResize(event:ResizeEvent):void
		{
			redrawChart = true;
			
			scroller.setActualSize(unscaledWidth, unscaledHeight);
			contentGroup.setActualSize(unscaledWidth, unscaledHeight);
			
			rulerArea.setActualSize(unscaledWidth, 80);
			rulerArea.setLayoutBoundsPosition(0, unscaledHeight - rulerArea.height);
			
			chartSprite.width = contentGroup.width * chartZoom;
			chartSprite.height = unscaledHeight;
		}
		
		override protected function createChildren():void
		{
			textFormat = new TextFormat(getStyle("fontFamily"), 12, 0xFFFFFF);
			
			contentGroup = new Group;
			contentGroup.clipAndEnableScrolling = true;
			contentGroup.addEventListener(TransformGestureEvent.GESTURE_ZOOM, chart_zoomHandler);
			addChild(contentGroup);
			
			chartSprite = new SpriteVisualElement;
			contentGroup.addElement(chartSprite);
			
			scroller = new Scroller;
			scroller.viewport = contentGroup;
			scroller.setStyle("verticalScrollPolicy", ScrollPolicy.OFF);
			scroller.setStyle("horizontalScrollPolicy", ScrollPolicy.ON);
			addChild(scroller);

			ruler = new Sprite;
			ruler.visible = false;
			addChild(ruler);
			
			rulerLabel = new Label;
			rulerLabel.visible = false;
			rulerLabel.setStyle("color", 0xFFFFFF);
			rulerLabel.setStyle("paddingLeft", 8);
			rulerLabel.setStyle("paddingRight", 8);
			rulerLabel.setStyle("paddingBottom", 6);
			rulerLabel.setStyle("paddingTop", 6);
			rulerLabel.setStyle("backgroundColor", 0x3AA1DB);
			addChild(rulerLabel);
			
			rulerArea = new Group;
			rulerArea.mouseChildren = false;
			rulerArea.addEventListener(MouseEvent.MOUSE_DOWN, rulerArea_mouseDownHandler);
			rulerArea.addEventListener(MouseEvent.MOUSE_MOVE, rulerArea_moveHandler);
			rulerArea.addEventListener(MouseEvent.MOUSE_OUT, rulerArea_mouseOutHandler);
			rulerArea.addEventListener(MouseEvent.MOUSE_UP, rulerArea_mouseOutHandler);
			addChild(rulerArea);
			
			var rulerAreaBackground:SpriteVisualElement = new AreaChartRulerInfoBackground;
			rulerAreaBackground.height = 20;
			rulerAreaBackground.percentWidth = 100;
			rulerAreaBackground.horizontalCenter = 0;
			rulerAreaBackground.bottom = 0;
			rulerArea.addElement(rulerAreaBackground);
			
			var rulerAreaLabel:Label = new Label;
			rulerAreaLabel.text = "SLIDE HERE TO SEE CHART DETAILS";
			rulerAreaLabel.horizontalCenter = 0;
			rulerAreaLabel.bottom = 3;
			rulerAreaLabel.alpha = 0.4;
			rulerAreaLabel.setStyle("fontSize", 14);
			rulerAreaLabel.setStyle("color", 0x0471c1);
			rulerArea.addElement(rulerAreaLabel);
		}

		public var selection:Object;
		protected var prevSelection:Object;
		protected function rulerArea_mouseDownHandler(event:MouseEvent):void
		{
			if (!ruler.visible)
				ruler.visible = rulerLabel.visible = true;
		}

		protected function rulerArea_moveHandler(event:MouseEvent):void
		{
			if (ruler.visible)
			{
				ruler.graphics.clear();
				ruler.graphics.lineStyle(1, 0x3AA1DB, 0.6);
				ruler.graphics.moveTo(event.localX, 0);
				ruler.graphics.lineTo(event.localX, unscaledHeight);
				
				var seriesIndex:int = series.length * (contentGroup.horizontalScrollPosition + event.localX) / chartSprite.width;
				if (seriesIndex >= 0 && seriesIndex < series.length)
				{
					selection = series[seriesIndex];
					if (selection != prevSelection)
					{
						prevSelection = selection; 
						
						if (rulerLabelFunction != null)
							rulerLabel.text = rulerLabelFunction(selection);
						else
							rulerLabel.text = selection[yAxisField];
						
						if (hasEventListener(FlexEvent.SELECTION_CHANGE))
						{
							var changeEvent:FlexEvent = new FlexEvent(FlexEvent.SELECTION_CHANGE);
							dispatchEvent(changeEvent);
						}
					}
					
					rulerLabel.setActualSize(rulerLabel.getPreferredBoundsWidth(), rulerLabel.getPreferredBoundsHeight());
					
					rulerLabel.y = 82;
					if (event.localX > rulerArea.width - rulerLabel.width)
						rulerLabel.x = event.localX - rulerLabel.width;
					else
						rulerLabel.x = event.localX;
				}
			}
		}

		protected function rulerArea_mouseOutHandler(event:MouseEvent):void
		{
			selection = null;
			prevSelection = null;
			
			var changeEvent:FlexEvent = new FlexEvent(FlexEvent.SELECTION_CHANGE);
			dispatchEvent(changeEvent);
			
			ruler.graphics.clear();
			ruler.visible = rulerLabel.visible = false;
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (seriesChanged)
			{
				redrawChart = true;
				seriesChanged = false;

				// Reseting values
				maxValue = NaN;
				
				var value:Number;
				for each(var item:Object in series)
				{
					value = Number(item[yAxisField]);
					if (!maxValue || maxValue < value)
						maxValue = value;
				}
				
				// Adding value labels
				for(var i:int = 0; i < HORIZONTAL_SCALES_NUM - 1; i++)
					valueLabels.push(addChild(createTextField()));
				
				chartZoom = 1;
				chartSprite.width = contentGroup.width;
				contentGroup.horizontalScrollPosition = 0;
				
				invalidateDisplayList();
			}
		}
		
		protected function chart_zoomHandler(event:TransformGestureEvent):void
		{
			if (chartSprite.width >= contentGroup.width)
			{
				var zoom:Number = chartZoom * event.scaleX;
				if (zoom < 1)
					chartZoom = 1;
				else if (zoom > series.length)
					chartZoom = series.length;
				else
					chartZoom = zoom;
				
				var newWidth:Number = contentGroup.width * chartZoom;
				if (chartSprite.width != newWidth)
				{
					redrawChart = true;
					chartSprite.width = newWidth;
				}
			}
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (redrawChart)
			{
				redrawChart = false;
				
				chartSprite.removeChildren();
				chartSprite.graphics.clear();
				chartSprite.graphics.lineStyle(1, 0xFFFFFF, 0.1);
				
				// Drawing horizontal lines and labels
				var tenths:int = 0;
				var chartMaxValue:Number = maxValue * 1.7;
				var chartScale:Number = chartMaxValue / HORIZONTAL_SCALES_NUM;
				var chartScaleHeight:Number = contentGroup.height / HORIZONTAL_SCALES_NUM;
				if (chartScale)
				{
					for (var i:int = 1; i < HORIZONTAL_SCALES_NUM; i++)
					{
						var scaleNum:int = HORIZONTAL_SCALES_NUM - i;
						
						chartSprite.graphics.moveTo(0, chartScaleHeight * scaleNum);
						chartSprite.graphics.lineTo(chartSprite.width, chartScaleHeight * scaleNum);
					
						var valueLabel:TextField = valueLabels[i - 1];
						valueLabel.text = Number(chartScale * i).toFixed(2);
						valueLabel.setTextFormat(textFormat);
						valueLabel.x = unscaledWidth - valueLabel.textWidth - 10;
						valueLabel.y = (chartScaleHeight * scaleNum) - 17;
					}
				}
				
				if (series && series.length > 0)
				{
					var pathCommands:Vector.<int> = new Vector.<int>;
					var pathData:Vector.<Number> = new Vector.<Number>;
					
					var valueX:Number = 0;
					var chartScaleWidth:Number = chartSprite.width / series.length;
					
					var lineOffset:Number = 0;
					
					var value:Number;
					var seriesItem:Object;
					var xAxisLabelText:String;
					
					var dateField:TextField;
					
					for (var j:int = 0; j < series.length; j++)
					{
						seriesItem = series[j];
						value = seriesItem[yAxisField]

						if (j == 0)
							pathCommands.push(GraphicsPathCommand.MOVE_TO);
						else
							pathCommands.push(GraphicsPathCommand.LINE_TO);
							
						pathData.push(valueX, chartSprite.height - (value / chartMaxValue * chartSprite.height));
						
						if (lineOffset == 0 || lineOffset >= 40 && j < series.length)
						{
							if (_xAxisLabelFunction != null)
								xAxisLabelText = _xAxisLabelFunction(seriesItem[xAxisField]);
							else
								xAxisLabelText = seriesItem[xAxisField];
							
							dateField = createTextField(
								xAxisLabelText,
								valueX + 5, 
								chartSprite.height - 42 /* bottom + text height */
							);
							dateField.setTextFormat(textFormat);
							
							chartSprite.addChild(dateField);		
							
							// Drawing vertical lines
							chartSprite.graphics.moveTo(valueX, 0);
							chartSprite.graphics.lineTo(valueX, chartSprite.height);
							
							lineOffset = 0;
						}
						
						valueX += chartScaleWidth;
						lineOffset += chartScaleWidth;
					}
					
					// Adding path closing commands and data
					pathCommands.push(GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO, GraphicsPathCommand.LINE_TO);
					pathData.push(chartSprite.width, chartSprite.height - (value / chartMaxValue * chartSprite.height),
						chartSprite.width, chartSprite.height, 0, chartSprite.height);
					
					chartSprite.graphics.beginFill(0x000000, 0.5);
					chartSprite.graphics.lineStyle(1, 0xFFFFFF, 0.3);
					chartSprite.graphics.drawPath(pathCommands, pathData);
					chartSprite.graphics.endFill();
				}
			}
		}
		
		public function set series(value:Array):void
		{
			_series = value;

			seriesChanged = true;
			invalidateProperties();
		}
		
		public function get series():Array
		{
			return _series;
		}
		
		public function get xAxisField():String
		{
			return _xAxisField;
		}
		
		public function set xAxisField(value:String):void
		{
			_xAxisField = value;
			
			seriesChanged = true;
			invalidateProperties();
		}
		
		public function get yAxisField():String
		{
			return _yAxisField;
		}
		
		public function set yAxisField(value:String):void
		{
			_yAxisField = value;
			
			seriesChanged = true;
			invalidateProperties();
		}
		
		protected function createTextField(fieldText:String = "", fieldX:Number = 0, fieldY:Number = 0):TextField
		{
			var textField:TextField = new TextField;
			textField.selectable = false;
			textField.multiline = false;
			textField.wordWrap = false;
			textField.text = fieldText;
			textField.x = fieldX;
			textField.y = fieldY;
			return textField;
		}


		public function get rulerLabelFunction():Function
		{
			return _rulerLabelFunction;
		}

		public function set rulerLabelFunction(value:Function):void
		{
			_rulerLabelFunction = value;
		}


		public function get xAxisLabelFunction():Function
		{
			return _xAxisLabelFunction;
		}

		public function set xAxisLabelFunction(value:Function):void
		{
			_xAxisLabelFunction = value;
		}
	}
}