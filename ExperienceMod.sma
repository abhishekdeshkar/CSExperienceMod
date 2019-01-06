#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <csx>
#include <fun>
#include <hamsandwich>
#include <nvault>  
#include <fakemeta_util>
#include <nvault_util> 

#pragma tabsize 0
#define MAX_PLAYERS	32
#define MAXLEVELS 20
#define nvault_clear(%1) nvault_prune(%1, 0, get_systime() + 1) 

#define PLUGIN "Advanced XP System"
#define VERSION "1.6"
#define AUTHOR "Abhishek Deshkar ||ECS||nUy"

#define ACCESS_LEVEL ADMIN_IMMUNITY
#define ADMIN_LISTEN ADMIN_LEVEL_C

// XP shop --> No Clip declaration
const TASK_NOCLIP_ID = 888

// XP Shop --> Speed Declaration.
const TASK_SPEED_ID = 6970
new bool:g_bHasSpeedShop[33]


// XP shop --> Gravity declaration
const TASK_GRAVITY_ID = 6970
new bool:g_bHasGravity[33]

//Xp shop --> Invisilibility Declaration
const TASK_INVI_ID = 6971
new bool:g_bHasInvi[33]


new const g_vaults[ ]        =       "XpClasicMods"
new const g_vaults2[ ]        =       "XPPasss"
new gVault
new gVault2

//Server Tag.
new static const svTag[] = "[=B`W=]"


#pragma tabsize 0
#define MAX_PLAYERS	32
#define MAXLEVELS 20
#define nvault_clear(%1) nvault_prune(%1, 0, get_systime() + 1) 

//for spec info spec_info
#define TASKSPEC_INFO	123

//Players Level Up or Down Info

new XpUp = 0
new XpDown = 0

//===================================== Knife stuff============================================
new bool:g_bHasSpeed[33]
const TASK_ID = 6969

const Float:FAST_SPEED = 696.0 //Your speed bonus
new iHp
new g_MessageColor
new g_NameColor
new g_AdminListen

//====================== SHOP RELATED DECLARATION=======================

// Make shop use at only once in the round
new bool:shopUsed[35]

//======================= END OF SHOP DECLARATION======================

new message[192]
new sayText
new teamInfo
new maxPlayers

new bool:login[35]

enum _:VaultData {
    
    szNames[ 64 ],
    szDatas[ 128 ]
};

#define MAX_BUFFER	2047
new szBuffer[ MAX_BUFFER + 1 ]

// First Blood 
new FirstBlood = 0


//Player cout to check whether only one player is in the server
new Players[32],playerCount


new strName[191]
new strText[191]
new alive[11]

new const g_szTag[][] = {
    "[Player]", // DO NOT REMOVE
    "[OWNER]",
    "[MODERATOR]",
    "[ADMIN]",
    "[Sr. Player]"
}

new const g_iTagFlag[sizeof(g_szTag)] = {
    ADMIN_ALL, // DO NOT REMOVE
    ADMIN_RCON,
    ADMIN_IMMUNITY,
    ADMIN_BAN,
    ADMIN_LEVEL_G
}


new g_iMsgidSayText;
new g_iAdsOnChat
new PlayerXP[33],PlayerLevel[33]
new XP_Kill,XP_Knife,XP_Hs,XP_rampagekill,XP_megakill
new XP_lostKill,XP_lostHs,XP_lostKnife,XP_losthe
new XP_FirstBlood
new namech
new XP_plant,XP_defuse,XP_he,xp_PointsHour,xp_PointsOneHour
new pCvar;
new g_iKills[35], g_iHS[35], g_iDmg[35] 
new toggle_spree
new kills[35], deaths[35]
new doublekills[35],triplekill[35], multikills[35], spree[35]
new Float:spreetime[35]	
new XP_spawn,XP_got,XP_drop
new HudSync_SpecInfo
new g_iWonPointsTerrorists
new g_iWonPointsCounterTerrorists
new g_iLostPointsTerrorists
new g_iLostPointsCounterTerrorists
new g_iK
new g_TimeBetweenAds
new g_iWonPointsPlanterExplode


new const g_ChatAdvertise[ ][ ] = {
	"!t Check xp command !n: !g /xp,/shop,/reg,/login,/topxp,/xpall,/class,/xpinfo !t !!",
	"!t Check stats command !n: !g/rank,/top15,/hp,/me",
	"!t Save our IP !n if !t you !g Liked our server !n: !t 183.87.110.27:33333",
	"!t Use Static !g Nick Name !nto !g Stay with your !t XP & Level"
}

new const LEVELS[MAXLEVELS + 1] = {
	0,
	100, // Noob Nigga I 
	300, // Noob Nigga II 
	500, // Casual I 
	700, // Casual II
	900, // Junior I
	1100, // Junior II
	1500, // Senior Sir I 
	1800, // Senior Sir II
	2100,  // Strategist I
	2400,  // Strategist II
	2722, // Gang Leader I
	3144, // Gang Leader II
	3666, // Global Assasin I
	3988, // Global Assasin II
	4399, // Hardcore Player I 
	4922, // Hardcore Player II
	5133, // Professional I
	5644, // Professional II
	6000 // Professional III
} 

new const Prefix[MAXLEVELS][]=
{ 
	"Newbie", 
	"Noob Nigga I", 
	"Noob Nigga II", 
	"Casual I", 
	"Casual II", 
	"Junior I", 
	"Junior II",
	"Senior Sir I",
	"Senior Sir II",  
	"Strategist I",
	"Strategist II",   
	"Gang Leader I",
	"Gang Leader II",  
	"Global Assasin I", 
	"Global Assasin II", 
	"Hardcore Player I",
	"Hardcore Player II",
	"Professional I",
	"Professional II",
	"Professional III"
} 

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_clcmd("say /xp" ,"PrintXp")
	register_clcmd("say xp" ,"PrintXp")
	register_clcmd("say /topxp","TopSkill")
	register_clcmd("say /top15","TopSkill")
	register_clcmd("say top15","TopSkill")
	register_clcmd("say topxp","TopSkill")
	register_clcmd("say /xpall","CmdTopShow")
	register_clcmd("say xpall","CmdTopShow")
	register_clcmd("say class" ,"Printclass")
	register_clcmd("say /class", "Printclass")
	register_clcmd("say xpinfo" ,"InfoXp")
	register_clcmd("say /xpinfo", "InfoXp")
	//register_clcmd("say /resetxp", "Cmd_Resetxp")

	//admin command
	register_concmd("amx_givexp" ,"CmdGiveXp",ADMIN_RCON,"Add xp to a player");
	register_concmd("amx_takexp", "CmdTakeXp",ADMIN_RCON,"Remove xp from a player");

	//XP Register System 
	register_clcmd("say /reg","checkRegistered")
	register_clcmd("doRegister","cmdDoRegister")
	 
	
	//Shop Item
	register_clcmd("say /shop", "ShowMenu", _, "Brings up the XP Shop Menu");
	register_clcmd("say shop", "ShowMenu", _, "Brings up the XP Shop Menu");
	
	//XP login System
	register_clcmd("say /login","cmdDoLogin")
	register_clcmd("doLogin","cmdLogin") 
	
	//register
	RegisterHam( Ham_Spawn, "player", "Playerspawn", 1 );
	register_event( "DeathMsg", "DeathMsg", "a" );
	register_forward(FM_ClientUserInfoChanged, "fwClientUserInfoChanged");
	RegisterHam(Ham_TakeDamage, "player", "hamTakeDamage");
	register_event("DeathMsg", "EventDeathMsg", "a");
	register_logevent("RoundEnd", 2, "1=Round_End"); 
	register_logevent( "logevent_roundstart", 2, "1=Round_Start" );
	register_logevent("logevent_spawnedwithbomb", 3, "2=Spawned_With_The_Bomb");
	register_logevent("logevent_dropthebomb", 3, "2=Dropped_The_Bomb");
	register_logevent("logevent_gotthebomb", 3, "2=Got_The_Bomb");
	register_event( "SendAudio", "TerroristsWin", "a", "2&%!MRAD_terwin" );
	register_event( "SendAudio", "CounterTerroristsWin", "a", "2&%!MRAD_ctwin" );
	
	
	
	  // Advanced Chat 
    g_MessageColor = register_cvar("amx_color", "2") // Message colors: [1] Default Yellow, [2] Green, [3] White, [4] Blue, [5] Red
    g_NameColor = register_cvar("amx_namecolor", "6") // Name colors: [1] Default Yellow, [2] Green, [3] White, [4] Blue, [5] Red, [6] Team-color
    g_AdminListen = register_cvar("amx_listen", "1") // Set whether admins see or not all messages(Alive, dead and team-only)

    sayText = get_user_msgid("SayText")
    teamInfo = get_user_msgid("TeamInfo")
    maxPlayers = get_maxplayers()

    register_message(sayText, "avoid_duplicated")

    register_concmd("amx_color", "set_color", ACCESS_LEVEL, "<color>")
    register_concmd("amx_namecolor", "set_name_color", ACCESS_LEVEL, "<color>")
    register_concmd("amx_listen", "set_listen", ACCESS_LEVEL, "<1 | 0>")
    register_clcmd("say", "hook_say")
    register_clcmd("say_team", "hook_teamsay")

	//cvar
	pCvar = register_cvar( "amx_auto_live", "1");
	XP_Kill = register_cvar("xp_kill","2");
	XP_lostKill = register_cvar("xp_lostkill","2");
	XP_Hs = register_cvar("xp_hs","4");
	XP_FirstBlood = register_cvar("XP_FirstBlood","6");
	XP_lostHs = register_cvar("xp_losths","4");
	XP_Knife = register_cvar("xp_knife","3");
	XP_lostKnife = register_cvar("xp_lostknife","3");
	namech = register_cvar("name_change","1");
	XP_plant = register_cvar("xp_plant","5");
	XP_defuse = register_cvar("xp_defuse","5");
	xp_PointsHour = register_cvar( "XP_points_hour", "10" );
	XP_he=register_cvar("xp_he","3");
	XP_megakill = register_cvar("xp_megakill","6");
	XP_rampagekill = register_cvar("xp_rampagekill","7");
	toggle_spree = register_cvar("PS_spree","1");
	XP_losthe = register_cvar("xp_losthe","3");
	XP_spawn = register_cvar("XP_spawn","5");
	XP_drop = register_cvar("XP_drop","5");
	XP_got = register_cvar("XP_got","5");
	g_iWonPointsTerrorists = register_cvar( "bps_won_points_ts", "3" );
	g_iWonPointsCounterTerrorists = register_cvar( "bps_won_points_cts", "3" );
	g_iLostPointsTerrorists = register_cvar( "bps_lost_points_ts", "3" );
	g_iLostPointsCounterTerrorists = register_cvar( "bps_lost_points_cts", "3" );
	g_iAdsOnChat = register_cvar( "bps_ads", "1" );
	g_TimeBetweenAds = register_cvar( "bps_time_between_ads", "50.0");
	if( get_pcvar_num( g_iAdsOnChat ) )
	{
		set_task( get_pcvar_float( g_TimeBetweenAds ), "ChatAdvertisements", _, _, _, "b" )
	}
	gVault=nvault_open(g_vaults) 
	gVault2=nvault_open(g_vaults2) 
	g_iMsgidSayText = get_user_msgid("SayText");

	MakeTOP15()
	
	//Spec level disp
	HudSync_SpecInfo= CreateHudSyncObj();
	set_task( 0.5, "Spec_Info", .flags = "b" )
	
	
}

