HoN Forum scripts
=================

Some Perl cobbled together to get information from HoN threads---namely, information that's useful for Mafia games. The task is split into two steps: extraction and querying.

Before you query the data, you have to fetch and store it. This is so that you're not pounding on S2's servers retrieving the same information over and over again every time you want to look at it.

Quick Setup
-----------

All scripts require a thread ID as their first argument. Running scripts without arguments or with `-h` will give a full argument list.

```bash
sqlite3 HoN-Forum.db < schema.sql  # Filename is important here
perl scrape.pl 497393              # 497393 is the thread ID for game XII
perl user-post-info.pl 497383
```

If you try analysing a thread that you haven't scraped yet, you're gonna have a bad time.

Example Query Output
--------------------

Geting some information on users' activity in a thread:

```
$ perl user-post-info.pl 488154
Mafia XI - The Chains Of Deception (id: 488154)
===============================================

     Username  Last post          Total posts  Wordcount
--------------------------------------------------------
       TheJoo  23 May 2013 10:44  68           6407
  SmurfinBird  23 May 2013 10:29  138          18809
 SomethingOdd  23 May 2013 09:27  49           666
      lortaku  23 May 2013 02:43  34           1736
     Bloodaxe  23 May 2013 00:34  82           8400
   SuwakoChan  23 May 2013 00:11  21           2483
       Wololo  22 May 2013 22:30  26           1088
     Apostate  22 May 2013 20:39  144          22390
    scoutTier  22 May 2013 20:28  5            252
        Ekamo  22 May 2013 18:45  33           5297
  SavagePanic  22 May 2013 17:09  117          8261
      Rubidxx  22 May 2013 15:52  17           1060
    Kluckmuck  22 May 2013 13:38  50           5073
      Hubaris  08 May 2013 00:25  146          12938
      iNsania  06 May 2013 12:29  76           5729
     Sammerrz  05 May 2013 21:11  37           900
      TaeYeon  05 May 2013 16:13  123          30078
     Beanybag  03 May 2013 13:17  88           7623
        Emiya  02 May 2013 18:53  18           2807
     Reldnahc  02 May 2013 16:07  28           3018
      Friggey  21 Apr 2013 09:39  9            1311
 brachaalizah  21 Apr 2013 01:43  16           2367
        Tedde  17 Apr 2013 10:25  1            6
 EndGoodSmith  16 Apr 2013 08:34  42           653
 YawningAngel  10 Apr 2013 17:26  6            852

Data retrieved 23 May 2013 13:58 +0000
```

Getting a mafia game's vote history:

```
$ perl mafia-vote-history.pl 488154 TheJoo "Day 1"
Mafia XI - The Chains Of Deception (id: 488154)
===============================================

Day 1 [02 Apr 2013 13:54]      TaeYeon voted   Apostate
Day 1 [02 Apr 2013 20:51]      iNsania voted   Apostate
Day 1 [02 Apr 2013 21:04]        Emiya voted   YawningAngel
Day 1 [02 Apr 2013 21:20] EndGoodSmith voted   YawningAngel
Day 1 [02 Apr 2013 21:41]      TaeYeon unvoted Apostate
Day 1 [02 Apr 2013 21:41]      TaeYeon voted   Hubaris

...

Day 1 [16 Apr 2013 23:05]       Wololo voted   Ekamo
Day 1 [16 Apr 2013 23:10]      iNsania unvoted Ekamo
Day 1 [16 Apr 2013 23:10]      iNsania voted   Ekamo
Day 1 [16 Apr 2013 23:20]     Reldnahc voted   Ekamo
Day 1 [16 Apr 2013 23:37]      Friggey voted   Ekamo
Day 1 [16 Apr 2013 23:43]  SmurfinBird unvoted Beanybag
Day 1 [16 Apr 2013 23:43]  SmurfinBird voted   Ekamo
Day 2 [18 Apr 2013 23:12]      TaeYeon voted   Hubaris
Day 2 [18 Apr 2013 23:21]    Kluckmuck voted   hubaris
Day 2 [18 Apr 2013 23:50]     Beanybag voted   Hubaris
Day 2 [19 Apr 2013 03:13] SomethingOdd voted   Friggey
Day 2 [19 Apr 2013 03:16] SomethingOdd unvoted Friggey
Day 2 [19 Apr 2013 03:16] SomethingOdd voted   brachaalizah
Day 2 [19 Apr 2013 03:34]      TaeYeon unvoted Hubaris
Day 2 [19 Apr 2013 03:35]      Hubaris voted   brachaalizah
Day 2 [19 Apr 2013 03:55]     Apostate voted   Braachaliza

...

Day 4 [30 Apr 2013 18:13]  SmurfinBird voted   Lortaku
Day 4 [30 Apr 2013 19:53]     Bloodaxe voted   lortaku
Day 4 [01 May 2013 03:44]     Beanybag voted   lortaku
Day 4 [01 May 2013 06:05]     Beanybag unvoted lortaku
Day 4 [01 May 2013 06:26] SomethingOdd voted   Lortaku
Day 4 [02 May 2013 10:57]    Kluckmuck unvoted bloodaxe
Day 4 [02 May 2013 10:57]    Kluckmuck voted   lortaku
Day 4 [02 May 2013 12:14]      TaeYeon voted   lortaku
Day 5 [05 May 2013 16:13]      iNsania voted   TaeYeon
Day 5 [05 May 2013 16:13]      iNsania unvoted TaeYeon

Data retrieved 23 May 2013 13:58 +0000
```
