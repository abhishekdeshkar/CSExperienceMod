#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <nvault>  
#include <csx> 
#include <fakemeta>
#include <engine>
#include <fakemeta_util>
#include <nvault_util> 

#define PLUGIN "EXP Level"
#define VERSION "1.0"
#define AUTHOR "Abhishek"

#pragma tabsize 0
#define MAX_PLAYERS	32
#define MAXLEVELS 19
#define nvault_clear(%1) nvault_prune(%1, 0, get_systime() + 1) 
#define TASKSPEC_INFO	5689745

new const gVaultNames[ ]  	=	"XP_names"
new gVault

new PlayerPass[32]

const TOPRANKS = 10
new iPlayerXP [ TOPRANKS + 1 ]
new TopNames [ TOPRANKS + 1 ]  

new g_iMsgidSayText;

new PlayerXP[33],PlayerLevel[33]
new XP_Kill,XP_Knife,XP_Hs,XP_rampagekill,XP_megakill
new XP_lostKill,XP_lostHs,XP_lostKnife,XP_losthe
new XP_save 
new XP_plant,XP_defuse,XP_he,xp_PointsHour
new g_vault
new namech
new pCvar;
new g_iKills[32], g_iHS[32], g_iDmg[32] 
new toggle_spree
new kills[33], deaths[33]
new doublekills[33], multikills[33], spree[33]
new Float:spreetime[33]	
new XP_spawn,XP_got,XP_drop
new HudSync_SpecInfo
new g_iWonPointsTerrorists
new g_iWonPointsCounterTerrorists
new g_iLostPointsTerrorists
new g_iLostPointsCounterTerrorists
new g_iK
new g_iAdsOnChat
new g_TimeBetweenAds

new const g_ChatAdvertise[ ][ ] = {
	"!g]-=[T[S]K]=-[ !nCheck xp command:!g/xp,/topxp,/class,/xpall,/xpinfo !t!!",
	"!g]-=[T[S]K]=-[ !nCheck TP command:!g/pro,/bot,/lol,/mml !t!!",
	"!g]-=[T[S]K]=-[ !nCheck Servers command:!g/server,/ip,/rate,/match,/freeadmin !t!!",
	"!g]-=[T[S]K]=-[ !nCheck stats command:!g/rank,/top15,/hp,/me !t!!"
}


new const LEVELS[MAXLEVELS] = {
	100, // Noob Nigga I 
	200, // Noob Nigga II 
	300, // Casual I 
	400, // Casual II
	500, // Junior I
	600, // Junior II
	700, // Senior Sir I 
	800, // Senior Sir II
	900,  // Strategist I
	1111,  // Strategist II
	1222, // Gang Leader I
	1444, // Gang Leader II
	1666, // Global Assasin I
	1888, // Global Assasin II
	1999, // Hardcore Player I 
	2222, // Hardcore Player II
	2333, // Professional I
	2444, // Professional II
	2555 // Professional III
} 

new const Prefix[MAXLEVELS +1][]=
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
	register_clcmd("say /xpall","show_top")
	register_clcmd("say xpall","show_top")
	register_clcmd("say /topxp","CmdTopShow")
	register_clcmd("say topxp","CmdTopShow")
	register_clcmd("say xp" ,"PrintXp")
	register_clcmd("say class" ,"Printclass")
	register_clcmd("say /class", "Printclass")
	register_clcmd("say xpinfo" ,"InfoXp")
	register_clcmd("say /xpinfo", "InfoXp")
	register_clcmd("say /resetxp", "Cmd_Resetxp")
	register_clcmd("say /test", "Cmd_test")

	//admin command
	register_concmd("amx_givexp" ,"CmdGiveXp",ADMIN_RCON,"Add xp to a player");
	register_concmd("amx_takexp", "CmdTakeXp",ADMIN_RCON,"Remove xp from a player");

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

	//cvar
	pCvar = register_cvar( "amx_auto_live", "1");
	XP_Kill = register_cvar("xp_kill","2");
	XP_lostKill = register_cvar("xp_lostkill","2");
	XP_Hs = register_cvar("xp_hs","4");
	XP_lostHs = register_cvar("xp_losths","4");
	XP_Knife = register_cvar("xp_knife","3");
	XP_lostKnife = register_cvar("xp_lostknife","3");
	XP_plant = register_cvar("xp_plant","5");
	XP_defuse = register_cvar("xp_defuse","5");
	xp_PointsHour = register_cvar( "XP_points_hour", "10" );
	XP_save = register_cvar("xp_save" ,"1");
	XP_he=register_cvar("xp_he","3");
	XP_megakill = register_cvar("xp_megakill","6");
	XP_rampagekill = register_cvar("xp_rampagekill","7");
	toggle_spree = register_cvar("PS_spree","1");
	XP_losthe = register_cvar("xp_losthe","3");
	XP_spawn = register_cvar("XP_spawn","5");
	XP_drop = register_cvar("XP_drop","5");
	XP_got = register_cvar("XP_got","5");
	namech = register_cvar("name_change","1");
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
	g_vault=nvault_open("XpClasicMod") 
	g_iMsgidSayText = get_user_msgid("SayText");
	HudSync_SpecInfo= CreateHudSyncObj();
	CreateTopTen ( )

	gVault = nvault_open(gVaultNames)
}

