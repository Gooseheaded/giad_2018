
#define ICON_WIDTH 30
#define ICON_HEIGHT 30

#define RED_SPICE "Red"
#define YELLOW_SPICE "Yellow"
#define BLUE_SPICE "Blue"
#define MAGENTA_SPICE "Magenta"
#define CYAN_SPICE "Cyan"
#define GREEN_SPICE "Green"
#define BLACK_SPICE "Black"

#define MAPTEXT_COLOR "<font color=black>"

#ifdef DEBUGPRINT
#define _DEBUGPRINT(text)  world.log<<text
#else
#define _DEBUGPRINT(text)
#endif


#define DIST(dx,dy) sqrt(dx*dx+dy*dy) //I also use this for vector lengths so DIST() may be a misnomer
#define DIST2(dx,dy) (dx*dx+dy*dy)

/*

'OceanAmbiance.ogg' by deleted_user_2731495 of Freesound.org

*/