public client_connect(id)
{
	LoadXp(id)
	set_task(4.0,"ClientMsg",0);
	set_task( 0.5,"Spec_Info",id + TASKSPEC_INFO, .flags = "b" )
	
}	

public client_putinserver(id)
{

	set_task (1800.0 ,"GiveXPHour", id);
	set_task (3600.0 ,"GiveXPOneHour", id);
}

public client_disconnect(id)
{
		CheckLevel(id);
	
		SaveXp(id)	
		PlayerXP[id]=0     
		PlayerLevel[id]=0
		g_iDmg[id] = 0 
		g_iKills[id] = 0  
		g_iHS[id] = 0
		
		remove_task(id + TASKSPEC_INFO)
	

}

public fwClientUserInfoChanged(id,buffer) 
{
	
	if (!is_user_connected(id) || get_pcvar_num(namech) == 0) {
		return FMRES_IGNORED;
		
		
	}
	
	static val[32]
	static name[32]
	get_user_name(id, name, 31)
	engfunc(EngFunc_InfoKeyValue, buffer, 
	
	"name", val, sizeof val- 1)
	
	if (equal(val, name)) {
		return FMRES_IGNORED
	}
	engfunc
	
	(EngFunc_SetClientKeyValue, id, buffer, "name", name)
	
	ColorChat(id,"!g%s !tName Changing !nhas been !gdisabled.!tReconnect !tTo change",svTag);
	return PLUGIN_HANDLED
}
public hamTakeDamage(victim, inflictor, attacker, Float:damage, DamageBits)  
{  
	if( 1 <= attacker <= 32)  
	{  
		if(cs_get_user_team(victim) != cs_get_user_team(attacker))  
		g_iDmg[attacker] += floatround(damage)  
		else  
		g_iDmg[attacker] -= floatround(damage)  
	}  
}  


public CheckLevel(id)
{
	//Player's XP should not be enter in minus state.
	if(PlayerXP[id] < 0 || PlayerLevel[id] < 0 )
	{
		
		PlayerXP[id]=0
		PlayerLevel[id]=0
	
	}
	if(PlayerXP[id] < LEVELS[PlayerLevel[id]])
	{	while(PlayerXP[id] < LEVELS[PlayerLevel[id]]) 
		{
			XpDown += 1
			PlayerLevel[id] -= 1
		//	ColorChat(id,"In +");
			
		} 
		
	}
	if(PlayerXP[id] >= LEVELS[PlayerLevel[id] + 1]) 
	{
		while(PlayerXP[id] >= LEVELS[PlayerLevel[id] + 1])
		{
			XpUp += 1
			PlayerLevel[id] += 1
			//ColorChat(id,"In -");
		}
	}
				
	SaveXp(id);

}


public EventDeathMsg()  
{  
	new killer = read_data(1)  
	new victim = read_data(2)  
	new is_hs = read_data(3)  
	
	if(killer != victim && killer && cs_get_user_team(killer) != cs_get_user_team(victim))  
	{  
		g_iKills[killer]++;  
		
		if(is_hs)  
		g_iHS[killer]++;  
	}  
	else  
	g_iKills[killer]--;  
}   
public RoundEnd(id)  
{  
	//============ Check for if there is one player in the server then do not give +10 xp =======================
	new rPlayers[32],rPlayerCount
	get_players(rPlayers, rPlayerCount)
	
	if(rPlayerCount>1)
	{
		new iBestPlayer = get_best_player()  
		new attacker=read_data(1)
		new attacker_name[32]
		get_user_name(attacker,attacker_name,31)
		
		new szName[32]  
		get_user_name(iBestPlayer, szName, charsmax(szName)) 
		
		PlayerXP[iBestPlayer] += get_pcvar_num(xp_PointsHour)
		
		
		ColorChat(0,"!g=- %s XP =-!nRound Destructive Player:!g%s !n[ !g%i!t kills!n / !g%i!t Hs!n / !g%i!t Dmg!n ] !tAwarded !g%i !tXP",svTag,szName, g_iKills[iBestPlayer], g_iHS[iBestPlayer],g_iDmg[iBestPlayer],get_pcvar_num(xp_PointsHour)) 
		
		
	}	
	
	
}  	  
get_best_player()  
{  
	new players[32], num;  
	get_players(players, num);  
	SortCustom1D(players, num, "sort_bestplayer")  
	
	return players[0]  
}  
public sort_bestplayer(id1, id2)  
{  
	if(g_iKills[id1] > g_iKills[id2])  
	return -1;  
	else if(g_iKills[id1] < g_iKills[id2])  
	return 1;  
	else  
	{  
		if(g_iDmg[id1] > g_iDmg[id2])  
		return -1;  
		else if(g_iDmg[id1] < g_iDmg[id2])  
		return 1;  
		else  
		return 0;  
	}  
	
	return 0;  
}  

public SaveXp(id) 
{  


	new name[32]
	get_user_name(id,name,31) 
	new vaultkey[64],vaultdata[256] 
	
	format(vaultkey,63,"%s-XpClasic",name)  
	format(vaultdata,255,"%i#%i#",PlayerXP[id],PlayerLevel[id]) 
	
	nvault_set(gVault,vaultkey,vaultdata)
	return PLUGIN_CONTINUE 
}  

public LoadXp(id) 
{
	new name[32]
	get_user_name(id,name,31) 
	new vaultkey[64],vaultdata[256] 
	
	format(vaultkey,63,"%s-XpClasic",name) 
	format(vaultdata,255,"%i#%i#",PlayerXP[id],PlayerLevel[id]) 
	
	nvault_get(gVault,vaultkey,vaultdata,255) 
	replace_all(vaultdata, 255, "#", " ") 
	new playerxp[33], playerlevel[33] 
	parse(vaultdata, playerxp, 31, playerlevel, 31) 
	PlayerXP[id] = str_to_num(playerxp) 
	PlayerLevel[id] = str_to_num(playerlevel) 
	
	return PLUGIN_CONTINUE 
	
}  