public Cmd_test(id)
{
ColorChat(0,"Xp : %d | Level : %d | Pass : %s",PlayerXP[id],PlayerLevel[id],PlayerPass[id])
}

public client_putinserver(id) {
	
	if(get_cvar_num("XP_save")==1)	LoadXp(id)
	
	set_task(2.0,"ClientMsg",id);
	set_task(0.5, "Spec_Info", (id + TASKSPEC_INFO), _, _, "b");
	set_task (1800.0 ,"GiveXPHour", id);
}

public plugin_precache()
{
	HudSync_SpecInfo= CreateHudSyncObj();
}

public client_connect(id)
{
	format(PlayerPass[id],32,"Testing")
}

public client_disconnect(id)
{
	if(get_pcvar_num(XP_save))
	{
		SaveXp(id)	
		PlayerXP[id]=0     
		PlayerLevel[id]=0
		g_iDmg[id] = 0;  
		g_iKills[id] = 0;  
		g_iHS[id] = 0;
		remove_task( id );	
	}
}

public fwClientUserInfoChanged(id,buffer) {
	
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
	
	console_print(id,"[-=[T[S]K]=- Xp]Name change is disabled on this server.")
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
	new iBestPlayer = get_best_player()  
	new attacker=read_data(1)
	new attacker_name[32]
	get_user_name(attacker,attacker_name,31)
	
	new szName[32]  
	get_user_name(iBestPlayer, szName, charsmax(szName)) 
	
	PlayerXP[iBestPlayer] += get_pcvar_num(xp_PointsHour)
	ColorChat(0,"!g]-=[T[S]K]=- xp[ !nRound Destructive Player:!g%s !n[ !g%i!t kills!n / !g%i!t Hs!n / !g%i!t Dmg!n ] !tAwarded !g%i !tXP",szName, g_iKills[iBestPlayer], g_iHS[iBestPlayer],g_iDmg[iBestPlayer],get_pcvar_num(xp_PointsHour)) 
	
	for(new i; i < 31; i++)  
	{  
		g_iDmg[i] = 0;  
		g_iHS[i] = 0;  
		g_iKills[i] = 0;  
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
/*  
public LoadXp(id)
{
	new name[32]
	get_user_name(id,name,31)
	new vaultkey[64],vaultdata[256]
	format(vaultkey,63,"%s-XpClasicMod",name)
	format(vaultdata,255,"%s#%i#%i#%s#",name,PlayerXP[id],PlayerLevel[id],PlayerPass[id])
	nvault_get(g_vault,vaultkey,vaultdata,255)
	replace_all(vaultdata, 255, "#", " ")
	new playerxp[33], playerlevel[33] , playerpass[33]
	parse(vaultdata, playerxp, 32, playerlevel, 32,playerpass,32)
	PlayerXP[id] = str_to_num(playerxp)
	PlayerLevel[id] = str_to_num(playerlevel)
	PlayerPass[id] = playerpass
	server_print("%s",playerpass)
	return PLUGIN_CONTINUE
} 

public SaveXp(id)
{
	new name[32]
	get_user_name(id,name,31)
	new vaultkey[64],vaultdata[256]
	format(vaultkey,63,"%s-XpClasicMod",name)
	format(vaultdata,255,"%s#%i#%i#%s#",name,PlayerXP[id],PlayerLevel[id],PlayerPass[id])
	server_print("%s",PlayerPass[id])
	nvault_set(g_vault,vaultkey,vaultdata)
	return PLUGIN_CONTINUE
}
*/

public SaveXp(id)
{
new name[32]
get_user_name(id,name,31)
new vaultkey[64],vaultdata[256]
format(vaultkey,63,"%s",name)
format(vaultdata,255,"%i#%i#%s#",PlayerXP[id],PlayerLevel[id],PlayerPass[id])
server_print("Save : %s",PlayerPass[id])
nvault_set(g_vault,vaultkey,vaultdata)
return PLUGIN_CONTINUE
}


public LoadXp(id)
{
new name[32]
get_user_name(id,name,31)
new vaultkey[64],vaultdata[256]
format(vaultkey,63,"%s",name)
format(vaultdata,255,"%i#%i#%s#",PlayerXP[id],PlayerLevel[id],PlayerPass[id])
nvault_get(g_vault,vaultkey,vaultdata,255)
replace_all(vaultdata, 255, "#", " ")
new playerxp[33], playerlevel[33] , playerpass
parse(vaultdata, playerxp, 32, playerlevel, 32,playerpass,32)
PlayerXP[id] = str_to_num(playerxp)
PlayerLevel[id] = str_to_num(playerlevel)
PlayerPass[id] = playerpass
server_print("Load : %s",playerpass)
return PLUGIN_CONTINUE
}


public ClientMsg(id)
{
	if( get_pcvar_num( pCvar ) )
	{
	    new name[32]
		get_user_name(id,name,31) //try now
		ColorChat(0,"!g]-=[T[S]K]=- xp[ !nPlayer:!t%s!n || !tXP:!g%i!n || !tLevel:!g%i!n || !tclass:!g%s !tis connected." ,name, PlayerXP[id], PlayerLevel[id],Prefix[PlayerLevel[id]]) 
		ColorChat(id,"!g]-=[T[S]K]=- xp[ !nCheck xp command:!g/xp,/topxp,/class,/xpall,/xpinfo !!! !tby 26-{indra}")
		ShowMsg(id)
	}
	
}

public ShowMsg(id)
{
	set_hudmessage(0,255, 0, 0.30, 0.85, 1, 6.0, 6.0);
	show_hudmessage(id,"Check xp command:/xp,/topxp,/class,/xpall,/xpinfo !!tby 26-{indra}")
}

public GiveXPHour( id )
{
	PlayerXP[id] += get_pcvar_num(xp_PointsHour) 
	ColorChat(id,"!g]-=[T[S]K]=- xp[ !nYou got !g%i !nXP for playing more !thalf hour!!",get_pcvar_num( xp_PointsHour))
}

public PrintXp(id) 
{ 
	ColorChat(id,"!g]-=[T[S]K]=- xp[ !tYour stats- XP:!g%i!n || !tlevel:!g%i!n || !tclass:!g%s!n || !tNeeded XP:!g%i",PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],LEVELS[PlayerLevel[id]]-PlayerXP[id])
	ShowHud(id) 
}

public ShowHud(id)
{
	set_hudmessage(0,255, 0, 0.30, 0.85, 1, 6.0, 6.0);
	show_hudmessage(id,"Your stats- XP:%i || level:%i || class:%s || Needed XP:%i",PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],LEVELS[PlayerLevel[id]]-PlayerXP[id])
}

