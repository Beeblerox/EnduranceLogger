/*
 * Endurance Logger, program that is intended to help you to track your fitness progress
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
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.ui.Keyboard;
import flash.Vector.Vector;
import flash.Vector.Vector;
import flash.Vector.Vector;
import motion.Actuate;
import motion.easing.Cubic;
import motion.easing.Linear;
import openfl.Assets;
import openfl.display.FPS;

class Main extends Sprite 
{
	var inited:Bool;
	var input_field:InputField;
	var colored_points_layer:Sprite;
	var colored_points_manager:ColoredPointsManager;
	var colored_points_manager2:ColoredPointsManager;
	var tf_min:TextField;
	var tf_max:TextField;
	var tf_start_date:TextField;
	var tf_end_date:TextField;
	var tf_info:TextField;
	var exercise_buttons:Array<Button>;
	var time_range_buttons:Array<Button>;
	var colored_points:Array<ColoredPoint>;
	var target_coord_x:Array<Float>;
	var target_coord_y:Array<Float>;
	var lines:Array<Sprite>;
	var background:ColoredRect;
	var lines_layer:Sprite;
	var min:Float;
	var max:Float;
	var previous_layers:Array<Sprite>;
	var info_panel:InfoPanel;
	
	/* ENTRY POINT */
	
	function resize(e) 
	{
		if (!inited) init();
		// else (resize or orientation change)
	}
	
	function init() 
	{
		if (inited) return;
		inited = true;

		// (your code here)
		
		// Stage:
		// stage.stageWidth x stage.stageHeight @ stage.dpiScale
		
		// Assets:
		// nme.Assets.getBitmapData("img/assetname.jpg");
		
		WorkoutData.init();
		
		colored_points_manager = new ColoredPointsManager(500);
		colored_points_manager2 = new ColoredPointsManager(500);
				
		background = new ColoredRect(stage.stageWidth, stage.stageHeight, 0xFFFFFF);
		background.addEventListener(MouseEvent.CLICK, onClick);
		addChild(background);
		
		input_field = new InputField();
		
		GV.colors = new Array();
		GV.colors.push(14926557);
		GV.colors.push(5944284);
		GV.colors.push(11657372);
		GV.colors.push(5559499);
		GV.colors.push(13689963);
		
		GV.exercise_text = new Array();
		GV.exercise_text.push("Pushups");
		GV.exercise_text.push("Pullups");
		GV.exercise_text.push("Squats");
		GV.exercise_text.push("Situps");
		GV.exercise_text.push("Dips");
		
		exercise_buttons = new Array();
		
		for (i in 0...5)
		{
			var exercise_button:Button = new Button(this, i * 150 + 100, 435, GV.exercise_text[i], input_field.show);
			exercise_button.setWidth(null, null, GV.colors[i], 0);
			exercise_button.exercise_type = i + 1;
			exercise_buttons.push(exercise_button);
		}
		
		setChildIndex(exercise_buttons[0], numChildren - 1);
		
		var time_range_text:Array<String> = new Array();
		time_range_text.push("Day");
		time_range_text.push("Week");
		time_range_text.push("Month");
		time_range_text.push("Year");
		time_range_text.push("All time");
		
		time_range_buttons = new Array();
		
		for (i in 0...5)
		{
			var time_range_button:Button = new Button(this, i * 75 + stage.stageWidth - 5*75 + 15, 20, time_range_text[i]);
			time_range_button.setWidth(75, 25, 0xF8F8F8);
			time_range_button.time_range = i + 1;
			time_range_buttons.push(time_range_button);
		}
		
		setChildIndex(time_range_buttons[0], numChildren - 1);
		
		var text_format:TextFormat = new TextFormat();
		text_format.font = "Arial";
		text_format.size = 52;
		text_format.align = TextFormatAlign.CENTER;
		
		tf_info = new TextField();
		tf_info.width = 700;
		tf_info.height = 600;
		tf_info.x = (stage.stageWidth - tf_info.width)/2 ;
		tf_info.y = (stage.stageHeight/600 * 430 - tf_info.textHeight) / 2;
		tf_info.defaultTextFormat = text_format;
		tf_info.selectable = false;
		tf_info.mouseEnabled = false;
		tf_info.wordWrap = true;
		
		background.addChild(tf_info);
		
		lines_layer = new Sprite();
		background.addChild(lines_layer);
		
		previous_layers = new Array();
		
		for (i in 0...15) 
		{
			var layer:Sprite = new Sprite();
			layer.alpha = 0.2 + 0.3*i/14;
			previous_layers.push(layer);
			background.addChild(layer);
		}
		
		colored_points_layer = new Sprite();
		background.addChild(colored_points_layer);
		
		var text_format:TextFormat = new TextFormat();
		text_format.align = TextFormatAlign.RIGHT;
		
		tf_min = new TextField();
		tf_min.defaultTextFormat = text_format;
		tf_min.text = "1";
		tf_min.x = 34 - tf_min.width;
		tf_min.y = 350 - tf_min.textHeight/2;
		tf_min.selectable = false;
		tf_min.mouseEnabled = false;
		background.addChild(tf_min);
		
		tf_max = new TextField();
		tf_max.defaultTextFormat = text_format;
		tf_max.text = "1";
		tf_max.x = 34 - tf_max.width;
		tf_max.y = 50 - tf_max.textHeight/2;
		tf_max.selectable = false;
		tf_max.mouseEnabled = false;
		background.addChild(tf_max);
		
		addChild(input_field);
		
		tf_start_date = new TextField();
		tf_start_date.width = 150;
		tf_start_date.height = 30;
		tf_start_date.x = 38;
		tf_start_date.y = 358 + tf_min.textHeight/2;
		tf_start_date.selectable = false;
		tf_start_date.mouseEnabled = false;
		background.addChild(tf_start_date);
		
		var text_format:TextFormat = new TextFormat();
		text_format.align = TextFormatAlign.RIGHT;
		
		tf_end_date = new TextField();
		tf_end_date.width = 150;
		tf_end_date.height = 30;
		tf_end_date.defaultTextFormat = text_format;
		tf_end_date.x = stage.stageWidth-175;
		tf_end_date.y = 358 + tf_min.textHeight/2;
		tf_end_date.selectable = false;
		tf_end_date.mouseEnabled = false;
		background.addChild(tf_end_date);
		
		background.graphics.lineStyle(1);
		
		var commands:Vector<Int> = new Vector<Int>();
		commands.push(1);
		commands.push(2);
		commands.push(2);
		
		var coords:Vector<Float> = new Vector<Float>();
		coords.push(35);
		coords.push(39);
		coords.push(35);
		coords.push(365);
		coords.push(stage.stageWidth-30);
		coords.push(365);
		
		background.graphics.drawPath(commands, coords);		
		
		info_panel = new InfoPanel();
		addChild(info_panel);
		
		var first_workout_date:Date = WorkoutData.getFirstWorkoutDate();
		
		if (first_workout_date == null)
		{
			info_panel.show("Hello!");
		}
		else
		{
			info_panel.show("Hello, and welcome back!");
		}
		
		var tips:Array<String> = new Array();
		tips.push("Don't forget to warm up!");
		tips.push("Eat healthy, small and often");
		tips.push("Avoid sleep deprivation");
		tips.push("Avoid overtraining");
		tips.push("Exercise using a good form");
		tips.push("Drink plenty of water");
		tips.push("Moderate physical activity is good for health");
		tips.push("Increase workout intensity gradually");
		tips.push("Be positive and optimistic");
		tips.push("Improve your sleep regimen and keep it healthy");
		
		info_panel.show("Tip of the Day:\n" + tips[Utils.randInt(0,tips.length-1)]);
				
		GV.showText = info_panel.show;
		
		//var fps:FPS = new FPS();
		//addChild(fps);
				
		lines = new Array();
		
		target_coord_x = new Array();
		target_coord_y = new Array();
		colored_points = new Array();
		
		GV.exercise_type = 1;
		GV.time_range = 1;		
		GV.updateData = updateData;
		GV.updateData();
		
		addEventListener(Event.ACTIVATE, onActivate );
		addEventListener(Event.DEACTIVATE, onDeactivate );
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		//trace(WorkoutData.getAllRecords());
	}
	
	private function onKeyDown(e:KeyboardEvent):Void 
	{
		switch (e.keyCode)
		{
			case Keyboard.NUMBER_1:
				if (!input_field.visible)
				{
					GV.exercise_type = 1;
					GV.updateData();
				}
				
			case Keyboard.NUMBER_2:
				if (!input_field.visible)
				{
					GV.exercise_type = 2;
					GV.updateData();
				}
				
			case Keyboard.NUMBER_3:
				if (!input_field.visible)
				{
					GV.exercise_type = 3;
					GV.updateData();
				}
				
			case Keyboard.NUMBER_4:
				if (!input_field.visible)
				{
					GV.exercise_type = 4;
					GV.updateData();
				}
				
			case Keyboard.NUMBER_5:
				if (!input_field.visible)
				{
					GV.exercise_type = 5;
					GV.updateData();
				}
				
			case Keyboard.ENTER:
				if (input_field.visible && input_field.mouseEnabled)
				{
					input_field.onClick();
				}
				else
				{
					input_field.show();
				}
				
			case Keyboard.ESCAPE:
				if (input_field.visible && input_field.mouseEnabled)
				{
					input_field.hide();
				}
		}
	}
	
	private function updateData():Void
	{
		colored_points_manager.k = 0;
		colored_points_manager2.k = 0;
		
		for (i in 0...5)
		{
			exercise_buttons[i].setSelected(false);
			time_range_buttons[i].setSelected(false);
		}
		
		exercise_buttons[GV.exercise_type-1].setSelected(true);
		time_range_buttons[GV.time_range-1].setSelected(true);
		
		var current_date:Date = Date.now();
		var date1 = DateTools.delta(current_date, -DateTools.hours( current_date.getHours() ) -DateTools.minutes(current_date.getMinutes()) - DateTools.seconds(current_date.getSeconds()) );
		
		var workout_stats_records:Array<WorkoutInfo> = null;
		
		var previous_stats_records:Array<Array<WorkoutInfo>> = new Array();
		
		switch(GV.time_range)
		{
			case 1: 
				workout_stats_records = WorkoutData.getDayWorkoutStats(date1);
				previous_stats_records = WorkoutData.getPreviousDaysStats(date1);
			case 2: 
				workout_stats_records = WorkoutData.getWeekWorkoutStats(date1);
				previous_stats_records = WorkoutData.getPreviousWeekStats(date1);
			case 3: 
				workout_stats_records = WorkoutData.getMonthWorkoutStats(date1);
				previous_stats_records = WorkoutData.getPreviousMonthStats(date1);
			case 4: 
				workout_stats_records = WorkoutData.getYearWorkoutStats(date1);
				previous_stats_records = WorkoutData.getPreviousYearStats(date1);
			case 5: workout_stats_records = WorkoutData.getAllTimeStats();
			case _: trace(GV.time_range);
		}
		
		var workout_stats_records_array:Array<Array<WorkoutInfo>> = new Array();
		workout_stats_records_array.push(workout_stats_records);
		
		if (previous_stats_records != null && previous_stats_records.length > 0)
		{
			for (previous_stats in previous_stats_records) workout_stats_records_array.push(previous_stats);
		}
		
		//trace(previous_stats_records);
		
		var i:Int = 0;
		
		var width_interval:Float = (stage.stageWidth-100) / Math.max(workout_stats_records.length-1, 1);
		
		getMinMax(workout_stats_records_array);
		
		showText(workout_stats_records);
				
		var height_interval:Float = 300;
		
		var sum:Int = 0;
				
		while (colored_points.length > 0)
		{
			Actuate.stop(colored_points[0]);
			colored_points.splice(0, 1);
		}
		
		while (lines.length > 0)
		{
			lines[0].graphics.clear();
			lines_layer.removeChild(lines[0]);
			lines.splice(0, 1);
		}
		
		while (target_coord_x.length > 0)
		{
			target_coord_x.splice(0, 1);
			target_coord_y.splice(0, 1);
		}
		
		for (workout_stats in workout_stats_records)
		{
			var colored_circle:ColoredPoint = colored_points_manager.getNext();
			colored_circle.setColor(GV.colors[GV.exercise_type-1]);
			//colored_circle.alpha = 1;
			
			var date:String = workout_stats.date;
			//if (GV.time_range == 1) date = date.substr(date.indexOf(" ")+1);
			
			sum += workout_stats.value;
			
			colored_circle.setText(date, workout_stats.value);
			Actuate.stop(colored_circle);
			target_coord_x.push(50 + i * width_interval);
			target_coord_y.push(350 - height_interval * (workout_stats.value-min) / Math.max(max - min, 1));
			//Actuate.tween(colored_circle, 1, { x:50 + i * width_interval, y:350 - height_interval * (workout_stats.value-min) / Math.max(max - min, 1) } );
			
			colored_points.push(colored_circle);
			
			if (colored_circle.parent == null) colored_points_layer.addChild(colored_circle);
			
			i++;
		}
		
		colored_points_manager.hideUnusedPoints();
		
		colored_points_manager2.k = 0;
		
		var previous_colored_circle:ColoredPoint = null;
		//trace(workout_stats_records_array);
		
		for (i in 0...previous_layers.length)
		{
			previous_layers[i].graphics.clear();
		}
		
		if (previous_stats_records.length > 0)
		{
			for (j in 0...previous_stats_records.length)
			{
				var index:Int = previous_layers.length - 1 - j;
				
				i = 0;
				width_interval = (stage.stageWidth - 100) / Math.max(previous_stats_records[j].length-1, 1);
				
				for (workout_stats in previous_stats_records[j])
				{
					var colored_circle:ColoredPoint = colored_points_manager2.getNext();
					colored_circle.setColor(GV.colors[GV.exercise_type-1]);
					//colored_circle.alpha = 0.3;
									
					var date:String = workout_stats.date;
					colored_circle.setText(date, workout_stats.value);
					Actuate.stop(colored_circle);
					
					//Actuate.tween(colored_circle, 1, { x:50 + i * width_interval, y:350 - height_interval * (workout_stats.value-min) / Math.max(max - min, 1) } );
					colored_circle.x = 50 + i * width_interval;
					colored_circle.y = 350 - height_interval * (workout_stats.value-min) / Math.max(max - min, 1);
					
					//trace(min);
					//trace((workout_stats.value-min) / Math.max(max - min, 1));
					
					//trace(date, workout_stats.value);
					//trace(colored_circle.x, colored_circle.y);
					
					if (i > 0)
					{
						previous_layers[index].graphics.lineStyle(1, 0xCCCCCC, 0.8);
					
						var y1:Float = previous_colored_circle.y;
						var y2:Float = colored_circle.y;
							
						if (y2 - y1 < -10)
						{
							previous_layers[index].graphics.lineStyle(1, Utils.combineRGB(125, 255, 125), 0.8);
						}
						
						previous_layers[index].graphics.moveTo(previous_colored_circle.x, previous_colored_circle.y);
						previous_layers[index].graphics.lineTo(colored_circle.x, colored_circle.y);
					}
					
					previous_colored_circle = colored_circle;
					
					if (colored_circle.parent == null) previous_layers[index].addChild(colored_circle);
					
					i++;
				}
			}
		}
		
		colored_points_manager2.hideUnusedPoints();
		
		moveToPoint();
		
		tf_info.textColor = Utils.adjustBrightness(GV.colors[GV.exercise_type-1], 50);
		
		tf_info.text = "You did " + Std.string(sum) + " " + GV.exercise_text[GV.exercise_type-1].toLowerCase();
		
		switch (GV.time_range)
		{
			case 1: tf_info.appendText(" today");
			case 2: tf_info.appendText(" in this week");
			case 3: tf_info.appendText(" in this month");
			case 4: tf_info.appendText(" in this year");
			case 5: tf_info.appendText(" during all the time");
		}
	}
	
	function showText(workout_stats_records:Array<WorkoutInfo>) 
	{
		if (workout_stats_records.length > 0)
		{
			tf_min.text = Std.string(min);
			tf_max.text = Std.string(max);
			tf_min.visible = true;
			tf_max.visible = true;
		}
		else
		{
			tf_min.visible = false;
			tf_max.visible = false;
		}
		
		if (workout_stats_records.length > 0)
		{
			var start_date:String = workout_stats_records[0].date;
			var end_date:String = workout_stats_records[workout_stats_records.length - 1].date;
			
			tf_start_date.text = start_date;
			tf_end_date.text = end_date;

			tf_start_date.visible = true;
			tf_end_date.visible = true;
		}
		else
		{
			tf_start_date.visible = false;
			tf_end_date.visible = false;
		}
	}
	
	private function getMinMax(workout_stats_records_array:Array<Array<WorkoutInfo>>)
	{
		min = 100000000;
		max = -1;
		
		for (workout_stats_records in workout_stats_records_array)
		{			
			for (workout_stats in workout_stats_records)
			{				
				min = Math.min(min, workout_stats.value);
				max = Math.max(max, workout_stats.value);
			}
		}
	}
	
	public function moveToPoint(n:Int=0):Void
	{
		var line:Sprite = null;
		
		if (n != 0)
		{
			line = new Sprite();
			lines.push(line);
			lines_layer.addChild(line);
		}		
		
		for (i in n...colored_points.length)
		{
			Actuate.stop(colored_points[i]);
			var tween = Actuate.tween(colored_points[i], 1, { x:target_coord_x[n], y:target_coord_y[n] } ).ease(Linear.easeNone);
			if (i == n) 
			{
				tween.onComplete(moveToPoint.bind(n+1));
				
				if (n != 0)
				{					
					tween.onUpdate(function ():Void
					{
						line.graphics.clear();
						line.graphics.lineStyle(1, 0xCCCCCC,0.8);
						
						if (colored_points[n - 1] == null || colored_points[n] == null)
						{
							Actuate.stop(colored_points[i]);
							return;
						}
						
						var y1:Float = colored_points[n - 1].y;
						var y2:Float = colored_points[n].y;
						
						if (y2 - y1 < -10)
						{
							line.graphics.lineStyle(1, Utils.combineRGB(125, 255, 125), 0.8);
						}
						
						line.graphics.moveTo(colored_points[n - 1].x, y1);
						line.graphics.lineTo(colored_points[n].x, y2);
					}
					);
				}
			}
		}
	}
	
	private function onClick(e:MouseEvent):Void 
	{
		if (input_field.visible)
		{
			input_field.hide();
		}
	}
	
	private function onActivate(e:Event):Void 
	{
		WorkoutData.init();
	}
	
	private function onDeactivate(e:Event):Void 
	{
		WorkoutData.close();
	}

	/* SETUP */

	public function new() 
	{
		super();	
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		stage.addEventListener(Event.RESIZE, resize);
		#if ios
		haxe.Timer.delay(init, 100); // iOS 6
		#else
		init();
		#end
	}
	
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Main());
	}
}
