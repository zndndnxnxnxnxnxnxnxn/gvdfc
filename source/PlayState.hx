package;

import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.math.FlxAngle;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
#if mobileC
import ui.Mobilecontrols;
#end
import AfterImages;

using StringTools;

class PlayState extends MusicBeatState
{	
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;
	private var SplashNote:NoteSplash;

	private var camFollow:FlxObject;
	
	var daSong:String = "";
	
	var accuracy:Float = 1;
	var hitNotes:Float = 0;
	var totalNotes:Float = 0;	
	var misses:Float = 0;
	private var floatshit:Float = 0;
	
	var grade:String = RatingSystem.gradeArray[0];

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var afterImageSprites:FlxTypedGroup<AfterImage>;
	public static var player2Strums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camNOTES:FlxCamera;
	private var camHUD:FlxCamera;
	private var camPAUSE:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	var noteSplashOp:Bool;
	var cutsceneOp:Bool;
	var middleScroll:Bool;	
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	
	var tank0:FlxSprite;
	var tank1:FlxSprite;
	var tank2:FlxSprite;
	var tank3:FlxSprite;
	var tank4:FlxSprite;
	var tank5:FlxSprite;
	var tankRolling:FlxSprite;
	var tankX = 400;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankWatchtower:FlxSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var picoStep:Ps;
	var tankStep:Ts;
	
	
	var blackFade:FlxSprite;
	var brokenPillar:FlxSprite;
	var sarvCirc1:FlxSprite;
	var sarvCirc2:FlxSprite;
	var selSign:FlxSprite;	

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var songName:FlxText;
	var songinfotxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;
	
	#if mobileC
	var mcontrols:Mobilecontrols; 
	#end

	override public function create()
	{		
		daSong = SONG.song.toLowerCase();
		RatingSystem.ghostTapping = FlxG.save.data.ghost;
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		grade = RatingSystem.gradeArray[0];
		misses=0;		
		accuracy = 1;
		
		camGame = new FlxCamera();
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		
		camNOTES = new FlxCamera();
		camNOTES.bgColor.alpha = 0;
		
		camPAUSE = new FlxCamera();
		camPAUSE.bgColor.alpha = 0;
		
		if (FlxG.save.data.downscroll)
			camNOTES.flashSprite.scaleY = -1;// Micd'Up

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camNOTES);		
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
			
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0;			
		grpNoteSplashes.add(sploosh);

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		switch (SONG.song.toLowerCase())
		{
			case 'parish':
			    dialogue = CoolUtil.coolTextFile(Paths.txt('parish/dialogue'));
			case 'worship':
			    dialogue = CoolUtil.coolTextFile(Paths.txt('worship/dialogue'));
			case 'zavodila':
			    dialogue = CoolUtil.coolTextFile(Paths.txt('zavodila/dialogue'));
		}