public Printclass(id) 
{ 
	ColorChat(id,"!g]-=[T[S]K]=-[ !tYour stats- !tclass:!g%s!n || !tNext class:!g%s",Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1])
	ShowClass(id)
}

public ShowClass(id)
{
	set_hudmessage(0,255, 0, 0.30, 0.85, 1, 6.0, 6.0);
	show_hudmessage(id,"Your stats- class:%s|| Next class:%s",Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1])
}

public logevent_roundstart( )
{
	new Players[ MAX_PLAYERS ], iNum, id;
	get_players( Players, iNum, "ch" );
	
	while( --iNum >= 0 )
	{
		id = Players[ iNum ];
		set_spree(id)
        reset_spree(id)
		set_hudmessage( 000, 160, 000, 0.0, 0.21, 0, 90.0, _, 0.0, 0.0 );
		show_hudmessage( id,"]-=[T[S]K]=- XP[^n[ XP ]: %i^n[ Level ]: %i^n[ Class ] : %s^n[ Next class ]: %s",PlayerXP[id],PlayerLevel[id],Prefix[PlayerLevel[id]],Prefix[PlayerLevel[id]+1]);
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
	
	if( g_iK >= sizeof g_ChatAdvertise )
	{
		g_iK = 0
	}
}

public Spec_Info(id)
{
	id -= TASKSPEC_INFO;
	if(is_user_alive(id)) 
	remove_task(TASKSPEC_INFO + id);
	else
	{
		new iSpecPlayer = entity_get_int(id, EV_INT_iuser2);
		new iSpecMode = entity_get_int(id, EV_INT_iuser1);
		
		new iSpecPlayer_Name[32]; get_user_name(iSpecPlayer, iSpecPlayer_Name, charsmax(iSpecPlayer_Name));
		
		if(iSpecMode == 1 || iSpecMode == 2 || iSpecMode == 4)
		{
			set_hudmessage(255, 255, 255, 0.01, 0.90, 2, 0.05, 2.0, 0.01, 3.0, -1);
			ShowSyncHudMsg(id, HudSync_SpecInfo, "Spectating: %s ^n[ XP : %i | Level : %i | class : %s ]", iSpecPlayer_Name, PlayerXP[ iSpecPlayer ], PlayerLevel[ iSpecPlayer ],Prefix[PlayerLevel[iSpecPlayer]]);
			
		}
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
    read_data(4, weapon, sizeof(weapon) -1) 
	{
		if(headshot)
		{
			PlayerXP[attacker] += get_pcvar_num(XP_Hs)  
			ColorChat(attacker,"!g[-=[T[S]K]=- Xp[ !nYou got !g%i !nXP for killing with headshot on !g%s!t.",get_pcvar_num(XP_Hs),Victim_name)	
			PlayerXP[Victim] -= get_pcvar_num(XP_lostHs)
			ColorChat(Victim,"!g]-=[T[S]K]=- Xp[ !nYou lost !g%i !nXP for dying with headshot on !g%s!t.",get_pcvar_num(XP_lostHs),attacker_name)
		}
		else
		{
			PlayerXP[attacker] += get_pcvar_num( XP_Kill ) 
			ColorChat(attacker,"!g]-=[T[S]K]=- Xp[ !nYou got !g%i !nXP for killing on !g%s!t.",get_pcvar_num(XP_Kill),Victim_name)
			PlayerXP[Victim] -= get_pcvar_num( XP_lostKill ) 
			ColorChat(Victim,"!g]-=[T[S]K]=- Xp[ !nYou lost !g%i !nXP for dying on !g%s!t.",get_pcvar_num(XP_lostKill),attacker_name)
		}
		if(equali(weapon, "knife")) 
		{
			PlayerXP[attacker] += get_pcvar_num(XP_Knife)  
			ColorChat(attacker,"!g]-=[T[S]K]=- Xp[ !nYou got !g%i !nXP for killing with knife on !g%s!t.",get_pcvar_num(XP_Knife),Victim_name)	
			PlayerXP[Victim] -= get_pcvar_num(XP_lostKnife)  
			ColorChat(Victim,"!g]-=[T[S]K]=- Xp[ !nYou lost !g%i !nXP for dying with knife on !g%s!t.",get_pcvar_num(XP_lostKnife),attacker_name) 
			set_hudmessage(r, g, b, 0.07, 0.67, 1, 6.0, 6.0, 0.1, 0.2, -1)
            show_hudmessage(0,"%s just Kn!fed %s^nknife kerke kya mila babaji ka thullu!!!",attacker_name,Victim_name)			
		}
		if(equali(weapon, "grenade")) 
		{
			PlayerXP[attacker] += get_pcvar_num(XP_he) 
			ColorChat(attacker,"!g]-=[T[S]K]=- Xp[ !nYou got !g%i !nXP for killing with he grenade on !g%s!t.",get_pcvar_num(XP_he),Victim_name)		
			PlayerXP[Victim] -= get_pcvar_num(XP_losthe) 
			ColorChat(Victim,"!g]-=[T[S]K]=- Xp[ !nYou got !g%i !nXP for dying with he grenade on !g%s!t.",get_pcvar_num(XP_losthe),attacker_name)
			set_hudmessage(r, g, b, 0.07, 0.67, 1, 6.0, 6.0, 0.1, 0.2, -1)
            show_hudmessage(0,"%s just grenade on %s^nOmg :O what the phack!!!",attacker_name,Victim_name)	
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

public TerroristsWin(id)
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
					PlayerXP[id] += get_pcvar_num( g_iWonPointsTerrorists )
					{
						ColorChat( id,"!g]-=[T[S]K]=- Xp[ !nYour team !g(T)!n have won !g%i!n XP for winning the round !g(Y)!t.",get_pcvar_num( g_iWonPointsTerrorists ))
					}
				}
			}
			
			case( CS_TEAM_CT ):
			{
				if( get_pcvar_num( g_iLostPointsCounterTerrorists ) )
				{
					PlayerXP[id] -= get_pcvar_num( g_iLostPointsCounterTerrorists )
					{
						ColorChat( id,"!g]-=[T[S[K]=- Xp[ !nYour team !g(CT)!n have lost !g%i!n XP for losing the round !g(:()!t.", get_pcvar_num( g_iLostPointsCounterTerrorists ))
					}
				}
			}
		}
	}
	
}

