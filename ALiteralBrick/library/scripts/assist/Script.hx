// API Script for Template Assist

// Set up same states as AssistStats (by excluding "var", these variables will be accessible on timeline scripts!)
STATE_INTRO = 0;
STATE_OUTRO = 1;
STATE_IDLE = 2;
STATE_AIRBORNE = 3;

var SPAWN_X_DISTANCE = -5; // How far in front of player to spawn
var SPAWN_HEIGHT = 20; // How high up from player to spawn
var LIFE_TIMER = 60 * 10; // max life of projectile

//Collision rebound variables
var FLOOR_REBOUND_MULT = -0.6;
var WALL_REBOUND_MULT = -0.6;
var HIT_Y_REBOUND_SET = -14;
var HIT_X_REBOUND_ADD = -1;

//Speed thresholds for airborne animations
var THROW_SPEED_REQ = 4;
var FALL_SPEED_REQ = 10;

//initial velocity of the projectile when spawned
var LAUNCH_X = 12;
var LAUNCH_Y = -10;

//variables that change
var life = self.makeInt(LIFE_TIMER);
var lastYSpeed = 0;
var lastXSpeed = 0;
var isRebounding = false;
var firstThrow = true;

// Runs on object init
function initialize()
{
	self.addEventListener(EntityEvent.COLLIDE_WALL, onWallHit, { persistent: true });
	self.addEventListener(EntityEvent.COLLIDE_FLOOR, onFloorHit, { persistent: true });
	self.addEventListener(GameObjectEvent.HIT_DEALT, onHit, { persistent: true });
	// Face the same direction as the user
	if (self.getOwner().isFacingLeft())
	{
		self.faceLeft();
	}

	Common.startFadeIn();

	// Reposition relative to the user
	Common.repositionToEntityEcb(self.getOwner(), self.flipX(SPAWN_X_DISTANCE), -SPAWN_HEIGHT);

	self.setXSpeed(LAUNCH_X);
	self.setYSpeed(LAUNCH_Y);
	self.playAnimation("thrown");
}

function onWallHit(event)
{
	self.setXSpeed(self.getXSpeed() * WALL_REBOUND_MULT);
	self.flip();
	firstThrow = false;
}

function onFloorHit(event)
{
	firstThrow = false;
	if (lastYSpeed > 6)
	{
		self.unattachFromFloor();
		self.setYSpeed(lastYSpeed * FLOOR_REBOUND_MULT);
	}
	else
	{
		self.toState(STATE_IDLE);
	}
}

function onHit(event)
{
	self.setYSpeed(HIT_Y_REBOUND_SET);
	self.setXSpeed(lastXSpeed * WALL_REBOUND_MULT + HIT_X_REBOUND_ADD);
	isRebounding = true;
	firstThrow = false;
	playAnimWithFrame("rebound");
}

function update()
{
	if (self.inState(STATE_OUTRO))
	{
		if (Common.fadeOutComplete())
		{
			self.destroy();
		}
	}
	else
	{
		lastYSpeed = self.getYSpeed();
		lastXSpeed = self.getXSpeed();
		life.dec();
		if (life.get() <= 0)
		{
			Common.startFadeOut();
			self.toState(STATE_OUTRO);
		}
		else
		{
			if (self.inState(STATE_IDLE))
			{
				if (self.isOnFloor() == false)
				{
					self.toState(STATE_AIRBORNE);
				}
				else
				{
					firstThrow = false;
				}
			}
			else
			{
				updateAirboneState();
			}
		}
	}
}

function updateAirboneState()
{
	var effXSpeed = lastXSpeed;
	if (effXSpeed < 0)
	{
		effXSpeed *= -1;
	}
	if (lastYSpeed > FALL_SPEED_REQ && effXSpeed < lastYSpeed)
	{
		playAnimWithFrame("fall");
		isRebounding = false;
		return;
	}
	if (firstThrow)
	{
		if (effXSpeed > THROW_SPEED_REQ)
		{
			playAnimWithFrame("thrown");
			return;
		}
	}
	playAnimWithFrame("rebound");
}

function playAnimWithFrame(anim)
{
	var currentAnim = self.getAnimation();
	if (currentAnim != anim)
	{
		var frame = self.getCurrentFrame();
		self.playAnimation(anim);
		self.playFrame(frame);
	}
}

function onTeardown()
{
}