public ClientMsg(id)
{
	if( get_pcvar_num( pCvar ) )
	{
	   
	
		ColorChat(id,"!g=- %s XP =- !nCheck xp command:!g/xp,/shop,/login,/reg,/topxp,/class,/xpall,/xpinfo",svTag)
		ShowMsg(id)
	}
	
}

public ShowMsg(id)
{
	set_hudmessage(0,255, 0, 0.30, 0.85, 1, 6.0, 6.0);
	show_hudmessage(id,"Check xp command:/xp,/topxp,/class,/xpall,/xpinfo")
}

public GiveXPHour( id )
{
	PlayerXP[id] += get_pcvar_num(xp_PointsHour) 
	ColorChat(id,"!g=- %s XP =- !nYou got !g%i !nXP for playing more !tthan half hour!!",svTag,get_pcvar_num( xp_PointsHour))
}
public GiveXPOneHour( id )
{
	PlayerXP[id] += get_pcvar_num(xp_PointsHour) 
	ColorChat(id,"!g=- %s XP =- !nYou got !g%i !nXP for playing since !tone hour!!",svTag,get_pcvar_num( xp_PointsOneHour))
}

public PrintXp(id) 
{ 
	
	
	CheckLevel(id);
	//ColorChat(id,"XpUp : %i  XpDown : %i",XpUp,XpDown)
	//ColorChat(id,"Cur XP %i NextLvlXp %i",PlayerXP[id],LEVELS[PlayerLevel[id] + 1])
	
	ColorChat(id,"!g=- %s XP =- !tYour stats- XP:!g%i!n || !tlevel:!g%i!n || !tclass:!g%s!n || !tNeeded XP:!g%i",svTag,PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],LEVELS[PlayerLevel[id] + 1]-PlayerXP[id])
	//ShowHud(id) 
}

/*
public ShowHud(id)
{
	set_hudmessage(random_num( 0, 255 ), random_num( 0, 255 ), random_num( 0, 255 ), 0.28, 0.30, random_num( 0, 2 ), 6.0, 6.0);
	show_hudmessage(id,"Your stats- XP : %i || level:%i || class:%s || Needed XP For Next Level:%i",PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],LEVELS[PlayerLevel[id] + 1]-PlayerXP[id])
} */

public Printclass(id) 
{ 
	ColorChat(id,"!g%s !tYour stats- !tclass:!g%s!n || !tNext class:!g%s",svTag,Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1])
	ShowClass(id)
}

public ShowClass(id)
{
	set_hudmessage(0,255, 0,  0.08, 0.88, 1, 6.0, 6.0);
	show_hudmessage(id,"Your stats- class:%s|| Next class:%s",Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1])
}

public logevent_roundstart( )
{
	// Set First Blood to zero to detect first Blood
	FirstBlood = 0
	
	//Open shop menu
	
	
	
	new Players[ MAX_PLAYERS ], iNum, id;
	get_players( Players, iNum, "ch" );
	
	while( --iNum >= 0 )
	{
		
		
		id = Players[ iNum ];
		set_spree(id)
        reset_spree(id)
		set_hudmessage( 000, 160, 000, 0.0, 0.21, 0, 90.0, _, 0.0, 0.0 );
		show_hudmessage( id,"=- %s XP =-^n[ XP ]: %i^n[ Level ]: %i^n[ Class ] : %s^n[ Next class ]: %s",svTag,PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1]);
	}
}
public ChatAdvertisements(id)
{
	new Players[ MAX_PLAYERS ]
	new iNum
	new i
	get_players( Players, iNum, "ch" )
	
	for( --iNum; iNum >= 0; iNum-- )
	{
		i = Players[ iNum ]
		{
			ColorChat(i,g_ChatAdvertise[ g_iK ])
		}
	}
	
	
	g_iK++
	
	if( g_iK >= sizeof (g_ChatAdvertise) )
	{
		g_iK = 0
	}
}
public Spec_Info()
{
	
	new iPlayers[ 32 ], iPlayersNum, id,  iSpectatedPlayer,szSpectatedPlayerName[ 33 ]
    get_players( iPlayers, iPlayersNum ,"bc" )
    
    if ( ! iPlayersNum )
        return;
    
    for ( new i = 0; i < iPlayersNum ; i++ )
    {
        id = iPlayers[ i ];
        iSpectatedPlayer = pev(id, pev_iuser2)  
        get_user_name(iSpectatedPlayer, szSpectatedPlayerName, sizeof szSpectatedPlayerName -1)
        set_hudmessage(255, 255, 255, 0.01, 0.90, 2, 0.05, 2.0, 0.01, 3.0, -1);
		ShowSyncHudMsg(id, HudSync_SpecInfo, "Spectating: %s ^n[ XP : %i | Level : %i | class : %s ]", szSpectatedPlayerName, PlayerXP[ iSpectatedPlayer ], PlayerLevel[ iSpectatedPlayer ],Prefix[PlayerLevel[iSpectatedPlayer]]);
    }
		
	
}

public DeathMsg() 
{
	new headshot=read_data(3) 
	new Victim=read_data(2)
	new attacker=read_data(1)
	new r, g, b
	r = random(256)
	g = random(256)
	b = random(256)
	new Victim_name[32]
	new attacker_name[32]
	get_user_name(Victim,Victim_name,31)
	get_user_name(attacker,attacker_name,31)
	new weapon[32] 
	
		new suicide = 0
		if (attacker == Victim) {
			suicide = 1
		}
		if(suicide==1)
		{
			
			PlayerXP[Victim] -= get_pcvar_num( XP_lostKill ) 
			ColorChat(Victim,"!g=- %s XP =- !nYou lost !g%i !nXP for committing suicide!",svTag,get_pcvar_num(XP_lostKill))
		}
		else
		{
			read_data(4, weapon, sizeof(weapon) -1) 
			{
				FirstBlood += 1
				if(FirstBlood == 1)
				{
						PlayerXP[attacker] += get_pcvar_num(XP_FirstBlood)  
						ColorChat(0 ,"!g=- %s XP =- !t %s !ngot !g%i !nXP for !tFirst Blood !non !g%s.",svTag,attacker_name, get_pcvar_num(XP_FirstBlood),Victim_name)	
				}
				if(headshot)
				{
					PlayerXP[attacker] += get_pcvar_num(XP_Hs)  
					ColorChat(attacker,"!g=- %s XP =- !nYou got !g%i !nXP for killing with headshot on !g%s!t.",svTag,get_pcvar_num(XP_Hs),Victim_name)	
					PlayerXP[Victim] -= get_pcvar_num(XP_lostHs)
					ColorChat(Victim,"!g=- %s XP =- !nYou lost !g%i !nXP for dying with headshot on !g%s!t.",svTag,get_pcvar_num(XP_lostHs),attacker_name)
				
				}
				
			
       
				else if(equali(weapon, "knife")) 
				{
					PlayerXP[attacker] += get_pcvar_num(XP_Knife)  
					ColorChat(attacker,"!g=- %s XP =- !nYou got !g%i !nXP for killing with knife on !g%s!t.",svTag,get_pcvar_num(XP_Knife),Victim_name)	
					PlayerXP[Victim] -= get_pcvar_num(XP_lostKnife)  
					//+50 HP ||  +2 Frags || Speed for 10 seconds
					
					
					set_user_health(attacker,get_user_health(attacker) + 50 )
					g_bHasSpeed[attacker] = true
					remove_task(attacker + TASK_ID)
					set_task(10.0, "taskRemoveSpeed", attacker + TASK_ID)
					set_user_maxspeed(attacker, FAST_SPEED)
					
					set_user_frags( attacker, get_user_frags( attacker ) + 2 )
					
					ColorChat(attacker,"!g=- %s XP =- !nYou got !g2 !tFrags !n+ !g[+50] Health !n& !tSpeed !nfor !gKnife Kill",svTag)	
					 
					ColorChat(Victim,"!g=- %s XP =- !nYou lost !g%i !nXP for dying with knife on !g%s!t.",svTag,get_pcvar_num(XP_lostKnife),attacker_name) 
					set_hudmessage(r, g, b, 0.07, 0.67, 1, 6.0, 6.0, 0.1, 0.2, -1)
					show_hudmessage(0,"%s just Kn!fed %s^nTook the Revenge!!",attacker_name,Victim_name)	
									
				}
				else if(equali(weapon, "grenade")) 
				{
					PlayerXP[attacker] += get_pcvar_num(XP_he) 
					ColorChat(attacker,"!g=- %s XP =- !nYou got !g%i !nXP for killing with he grenade on !g%s!t.",svTag,get_pcvar_num(XP_he),Victim_name)		
					PlayerXP[Victim] -= get_pcvar_num(XP_losthe) 
					ColorChat(Victim,"!g=- %s XP =- !nYou got !g%i !nXP for dying with he grenade on !g%s!t.",svTag,get_pcvar_num(XP_losthe),attacker_name)
					set_hudmessage(r, g, b, 0.07, 0.67, 1, 6.0, 6.0, 0.1, 0.2, -1)
					show_hudmessage(0,"%s just grenade on %s^nOmg :O !!",attacker_name,Victim_name)	
					
				}
				else
				{
					PlayerXP[attacker] += get_pcvar_num( XP_Kill ) 
					ColorChat(attacker,"!g=- %s XP =- !nYou got !g%i !nXP for killing on !g%s!t.",svTag,get_pcvar_num(XP_Kill),Victim_name)
					PlayerXP[Victim] -= get_pcvar_num( XP_lostKill ) 
					ColorChat(Victim,"!g=- %s XP =- !nYou lost !g%i !nXP for dying on !g%s!t.",svTag,get_pcvar_num(XP_lostKill),attacker_name)
				
				}
			}
		}
	if( get_pcvar_num(toggle_spree) )
	{
		if(get_user_team(attacker)!=get_user_team(Victim)&&attacker!=Victim)
		{
			kills[attacker] = kills[attacker] + 1
			deaths[Victim] = deaths[Victim] + 1
			check_kills(attacker)
		}
	}
	
	return PLUGIN_HANDLED
}