public CounterTerroristsWin(id)
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
					PlayerXP[id] -= get_pcvar_num( g_iLostPointsTerrorists )
					{
						ColorChat( id,"!g]-=[T[S]K]=- Xp[ !nYour team !g(T)!n have lost !g%i!n XP for losing the round !g(:()!t.", get_pcvar_num( g_iLostPointsTerrorists ))
					}
				}
			}
			
			case( CS_TEAM_CT ):
			{
				if( get_pcvar_num( g_iWonPointsCounterTerrorists ) )
				{
					PlayerXP[id]  += get_pcvar_num( g_iWonPointsCounterTerrorists )
					{
						ColorChat( id,"!g]-=[T[S]K]=- Xp[ !nYour team !g(CT)!n have won !g%i!n XP for winning the round !g(Y)!t.", get_pcvar_num( g_iWonPointsCounterTerrorists ))
					}
				}
			}
		}
	}
	
}

public Playerspawn(id) 
{
	if((PlayerLevel[id] < 19 && PlayerXP[id] >= LEVELS[PlayerLevel[id]])) 
	{
		PlayerLevel[id] += 1
		ColorChat(id,"!g]-=[T[S]K]=- Xp[ !t Congratulations,now you have !g%i !n XP with level !g%i and Class:%s",PlayerXP[id],PlayerLevel[id],Prefix[LEVELS[id]])
	}
}

