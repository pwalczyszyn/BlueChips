package com.adobe.demo.blueChips.skins
{
	import flash.system.Capabilities;
	
	import org.osmf.layout.ScaleMode;
	
	import spark.components.Image;
	import spark.skins.mobile.SplitViewNavigatorSkin;
	
	public class TexturedApplicationSkin extends SplitViewNavigatorSkin
	{
		protected var background:Image;
		
		public function TexturedApplicationSkin()
		{
			super();
		}

		override protected function createChildren():void
		{
			var res:Number = Math.max(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
			background = new Image;
			if (res <= 1024)
				background.source = "assets/images/background-1024.png";
			else
				background.source = "assets/images/background-1280.png";
			background.scaleMode = ScaleMode.NONE;
			addChild(background);
			
			super.createChildren();
		}
		
		override protected function layoutContents(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.layoutContents(unscaledWidth, unscaledHeight);
			
			setElementSize(background, 
				background.getPreferredBoundsWidth(),
				background.getPreferredBoundsHeight());
			setElementPosition(background, 
				(unscaledWidth - background.getPreferredBoundsWidth()) /2 , 
				(unscaledHeight - background.getPreferredBoundsHeight()) / 2);
		}
		
		override protected function drawBackground(unscaledWidth:Number, unscaledHeight:Number):void
		{
		}
	}
}