public taskRemoveSpeed(id)
{
    id -= TASK_ID
    g_bHasSpeed[id] = false
    set_user_maxspeed(id,FAST_SPEED)
}

public TerroristsWin(id)
{
	get_players(Players, playerCount)
	
	if(playerCount>1)
	{
		new Players[ MAX_PLAYERS ]
		new iNum
		new i
		
		get_players( Players, iNum, "ch" )
		
		for( --iNum; iNum >= 0; iNum-- )
		{
			i = Players[ iNum ]
			
			switch( cs_get_user_team( i ) )
			{
				case( CS_TEAM_T ):
				{
					if( get_pcvar_num( g_iWonPointsTerrorists ) )
					{
						PlayerXP[i] += get_pcvar_num( g_iWonPointsTerrorists )
						{
							ColorChat( i,"!g=-%s XP =- !nYour team !g(T)!n have won !g%i!n XP for winning the round !g(Y)!t.",svTag,get_pcvar_num( g_iWonPointsTerrorists ))
						}
					}
				}
				
				case( CS_TEAM_CT ):
				{
					if( get_pcvar_num( g_iLostPointsCounterTerrorists ) )
					{
						PlayerXP[i] -= get_pcvar_num( g_iLostPointsCounterTerrorists )
						{
							ColorChat( i,"!g=-%s XP =-!nYour team !g(CT)!n have lost !g%i!n XP for losing the round !g(:()!t.",svTag, get_pcvar_num( g_iLostPointsCounterTerrorists ))
						}
					}
				}
			}
		}
	}
}

public CounterTerroristsWin(id)
{	
	get_players(Players, playerCount)
	
	if(playerCount>1)
	{
		new Players[ MAX_PLAYERS ]
		new iNum
		new i
		
		get_players( Players, iNum, "ch" )
		
		for( --iNum; iNum >= 0; iNum-- )
		{
			i = Players[ iNum ]
			
			switch( cs_get_user_team( i ) )
			{
				case( CS_TEAM_T ):
				{
					if( get_pcvar_num( g_iLostPointsTerrorists ) )
					{
						PlayerXP[i] -= get_pcvar_num( g_iLostPointsTerrorists )
						{
							ColorChat( i,"!g=-%s XP =-  !nYour team !g(T)!n have lost !g%i!n XP for losing the round !g(:()!t.",svTag, get_pcvar_num( g_iLostPointsTerrorists ))
						}
					}
				}
				
				case( CS_TEAM_CT ):
				{
					if( get_pcvar_num( g_iWonPointsCounterTerrorists ) )
					{
						PlayerXP[i]  += get_pcvar_num( g_iWonPointsCounterTerrorists )
						{
							ColorChat( i,"!g=-%s XP =-  !nYour team !g(CT)!n have won !g%i!n XP for winning the round !g(Y)!t.",svTag,get_pcvar_num( g_iWonPointsCounterTerrorists ))
						}
					}
				}
			}
		}
	}
}

public bomb_explode( planter, defuser )
{
		PlayerXP[ planter ] += get_pcvar_num( g_iWonPointsPlanterExplode )
		ColorChat( planter, "!g%s!n You earned!t %i!n point with the bomb explosion", svTag, get_pcvar_num( g_iWonPointsPlanterExplode ) )
		
}
public Playerspawn(id) 
{	
	g_iDmg[id] 		= 0;  
	g_iHS[id] 		= 0;  
	g_iKills[id] 	= 0; 
	CheckLevel(id)
	shopUsed[id] = false
	
	if(XpUp > 0)
	{
		ColorChat(id,"!g=- %s XP =- !t Congratulations !! !g You gained !t %i Level.",svTag,XpUp)
		XpUp=0
		SaveXp(id)
	}
	else if(XpDown > 0)
	{
		ColorChat(id,"!g=- %s XP =- !tYou have lost !g%i Level !ndue to !gPoor Game Play",svTag,XpDown)
		XpDown=0
		SaveXp(id)
	}
	else
	{
		ColorChat(id,"!g=- %s XP =- !tYour stats- XP:!g%i!n || !tlevel:!g%i!n || !tclass:!g%s!n || !tNeeded XP:!g%i",svTag,PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],LEVELS[PlayerLevel[id] + 1]-PlayerXP[id])
	}
	
}
public bomb_planted(id)  
{

	get_players(Players, playerCount)
	
	if(playerCount>1)
	{
		new name[32]
		get_user_name(id,name,31)
		{
			PlayerXP[id] += get_pcvar_num(XP_plant) 
			ColorChat(id ,"!g=- %s XP =- !tYou got !g%i !nXP for planting the bomb !g(c4)!t.",svTag,get_pcvar_num(XP_plant))							
		}
	}

	return PLUGIN_HANDLED
}
public bomb_defused(id)  
{
	new name[32]
	get_user_name(id,name,31)
	{ 
		PlayerXP[id] += get_pcvar_num(XP_defuse)
		ColorChat(id ,"!g=-%s XP =- !tYou !ngot !g%i !nXP for defusing the bomb !g(c4)!t.",svTag,get_pcvar_num(XP_defuse))	
	}
	return PLUGIN_HANDLED
}
public logevent_spawnedwithbomb()
{

	get_players(Players, playerCount)
	
	if(playerCount>1)
	{
		new id = get_loguser_index()
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		{
			PlayerXP[id] += get_pcvar_num(XP_spawn)
			ColorChat(id,"!g=-%s XP =- You !ngot !g%i!n XP for getting spawned with the bomb !g(c4)!t.",svTag,get_pcvar_num(XP_spawn))
		}
	}
}

public logevent_gotthebomb()
{
	get_players(Players, playerCount)
	if(playerCount>1)
	{
		new id = get_loguser_index()
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		{
			PlayerXP[id] += get_pcvar_num(XP_got)
			ColorChat(id,"!g=-%s XP =- %s !ngot !g%i!n XP for picking up the dropped bomb !g(c4)!t.",svTag,szName,get_pcvar_num(XP_got))
		}
	}
}

public logevent_dropthebomb()
{
	get_players(Players, playerCount)
	if(playerCount>1)
	{
		new id = get_loguser_index()
		new szName[32]
		get_user_name(id, szName, charsmax(szName))
		{
			PlayerXP[id] -= get_pcvar_num(XP_drop)
			ColorChat(id,"!g=-%s XP =- You !nlost !g%i!n XP for dropping the bomb !g(c4)!t.",svTag,get_pcvar_num(XP_drop))
		}
	}
}

stock get_loguser_index() 
{
	new loguser[80], name[32]
	read_logargv(0, loguser, 79)
	parse_loguser(loguser, name, 31)
	return get_user_index(name)
}  

public InfoXp(id) {
	
	show_motd(id,"/addons/amxmodx/configs/inf.txt")	
}

public CmdGiveXp(id) 
{ 
	if( get_user_flags( id ) & ADMIN_RCON ) 
	{	
		new PlayerToGive[32], XP[32]
		read_argv(1,PlayerToGive,31)

		read_argv(2,XP, 31)
		new Player = cmd_target(id,PlayerToGive,9)
		
		if(!Player) {

			return PLUGIN_HANDLED
		}
		
		new XPtoGive = str_to_num(XP)
		new name[32],owner[32]
		get_user_name(id,owner,31)		
		get_user_name(Player,name,31)
		ColorChat(0,"!nADMIN !g%s !ngive to !g%s %s !tXP.", owner,name,XP)	
		PlayerXP[Player]+= XPtoGive
		SaveXp(id)

	}
	else
	{
		client_print(id,print_console,"You have no access to that command")
		return PLUGIN_HANDLED
	}
	return PLUGIN_HANDLED
}