public bomb_planted(id)  
{
	new name[32]
	get_user_name(id,name,31)
	{
		PlayerXP[id] += get_pcvar_num(XP_plant) 
		ColorChat(0 ,"!g]-=[T[S]K]=- Xp[ %s !ngot !g%i !nXP for planting the bomb !g(c4)!t.", name, get_pcvar_num(XP_plant))	
	}
	return PLUGIN_HANDLED
}

public bomb_defused(id)  
{
	new name[32]
	get_user_name(id,name,31)
	{ 
		PlayerXP[id] += get_pcvar_num(XP_defuse)
		ColorChat(0 ,"!g]-=[T[S]K]=- Xp[ %s !ngot !g%i !nXP for defusing the bomb !g(c4)!t.",name, get_pcvar_num(XP_defuse))	
	}
	return PLUGIN_HANDLED
}

public logevent_spawnedwithbomb()
{
	new id = get_loguser_index()
	new szName[33]
	get_user_name(id, szName, charsmax(szName))
	{
		PlayerXP[id] += get_pcvar_num(XP_spawn)
		ColorChat(0,"!g]-=[T[S]K]=- Xp[ %s !ngot !g%i!n XP for getting spawned with bomb !g(c4)!t.",szName,get_pcvar_num(XP_spawn))
	}
}

public logevent_gotthebomb()
{
	new id = get_loguser_index()
	new szName[33]
	get_user_name(id, szName, charsmax(szName))
	{
		PlayerXP[id] += get_pcvar_num(XP_got)
		ColorChat(0,"!g]-=[T[S]K[=- Xp[ %s !ngot !g%i!n XP for picking up the dropped bomb !g(c4)!t.",szName,get_pcvar_num(XP_got))
	}
}