		switch (SONG.song.toLowerCase())
		{
                case 'parish' | 'worship':
					defaultCamZoom = .7;
					curStage = 'church';
					
					var floor:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church1/floor'));
					floor.antialiasing = true;
				    floor.scrollFactor.set(1, 1);
					floor.active = false;
					floor.setGraphicSize(Std.int(floor.width*1.3));
					add(floor);

					var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church1/bg'));
					bg.antialiasing = true;
					bg.scrollFactor.set(.8, .8);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width*1.3));
					add(bg);

					var fg:FlxSprite = new FlxSprite(-275, -800).loadGraphic(Paths.image('sacredmass/church1/pillars'));
					fg.antialiasing = true;
					fg.scrollFactor.set(1,1);
					fg.active = false;
					fg.setGraphicSize(Std.int(fg.width*1.25));
					add(fg);

					if(SONG.song.toLowerCase()=='worship')
					{
							fg.color = 0xBC93A8;
							bg.color = 0xBC93A8;
							floor.color = 0xBC93A8;
					}
				case 'casanova':
					defaultCamZoom = .7;
					curStage = 'foguChurch';
					
					var floor:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('selever/churchSelever/floor'));
					floor.antialiasing = true;
					floor.scrollFactor.set(1, 1);
					floor.active = false;
					floor.setGraphicSize(Std.int(floor.width*1.3));
					add(floor);

					var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('selever/churchSelever/bg'));
					bg.antialiasing = true;
					bg.scrollFactor.set(.8, .8);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width*1.3));
					add(bg);

					var fg:FlxSprite = new FlxSprite(-275, -800).loadGraphic(Paths.image('selever/churchSelever/pillars'));
					fg.antialiasing = true;
					fg.scrollFactor.set(1,1);
					fg.active = false;
					fg.setGraphicSize(Std.int(fg.width*1.25));
					add(fg);
					
					blackFade = new FlxSprite(-FlxG.width*FlxG.camera.zoom,-FlxG.height * FlxG.camera.zoom).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
					blackFade.scrollFactor.set();
					blackFade.active = false;
					blackFade.alpha=0;
					
					selSign = new FlxSprite(100, 100).loadGraphic(Paths.image('selever/circ'));
					selSign.active = false;
					selSign.alpha = 0;
					selSign.x -= 65;
					add(selSign);
				case 'gospel':
					defaultCamZoom = .7;
					curStage = 'churchSatan';
					
					var floor:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church3/floor'));
					floor.antialiasing = true;
					floor.scrollFactor.set(1, 1);
					floor.active = false;
					floor.setGraphicSize(Std.int(floor.width*1.3));
					add(floor);

				    var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church3/bg'));
					bg.antialiasing = true;
					bg.scrollFactor.set(1, 1);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width*1.3));
					add(bg);

					var fg:FlxSprite = new FlxSprite(-275, -800).loadGraphic(Paths.image('sacredmass/church3/pillars'));
				    fg.antialiasing = true;
					fg.scrollFactor.set(1,1);
					fg.active = false;
				    fg.setGraphicSize(Std.int(fg.width*1.3));
					add(fg);

					sarvCirc1 = new FlxSprite(-400, -650).loadGraphic(Paths.image('sacredmass/church3/circ1'));
					sarvCirc1.antialiasing = true;
					sarvCirc1.active = false;
				    sarvCirc1.setGraphicSize(Std.int(sarvCirc1.width*1.3));
					sarvCirc1.centerOrigin();
					sarvCirc1.origin.y = 655;
				    sarvCirc1.origin.x = 981;
					sarvCirc1.scrollFactor.set(.75, 1);
					add(sarvCirc1);

					sarvCirc2 = new FlxSprite(-400, -650).loadGraphic(Paths.image('sacredmass/church3/circ2'));
					sarvCirc2.antialiasing = true;
					sarvCirc2.active = false;
					sarvCirc2.setGraphicSize(Std.int(sarvCirc2.width*1.3));
					sarvCirc2.centerOrigin();
					sarvCirc2.origin.y = 655;
					sarvCirc2.origin.x = 981;
					sarvCirc2.scrollFactor.set(.75, 1);
					add(sarvCirc2);

					var sarvSign:FlxSprite = new FlxSprite(-400, -650).loadGraphic(Paths.image('sacredmass/church3/circ0'));
					sarvSign.antialiasing = true;
					sarvSign.scrollFactor.set(.8, 1);
					sarvSign.active = false;
					sarvSign.setGraphicSize(Std.int(sarvSign.width*1.3));
					add(sarvSign);

				case 'zavodila':
					defaultCamZoom = .7;
					curStage = 'churchRuv';
					
					var floor:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church2/floor'));
					floor.antialiasing = true;
					floor.scrollFactor.set(1, 1);
					floor.active = false;
					floor.setGraphicSize(Std.int(floor.width*1.3));
				    add(floor);

					var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church2/bg'));
					bg.antialiasing = true;
					bg.scrollFactor.set(.8, .8);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width*1.3));
					add(bg);

					var fg:FlxSprite = new FlxSprite(-275, -800).loadGraphic(Paths.image('sacredmass/church2/pillars'));
					fg.antialiasing = true;
					fg.scrollFactor.set(1,1);
					fg.active = false;
					fg.setGraphicSize(Std.int(fg.width*1.25));
					add(fg);

				    brokenPillar = new FlxSprite(-325, -750).loadGraphic(Paths.image('sacredmass/church2/pillarbroke'));
					brokenPillar.antialiasing = true;
					brokenPillar.scrollFactor.set(1, 1);
					brokenPillar.active = false;
					brokenPillar.setGraphicSize(Std.int(bg.width*1.35));

					blackFade = new FlxSprite(-FlxG.width*FlxG.camera.zoom,-FlxG.height * FlxG.camera.zoom).makeGraphic(Std.int(FlxG.width * 3), Std.int(FlxG.height * 3), FlxColor.BLACK);
					blackFade.scrollFactor.set();
					blackFade.active = false;
					blackFade.alpha=0;
		        default:
		            defaultCamZoom = .9;
		            curStage = 'stage';
		            var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback'));
		            bg.antialiasing = true;
		            bg.scrollFactor.set(0.9, 0.9);
		            bg.active = false;
		            add(bg);

		            var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		            stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		            stageFront.updateHitbox();
		            stageFront.antialiasing = true;
		            stageFront.scrollFactor.set(0.9, 0.9);
		            stageFront.active = false;
		            add(stageFront);

		            var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		            stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		            stageCurtains.updateHitbox();
		            stageCurtains.antialiasing = true;
		            stageCurtains.scrollFactor.set(1.3, 1.3);
		            stageCurtains.active = false;

		            add(stageCurtains);
        }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tankStage':
			    gfVersion = 'gf-tankmen';
			case 'tankStage2':
			    gfVersion = 'picoSpeaker';				
		}

		if (curStage == 'limo')
			gfVersion = 'gf-car';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		
		afterImageSprites = new FlxTypedGroup<AfterImage>();

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'tankman':	
				dad.y += 180;
			case 'sarvente-lucifer':
				dad.x -= 75;
				dad.y -= 400;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tankStage':
				gf.y += -55;
				gf.x -= 200;

				boyfriend.x += 40;
				dad.y += 60;
				dad.x -= 80;
			case 'tankStage2':
				//gf.y += 10;
				//gf.x -= 30;
				gf.y += -155;
				gf.x -= 90;

				boyfriend.x += 40;
				dad.y += 60;
				dad.x -= 80;
			case 'church' | 'churchRuv' | 'foguChurch':
				gf.y -= 55;
				gf.x -= 165;
				dad.x -= 75;
				boyfriend.x += 75;
				boyfriend.y += 25;
				gf.scrollFactor.set(1,1);
			case 'churchSatan':
				gf.y -= 55;
				gf.x -= 165;
				boyfriend.x += 75;
				boyfriend.y += 25;
				gf.scrollFactor.set(1,1);	
		}

		add(gf);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);
			
		if(curStage=='churchRuv'){
			add(brokenPillar);
			add(blackFade);
		}
		
		if(curStage=='foguChurch')
		{
			add(blackFade);
			add(selSign);			
		}		

		add(afterImageSprites);

		add(dad);
		add(boyfriend);
		
		if (curStage == 'tankStage' || curStage == 'tankStage2')
		{
			add(tank0);
			add(tank1);
			add(tank2);
			add(tank4);
			add(tank5);
			add(tank3);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);
		
		noteSplashOp = FlxG.save.data.notesplash;
		cutsceneOp = FlxG.save.data.cutscenes;
		middleScroll = FlxG.save.data.middle;

		playerStrums = new FlxTypedGroup<FlxSprite>();
		player2Strums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (FlxG.save.data.downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);
		
		songinfotxt = new FlxText(4,healthBarBG.y + 50,0,SONG.song + " " + (storyDifficulty == 3 ? "Alt" : storyDifficulty == 2 ? "Hard" : storyDifficulty == 1 ? "Normal" : "Easy"), 16);
		songinfotxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		songinfotxt.scrollFactor.set();
		add(songinfotxt);

		if (FlxG.save.data.downscroll)
			songinfotxt.y = FlxG.height * 0.9 + 45;
		
		if (FlxG.save.data.songtext)
		{
		    songinfotxt.alpha = 0;
		}
		
		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 50, 0, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		add(scoreTxt);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		strumLineNotes.cameras = [camNOTES];
		grpNoteSplashes.cameras = [camNOTES];
		notes.cameras = [camNOTES];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		songinfotxt.cameras = [camHUD];
		#if mobileC
			mcontrols = new Mobilecontrols();
			switch (mcontrols.mode)
			{
				case VIRTUALPAD_RIGHT | VIRTUALPAD_LEFT | VIRTUALPAD_CUSTOM:
					controls.setVirtualPad(mcontrols._virtualPad, FULL, NONE);
				case HITBOX:
					controls.setHitBox(mcontrols._hitbox);
				default:
			}
			trackedinputs = controls.trackedinputs;
			controls.trackedinputs = [];

			var camcontrol = new FlxCamera();
			FlxG.cameras.add(camcontrol);
			camcontrol.bgColor.alpha = 0;
			mcontrols.cameras = [camcontrol];

			mcontrols.visible = false;

			add(mcontrols);
		#end

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
            switch (curSong.toLowerCase())
			{
			    case 'parish':
                    parishIntro();				
                case 'worship':
					startCutscene(doof);
				case 'zavodila':
					zavodilaIntro();	
				case 'gospel':
                    zavodilaEnding();	
				case 'casanova':
                    casanovaIntro();	
				default:
					startCountdown();
			}
		}
		else
		{
            switch (curSong.toLowerCase())
			{
                case 'parish' | 'worship' | 'gospel' | 'zavodila' | 'casanova':
				    camHUD.visible = false;
					camNOTES.visible = false;					
				
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						camFollow.y = -400;
						camFollow.x = 600;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});	
				default:
					startCountdown();
			}
		}

		super.create();
	}	
	
	function startCutscene(dialogueBox:DialogueBox)
	{

		if (dialogueBox != null)
		{		
			inCutscene = true;			
			add(dialogueBox);
		} 
		else
		{	
			startCountdown();
		}
	}
	
	function parishIntro()
	{		
		inCutscene = true;	
		
		FlxG.sound.playMusic(Paths.music('parish_intro', 'shared'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);
			
		var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church1/base'));
		bg.scrollFactor.set(.9, .9);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width*1.3));
		add(bg);
		
		var sarvCall:FlxSprite = new FlxSprite(100, 100);
		sarvCall.frames = Paths.getSparrowAtlas('sacredmass/nokiaPhoneCall');
		sarvCall.animation.addByPrefix('play1', 'Anim-Lol', 24, false);
		sarvCall.animation.play('play1', true);		
		sarvCall.x -= 75;
		add(sarvCall);	

		camFollow.setPosition(sarvCall.getMidpoint().x + 150, sarvCall.getMidpoint().y - 100);
		sarvCall.animation.play('play1');
		
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('parish/firstdialogue')));
		doof.finishThing = function()
		{
			FlxG.sound.play(Paths.sound('Nokia Beep', 'shared'));	
		    FlxG.sound.music.stop();
			remove(sarvCall);			
			remove(bg);		
		    churchIntro1();
		}
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
		
	}
	
	function zavodilaIntro()
	{		
		inCutscene = true;	
		
		var bg:FlxSprite = new FlxSprite(-400, -750).loadGraphic(Paths.image('sacredmass/church2/base'));
		bg.scrollFactor.set(.9, .9);
		bg.active = false;
		bg.setGraphicSize(Std.int(bg.width*1.3));
		add(bg);
		
		var ruvAlone:FlxSprite = new FlxSprite(700, 200).loadGraphic(Paths.image('sacredmass/he likes to be alone'));	
		add(ruvAlone);
		
		var sarvTired:FlxSprite = new FlxSprite(100, 100);
		sarvTired.frames = Paths.getSparrowAtlas('sacredmass/theseknees');
		sarvTired.animation.addByPrefix('play', 'TiredSarv', 24, true);
		sarvTired.animation.play('play');		
		sarvTired.x -= 200;
		add(sarvTired);	

		camFollow.setPosition(sarvTired.getMidpoint().x + 150, sarvTired.getMidpoint().y - 100);
		
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('zavodila/firstdialogue')));
		doof.finishThing = function()
		{
			remove(ruvAlone);		
			remove(sarvTired);			
			remove(bg);		
		    churchIntro3();
		}
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
		
	}
					
	function zavodilaEnding()
	{	
		inCutscene = true;	

		var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.scrollFactor.set(0);
		black.setGraphicSize(Std.int(black.width * 4));
	    black.screenCenter(X);
		add(black);
	    var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('zavodila/dialogueEnd')));
		doof.finishThing = function()
		{
			remove(black);		
            gospelIntro();	
		}
	    doof.cameras = [camHUD];
	    doof.scrollFactor.set();
	    thecutscene(doof);
	}
	
	function thecutscene(dialogueBox:DialogueBox)
	{
		if (dialogueBox != null)
		{		
			inCutscene = true;		
			add(dialogueBox);
		} 
		else
		{	
			startCountdown();
		}
	}
	
	function casanovaIntro()
	{		
		inCutscene = true;	
			
	    var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.scrollFactor.set(0);
		black.setGraphicSize(Std.int(black.width * 4));
	    black.screenCenter(X);
		add(black);
			
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('casanova/firstdialogue')));
		doof.finishThing = function()
		{
			remove(black);		
		    churchIntro2();
		}
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
		
	}
	
	function churchIntro2()
	{		
		inCutscene = true;
		
		camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('casanova/dialogue')));
		doof.finishThing = startCountdown;
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
	}
	
	function churchIntro1()
	{		
		inCutscene = true;
		
		camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('parish/dialogue')));
		doof.finishThing = startCountdown;
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
	}
	
	function churchIntro3()
	{		
		inCutscene = true;
		
		camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('zavodila/dialogue')));
		doof.finishThing = startCountdown;
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
	}
	
	function churchIntro4()
	{		
		inCutscene = true;
		
		camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			
		var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('zavodila/dialogue')));
		doof.finishThing = startCountdown;
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		thecutscene(doof);
	}	
	
	function gospelIntro():Void
	{
		inCutscene = true;
		
		var red:FlxSprite = new FlxSprite(-400, -750).makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(245, 66, 155));
		red.scrollFactor.set(0);
		red.setGraphicSize(Std.int(red.width * 4));
	    red.screenCenter(X);

		var senpaiEvil:FlxSprite = new FlxSprite(-75, -400);
		senpaiEvil.frames = FlxAtlasFrames.fromTexturePackerXml(Paths.getPath("images/sacredmass/pegMePlease.png", IMAGE, 'shared'), Paths.getPath("images/sacredmass/pegMePlease.xml", TEXT, 'shared'));
		senpaiEvil.animation.addByPrefix('idle', 'SarvTransAnim', 24, false);

		add(red);	
		add(senpaiEvil);	
		
		camFollow.setPosition(senpaiEvil.getMidpoint().x + 150, senpaiEvil.getMidpoint().y - 100);
		
		senpaiEvil.animation.play('idle');		
		FlxG.sound.play(Paths.sound('sarvTransform', 'shared'), 1, false, null, true, function()
		{		
			remove(senpaiEvil);
			remove(red);
			FlxG.camera.fade(FlxColor.WHITE, 5, true, function()
			{
				var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('gospel/dialogue')));
		        doof.finishThing = startCountdown;
		        doof.cameras = [camHUD];
		        doof.scrollFactor.set();
		        startCutscene(doof);
			}, true);
		});				
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		#if mobileC
		mcontrols.visible = true;
		#end
		camHUD.visible = true;	
		camNOTES.visible = true;	
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3'), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2'), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1'), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo'), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else {}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			
			if(middleScroll && player == 0)
				babyArrow.visible=false;

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}
				case 'churchSatan':
					babyArrow.frames = Paths.getSparrowAtlas('sacredmass/NOTE_assets', 'shared');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}
			
			if (FlxG.save.data.downscroll)
				babyArrow.flipY = true;

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;
			
			switch (player)
			{
				case 0:
					player2Strums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			
			if (middleScroll)
				babyArrow.x -= 275;
			
			player2Strums.forEach(function(spr:FlxSprite)
			{					
				spr.centerOffsets();
			});

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}
	
	function updateAccuracy():Void
	{
		if(totalNotes == 0)
			accuracy = 1;
		else
			accuracy = hitNotes / totalNotes;

		grade = RatingSystem.AccuracyToGrade(accuracy);
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	
	function truncateFloat( number : Float, precision : Int): Float 
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}
	
	var timer:Float=0;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		afterImageSprites.update(elapsed);
		afterImageSprites.forEachDead( function(image:AfterImage)
		{
			afterImageSprites.remove(image,true);
		});

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			case 'tankStage':
				moveTank();
			case 'tankStage2':
				moveTank();
		}

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore + " | Accuracy:" + truncateFloat(accuracy*100, 2) + "% | " + grade;

		if (FlxG.keys.justPressed.ENTER #if android || FlxG.android.justReleased.BACK #end && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));
		}

		if (FlxG.keys.justPressed.ZERO)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

				switch (dad.curCharacter)
				{
					case 'mom':
						camFollow.y = dad.getMidpoint().y;
					case 'senpai':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
				}

				if (dad.curCharacter == 'mom')
					vocals.volume = 1;

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{			
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
				
				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'church' | 'churchRuv' | 'churchSatan' | 'foguChurch':
					    camFollow.x = boyfriend.getMidpoint().x - 100;
						camFollow.y = boyfriend.getMidpoint().y - 150;
				}

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
			camNOTES.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}
		
        if (FlxG.save.data.practice)
		{
		    if (health <= 0)
		    {
			    boyfriend.stunned = true;

			    persistentUpdate = false;
			    persistentDraw = false;
			    paused = true;

			    vocals.stop();
			    FlxG.sound.music.stop();

			    openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		    }
	    }

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{	
			notes.forEachAlive(function(daNote:Note)
			{	
				daNote.cameras = [camNOTES];
				
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}				

				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));

				// i am so fucking sorry for this if condition
				if (daNote.isSustainNote
					&& daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2
					&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
				{
					var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
					swagRect.y /= daNote.scale.y;
					swagRect.height -= swagRect.y;

					daNote.clipRect = swagRect;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}
					
					if(curStage=='churchSatan')
					{
						sarvCirc2.angle += 5;
						sarvCirc1.angle += 5;
					}
					
					if(curStage=='foguChurch')
					{
						selSign.angle += 5;
					}					

					var afterImage = new AfterImage(dad);
					afterImage.y += FlxG.random.int(-25,25);
					afterImage.x += FlxG.random.float(-15,15)+15;

					afterImage.velocity.x = FlxG.random.float(-25,25)*6;
					afterImage.acceleration.x = -afterImage.velocity.x/1.5;
					afterImageSprites.add(afterImage);
					
					if (FlxG.save.data.noteglow)
					{
						player2Strums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm', true);
							}
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 13;
								spr.offset.y -= 13;
							}
							else
								spr.centerOffsets();
						});
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						totalNotes++;
						vocals.volume = 0;
						updateAccuracy();
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		
		if (FlxG.save.data.noteglow)
		{
			player2Strums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function endSong():Void
	{		
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		#if mobileC
		mcontrols.visible = false;
		#end
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

	    if (isStoryMode)
	    {
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

		    if (storyPlaylist.length <= 0)
		    {
				//FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

					if (SONG.song.toLowerCase() == 'casanova')
				    {
					    vocals.pause();
					    Conductor.songPosition = 0;
					    paused = true;
						
					    var black:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		                black.scrollFactor.set(0);
						black.setGraphicSize(Std.int(black.width * 4));
						black.screenCenter(X);
		                add(black);
						
					    var doof = new DialogueBox(false, CoolUtil.coolTextFile(Paths.txt('casanova/dialogueEnd')));
					    doof.finishThing = runTheThing;
					    doof.cameras = [camHUD];
					    doof.scrollFactor.set();
					    startCutscene(doof);
				    }
				    else
					{
					    FlxG.sound.playMusic(Paths.music('freakyMenu'));
     					FlxG.switchState(new StoryMenuState());
					}

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					//NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
		    }
		    else
		    {
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';
					
				if (storyDifficulty == 3)
					difficulty = '-alt';				

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;
					camNOTES.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				
				#if desktop
				if (FlxG.save.data.cutscenes)
			    {   
				    if (daSong == 'ugh')
				    {
					    var video:MP4Handler = new MP4Handler();
                        video.playMP4(Paths.video('gunsCutscene'), new PlayState(), false, false, false);
				    }
				    else if (daSong == 'guns')
				    {
					    var video:MP4Handler = new MP4Handler();
                        video.playMP4(Paths.video('stressCutscene'), new PlayState(), false, false, false);
				    }			
                    else
			            LoadingState.loadAndSwitchState(new PlayState());
			    }
				else
				{
			        LoadingState.loadAndSwitchState(new PlayState());
				}
				#else
				LoadingState.loadAndSwitchState(new PlayState());
				#end
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		
		totalNotes++;
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
		}
		
		if (daRating == "sick")
		{
		    if (noteSplashOp)
		    {
			    var recycledNote = grpNoteSplashes.recycle(NoteSplash);
			    recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			    grpNoteSplashes.add(recycledNote);
		    }
		}

        hitNotes += RatingSystem.RatingToHit(daRating);
		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		if(FlxG.save.data.ratingInHUD){
			var ratingCameras = [camHUD];
			rating.scrollFactor.set(0,0);
			rating.x -= 175;
			rating.cameras = ratingCameras;
		}

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			
			if(FlxG.save.data.ratingInHUD){
			    var numScoreCameras = [camHUD];
					numScore.scrollFactor.set(0,0);
					numScore.cameras = numScoreCameras;
			}

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

        updateAccuracy();
		curSection += 1;
	}

	private function keyShit():Void // I've invested in emma stocks
	{	
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
			var pressArray:Array<Bool> = [
				controls.LEFT_P,
				controls.DOWN_P,
				controls.UP_P,
				controls.RIGHT_P
			];
			var releaseArray:Array<Bool> = [
				controls.LEFT_R,
				controls.DOWN_R,
				controls.UP_R,
				controls.RIGHT_R
			];

			// HOLDS, check for sustain notes
			if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData])
						goodNoteHit(daNote);
				});
			}
	 
			// PRESSES, check for note hits
			if (pressArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
			{
				boyfriend.holdTimer = 0;
	 
				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false,false,false,false]; // we don't want to do judgments for more than one presses
				
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					{
						if (!directionsAccounted[daNote.noteData])
						{
							if (directionList.contains(daNote.noteData))
							{
								directionsAccounted[daNote.noteData] = true;
								for (coolNote in possibleNotes)
								{
									if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
									{ // if it's the same note twice at < 10ms distance, just delete it
										// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
										dumbNotes.push(daNote);
										break;
									}
									else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
									{ // if daNote is earlier than existing note (coolNote), replace
										possibleNotes.remove(coolNote);
										possibleNotes.push(daNote);
										break;
									}
								}
							}
							else
							{
								possibleNotes.push(daNote);
								directionList.push(daNote.noteData);
							}
						}
					}
				});	 
				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
	 
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	 
				var dontCheck = false;

                if (perfectMode)
						goodNoteHit(possibleNotes[0]);
					else if (possibleNotes.length > 0 && !dontCheck)
					{
						if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								{ // if a direction is hit that shouldn't be
									if (pressArray[shit] && !directionList.contains(shit))
										noteMiss(shit, null);
								}
						}
						for (coolNote in possibleNotes)
						{
							if (pressArray[coolNote.noteData])
							{
								scoreTxt.color = FlxColor.WHITE;
								goodNoteHit(coolNote);
							}
						}
					}
					else if (!FlxG.save.data.ghost)
						{
							for (shit in 0...pressArray.length)
								if (pressArray[shit])
									noteMiss(shit, null);
						}
			}
			
			if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					boyfriend.playAnim('idle');
			}
	 
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if ((pressArray[spr.ID]) && spr.animation.curAnim.name != 'confirm')
					spr.animation.play('pressed');
				if (!holdArray[spr.ID])
					spr.animation.play('static');
	 
				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			misses++;
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;
			
            if (FlxG.save.data.practice)
			{
			    FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			}		

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
			
			updateAccuracy();
		}
	}

	/*function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0, daNote:Note);
		if (downP)
			noteMiss(1, daNote:Note);
		if (upP)
			noteMiss(2, daNote:Note);
		if (rightP)
			noteMiss(3, daNote:Note);
	}*/

	function noteCheck(controlArray:Array<Bool>, note:Note):Void
	{			
			if (controlArray[note.noteData])
			{
				goodNoteHit(note);
				
				/*if (mashing > getKeyPresses(note) && mashViolations <= 2)
				{
					mashViolations++;

					goodNoteHit(note, (mashing > getKeyPresses(note)));
				}
				else if (mashViolations > 2)
				{
					// this is bad but fuck you
					playerStrums.members[0].animation.play('static');
					playerStrums.members[1].animation.play('static');
					playerStrums.members[2].animation.play('static');
					playerStrums.members[3].animation.play('static');
					health -= 0.4;
					trace('mash ' + mashing);
					if (mashing != 0)
						mashing = 0;
				}
				else
					goodNoteHit(note, false);*/

			}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}
			else 
			{		
			    hitNotes++;
			   totalNotes++;
		    }

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}
			
			var afterImage = new AfterImage(boyfriend);
			afterImage.y += FlxG.random.int(-25,25);
			afterImage.x -= 15;
			afterImage.velocity.x = FlxG.random.float(-25,25)*6;
			afterImage.acceleration.x = -afterImage.velocity.x/1.5;
			afterImageSprites.add(afterImage);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			
			updateAccuracy();
		}
	}
	
	function runTheThing():Void
	{
	    FlxG.sound.playMusic(Paths.music('freakyMenu'));
		FlxG.switchState(new StoryMenuState());
	}
	
	public function CutsceneStart()
	{
		LoadingState.loadAndSwitchState(new PlayState());
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}
		
		switch(SONG.song.toLowerCase())
		{
			case'zavodila':
				if(curStep==112 || curStep==912)
				{
					FlxTween.tween(blackFade,{alpha:.85},1.5,{
						ease: FlxEase.linear
					});
				}else if(curStep==128 || curStep==928)
				{
					FlxTween.tween(blackFade,{alpha:0},.1,{
						ease: FlxEase.linear
					});
				}
			case'casanova':
				if(curStep == 1)
				{
				    blackFade.alpha = 0.6;
					dad.playAnim('hey', true);
					FlxTween.tween(selSign, {alpha: 0.6}, 0.2, {ease: FlxEase.circOut});				
					FlxTween.tween(blackFade, {alpha: 0}, 1, {ease: FlxEase.circOut});	
					FlxTween.tween(selSign, {alpha: 0}, 6.0, {ease: FlxEase.circOut});
				}
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
		
		if (dad.curCharacter == 'tankman' && SONG.song.toLowerCase() == 'stress')
		{
			if (curStep == 735)
			{
				dad.addOffset("singDOWN", 45, 20);
				dad.animation.getByName('singDOWN').frames = dad.animation.getByName('prettyGoodAnim').frames;
				dad.playAnim('prettyGoodAnim', true);
			}

			if (curStep == 736 || curStep == 737)
			{
				
				dad.playAnim('prettyGoodAnim', true);
			}

			if (curStep == 767)
			{
				dad.addOffset("singDOWN", 98, -90);
				dad.animation.getByName('singDOWN').frames = dad.animation.getByName('oldSingDOWN').frames;
			}
		}
		
		if(SONG.song.toLowerCase() == 'stress')
		{
			//RIGHT
			for(i in 0...picoStep.right.length)
			{
				if (curStep == picoStep.right[i])
				{
					gf.playAnim('shoot' + FlxG.random.int(1, 2), true);
					//var tankmanRunner:TankmenBG = new TankmenBG();
				}
			}
			//LEFT
			for(i in 0...picoStep.left.length)
			{
				if (curStep == picoStep.left[i])
				{
					gf.playAnim('shoot' + FlxG.random.int(3, 4), true);
				}
			}
			//Left tankspawn
			for (i in 0...tankStep.left.length)
			{
				if (curStep == tankStep.left[i]){
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(630, 730) * -1, 255, true, 1, 1.5);

					tankmanRun.add(tankmanRunner);
				}
			}

			//Right spawn
			for(i in 0...tankStep.right.length)
			{
				if (curStep == tankStep.right[i]){
					var tankmanRunner:TankmenBG = new TankmenBG();
					tankmanRunner.resetShit(FlxG.random.int(1500, 1700) * 1, 275, false, 1, 1.5);
					tankmanRun.add(tankmanRunner);
				}
			}
		}

		if (dad.curCharacter == 'tankman' && SONG.song.toLowerCase() == 'ugh')
		{
			
			if (curStep == 59 || curStep == 443 || curStep == 523 || curStep == 827) // -1
			{
				dad.addOffset("singUP", 45, 0);
				
				dad.animation.getByName('singUP').frames = dad.animation.getByName('ughAnim').frames;
			}

			if (curStep == 64 || curStep == 448 || curStep == 528 || curStep == 832) // +4
			{
				dad.addOffset("singUP", 24, 56);
				dad.animation.getByName('singUP').frames = dad.animation.getByName('oldSingUP').frames;
			}
		
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}	

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camNOTES.zoom += 0.03;
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
			camNOTES.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}
		
		if (dad.curCharacter == 'ruv' && dad.animation.curAnim.name.startsWith('sing'))
		{
			FlxG.camera.shake(0.01, 0.1);		
            gf.playAnim('scared', true);
		}
		
		if (boyfriend.animation.curAnim.name.startsWith('sing') || boyfriend.animation.curAnim.name == 'idle')
		{
			switch(curSong)
			{
				case 'Parish':
				{
					if(curBeat > 48 && curBeat != 64 && curBeat != 96 && curBeat != 128 && curBeat != 160 && curBeat < 176)
					{
						if(curBeat % 16 == 15)
						{
						   boyfriend.playAnim('hey');
						}
					}
				}
			}
		}
		
		if (curBeat % 16 == 15 && SONG.song == 'Parish' && dad.curCharacter == 'sarvente' && curBeat > 32 && curBeat != 48 && curBeat != 80 && curBeat != 112 && curBeat != 144 && curBeat < 160)
		{
			dad.playAnim('hey', true);
		}	

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "tankStage2":
			if(curBeat % 2 == 0)
			{
				tankWatchtower.animation.play('idle', true);
				tank0.animation.play('idle', true);
				tank1.animation.play('idle', true);
				tank2.animation.play('idle', true);
				tank3.animation.play('idle', true);
				tank4.animation.play('idle', true);
				tank5.animation.play('idle', true);
			}
			case "tankStage":		
			if(curBeat % 2 == 0)
			{
				tankWatchtower.animation.play('idle', true);
				tank0.animation.play('idle', true);
				tank1.animation.play('idle', true);
				tank2.animation.play('idle', true);
				tank3.animation.play('idle', true);
				tank4.animation.play('idle', true);
				tank5.animation.play('idle', true);
			}
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}
	
	function moveTank()
	{
		tankAngle += FlxG.elapsed * tankSpeed;
		tankRolling.angle = tankAngle - 90 + 15;
		tankRolling.x = tankX + 1500 * FlxMath.fastCos(FlxAngle.asRadians(tankAngle + 180));
		tankRolling.y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(tankAngle + 180));
	}

	function again()
	{
		tankRolling.x = 300;
		tankRolling.y = 300;
		moveTank();
	}

	var curLight:Int = 0;
}

typedef Ps = 
{
	var right:Array<Int>;
	var left:Array<Int>;
}

//tank spawns
typedef Ts = 
{
	var right:Array<Int>;
	var left:Array<Int>;
}