public CmdTakeXp(id) 
{ 
	
	if(get_user_flags(id) & ADMIN_RCON ) 
	{

		new PlayerToTake[32], XP[32]
		read_argv
		
		(1,PlayerToTake,31 )
		read_argv(2,XP,31 )
		new Player = cmd_target(id,PlayerToTake,9)
		
		if(!Player)
		{			
			return PLUGIN_HANDLED	
		}
		
		new XPtoTake = str_to_num(XP)
		new name[32],owner[32]
		
		
		get_user_name(id,owner,31)
		get_user_name(Player,name,31)
		ColorChat(0,"!nADMIN !g%s !ntake from !g%s %s !tXP.",owner,name,XP)
		PlayerXP[ Player ]-=XPtoTake
		SaveXp( id )
	}
	else 
	{		
		client_print(id,print_console,"You hav no acces to that command.")
		return PLUGIN_HANDLED	
	}
	return PLUGIN_HANDLED
}
public CmdTopShow (id) 
{
	new i,count
	static sort [33] [2], maxPlayers
	
	if ( !maxPlayers)  
	{
		maxPlayers =get_maxplayers()
	}
	for (i= 1; i <= maxPlayers; i++)
	{
		sort[count][0] = i
		sort[count][1] = PlayerXP[i]
		count++
	}
	
	SortCustom2D (sort,count,"stats_custom_compare")
	
	new motd [1024],len
	
	len=format (motd,1023,"<body bgcolor=#000000><center><font color=#FFB000><pre>")
	len +=format(motd[len],1023-len,"%s %-22.22s %3s^n","#","Name","XP")
	
	new players [32], num
	get_players (players,num)
	
	new b = clamp (count,0,15)
	
	new name [32], player
	
	for (new a = 0; a<b;a++)
	{
		player = sort [a] [0]
		get_user_name(player,name,31)		
		len +=format(motd[len],1023-len,"%d %-22.22s %d^n",a+1,name,sort[a][1])
	}
	
	len +=format(motd[len],1023-len,"</body></font></pre></center>")
	show_motd( id,motd,"XP Top 15")
	
	return PLUGIN_CONTINUE
}

public stats_custom_compare(elem1[], elem2[])
{
	if(elem1[1] > elem2[1])
	return -1;
	else if(elem1[1] < elem2[1])
	return 1;
	
	return 0;
}

public TopSkill(id)
{
		show_motd( id, szBuffer, "Top 15 XP Holders" )
}

public cmdRank(id)
{

	new Array:aKey = ArrayCreate( 64 );
	new Array:aData = ArrayCreate( 128 );
	new Array:aAll = ArrayCreate( VaultData );
	
	new iVault = nvault_util_open( "XpClasicMods" );
	new iCount = nvault_util_count( iVault );
	new iPos, szKey[ 64 ], szValue[ 128 ], iTimestamp;
	
	for( new i = 1; i <= iCount; i++ ) {
		iPos = nvault_util_read( iVault, iPos, szKey, sizeof( szKey ) - 1, szValue, sizeof( szValue ) - 1, iTimestamp );
		
		ArrayPushArray( aKey, szKey );
		ArrayPushArray( aData, szValue );
	}
	
	new iArraySize = ArraySize( aKey );	
	new Data[ VaultData ];
	
	for( new i = 0; i < iArraySize; i++ )
	{
		ArrayGetString( aKey, i, Data[ szNames ], sizeof( Data[ szNames ] ) - 1 );
		ArrayGetString( aData, i, Data[ szDatas ], sizeof( Data[ szDatas ] ) - 1 );
		
		ArrayPushArray( aAll, Data );
	}
	
	ArraySort( aAll, "SortData" );
	
	new g_szusername[32]
	
	get_user_name(id,g_szusername,31)
	
	new szAuthIdFromArray[ 35 ]
	new getRight[35]
	new getLeft[35]
		
		new j
		new counter = 0
		for( j = 0; j < iArraySize; j++ )
		{
			
			ArrayGetString( aAll, j, szAuthIdFromArray, charsmax( szAuthIdFromArray ) )
			counter = counter + 1
			strtok(szAuthIdFromArray,getLeft,34,getRight,34,'-')
			if( equal( getLeft, g_szusername ) )
			{
				
				break
			}	
		}
		
		ArrayDestroy( aKey )
		ArrayDestroy( aData )
		ArrayDestroy( aAll )
		
		ColorChat(id, "!g%s!n Your rank is!t %i!n of!t %i!n players with!t %i!n points ", svTag,counter, iArraySize, PlayerXP[ id ] )
}

public MakeTOP15( )
{
	new iLen;
	
	iLen = formatex( szBuffer, sizeof( szBuffer ) - 1,
	"<body bgcolor=#FFFFFF>\
	<table width=100%% cellpadding=2 cellspacing=0 border=0>\
	<tr align=center bgcolor=#1E1E1E>\
	<th width=5%%>#\
	<th width=70%% align=left><font color='white'>Top-Players</font>\
	<th width=30%><font color='white'>Top-XP</font>" );
	
	new Array:aKey = ArrayCreate( 64 );
	new Array:aData = ArrayCreate( 128 );
	new Array:aAll = ArrayCreate( VaultData );
	
	new iVault = nvault_util_open( "XpClasicMod" );
	new iCount = nvault_util_count( iVault );
	new iPos, szKey[ 64 ], szValue[ 128 ], iTimestamp;
	
	for( new i = 1; i <= iCount; i++ ) {
		iPos = nvault_util_read( iVault, iPos, szKey, sizeof( szKey ) - 1, szValue, sizeof( szValue ) - 1, iTimestamp );
		
		ArrayPushArray( aKey, szKey );
		ArrayPushArray( aData, szValue );
	}
	
	new iArraySize = ArraySize( aKey );	
	new Data[ VaultData ];
	
	for( new i = 0; i < iArraySize; i++ )
	{
		ArrayGetString( aKey, i, Data[ szNames ], sizeof( Data[ szNames ] ) - 1 );
		ArrayGetString( aData, i, Data[ szDatas ], sizeof( Data[ szDatas ] ) - 1 );
		
		ArrayPushArray( aAll, Data );
	}
	
	ArraySort( aAll, "SortData" );
	
	new t_szName[ 60 ], t_szData[ 60 ];
	new iSize = clamp( iArraySize, 0, 15 );
	
	for( new x = 0; x < iSize; x++ )
	{
		ArrayGetArray( aAll, x, Data );
		
		parse( Data[ szNames ], t_szName, sizeof( t_szName ) - 1 );
		parse( Data[ szDatas ], t_szData, sizeof( t_szData ) - 1 );
		
		replace_all( t_szName, sizeof( t_szName ) - 1, "<", "&lt;" );
		replace_all( t_szName, sizeof( t_szName ) - 1, ">", "&gt;" );
		replace_all( t_szName, sizeof( t_szName ) - 1, "-XpClasic", " " );
		 new szArg1[50], szArg2[50]
		 
		
		strtok(t_szData, szArg1, charsmax(szArg1), szArg2, charsmax(szArg2), '#')
		
		iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<tr align=center>" );
		iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<td>%d", x + 1 );
		iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<td align=left>%s", t_szName );
		iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "<td>%s", szArg1 );
	}
	
	iLen += formatex( szBuffer[ iLen ], sizeof( szBuffer ) - 1 - iLen, "</table></body>" );
	
	nvault_util_close( iVault );
	
	ArrayDestroy( aKey );
	ArrayDestroy( aData );
	ArrayDestroy( aAll );
}

public SortData( Array:aArray, iItem1, iItem2, iData[ ], iDataSize )
{
	new Data1[ VaultData ], Data2[ VaultData ];
	
	ArrayGetArray( aArray, iItem1, Data1 );
	ArrayGetArray( aArray, iItem2, Data2 );
	
	new POINT_1[ 7 ], POINT_2[ 7 ];
	parse( Data1[ szDatas ], POINT_1, sizeof( POINT_1 ) - 1 );
	parse( Data2[ szDatas ], POINT_2, sizeof( POINT_2 ) - 1 );
	
	new iCount1; iCount1 = str_to_num( POINT_1 );
	new iCount2; iCount2 = str_to_num( POINT_2 );
	
	return( iCount1 > iCount2 ) ? -1 : ( ( iCount1 < iCount2 ) ? 1 : 0 );
}