public logevent_dropthebomb()
{
	new id = get_loguser_index()
	new szName[33]
	get_user_name(id, szName, charsmax(szName))
	{
		PlayerXP[id] -= get_pcvar_num(XP_drop)
		ColorChat(0,"!g]-=[T[S]K[=- Xp[ %s !nlost !g%i!n XP for dropping the bomb !g(c4)!t.",szName,get_pcvar_num(XP_drop))
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
	
	show_motd
	
	(id,"/addons/amxmodx/configs/inf.txt")	
	
}

public CmdGiveXp(id) { 
	
	if( get_user_flags( id ) & 
			
			ADMIN_RCON ) {
		
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
	
	else {
		
		
		
		client_print(id,print_console,"You have no acces to that command")
		
		return PLUGIN_HANDLED
		
		
	}
	
	return PLUGIN_HANDLED
	
}

public CmdTakeXp(id) { 
	
	if(get_user_flags(id) 
			
			& ADMIN_RCON ) {
		
		
		new PlayerToTake[32], XP[32]
		read_argv
		
		(1,PlayerToTake,31 )
		read_argv(2,XP,31 )
		new Player = cmd_target(id,PlayerToTake,9)
		
		if(!Player) {
			
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
	
	else {
		
		client_print(id,print_console,"You hav no acces to that command.")
		
		return PLUGIN_HANDLED
		
	}
	
	return PLUGIN_HANDLED
	
}

public show_top(id)
{
	static Sort[33][2];
	new players[32],num,count,index;
	get_players(players,num);
	
	for(new i = 0; i < num; i++){
		index = players[i];
		Sort[count][0] = index;
		Sort[count][1] = PlayerXP[index];
		count++;
	}
	
	SortCustom2D(Sort,count,"compare_xp");
	new motd[512],iLen;
	iLen = format(motd, sizeof motd - 1,"<body bgcolor=#000000><font color=#98f5ff><pre>");
	iLen += format(motd[iLen], (sizeof motd - 1) - iLen,"%s %-22.22s %3s^n^n", "#", "Name", "Xp");
	
	new y = clamp(count,0,10);
	new name[32],kindex;
	
	for(new x = 0; x < y; x++){
		kindex = Sort[x][0];
		get_user_name(kindex,name,sizeof name - 1);
		iLen += format(motd[iLen], (sizeof motd - 1) - iLen,"%d %-22.22s %d^n^n", x + 1, name, Sort[x][1]);
	}
	iLen += format(motd[iLen], (sizeof motd - 1) - iLen,"</body></font></pre>");
	show_motd(id,motd, "XP ALL");
}

public compare_xp(elem1[], elem2[])
{
	if(elem1[1] > elem2[1])
	return -1;
	else if(elem1[1] < elem2[1])
	return 1;
	
	return 0;
}

public CreateTopTen ( )
{
    new Array:aNames, Array:aAuths, Array:aPlayerXP
    new iTotal = SortTopPlayers ( aNames, aAuths, aPlayerXP )
    
    new szName [ 156 ], szAuth [ 156 ]
    
    for ( new i = 0; i < TOPRANKS; i++ )
    {
        if ( i < iTotal )
        {
            ArrayGetString ( aNames, i, szName, charsmax ( szName ) )
            ArrayGetString ( aAuths, i, szAuth, charsmax ( szAuth ) )
            replace_all ( szName, charsmax ( szName ), "&", "&amp;" )
            replace_all ( szName, charsmax ( szName ), "<", "&lt;" )
            replace_all ( szName, charsmax ( szName ), ">", "&gt;" )
            formatex ( TopNames [ i + 1 ], charsmax ( TopNames [ ] ), "%s", szName )
            iPlayerXP [ i + 1 ] = ArrayGetCell ( aPlayerXP, i )
        }
    }
    
    ArrayDestroy ( aNames )
    ArrayDestroy ( aAuths )
    ArrayDestroy ( aPlayerXP )
    
    return PLUGIN_HANDLED
}

public CmdTopShow ( id )
{
    new html_motd [ 2500 ], len
    
    len = formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<STYLE>body{background:#252525;color:#ofcbc2;font-family:sand-serif}table{width:100%%;font-size:16px}</STYLE><table cellpadding=2 cellspacing=0 border=0>" )
    len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "<tr align=center bgcolor=%52697B><th width=14%% align=left><font color=white> Rank: <th width=10%%> Name: <th width=10%%> Total XP:" )
    
    for ( new i =0; i < TOPRANKS; i++ )
    {
        if ( i == 0 || i == 2 || i == 4 || i == 6 || i == 8 )
        {
            len += formatex  ( html_motd [ len ], charsmax ( html_motd ) - len, "<tr align=center%s><td align=left><font color=white> %i. <td> %s <td> %i", " bgcolor=#252525", ( i + 1 ), TopNames [ i + 1 ], iPlayerXP [ i + 1 ] )
        }
        else
        {
            len += formatex  ( html_motd [ len ], charsmax ( html_motd ) - len, "<tr align=center%s><td align=left><font color=white> %i. <td> %s <td> %i", " bgcolor=#4F4F4F", ( i + 1 ), TopNames [ i + 1 ], iPlayerXP [ i + 1 ] )
        }
    }
    
    len += formatex ( html_motd [ len ], charsmax ( html_motd ) - len, "</table></body>" )
    
    show_motd ( id, html_motd, "#MM | Top10" )
    
    return PLUGIN_HANDLED
}

SortTopPlayers ( &Array:aNames, &Array:aSteamIDs, &Array:aPlayerXP )
{
    aNames = ArrayCreate ( 32 )
    aSteamIDs = ArrayCreate ( 35 )
    aPlayerXP = ArrayCreate ( 1 )
    
    new hVault = nvault_util_open ( "XpClasicMod" )
    new iCount = nvault_util_count ( hVault )
    new iPos
    new szSteamID [ 35 ], szPlayerXP [ 11 ], iTimeStamp, szName [ 32 ]
    
    for ( new i = 0; i < iCount; i++ )
    {
        iPos = nvault_util_read ( hVault, iPos, szSteamID, charsmax ( szSteamID ), szPlayerXP, charsmax ( szPlayerXP ), iTimeStamp )
        
        nvault_get ( gVault, szSteamID, szName, charsmax ( szName ) )
        
        ArrayPushString ( aNames, szName )
        ArrayPushString ( aSteamIDs, szSteamID )
        ArrayPushCell ( aPlayerXP, str_to_num ( szPlayerXP ) )
    }
    nvault_util_close ( hVault )
    
    new iPlayerXP
    for ( new i = 0, j; i < ( iCount - 1 ); i++ )
    {
        iPlayerXP = ArrayGetCell ( aPlayerXP, i )
        
        for ( j = i + 1; j < iCount; j++ )
        {
            if ( iPlayerXP < ArrayGetCell ( aPlayerXP, j ) )
            {
                ArraySwap ( aNames, i, j )
                ArraySwap ( aSteamIDs, i, j )
                ArraySwap ( aPlayerXP, i, j )
                
                i--
                break
            }
        }
    }
    return iCount
}  

public Cmd_Resetxp(id) {
	
	new gvault
	if(get_user_flags(id) & ADMIN_IMMUNITY) {
		nvault_clear(gvault)
		for(new i = 0; i < 33; i++) {
			PlayerXP[i] = 0
			PlayerLevel[i] = 0
		}
	} else {
		ColorChat(id,"!g]-=[T[S]K]=- xp[ !tYou do not have permissions to reset xp!n!")
	}
}

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
		show_hudmessage(0,"Double Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num( XP_Kill )
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making Double kills!!", get_pcvar_num( XP_Kill ))
	}
	if(spree[id] == 3)
	{	
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 3.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Triple Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_Knife) 
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making Triple kills!!", get_pcvar_num(XP_Knife))
	}	
	if(spree[id] == 4)
	{	
		set_hudmessage(r, g, b, 0.01, 0.52, 1, 6.0, 3.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Multi Kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_Hs) 
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making Four kills!!", get_pcvar_num(XP_Hs))
	}
	if(spree[id] == 5)
	{
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Ultra kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_plant)
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making F!ve kills!!", get_pcvar_num(XP_plant))
	}	
	if(spree[id] == 6)
	{
		set_hudmessage(r, g, b, 0.01, 0.52, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Mega kill: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_megakill)
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making Six kills!!", get_pcvar_num(XP_megakill))
	}
	if(spree[id] == 7)
	{
		set_hudmessage(r, g, b, 0.01, 0.56, 1, 6.0, 5.0, 0.1, 0.2, -1);
		show_hudmessage(0,"Rampage: %s", name);
		PlayerXP[attacker] += get_pcvar_num(XP_rampagekill)
		ColorChat(id, "!n]-=[T[S]K]=- Xp[ !gYou awarded %i XP for making Se7eN kills!!", get_pcvar_num(XP_rampagekill))
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
