/*
 * Endurance Logger, program that is intended to help your to track your fitness progress
 * Copyright (C) 2013 AS3Boyan
 * 
 * This file is part of Endurance Logger.
 * Endurance Logger is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Endurance Logger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Endurance Logger.  If not, see <http://www.gnu.org/licenses/>.
*/

package ;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import haxe.Timer;
import motion.Actuate;

class InfoPanel extends Sprite
{

	var tf:TextField;
	var timer:Timer;
	var text_queue:Array<String>;
	var time_queue:Array<Int>;
	var active:Bool;
	
	public function new() 
	{		
		super();
		
		var text_format:TextFormat = new TextFormat();
		text_format.align = TextFormatAlign.CENTER;
		text_format.font = "Arial";
		text_format.size = 36;
		text_format.color = 0xFFFFFF;
		
		tf = new TextField();
		tf.defaultTextFormat = text_format;
		
		//Previous workout sessions are shown as half transparent graph
		
		tf.mouseEnabled = false;
		tf.wordWrap = true;
		tf.multiline = true;
		tf.selectable = false;
		
		addChild(tf);
		
		text_queue = new Array();
		time_queue = new Array();
		
		active = false;
		
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
		addEventListener(MouseEvent.CLICK, onClick);
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		hide();
	}
	
	public function show(_text:String, _time:Int = 3000):Void
	{
		text_queue.push(_text);
		time_queue.push(_time);
		
		if (!active)
		{
			checkQueue();
		}
	}
	
	public function hide():Void
	{
		mouseEnabled = false;
		Actuate.tween(this, 1, { y: -height } ).onComplete(checkQueue);
		timer.stop();
	}
	
	function checkQueue() 
	{
		active = false;
		
		if (text_queue.length > 0)
		{
			var text_queue_element:String = text_queue.splice(0, 1)[0];
			
			showText(text_queue_element);
		}
	}
	
	function showText(_text:String):Void
	{
		tf.text = _text;
		tf.y = (height - tf.textHeight) / 2;
		
		Actuate.tween(this, 1, { y: 0 } );
	
		timer = new Timer(time_queue.splice(0, 1)[0]);
		timer.run = hide;
		
		mouseEnabled = true;
		active = true;
		parent.setChildIndex(this, parent.numChildren - 1);
	}
	
	private function onAdded(e:Event):Void 
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		
		graphics.beginFill(0x000000);
		graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight / 4);
		graphics.endFill();
		
		tf.width = stage.stageWidth;
		tf.height = stage.stageHeight / 4;
		
		y = -height;
	}
	
}