/*
public Cmd_Resetxp(id) 
{
	
		new gvault
	if(get_user_flags(id) & ADMIN_IMMUNITY) {
		nvault_clear(gvault)
		for(new i = 0; i < 33; i++) {
			PlayerXP[i] = 0
			PlayerLevel[i] = 0
		}
	} else {
		ColorChat(id,"!g=- %s XP =- !tYou do not have permissions to reset xp!n!",svTag)
	} 
	
	
	PlayerXP[id] = 0
	PlayerLevel[id] = 0
	SaveXp(id)
	
} */

public check_kills(id)
{
	
	spree[id] = spree[id] + 1
	spreetime[id] = spreetime[id] + 4.0
	
	new name[20]
	get_user_name(id, name, 19)
	
	new attacker=read_data(1)
	new attacker_name[32]
	get_user_name(attacker,attacker_name,31)
	
	new r, g, b
	r = random(256)
	g = random(256)
	b = random(256)
	
	if(spree[id] == 2)
	{		
		set_hudmessage(r, g, b, 0.01, 0.54, 1, 6.0, 3.0, 0.1, 0.2, -1);
		//show_hudmessage(0,"Double Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num( XP_Kill )
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for making Double kills!!",svTag, get_pcvar_num( XP_Kill ))
	}
	if(spree[id] == 3)
	{	
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 3.0, 0.1, 0.2, -1);
		//show_hudmessage(0,"Triple Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_Knife) 
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for making Triple kills!!",svTag, get_pcvar_num(XP_Knife))
	}	
	if(spree[id] == 4)
	{	
		set_hudmessage(r, g, b, 0.01, 0.52, 1, 6.0, 3.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Multi Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_Hs) 
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for making Four kills!!",svTag, get_pcvar_num(XP_Hs))
	}
	if(spree[id] == 5)
	{
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Ultra kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_plant)
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for making !t5 Kills. !gMonster Kill!!!",svTag,get_pcvar_num(XP_plant))
	}	
	if(spree[id] == 6)
	{
		set_hudmessage(r, g, b, 0.01, 0.52, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Mega kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_megakill)
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for !t6 Kills. !g Mega kill !!",svTag, get_pcvar_num(XP_megakill))
	}
	if(spree[id] == 7)
	{
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Rampage: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_rampagekill)
		ColorChat(id, "!n=- %s XP =- !gYou awarded %i XP for !t7 Kills. !g Rampage !!",svTag, get_pcvar_num(XP_rampagekill))
	}
	
	remove_task(id)
	set_task(spreetime[id], "reset_spree", id)
	
}
public reset_spree(id)
{
	set_spree(id)
	spree[id] = 0
}


public set_spree(id)
{
	if(spree[id] == 2)
	doublekills[id] = doublekills[id] + 1
	else if(spree[id] == 3)
	triplekill[id] = triplekill[id] + 1

	else if(spree[id] > 2)
	multikills[id] = multikills[id] + 1
}

stock ColorChat(id, const text[], any:...)
{
	
	new szMsg[191], iPlayers[32], iCount = 1;
	vformat(szMsg, charsmax(szMsg), text, 3);
	
	replace_all(szMsg, charsmax(szMsg), "!g","^x04");
	replace_all(szMsg, charsmax(szMsg), "!n","^x01");
	replace_all(szMsg, charsmax(szMsg), "!t","^x03");
	
	if(id)
	iPlayers[0] = id;
	else
	get_players(iPlayers, iCount, "ch");
	
	for(new i = 0 ; i < iCount ; i++)
	{
		if(!is_user_connected(iPlayers[i]))
		continue;
		
		message_begin(MSG_ONE_UNRELIABLE, g_iMsgidSayText, _, iPlayers[i]);
		write_byte(iPlayers[i]);
		write_string(szMsg);
		message_end();
	}
}

stock player_in_list(id)
{
	new s_Name[32], s_AuthID[32]
	get_user_name (id,s_Name,31)
	get_user_authid(id,s_AuthID,31)
	
	for(new i; i<TotalLines; i++ )
	{
		if (!strcmp(s_Name,PlayerList[i]))
		return 1
		if (!strcmp(s_AuthID,PlayerList[i]))
		return 1
	}
	return 0
}

//====================================== Advanced Chat System


public avoid_duplicated(msgId, msgDest, receiver)
{
    return PLUGIN_HANDLED
}

get_tag_index(id)
{
    new flags = get_user_flags(id)
    
    for(new i = 1; i < sizeof(g_iTagFlag); i++)
    {
        if(check_admin_flag(flags, g_iTagFlag[i]))
        {
            return i
        }
    }
    
    return 0
}

check_admin_flag(flags, flag)
{
    if(flag == ADMIN_ADMIN)
    {
        return ((flags & ~ADMIN_USER) > 0)
    }
    else if(flag == ADMIN_ALL)
    {
        return 1
    }
    
    return (flags & flag)
}

public hook_say(id)
{
    read_args(message, 191)
    remove_quotes(message)

    // Gungame commands and empty messages
    if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
        return PLUGIN_CONTINUE

    new name[32]
    get_user_name(id, name, 31)

    new admin = get_tag_index(id)

    new isAlive

    if(is_user_alive(id))
    {
        isAlive = 1
        alive = "^x01"
    }
    else
    {
        isAlive = 0
        alive = "^x01*DEAD* "
    }

    static color[10]

    if(admin)
    {
        // Name
        switch(get_pcvar_num(g_NameColor))
        {
            case 1:
                format(strName, 191, "^x04%s %s%s", g_szTag[admin], alive, name)
            case 2:
                format(strName, 191, "^x04%s %s^x04%s ", g_szTag[admin], alive, name)
            case 3:
            {
                color = "SPECTATOR"
                format(strName, 191, "^x04%s %s^x03%s ", g_szTag[admin], alive, name)
            }
            case 4:
            {
                color = "CT"
                format(strName, 191, "^x04%s %s^x03%s", g_szTag[admin], alive, name)
            }
            case 5:
            {
                color = "TERRORIST"
                format(strName, 191, "^x04%s %s^x03%s", g_szTag[admin], alive, name)
            }
            case 6:
            {
                get_user_team(id, color, 9)
                format(strName, 191, "^x03%s ^x04-Level %i] %s ^x03 %s", g_szTag[admin],PlayerLevel[id], alive, name)
            }
        }

        // Message
        switch(get_pcvar_num(g_MessageColor))
        {
            case 1:    // Yellow
                format(strText, 191, "%s", message)
            case 2:    // Green
                format(strText, 191, "^x04%s", message)
            case 3:    // White
            {
                copy(color, 9, "SPECTATOR")
                format(strText, 191, "^x03%s", message)
            }
            case 4:    // Blue
            {
                copy(color, 9, "CT")
                format(strText, 191, "^x03%s", message)
            }
            case 5:    // Red
            {
                copy(color, 9, "TERRORIST")
                format(strText, 191, "^x03%s", message)
            }
        }
    }
    else     // Player is not admin. Team-color name : Yellow message
    {
        get_user_team(id, color, 9)
        format(strName, 191, "^x04[Level %i] %s^x03%s", PlayerLevel[id], alive, name)
		
        format(strText, 191, "%s", message)
    }

    format(message, 191, "%s^x01 :  %s", strName, strText)
    sendMessage(color, isAlive)    // Sends the colored message
    return PLUGIN_CONTINUE
}

public hook_teamsay(id)
{
    new playerTeam = get_user_team(id)
    new playerTeamName[19]

    switch(playerTeam) // Team names which appear on team-only messages
    {
        case 1:
            copy(playerTeamName, 11, "Terrorists")

        case 2:
            copy(playerTeamName, 18, "Counter-Terrorists")

        default:
            copy(playerTeamName, 9, "Spectator")
    }

    read_args(message, 191)
    remove_quotes(message)

    // Gungame commands and empty messages
    if(message[0] == '@' || message[0] == '/' || message[0] == '!' || equal(message, "")) // Ignores Admin Hud Messages, Admin Slash commands,
        return PLUGIN_CONTINUE

    new name[32]
    get_user_name(id, name, 31)

    new admin = get_tag_index(id)

    new isAlive

    if(is_user_alive(id))
    {
        isAlive = 1
        alive = "^x01"
    }
    else
    {
        isAlive = 0
        alive = "^x01*DEAD* "
    }

    static color[10]

    if(admin)
    {
        // Name
        switch(get_pcvar_num(g_NameColor))
        {
            case 1:
                format(strName, 191, "%s(%s)^x04%s %s", alive, playerTeamName, g_szTag[admin], name)
            case 2:
                format(strName, 191, "%s(%s)^x04%s ^x04%s", alive, playerTeamName, g_szTag[admin], name)
            case 3:
            {
                color = "SPECTATOR"
                format(strName, 191, "%s(%s)^x04%s ^x03%s", alive, playerTeamName, g_szTag[admin], name)
            }
            case 4:
            {
                color = "CT"
                format(strName, 191, "%s(%s)^x04%s ^x03%s", alive, playerTeamName, g_szTag[admin], name)
            }
            case 5:
            {
                color = "TERRORIST"
                format(strName, 191, "%s(%s)^x04%s ^x03%s", alive, playerTeamName, g_szTag[admin], name)
            }
            case 6:
            {
                get_user_team(id, color, 9)
                format(strName, 191, "^x03%s ^x04[Level %i] %s^x03 %s", g_szTag[admin],PlayerLevel[id], alive, name)
            }
        }

        // Message
        switch(get_pcvar_num(g_MessageColor))
        {
            case 1:    // Yellow
                format(strText, 191, "%s", message)
            case 2:    // Green
                format(strText, 191, "^x04%s", message)
            case 3:    // White
            {
                copy(color, 9, "SPECTATOR")
                format(strText, 191, "^x03%s", message)
            }
            case 4:    // Blue
            {
                copy(color, 9, "CT")
                format(strText, 191, "^x03%s", message)
            }
            case 5:    // Red
            {
                copy(color, 9, "TERRORIST")
                format(strText, 191, "^x03%s", message)
            }
        }
    }
    else     // Player is not admin. Team-color name : Yellow message
    {
        get_user_team(id, color, 9)
        format(strName, 191, "^x04[Level %i] %s^x03%s", PlayerLevel[id], alive, name)
        format(strText, 191, "%s", message)
    }

    format(message, 191, "%s ^x01:  %s", strName, strText)

    sendTeamMessage(color, isAlive, playerTeam)    // Sends the colored message

    return PLUGIN_CONTINUE
}


