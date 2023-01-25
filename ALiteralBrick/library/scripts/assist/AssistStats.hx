// Assist stats for Template Assist

// Define some states for our state machine
STATE_INTRO = 0;
STATE_OUTRO = 1;
STATE_IDLE = 2;
STATE_AIRBORNE = 3;

{
	spriteContent: self.getResource().getContent("aliteralbrick"),
	initialState: STATE_AIRBORNE,
	stateTransitionMapOverrides: [
		STATE_INTRO => {
			animation: "intro"
		},
		STATE_OUTRO => {
			animation: "outro"
		},
		STATE_IDLE => {
			animation: "idle"
		},
		STATE_AIRBORNE => {
			animation: "rebound"
		}
		
	],
	gravity: 0.9,
	friction: 0.2,
	groundSpeedCap: 22,
	aerialSpeedCap: 22,
	aerialFriction: 0.15,
	terminalVelocity: 20,
	assistChargeValue: 75
}
