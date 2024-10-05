package;

import openfl.display.GraphicsEndFill;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
#if mobileC
import ui.FlxVirtualPad;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	#if mobileC
	var _pad:FlxVirtualPad;
	#end

	override function create()
	{

		Config.reload();
	
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.25));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.25));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

	/*	for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 20 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
		}
		*/
		for (i in 0...optionShit.length)
			{
				var menuItem:FlxSprite = new FlxSprite(0, 10 + (i * 140));
				menuItem.frames = tex;
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.scrollFactor.set();
				menuItem.antialiasing = true;
				menuItems.add(menuItem);
				if (menuItem.ID == 4)
					menuItem.y -= 30;
				

				menuItem.x -= 500;
				menuItem.alpha = 0;

				FlxTween.tween(menuItem, {alpha: 1, x: menuItem.x + 500}, 0.7, {startDelay: 0.3 * i, ease: FlxEase.smoothStepOut});
				
			}
		FlxG.camera.follow(camFollow, null, 0.012);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		//AtlasFrameMaker.renderTest('assets/images/TEST', "Idle");

	

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if mobileC
		_pad = new FlxVirtualPad(UP_DOWN, A_B);
		_pad.alpha = 0.75;
		this.add(_pad);
		#end

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			#if mobileC
			var UP_P = _pad.buttonUp.justPressed;
			var DOWN_P = _pad.buttonDown.justPressed;
			var BACK = _pad.buttonB.justPressed #if android || FlxG.android.justReleased.BACK #end;
			var ACCEPT = _pad.buttonA.justPressed;
			#end

			if (controls.UP_P #if mobileC || UP_P #end)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.DOWN_P #if mobileC || DOWN_P #end)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK #if mobileC || BACK #end)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT #if mobileC || ACCEPT #end)
			{
				if (optionShit[curSelected] == 'donate')
				{
					
					FlxG.openURL('http://paypal.me/kolsan8');
				
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(optionShit[curSelected] == "options")
						FlxG.sound.music.stop();

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0, x : -500}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										FlxG.sound.music.stop();
										FlxG.switchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										FlxG.switchState(new FreeplayState());

										trace("Freeplay Menu Selected");

									case 'options':
										//FlxTransitionableState.skipNextTransIn = true;
										//FlxTransitionableState.skipNextTransOut = true;
										FlxG.switchState(new ConfigMenu());
										ConfigMenu.ingame = false;
									case 'gallery':
										FlxG.switchState(new Gallery());
										FlxG.sound.music.fadeOut(1,0);
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