public set_color(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newColor
    read_argv(1, arg, 1)

    newColor = str_to_num(arg)

    if(newColor >= 1 && newColor <= 5)
    {
        set_pcvar_num(g_MessageColor, newColor)

        if(get_pcvar_num(g_NameColor) != 1 &&
            ((newColor == 3 &&  get_pcvar_num(g_NameColor) != 3)
            ||(newColor == 4 &&  get_pcvar_num(g_NameColor) != 4)
            ||(newColor == 5 &&  get_pcvar_num(g_NameColor) != 5)))
        {
            set_pcvar_num(g_NameColor, 2)
        }
    }

    return PLUGIN_HANDLED
}


public set_name_color(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newColor
    read_argv(1, arg, 1)

    newColor = str_to_num(arg)

    if(newColor >= 1 && newColor <= 6)
    {
        set_pcvar_num(g_NameColor, newColor)

        if((get_pcvar_num(g_MessageColor) != 1
            &&((newColor == 3 &&  get_pcvar_num(g_MessageColor) != 3)
            ||(newColor == 4 &&  get_pcvar_num(g_MessageColor) != 4)
            ||(newColor == 5 &&  get_pcvar_num(g_MessageColor) != 5)))
            || get_pcvar_num(g_NameColor) == 6)
        {
            set_pcvar_num(g_MessageColor, 2)
        }
    }

    return PLUGIN_HANDLED
}


public set_listen(id, level, cid)
{
    if(!cmd_access(id, level, cid, 2))
        return PLUGIN_HANDLED

    new arg[1], newListen
    read_argv(1, arg, 1)

    newListen = str_to_num(arg)

    set_pcvar_num(g_AdminListen, newListen)

    return PLUGIN_HANDLED
}


public sendMessage(color[], alive)
{
    new teamName[10]

    for(new player = 1; player < maxPlayers; player++)
    {
        if(!is_user_connected(player))
            continue

        if(alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ADMIN_LISTEN)
        {
            get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
            changeTeamInfo(player, color)        // Changes user's team according to color choosen
            writeMessage(player, message)        // Writes the message on player's chat
            changeTeamInfo(player, teamName)    // Changes user's team back to original
        }
    }
}


public sendTeamMessage(color[], alive, playerTeam)
{
    new teamName[10]

    for(new player = 1; player < maxPlayers; player++)
    {
        if(!is_user_connected(player))
            continue

        if(get_user_team(player) == playerTeam || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ADMIN_LISTEN)
        {
            if(alive && is_user_alive(player) || !alive && !is_user_alive(player) || get_pcvar_num(g_AdminListen) && get_user_flags(player) & ADMIN_LISTEN)
            {
                get_user_team(player, teamName, 9)    // Stores user's team name to change back after sending the message
                changeTeamInfo(player, color)        // Changes user's team according to color choosen
                writeMessage(player, message)        // Writes the message on player's chat
                changeTeamInfo(player, teamName)    // Changes user's team back to original
            }
        }
    }
}


public changeTeamInfo(player, team[])
{
    message_begin(MSG_ONE, teamInfo, _, player)    // Tells to to modify teamInfo(Which is responsable for which time player is)
    write_byte(player)                // Write byte needed
    write_string(team)                // Changes player's team
    message_end()                    // Also Needed
}


public writeMessage(player, message[])
{
    message_begin(MSG_ONE, sayText, {0, 0, 0}, player)    // Tells to modify sayText(Which is responsable for writing colored messages)
    write_byte(player)                    // Write byte needed
    write_string(message)                    // Effectively write the message, finally, afterall
    message_end()                        // Needed as always
} 


//================================= End of Advanced Chat System

//================================================ Register System====================


public cmdDoRegister(id)
{

		new szKey[ 100 ] , szUName[ 33 ];
		get_user_name( id ,  szUName , charsmax( szUName ) );

		formatex( szKey , charsmax( szKey ) , "%s-XPPasss",  szUName );
		nvault_get( gVault2 , szKey , szUName , charsmax( szUName ) );
		//server_print("%s",szUName);
		if(equali(szUName,""))
		{
			new szArgs[ 255 ] , szKey[ 100 ];
			new szName[ 33 ];
			read_args( szArgs , charsmax( szArgs ) );
			remove_quotes( szArgs );
			
			
			
			get_user_name( id ,  szName , charsmax( szName ) );
			formatex( szKey , charsmax( szKey ) , "%s-XPPass",  szName );
			nvault_set( gVault2 , szKey , szArgs );
		}	
		else
		{
			ColorChat(id,"!g-=%s XP =- !nYou have !nalready !gRegistered!! say /login to login.",svTag)
		}

}

public checkRegistered(id)
{

		
			set_hudmessage(0, 255, 0, 0.0, 0.67, 0, 6.0, 12.0)
			show_hudmessage(id, "Type Password ^n To Protect your nick XP")

			ColorChat(id,"!g=- %s Registeration =- !gEnter a password !tTo protect your Nick XP",svTag)
			client_cmd(id,"messagemode doRegister")
}




//====================================== End of register System


//Login System

//Take password	
public cmdDoLogin(id)
{
			ColorChat(id,"!g=- %s Login =- !gEnter your password to access %s Shop.",svTag,svTag)
			client_cmd(id,"messagemode doLogin")
}

