package com.adobe.demo.blueChips.skins
{
	import com.adobe.demo.blueChips.skins.assets.CompanyItemRendererBackground;
	import com.adobe.demo.blueChips.skins.assets.CompanyItemRendererBackgroundSelected;
	
	import flash.text.TextFormatAlign;
	
	import spark.components.LabelItemRenderer;
	import spark.components.supportClasses.StyleableTextField;
	import spark.core.SpriteVisualElement;
	
	/**
	 * 
	 * ASDoc comments for this item renderer class
	 * 
	 */
	public class CompanyItemRenderer extends LabelItemRenderer
	{
		
		protected var lastTradeDisplay:StyleableTextField;
		
		protected var changeDisplay:StyleableTextField;
		
		protected var background:SpriteVisualElement;
		
		protected var backgroundSelected:SpriteVisualElement;
		
		public function CompanyItemRenderer()
		{
			super();
		}
		
		/**
		 * @private
		 *
		 * Override this setter to respond to data changes
		 */
		override public function set data(value:Object):void
		{
			super.data = value;
			
			label = value.Symbol;
			
			var changeValue:Number = Number(value.Change);
			if (changeValue == 0)
			{
				changeDisplay.setStyle("color", getStyle("color"));
				changeDisplay.text = value.Change + "  ";
			}
			else if (changeValue > 0)
			{
				changeDisplay.setStyle("color", 0x00FF00);
				changeDisplay.text = value.Change + " ▲";
			}
			else
			{
				changeDisplay.setStyle("color", 0xFF0000);
				changeDisplay.text = value.Change + " ▼";
			}
			
			var dateSplit:Array = String(value.LastTradeDate).split("/");
			var date:String = dateSplit.length == 3 ? " - " + dateSplit[0] + "/" + dateSplit[1] : "";
			lastTradeDisplay.text = value.LastTradePriceOnly + date;
		} 
		
		/**
		 * @private
		 * 
		 * Override this method to create children for your item renderer 
		 */	
		override protected function createChildren():void
		{
			super.createChildren();
			
			background = new CompanyItemRendererBackground;
			
			lastTradeDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			lastTradeDisplay.editable = false;
			lastTradeDisplay.selectable = false;
			lastTradeDisplay.multiline = false;
			lastTradeDisplay.wordWrap = false;
			lastTradeDisplay.setStyle("textAlign", TextFormatAlign.CENTER);
			addChild(lastTradeDisplay);
			
			changeDisplay = StyleableTextField(createInFontContext(StyleableTextField));
			changeDisplay.editable = false;
			changeDisplay.selectable = false;
			changeDisplay.multiline = false;
			changeDisplay.wordWrap = false;
			changeDisplay.setStyle("textAlign", TextFormatAlign.RIGHT);
			addChild(changeDisplay);
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the item renderer 
		 * sizes itself. For performance reasons, do not call 
		 * super.measure() unless you need to.
		 */ 
		override protected function measure():void
		{
			measuredWidth = measuredMinWidth = 240;
			measuredHeight = measuredMinHeight = 50;
		}
		
		/**
		 * @private
		 * 
		 * Override this method to change how the background is drawn for 
		 * item renderer.  For performance reasons, do not call 
		 * super.drawBackground() if you do not need to.
		 */
		override protected function drawBackground(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			if (selected)
			{
				if (!backgroundSelected)
					backgroundSelected = new CompanyItemRendererBackgroundSelected;
				
				if (background && background.parent)
					removeChild(background);
				
				if (!backgroundSelected.parent)
					addChildAt(backgroundSelected, 0);
				
				setElementSize(backgroundSelected, unscaledWidth, unscaledHeight);
				
				labelDisplay.setStyle("color", 0xFFFFFF);
				lastTradeDisplay.setStyle("color", 0xFFFFFF);
			}
			else
			{
				if (backgroundSelected && backgroundSelected.parent)
					removeChild(backgroundSelected);
				
				if (!background.parent)
					addChildAt(background, 0);
				setElementSize(background, unscaledWidth, unscaledHeight);
				
				labelDisplay.setStyle("color", 0xABABAB);
				lastTradeDisplay.setStyle("color", 0xABABAB);
			}
		}
		
		/**
		 * @private
		 *  
		 * Override this method to change how the background is drawn for this 
		 * item renderer. For performance reasons, do not call 
		 * super.layoutContents() if you do not need to.
		 */
		override protected function layoutContents(unscaledWidth:Number, 
												   unscaledHeight:Number):void
		{
			var labelsHeight:Number = getElementPreferredHeight(labelDisplay);
			var labelsVerticalCenter:Number = (unscaledHeight - labelsHeight) / 2;
			
			setElementSize(labelDisplay, 50, labelsHeight);
			setElementPosition(labelDisplay, 10, labelsVerticalCenter);
			
			setElementSize(lastTradeDisplay, 120, labelsHeight);
			setElementPosition(lastTradeDisplay, (unscaledWidth - lastTradeDisplay.width) / 2, labelsVerticalCenter);
			
			setElementSize(changeDisplay, 70, labelsHeight);
			setElementPosition(changeDisplay, unscaledWidth - 10 - changeDisplay.width, labelsVerticalCenter);
		}
	}
}