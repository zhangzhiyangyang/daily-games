# 每日一个游戏（进阶版）
# 双击配套 BAT 文件运行。会创建桌面文件夹，并安排每天上午 9 点生成一款进阶小游戏。
$ErrorActionPreference = "Stop"
$root = Join-Path ([Environment]::GetFolderPath("Desktop")) "每日一个游戏"
$scriptPath = Join-Path $root "每日生成游戏.ps1"

if ($args.Count -eq 0) {
    New-Item -ItemType Directory -Path $root -Force | Out-Null
    Copy-Item -LiteralPath $PSCommandPath -Destination $scriptPath -Force
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -RunDaily"
    $trigger = New-ScheduledTaskTrigger -Daily -At 9:00AM
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
    Register-ScheduledTask -TaskName "每日一个游戏-自动生成" -Action $action -Trigger $trigger -Settings $settings -Description "每天生成一款进阶小游戏" -Force | Out-Null
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $scriptPath -RunDaily
    Write-Host "`n进阶版设置完成！每天上午 9 点生成一款小游戏。" -ForegroundColor Green
    Read-Host "按回车键退出"
    exit
}

$today = Get-Date -Format "yyyy-MM-dd"
$dayFolder = Join-Path $root $today
New-Item -ItemType Directory -Path $dayFolder -Force | Out-Null
$games = @(
@{
Name="星际生存：弹幕射击"
Html=@'
<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>星际生存</title><style>body{margin:0;background:#070b1a;color:#eef;font-family:system-ui;text-align:center}h1{margin:10px}canvas{background:radial-gradient(#18264a,#050814);display:block;margin:auto;max-width:96vw;border:1px solid #405080}p{margin:6px}</style><h1>🚀 星际生存</h1><p>方向键/WASD 移动，空格射击。躲避敌人，击落敌机！</p><p>生命：<b id="hp">3</b>　得分：<b id="score">0</b>　波次：<b id="wave">1</b></p><canvas id="c" width="800" height="520"></canvas><p><button onclick="start()">重新开始</button></p><script>
const c=document.querySelector('#c'),x=c.getContext('2d'),keys={};let p,shots,enemies,score,wave,alive,frame;
onkeydown=e=>{keys[e.key.toLowerCase()]=true;if(e.key===' ')e.preventDefault()};onkeyup=e=>keys[e.key.toLowerCase()]=false;
function start(){p={x:400,y:450,hp:3,cool:0,inv:0};shots=[];enemies=[];score=0;wave=1;alive=true;frame=0;requestAnimationFrame(loop)}
function loop(){if(!alive)return;frame++;x.clearRect(0,0,800,520);if(keys.arrowleft||keys.a)p.x-=5;if(keys.arrowright||keys.d)p.x+=5;if(keys.arrowup||keys.w)p.y-=5;if(keys.arrowdown||keys.s)p.y+=5;p.x=Math.max(18,Math.min(782,p.x));p.y=Math.max(20,Math.min(500,p.y));
if((keys[' ']||keys.enter)&&p.cool<=0){shots.push({x:p.x,y:p.y-15});p.cool=10}p.cool--;if(frame%Math.max(18,55-wave*2)===0){enemies.push({x:25+Math.random()*750,y:-20,v:1.4+Math.random()*1.6+wave*.15,hp:1+(wave>3?1:0)})}if(score>=wave*100)wave++;
shots.forEach(s=>{s.y-=8;x.fillStyle='#65f7ff';x.fillRect(s.x-2,s.y,4,12)});enemies.forEach(e=>{e.y+=e.v;x.fillStyle='#ff5577';x.beginPath();x.moveTo(e.x,e.y+14);x.lineTo(e.x-13,e.y-10);x.lineTo(e.x+13,e.y-10);x.fill()});
for(let i=enemies.length-1;i>=0;i--){let e=enemies[i];if(shots.some(s=>Math.abs(s.x-e.x)<15&&Math.abs(s.y-e.y)<15)){enemies.splice(i,1);score+=10;continue}if(Math.hypot(p.x-e.x,p.y-e.y)<24&&p.inv<=0){p.hp--;p.inv=50;enemies.splice(i,1);if(p.hp<=0){alive=false;alert('飞船被击毁！得分：'+score+'。点击重新开始再挑战。')}}else if(e.y>540){enemies.splice(i,1);if(p.inv<=0){p.hp--;p.inv=50;if(p.hp<=0){alive=false;alert('任务失败！得分：'+score)}}}}
p.inv--;x.fillStyle=p.inv>0?'#fff':'#61a8ff';x.beginPath();x.moveTo(p.x,p.y-18);x.lineTo(p.x-14,p.y+15);x.lineTo(p.x,p.y+8);x.lineTo(p.x+14,p.y+15);x.fill();document.querySelector('#hp').textContent=p.hp;document.querySelector('#score').textContent=score;document.querySelector('#wave').textContent=wave;if(alive)requestAnimationFrame(loop)}
start();
</script></html>
'@
},
@{
Name="迷宫寻宝：钥匙与机关"
Html=@'
<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>迷宫寻宝</title><style>body{font-family:system-ui;background:#151b24;color:#eee;text-align:center}canvas{width:min(90vw,600px);image-rendering:pixelated;border:2px solid #65758b}button{padding:10px;margin:3px}</style><h1>🗝️ 迷宫寻宝</h1><p>WASD/方向键移动。找到钥匙才能打开金色出口；绿色宝石加分，红色陷阱会扣血。</p><p>生命 <b id="hp">3</b>　宝石 <b id="g">0</b></p><canvas id="c" width="600" height="480"></canvas><p><button onclick="reset()">重新生成迷宫</button></p><script>
const c=document.querySelector('#c'),ctx=c.getContext('2d'),N=15,S=40;let map,player,key,exit,gems,traps,hp,got,score,won;onkeydown=e=>{let d={arrowup:[0,-1],w:[0,-1],arrowdown:[0,1],s:[0,1],arrowleft:[-1,0],a:[-1,0],arrowright:[1,0],d:[1,0]}[e.key.toLowerCase()];if(d)move(...d)};
function reset(){map=Array.from({length:N},()=>Array(N).fill(1));function carve(x,y){map[y][x]=0;let ds=[[0,-2],[2,0],[0,2],[-2,0]].sort(()=>Math.random()-.5);for(let [dx,dy] of ds){let nx=x+dx,ny=y+dy;if(nx>0&&ny>0&&nx<N-1&&ny<N-1&&map[ny][nx]){map[y+dy/2][x+dx/2]=0;carve(nx,ny)}}}carve(1,1);player={x:1,y:1};exit={x:13,y:13};map[13][13]=0;key={x:13,y:1};map[1][13]=0;gems=[];traps=[];for(let i=0;i<12;i++){let x=1+Math.floor(Math.random()*13),y=1+Math.floor(Math.random()*13);if(!map[y][x]&&(x!==1||y!==1)&&!(x===13&&y===13))gems.push({x,y})}for(let i=0;i<8;i++){let x=1+Math.floor(Math.random()*13),y=1+Math.floor(Math.random()*13);if(!map[y][x])traps.push({x,y})}hp=3;got=false;score=0;won=false;draw()}function move(dx,dy){if(won||hp<=0)return;let nx=player.x+dx,ny=player.y+dy;if(nx<0||ny<0||nx>=N||ny>=N||map[ny][nx])return;player={x:nx,y:ny};if(player.x===key.x&&player.y===key.y)got=true;let i=gems.findIndex(g=>g.x===nx&&g.y===ny);if(i>=0){gems.splice(i,1);score+=10}let t=traps.findIndex(g=>g.x===nx&&g.y===ny);if(t>=0){traps.splice(t,1);hp--}if(nx===exit.x&&ny===exit.y&&got){won=true;score+=50;alert('成功逃出迷宫！最终得分：'+score)}if(hp<=0)alert('生命耗尽！点击重新生成再挑战。');draw()}function draw(){ctx.clearRect(0,0,600,480);for(let y=0;y<N;y++)for(let x=0;x<N;x++){ctx.fillStyle=map[y][x]?'#344256':'#dce6ee';ctx.fillRect(x*S,y*S,S-1,S-1)}function dot(o,col,r=9){ctx.fillStyle=col;ctx.beginPath();ctx.arc(o.x*S+20,o.y*S+20,r,0,7);ctx.fill()}gems.forEach(g=>dot(g,'#20a779',6));traps.forEach(t=>dot(t,'#d94c5c',7));dot(key,got?'#8a98a8':'#f0c541',10);dot(exit,got?'#ffb347':'#8a98a8',12);dot(player,'#3878ed',12);document.querySelector('#hp').textContent=hp;document.querySelector('#g').textContent=score}reset();
</script></html>
'@
},
@{
Name="塔防指挥官"
Html=@'
<!doctype html><html lang="zh-CN"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>塔防指挥官</title><style>body{font-family:system-ui;text-align:center;background:#18241e;color:#eff8ee}canvas{max-width:96vw;background:#b8d4a3;border-radius:12px}button{padding:9px 14px;margin:4px;border:0;border-radius:8px;cursor:pointer}</style><h1>🛡️ 塔防指挥官</h1><p>点击地图放置炮塔（每座 50 金币）。阻止敌人抵达终点，撑过 10 波！</p><p>金币：<b id="money">150</b>　生命：<b id="life">10</b>　波次：<b id="wave">0</b></p><canvas id="c" width="700" height="420"></canvas><p><button id="next">开始下一波</button><button id="restart">重新开始</button></p><script>
const c=document.querySelector('#c'),ctx=c.getContext('2d');let towers,enemies,bullets,money,life,wave,running,spawned,tick;const path=[[-20,100],[160,100],[160,280],[350,280],[350,130],[530,130],[530,350],[720,350]];
function reset(){towers=[];enemies=[];bullets=[];money=150;life=10;wave=0;running=false;spawned=0;tick=0;draw()}restart.onclick=reset;next.onclick=()=>{if(running||life<=0||wave>=10)return;wave++;running=true;spawned=0;document.querySelector('#wave').textContent=wave};c.onclick=e=>{let r=c.getBoundingClientRect(),x=(e.clientX-r.left)*700/r.width,y=(e.clientY-r.top)*420/r.height;if(money>=50){towers.push({x,y,cool:0});money-=50;draw()}};function pos(e){let a=path[e.seg],b=path[e.seg+1];return{x:a[0]+(b[0]-a[0])*e.t,y:a[1]+(b[1]-a[1])*e.t}}function draw(){ctx.clearRect(0,0,700,420);ctx.strokeStyle='#e6c78c';ctx.lineWidth=34;ctx.lineCap='round';ctx.beginPath();path.forEach(([x,y],i)=>i?ctx.lineTo(x,y):ctx.moveTo(x,y));ctx.stroke();towers.forEach(t=>{ctx.fillStyle='#315fc4';ctx.beginPath();ctx.arc(t.x,t.y,17,0,7);ctx.fill();ctx.fillStyle='#eaf2ff';ctx.fillRect(t.x-4,t.y-21,8,20)});enemies.forEach(e=>{let p=pos(e);ctx.fillStyle='#b93d3d';ctx.beginPath();ctx.arc(p.x,p.y,11,0,7);ctx.fill();ctx.fillStyle='#222';ctx.fillRect(p.x-12,p.y-18,24,4);ctx.fillStyle='#65d16e';ctx.fillRect(p.x-12,p.y-18,24*e.hp/e.max,4)});bullets.forEach(b=>{ctx.fillStyle='#fff34a';ctx.beginPath();ctx.arc(b.x,b.y,4,0,7);ctx.fill()});ctx.fillStyle='#243c2d';ctx.font='14px system-ui';ctx.fillText('入口',8,70);ctx.fillText('终点',635,390);document.querySelector('#money').textContent=money;document.querySelector('#life').textContent=life}
function loop(){if(!running)return;tick++;if(spawned<wave*5&&tick%35===0){let hp=2+wave*.7;enemies.push({seg:0,t:0,hp,max:hp,speed:.008+wave*.0005});spawned++}enemies.forEach(e=>{let a=path[e.seg],b=path[e.seg+1],dist=Math.hypot(b[0]-a[0],b[1]-a[1]);e.t+=e.speed*2.4;if(e.t>=1){e.seg++;e.t=0;if(e.seg>=path.length-1){e.dead=true;life--}}});towers.forEach(t=>{t.cool--;if(t.cool<=0){let p=enemies.find(e=>{if(e.dead)return false;let q=pos(e);return Math.hypot(q.x-t.x,q.y-t.y)<105});if(p){let q=pos(p);bullets.push({x:t.x,y:t.y,target:p,tx:q.x,ty:q.y});t.cool=28}}});bullets.forEach(b=>{if(!b.target.dead){let p=pos(b.target);b.tx=p.x;b.ty=p.y}let dx=b.tx-b.x,dy=b.ty-b.y,d=Math.hypot(dx,dy)||1;b.x+=dx/d*7;b.y+=dy/d*7;if(d<9){b.target.hp-=1;b.dead=true;if(b.target.hp<=0&&!b.target.dead){b.target.dead=true;money+=12}}});enemies=enemies.filter(e=>!e.dead);bullets=bullets.filter(b=>!b.dead);draw();if(life<=0){running=false;alert('防线失守！你守到了第 '+wave+' 波。');return}if(spawned>=wave*5&&enemies.length===0){running=false;money+=25;if(wave>=10){alert('🎉 恭喜！你守住了全部 10 波！')} }else requestAnimationFrame(loop)}const oldNext=next.onclick;next.onclick=()=>{if(running||life<=0||wave>=10)return;wave++;running=true;spawned=0;tick=0;document.querySelector('#wave').textContent=wave;requestAnimationFrame(loop)};reset();
</script></html>
'@
}
)
$index = ([int](Get-Date -Format "yyyyMMdd")) % $games.Count
$game = $games[$index]
$htmlPath = Join-Path $dayFolder "index.html"
if (-not (Test-Path $htmlPath)) {
    Set-Content -LiteralPath $htmlPath -Value $game.Html -Encoding UTF8
    @"
日期：$today
游戏：$($game.Name)

今日开发挑战：
1. 先玩通关或坚持至少 3 分钟。
2. 阅读 index.html，找到控制移动、敌人、分数或波次的代码。
3. 修改一个数值，再观察游戏难度如何变化。
4. 自己增加一个新机制，并把改动写在本文件末尾。
"@ | Set-Content -LiteralPath (Join-Path $dayFolder "今日开发任务.txt") -Encoding UTF8
    @"
日期：$today
游戏：$($game.Name)
运行：双击 index.html，在浏览器中打开。
练习：今日开发任务.txt
"@ | Set-Content -LiteralPath (Join-Path $root "README-$today.txt") -Encoding UTF8
}