public cmdLogin(id)
{
		new szArgs[256]
		read_args(szArgs,256)
		remove_quotes(szArgs)
		
		new szKey[ 100 ] , szName[ 33 ];
		get_user_name( id ,  szName , charsmax( szName ) );

		formatex( szKey , charsmax( szKey ) , "%s-XPPass",  szName );
		nvault_get( gVault2 , szKey , szName , charsmax( szName ) );     
		//client_print( id , print_chat , "* Your pass = %s" , szName ); 
		
		if(equali(szArgs,szName,255))
		{
			
			ColorChat(id,"!g=- %s Shop =- !t You have !glogged in to !tthe system.",svTag)
			login[id]=true
			
		}
		else
		{
			ColorChat(id,"!g=- %s Shop =- !tIncorrect !gPassword.",svTag)
			login[id]=false
		}
		
	

}
//================================================ Shop System =========================
public ShowMenu(id)
{

		new szArgs[256]
		read_args(szArgs,256)
		remove_quotes(szArgs)
		
		new szKey[ 100 ] , szName[ 33 ];
		get_user_name( id ,  szName , charsmax( szName ) );

		formatex( szKey , charsmax( szKey ) , "%s-XPPass",  szName );
		nvault_get( gVault2 , szKey , szName , charsmax( szName ) );  
		
		new menu = menu_create("XP Shop", "xp_shopMenu");
	
		if(equali(szName,""))
		{
			ColorChat(id,"!g=- %s XP=- !tYou !nhave !gto be !gregistered !nby !tsaying !g/reg ",svTag)
			set_hudmessage(0, 255, 0, 0.18, 0.31, 0, 6.0, 12.0)
			show_hudmessage(id, "Say /reg to Register to access %s Shop",svTag)
		}	
		else
		{	
			
			if(login[id]==true)
			{
				if(shopUsed[id]==false)
				{
					
					if(PlayerXP[id]<200 && PlayerLevel[id] < 2)
					{
						menu_additem(menu, "Buy 50 Health(Locked)", "", 0); // case 0
						menu_additem(menu, "Buy 200 Armor(Locked) ", "", 0); // case 1
					}
					else
					{
						menu_additem(menu, "Buy 50 Health", "", 0); // case 0
						menu_additem(menu, "Buy 200 Armor", "", 0); // case 1
					}
					if(PlayerXP[id]<400 && PlayerLevel[id] < 4)
					{
						menu_additem(menu, "Buy Speed(Locked)", "", 0); // case 2
				
					}
					else
					{
						menu_additem(menu, "Buy Speed", "", 0); // case 2
					}
					if(PlayerXP[id]<600 && PlayerLevel[id] < 5)
					{
						menu_additem(menu, "Buy Gravity(Locked)", "", 0); // case 3
					}
					else
					{
						menu_additem(menu, "Buy Gravity", "", 0); // case 3
					}
					if(PlayerXP[id]<1200 && PlayerLevel[id] < 11)
					{
						menu_additem(menu, "Buy Respawn(Locked)", "", 0); // case 4
					}
					else
					{
						menu_additem(menu, "Buy Respawn", "", 0); // case 4
					}
					if(PlayerXP[id]<1400 && PlayerLevel[id] < 13)
					{
						menu_additem(menu, "Buy Invisibility(Locked)", "", 0); // case 5
					}
					else
					{
						menu_additem(menu, "Buy Invisibility", "", 0); // case 5
					}
					if(PlayerXP[id]<1600 && PlayerLevel[id] < 14)
					{
						menu_additem(menu, "Buy No-Clip(Locked)", "", 0); // case 6
					}
					else
					{
						menu_additem(menu, "Buy No-Clip", "", 0); // case 6
					}
					menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
					menu_setprop(menu, MPROP_PERPAGE, 5);

					menu_display(id, menu, 0);
				}
				else
				{
					ColorChat(id,"!g=- %s Shop =-  !tYou can use !gShop !nAt only !gonce in the round",svTag)
				}
			}
			else
			{
				set_hudmessage(255, 255, 0, 0.0, 0.75, 0, 6.0, 12.0)
				show_hudmessage(id, "say /login to login first to access shop.")

				ColorChat(id,"!g=-%s Sop =- !tYou have to !nlogged in with the !tcorrect password.Say /shop to access shop.",svTag)
			}
			
		}
	
	return PLUGIN_HANDLED;
}
public xp_shopMenu(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_cancel(id);
		return PLUGIN_HANDLED;
	}

	new command[6], name[64], access, callback;

	menu_item_getinfo(menu, item, access, command, sizeof command - 1, name, sizeof name - 1, callback);

	switch(item)
	{
		case 0:
		
		if(PlayerXP[id]<200 && PlayerLevel[id] < 2)
		{
			ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)
		}
		else
		{
			if(is_user_alive(id))
			{
				new SetHP
				iHp = get_user_health(id)
				SetHP = iHp + 50
				set_user_health(id,SetHP)
				PlayerXP[id] -= 70
				ColorChat(id,"!g=- %s Shop =- !t You bought !g Heath !t Successfully!",svTag)
				shopUsed[id]=true
			}
			else
			{
				ColorChat(id,"!g=- %s Shop =- !t You need !gto be alive !!",svTag);
			}
		}
		case 1: 
		if(PlayerXP[id]<200 && PlayerLevel[id] <3)
		{
		
			ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)
		
		}
		else
		{
			if(is_user_alive(id))
			{
				cs_set_user_armor(id,200,CS_ARMOR_VESTHELM)
				PlayerXP[id] -= 50
				ColorChat(id,"!g=- %s Shop =- !t You bought !g Armor !t Successfully!",svTag)
				shopUsed[id]=true
			}
			else
			{
				ColorChat(id,"!g=- %s Shop =- !t You need !g to be alive !!",svTag);
			}
		}
		
		
			case 2: 
			if(PlayerXP[id]<400 && PlayerLevel[id] < 4)
			{
				ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)
			}
			else
			{	
				if(is_user_alive(id))
				{
					g_bHasSpeedShop[id]=true
					remove_task(id + TASK_SPEED_ID)
					set_task(100.0, "taskRemoveShopSpeed", id + TASK_SPEED_ID)
					set_user_maxspeed(id, FAST_SPEED)
					PlayerXP[id] -= 70
					ColorChat(id,"!g=- %s Shop =- !t You bought !g Speed for 100 Second !t Successfully!",svTag)
					shopUsed[id]=true
				}
				else
				{
					ColorChat(id,"!g=- %s Shop =- !t You need !g to be alive !!",svTag);
				}
			}
			
		case 3:
			if(PlayerXP[id]<500 && PlayerLevel[id] < 5)
			{
				ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)
			}
			else
			{
				if(is_user_alive(id))
				{
					g_bHasGravity[id]=true
					remove_task(id + TASK_GRAVITY_ID)
					set_task(100.0,"taskRemoveGravity",id + TASK_GRAVITY_ID)
					set_user_gravity(id, 0.25) // (.40 x 800 = 200 )
					PlayerXP[id] -= 80
					ColorChat(id,"!g=- %s Shop =- !t You bought !g Gravity for 100 Second !t Successfully!",svTag)
					g_bHasGravity[id]=true
				}
				else
				{
					ColorChat(id,"!g=- %s Shop =- !t You need !gto be alive !!",svTag);
				}
			}
		case 4:
		
		if(PlayerXP[id]<1200 && PlayerLevel[id] < 11)
		{
			ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)	
		}
		else
		{
			ColorChat(id,"!g=- %s Shop =- !t You bought !g Respawn !t Successfully!",svTag)
			cs_user_spawn(id)
			PlayerXP[id] -= 120
			
		}
		case 5: 
		
		if(PlayerXP[id]<1400 && PlayerLevel[id] < 13)
		{
			ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)	
		}
		else
		{
			if(is_user_alive(id))
			{
					g_bHasInvi[id] = true
					remove_task(id + TASK_INVI_ID)
					set_task(100.0,"taskRemoveInvi",id + TASK_INVI_ID)
					static kRndMode
					kRndMode = _:kRenderTransAlpha 
					//kRndMode =  _:kRenderNormal 
					set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRndMode, 0 )
					ColorChat(id,"!g=- %s Shop =- !t You bought !g Invisibility for 100 Second !t Successfully!",svTag)
					PlayerXP[id] -= 150
			}
			else
			{
				ColorChat(id,"!g=- %s Shop =- !t You need !gto be alive !!",svTag);
			}
			
		}
		
		case 6:
		if(PlayerXP[id]<1600 && PlayerLevel[id] < 14)
		{
			ColorChat(id,"!g=- %s Shop =- !t You don't Have !g enough XP and !t Level!",svTag)	
		}
		else
		{
			if(is_user_alive(id))
			{
					set_user_noclip(id,1)
					remove_task(id + TASK_NOCLIP_ID)
					set_task(100.0,"taskRemoveNoClip",id + TASK_NOCLIP_ID) 
					ColorChat(id,"!g=- %s Shop =- !t You bought !g No Clip for 100 Second !t Successfully!",svTag)
					PlayerXP[id] -= 200
			}
			else
			{
				ColorChat(id,"!g=- %s Shop =- !t You need !gto be alive !!",svTag);
			}
			
		}
	}
	CheckLevel(id)
	menu_destroy(menu);
	//menu_display(id, menu, 0);
	
	return PLUGIN_HANDLED;
}

//=============== End of Menu ==================

//========== shop speed remove
public taskRemoveShopSpeed(id)
{
    id -= TASK_SPEED_ID
    g_bHasSpeedShop[id] = false
    set_user_maxspeed(id, 241.0)
	ColorChat(id,"!tYour !gfast speed !tremoved!")
} 

//====== Shop Gravity remove

public taskRemoveGravity(id)
{
    id -= TASK_GRAVITY_ID
    g_bHasGravity[id]= false
	set_user_gravity(id, 1.0) 
	ColorChat(id,"!tYour !gGravity !tremoved!")
} 

//============ Shop Invisibility Remove

public taskRemoveInvi(id)
{
	id -= TASK_INVI_ID
	g_bHasInvi[id] = false
	static kRndMode
	//kRndMode = _:kRenderTransAlpha 
	kRndMode =  _:kRenderNormal 
	set_user_rendering( id, kRenderFxNone, 0, 0, 0, kRndMode, 0 )
	ColorChat(id,"!tYour !gInvisibility !tremoved!")
}

//============ Shop No Clip Remove

public taskRemoveNoClip(id)
{
	id -= TASK_NOCLIP_ID
	set_user_noclip(id,0)
}

//================ Plugin End ========

public plugin_end()
{
   
    nvault_close(gVault)
    nvault_close(gVault2)
}
