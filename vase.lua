-- title:  Vase
-- author: verysoftwares
-- desc:   tile-based collectathon
-- script: lua

t=0
x=2
y=7
pi=math.pi
sin=math.sin
cos=math.cos
ins=table.insert
rem=table.remove
fmt=string.format
sub=string.sub

plrflip=0

inventory={}

hidden={}

function inv_len()
		local i=1
		while fget(mget(x,y-i),2) do
				i=i+1
		end
		return i-1
end

function inv_rem()
		local i=1
		while fget(mget(x,y-i),2) do
				mset(x,y-i,mget(x,y-i-1))
				i=i+1
		end
		mset(x,y-i,0)
end

function move(dx)
		if can_turn(dx) then
				if dx<0 then plrflip=1 else plrflip=0 end

				dx=0
				local snd=false
				-- move inventory
				local i=1
				local ir=false
				while fget(mget(x,y-i),2) do
						if hidden[posstr(x+dx,y-i)] and hidden[posstr(x+dx,y-i)].id==12 and gates[posstr(x+dx,y-i)].count>0 then
								--hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
								ir=true
								gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
								local connect=gates[posstr(x+dx,y-i)].connect
								if connect then
								gates[connect].count=gates[connect].count-1
								end
								sfx(2,'E-4',30,2)
								snd=true
						end
						i=i+1
				end

				if ir then inv_rem() end
				if not snd then sfx(0,'E-1',6,2) end

				reveal_hidden()

				if not fget(mget(x,y+1),1) then fall() end
				return
		end
		if can_pickup(dx) then
				if dx<0 then plrflip=1 else plrflip=0 end
				--ins(inventory,{sp=mget(x-1,y)})
				if mget(x,y-1)==61 then
						local cx,cy=119,65
						while mget(cx,cy)>0 do
								cx=cx-1
								if cx==116 then cx=119; cy=cy-1 end
						end
						mset(cx,cy,mget(x+dx,y))
						mset(x+dx,y,0)
						sfx(1,'E-4',22,2)
						return
				end

				local oldy=y-inv_len()-1
				local old=mget(x,oldy)

				local i=inv_len()
				while fget(mget(x,y-i),2) and mget(x,y-i)~=33 do
						mset(x,y-i-1,mget(x,y-i))
						mset(x,y-i,0)
						i=i-1
				end

				mset(x,y-1,mget(x+dx,y))
				mset(x+dx,y,0)

				local i=1
				local ir=false
				while fget(mget(x,y-i),2) do
						if y-i==oldy and fget(old,3) then
								hidden[posstr(x,y-i)]={id=old,t=t}
								--trace(y-i)
								--trace(mget(x,y-i))
								--trace(old)
								--trace(gates[posstr(x,y-i)].id)
								if mget(x,y-i)==gates[posstr(x,y-i)].id and gates[posstr(x,y-i)].count>0 then
										--trace('inv rem')
										ir=true
										gates[posstr(x,y-i)].count=gates[posstr(x,y-i)].count-1
										local collect=gates[posstr(x,y-i)].collect
										if collect then gates[collect].count=gates[collect].count-1 end
										sfx(2,'E-4',30,2)
										snd=true
								end
						end
						i=i+1
				end

				if ir then inv_rem() end

				reveal_hidden()

				if not snd then sfx(1,'E-4',22,2) end
				
				if mget(x,y-1)==61 then
						rooms[4].visited=true
				end
		elseif can_move(dx) then
				if dx<0 then plrflip=1 else plrflip=0 end
				
				local snd=false
				-- move inventory
				local i=0
				local ir=false
				while fget(mget(x,y-i),2) do
						if fget(mget(x+dx,y-i),3) then
								--hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
								if mget(x,y-i)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then
										ir=true
										gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
										local connect=gates[posstr(x+dx,y-i)].connect
										if connect then
										gates[connect].count=gates[connect].count-1
										end
										sfx(2,'E-4',30,2)
										snd=true
								end
						end
						if mget(x+dx,y-i)>0 then
								hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
						end
						mset(x+dx,y-i,mget(x,y-i))
						mset(x,y-i,0)
						i=i+1
				end

				x=x+dx
				if ir then inv_rem() end
				
				if not snd then sfx(0,'E-1',6,2) end
				if not fget(mget(x,y+1),1) then fall() end

				reveal_hidden()
		end 	
end

function reveal_hidden()
		for k,h in pairs(hidden) do
				local hx,hy=strpos(k)
				if (h.t~=t or y-inv_len()>hy) and (not fget(mget(hx,hy),2) or (mget(hx,hy)==33 and hx~=x)) then
				mset(hx,hy,h.id)
				hidden[k]=nil
				end
		end
end

function draw_room(r)
		if r.visited then
		rect(r.x-4,r.y-4,r.mw*8+2*4,r.mh*8+2*4,0)
		rectb(r.x-4,r.y-4,r.mw*8+2*4,r.mh*8+2*4,5)
		rect(r.x,r.y,r.mw*8,r.mh*8,r.c)
		map(r.mx,r.my,r.mw,r.mh,r.x,r.y,0,1,remap)
		end
end

function transition()
		local clear=true
		for i,r in ipairs(rooms) do
				if r.tx then 
						clear=false
						if r.tx<r.x then
						r.x=r.x-3
						if r.x<=r.tx then r.x=r.tx; r.tx=nil end
						elseif r.tx>r.x then
						r.x=r.x+3
						if r.x>=r.tx then r.x=r.tx; r.tx=nil end
						elseif r.tx==r.x then r.tx=nil end
						if r.x>=240 then r.visited=false end
				end
		end

		cls(0)
		for i,r in ipairs(rooms) do
				if r~=rooms[4] then 
				-- box will be drawn on top of everything
				draw_room(r)
				end
		end
	
		mark_gates()
		
		draw_room(rooms[4])
	
		if clear then 
		local i=0
		local offy=0
		while i<=inv_len() do 
				if fget(mget(gatetx,gatety-i),1) or gatety-i<tgt_room.my then
				offy=offy+1
				end
				i=i+1
		end
		local i=0
		while fget(mget(x,y-i),2) do 
		mset(gatetx,gatety-i+offy,mget(x,y-i))
		mset(x,y-i,0)
		i=i+1
		end
		if x==6 and gatey==6 then
		--gates[posstr(8,3)].count=0
		elseif x==21 and gatey==3 then
		elseif x==23 and gatey==6 then
		rooms[3].visited=false
		elseif x==8 and gatey==3 then
		rooms[2].visited=false
		end
		TIC=update 
		hidden[posstr(gatetx,gatety)]={id=12,t=t}
		mset(x,gatey,12)
		x=gatetx; y=gatety+offy
		cur_room=tgt_room
		end
	
		t=t+1
end

function delay()
		t=t+1
		if t-dt>=64 then reset() end
end

function fall()
		local i=1
		while fget(mget(x,y-i),2) do
				mset(x,y-i+1,mget(x,y-i))
				i=i+1
		end
		if fget(mget(x,y-i+1),2) then mset(x,y-i+1,0) end
		y=y+1
		if mget(x,y)>0 then hidden[posstr(x,y)]={id=mget(x,y),t=t} end
		
		if y>=cur_room.my+cur_room.mh then
		local i=0
		while fget(mget(x,y-i),2) do
				mset(x,y-i,0)
				i=i+1
		end
		sfx(12,'E-4',64,2)
		TIC=delay; dt=t+1
		end

		reveal_hidden()
end

function box_in_room(r)
		for gx=r.mx,r.mx+r.mw do for gy=r.my,r.my+r.mh do
				if mget(gx,gy)==61 then return true end
		end end
		return false
end

function inv_has(sp)
		local i=1
		while fget(mget(x,y-i),2) do
				if mget(x,y-i)==sp then return true end
				i=i+1
		end
		return false
end

function update()

		local oldx,oldy=x,y
		if btnp(0) and can_jump() then 
				local i=inv_len()
				while fget(mget(x,y-i),2) do
						if mget(x,y-i-1)>0 and not fget(mget(x,y-i-1),2) then
								hidden[posstr(x,y-i-1)]={id=mget(x,y-i-1),t=t}
						end
						if mget(x,y-i-1)~=33 then
						mset(x,y-i-1,mget(x,y-i))
						end
						i=i-1
				end
				--mset(x,y-i,0)
				y=y-1
				local snd=false
				if inv_len()>0 and gates[posstr(x,y-inv_len())] and gates[posstr(x,y-inv_len())].id==mget(x,y-1) and gates[posstr(x,y-inv_len())].count>0 then
							gates[posstr(x,y-inv_len())].count=gates[posstr(x,y-inv_len())].count-1
							local connect=gates[posstr(x,y-inv_len())].connect
							if connect then
							gates[connect].count=gates[connect].count-1
							end
							sfx(2,'E-4',30,2)
							snd=true
							inv_rem()
				end
				if not snd then sfx(9,'E-5',22,2) end
				
				reveal_hidden()
		end
		if btnp(1) and can_fall() then
				fall()
				if y<cur_room.my+cur_room.mh then sfx(8,'E-5',16,2) end
		end
		if btnp(2) then move(-1) end
		if btnp(3) then move(1)  end
		if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
		mset(x,y,33)
		if btnp(4) and can_travel() then
				local i=0
				while fget(mget(x,y-i),2) do
				if gates[posstr(x,y-i)] and gates[posstr(x,y-i)].count==0 then 
						gatey=y-i
						if x==6 and y-i==6 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10
						tgt_room=rooms[2]
						rooms[2].x=240
						rooms[2].visited=true
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10
						gatetx=8; gatety=3
						if box_in_room(rooms[1]) and not inv_has(61) then rooms[4].tx=240 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
						end
						if x==21 and y-i==3 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4
						tgt_room=rooms[3]
						rooms[3].x=240
						rooms[3].visited=true
						rooms[3].tx=240-rooms[3].mw*8-64+24+6-10
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240 end
						if box_in_room(rooms[3]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9; rooms[3].tx=rooms[3].tx-9 end
						gatetx=23; gatety=6
						end
						if x==8 and y-i==3 then
						rooms[1].tx=240/2-7*8/2
						rooms[2].tx=240
						tgt_room=rooms[1]
						gatetx=6; gatety=6
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240 end
						if box_in_room(rooms[1]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-10*8 end
						end
						if x==23 and y-i==6 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4+8*12-8*3-4
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4+8*12-8*3-4
						rooms[3].tx=240
						tgt_room=rooms[2]
						gatetx=21; gatety=3
						if box_in_room(rooms[3]) and not inv_has(61) then rooms[4].tx=240 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
						end
						TIC=transition
						sfx(7,'E-5',70,2) 
						if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
						mset(x,y,33)
						TIC(); return
				end			
				i=i+1
				end
		elseif btnp(4) and can_drop() then
				local dx=1
				if plrflip==1 then dx=-1 end
				local sp=mget(x,y-1)
				inv_rem()
				mset(x+dx,y,sp)
				sfx(10,'E-1',22,2)
				
				reveal_hidden()
		end
		
		if btnp(5) and can_reclaim() then
				--local g=posstr(x,y)
				
				local i=0
				local g
				while fget(mget(x,y-i),2) do
				if (hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count<gates[posstr(x,y-i)].maxcount) then g=posstr(x,y-i); break end
				i=i+1
				end
				
				if not g then return end
	
				gates[g].count=gates[g].count+1
				local connect=gates[g].connect
				if connect then
				gates[connect].count=gates[connect].count+1
				end
				
				if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then									
						if not fget(mget(x,y+1),1) then
								local i=1 
								while fget(mget(x,y-i),2) do
										mset(x,y-i+1,mget(x,y-i))
										i=i+1
								end
								mset(x,y-i+1,0)
								y=y+1
						end
				end
	
				mset(x,y-inv_len()-1,gates[g].id)
				sfx(11,'E-4',43,2)
		elseif btnp(5) and can_cube() then
				
		end
	
		--[[
		if btnp(4) then zt=t; st=t end
	
		if not zt then
		cls(t*0.06)
		print("HELLO WORLD!",0,0,(t-16)*0.06%16)
		else
		cls(zt*0.06)
		print("HELLO WORLD!",0,0,(zt-16)*0.06%16)
		local j=0
		for i=math.max(0,(t-st-128)*0.25),(t-st)*0.25 do
		for c=0,4-1 do
		local a=j*2+t*0.08+c*2*pi/4
		local a2=j*2+t*0.08+(c+1)*2*pi/4
		line(x+cos(a)*(i+1)*3,y+sin(a)*(i+1)*3,x+cos(a2)*(i+1)*3,y+sin(a2)*(i+1)*3,(zt-16)*0.06%16)
		end
		j=j+1
		end	
		end
		]]
	
		cls(0)
		for i,r in ipairs(rooms) do 
				draw_room(r)
		end
	
		mark_gates()

		local sortgates={}
		--[[for k,g in pairs(gates) do
				local gx,gy=strpos(k)
				if gx>=cur_room.mx and gx<cur_room.mx+cur_room.mw and gy>=cur_room.my and gy<cur_room.my+cur_room.mh then
						ins(sortgates,g)
						g.x=gx; g.y=gy
				end
		end]]
		ins(sortgates,{x=cur_room.mx-1,y=cur_room.my,count=-1})
		table.sort(sortgates,function(a,b) return a.y<b.y or (a.y==b.y and a.x>b.x) end)
		local l,r=0,0
		for i,g in ipairs(sortgates) do
				local gx,gy=g.x,g.y
				local bx,by,bw,bh
				
				if g.count>0 then
						local tw=print(fmt('%dx',g.count),0,-6,12)
						bw=tw+4+8; bh=8+4
				elseif g.count==0 then
						local tw=print('OPEN',0,-6,12)
						bw=tw+4; bh=6+4+1
				elseif g.count==-1 then
						local avail=avail_actions()
						bw=0
						for j,a in ipairs(avail) do
								local aw=0
								aw=aw+print(a[1],0,-6,12,false,1,true)+1
								aw=aw+8
								if a.sp then aw=aw+8 end
								if aw>bw then bw=aw end
						end
						bw=bw+4; bh=#avail*9+4-1
				end
				
				if g.x<cur_room.mx+cur_room.mw/2 then
						bx=cur_room.x-bw-2; by=cur_room.y-2+l
				else
						bx=cur_room.x+cur_room.mw*8+2; by=cur_room.y-2+r
				end
				
				-- we now have our bx,by,bw,bh
				
				line(cur_room.x+(gx-cur_room.mx)*8+4,cur_room.y+(gy-cur_room.my)*8+4,bx+bw/2,by+bh/2,12)
				rect(bx,by,bw,bh,0)
				rectb(bx,by,bw,bh,12)

				if g.count>0 then
						local tw=print(fmt('%dx',g.count),bx+2,by+3,12)
						local oy=0
						if g.id==11 or g.id==61 then oy=-1 end
						spr(g.id,bx+2+tw,by+2+oy,0)
				elseif g.count==0 then
						print('OPEN',bx+2,by+3,12)
				elseif g.count==-1 then
						local avail=avail_actions()
						for j,a in ipairs(avail) do
								spr(a.id,bx+2,by+2+(j-1)*9,0)
								local tw=print(a[1],bx+2+8+1,by+2+(j-1)*9+1,12,false,1,true)
								if a.sp then 
										local oy=0
										if a.sp==11 or a.sp==61 then oy=-1 end
										spr(a.sp,bx+2+8+tw+1,by+2+(j-1)*9+oy,0) 
								end
						end
				end
								
				if g.x<cur_room.mx+cur_room.mw/2 then
						l=l+bh+2
				else
						r=r+bh+2
				end
		end
		
		if y<cur_room.my+cur_room.mh then
		spr(33,cur_room.x+(x-cur_room.mx)*8,cur_room.y+(y-cur_room.my)*8,0,1,plrflip)
		end
				
		if rooms[4].visited and rooms[4].x>240-5*8 then
				for i=1,4 do rooms[i].x=rooms[i].x-3 end
		end
		
		local tw=print('"Hello world."',0,-6,12,false,1,true)
		print('"Hello world."',cur_room.x+cur_room.mw*8/2-tw/2,cur_room.y+cur_room.mh*8+8,12,false,1,true)
		
		t=t+1
end

rooms={
{mx=0,my=4,mw=7,mh=17-4,x=240/2-7*8/2,y=136/2-(17-4)*8/2,c=15,visited=true},
{mx=7,my=1,mw=22-7+1,mh=10-1,x=240/2-10*8/2,y=136/2-(17-4)*8/2,c=8,visited=false},
{mx=23,my=6,mw=7,mh=11,x=240,y=136/2-(17-4)*8/2+8*3,c=2,visited=false},
{mx=116,my=64,mw=4,mh=4,x=240,y=136/2,c=1,visited=false},
}
cur_room=rooms[1]
gates={
['6:6']={id=11,count=3,connect='8:3'},
['8:3']={id=11,count=3,connect='6:6'},
['14:1']={id=11,count=6},
['21:3']={id=11,count=3,connect='23:6'},
['13:7']={id=44,count=1},
['16:7']={id=11,count=1},
['23:6']={id=11,count=3,connect='21:3'},
}
for k,g in pairs(gates) do
		g.maxcount=g.count
end

-- you give this the numbers 0 and 1, it will return a string '0:1'.
-- table keys use this format consistently. 
    function posstr(x,y)
        return fmt('%d:%d',x,y)
    end

-- you give this the string '0:1', it will return 0 and 1. 
    function strpos(pos)
        local delim=string.find(pos,':')
        local x=sub(pos,1,delim-1)
        local y=sub(pos,delim+1)
        --important tonumber calls
        --Lua will handle a string+number addition until it doesn't
        return tonumber(x),tonumber(y)
    end

-- palette swapping by BORB
		function pal(c0,c1)
		  if(c0==nil and c1==nil)then for i=0,15 do poke4(0x3FF0*2+i,i) end 
		  else poke4(0x3FF0*2+c0,c1) end
		end

function shadowspr(sp,spx,spy)
		for p=0,15 do pal(p,0) end
		spr(sp,spx,spy,0)
		pal()
end

function mark_gates()
for i,r in ipairs(rooms) do	if r.visited then
		for k,g in pairs(gates) do
				local gx,gy=strpos(k)
				if g.count>0 and gx>=r.mx and gx<r.mx+r.mw and gy>=r.my and gy<r.my+r.mh then
						if mget(gx,gy)==12 then
						rect(r.x+(gx-r.mx)*8,r.y+(gy-r.my)*8,8,8,5)
						shadowspr(g.id,r.x+(gx-r.mx)*8,r.y+(gy-r.my)*8)
						end
						if not fget(mget(gx,gy-1),2) then
						local tw=print(g.count,0,-6)
						print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2-1,0)
						print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2+1,0)
						print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1-1,r.y+(gy-r.my)*8-8+2,0)
						print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1+1,r.y+(gy-r.my)*8-8+2,0)
						print(g.count,r.x+(gx-r.mx)*8+4-tw/2+1,r.y+(gy-r.my)*8-8+2,12)
						end
				end
		end
		end end
end

function remap(tile,x,y)
		local flip=0
		if tile==12 then tile=12+t*(0.2)%4 end
		if tile==33 and plrflip then flip=plrflip end
		return tile,flip,0
end

function avail_actions()
		local avail={}

		if can_deposit(-1) then ins(avail,{'Deposit',id=52,sp=mget(x,y-1)})
		elseif can_turn(-1) then ins(avail,{'Turn',id=52})
		elseif can_move(-1) then ins(avail,{'Move',id=52})
		elseif can_pickup(-1) then ins(avail,{'Get',id=52,sp=mget(x-1,y)}) end
		if can_deposit(1) then ins(avail,{'Deposit',id=50,sp=mget(x,y-1)})
		elseif can_turn(1) then ins(avail,{'Turn',id=50})
		elseif can_move(1) then ins(avail,{'Move',id=50}) 
		elseif can_pickup(1) then ins(avail,{'Get',id=50,sp=mget(x+1,y)}) end
		if can_jump() then ins(avail,{'Jump',id=49}) end
		if can_fall() then ins(avail,{'Fall',id=51}) end
		if can_travel() then ins(avail,{'Travel',id=53}) 
		elseif can_drop() then ins(avail,{'Drop',id=53,sp=mget(x,y-1)}) end
		if can_reclaim() then ins(avail,{'Reclaim',id=54})
		elseif can_cube() then ins(avail,{'Enter',id=54,sp=61}) end
		
		return avail
end

function can_move(dx)
		if x+dx<cur_room.mx or x+dx>=cur_room.mx+cur_room.mw then return false end
		local i=0
		local falling=not fget(mget(x,y+1),1)
		while fget(mget(x,y-i),2) do
				if (not falling and fget(mget(x+dx,y-i),1)) and not (i==0 and falling and not fget(mget(x+dx,y-i+1),1)) then
						return false
				end
				if falling and i>0 then
						if fget(mget(x+dx,y-i+1),1) then return false end
				end
				i=i+1
		end
		return true
end

function can_pickup(dx)
		if not fget(mget(x+dx,y),2) then return false end
		
		if mget(x,y-1)==61 then
				local cx,cy=119,65
				while mget(cx,cy)>0 do
						cx=cx-1
						if cx==116 then cx=119; cy=cy-1; if cy<64 then return false end end
				end
				return true
		end

		return not (fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my))
end

function can_jump()
		if not fget(mget(x,y+1),1) then return false end
		if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then
				return false
		end
		return true
end

function can_fall()
		return not fget(mget(x,y+1),1)
end

function can_drop()
		if inv_len()==0 then return false end
		if not fget(mget(x,y+1),1) then return false end
		local dx=1
		if plrflip==1 then dx=-1 end
		if mget(x+dx,y)==0 and fget(mget(x+dx,y+1),1) then return true end
		return false
end

function can_travel()
		local i=0
		local has_gate=nil
		while fget(mget(x,y-i),2) do
				if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count==0 then has_gate=posstr(x,y-i); break end
				i=i+1
		end
		if not has_gate then return false end
		local connect=gates[has_gate].connect
		local gx,gy=strpos(connect)
		local tgt_room
		if gx==23 and gy==6 then tgt_room=rooms[3] end
		if (gx==21 and gy==3) or (gx==8 and gy==3) then tgt_room=rooms[2] end
		if gx==6 and gy==6 then tgt_room=rooms[1] end
		local i=0
		local offy=0
		while i<=inv_len() do 
				if fget(mget(gx,gy-i),1) or gy-i<tgt_room.my then
				offy=offy+1
				if fget(mget(gx,gy+offy),1) or gy+offy>=tgt_room.my+tgt_room.mh then return false end
				end
				i=i+1
		end
		return true
end

function can_reclaim()
		local i=0
		local overlap=false
		while fget(mget(x,y-i),2) do
		if (hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count+1<=gates[posstr(x,y-i)].maxcount) then overlap=true; break end
		i=i+1
		end
		if not overlap or mget(x,y-i-1)==33 then return false end
		if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then
				if not fget(mget(x,y+1),1) then
						return true
				end
				return false
		end
		return true
end

function can_turn(tdx)
		if tdx<0 then return plrflip==0 else return plrflip==1 end
end

function can_cube()
		i=1
		while fget(mget(x,y-i),2) do
				if mget(x,y-i)==61 then return true end
				i=i+1
		end
		return false
end

function can_deposit(dx)
		local i=1
		while fget(mget(x,y-i),2) do
				if not can_turn(dx) and mget(x+dx,y-i)==12 and gates[posstr(x+dx,y-i)] and gates[posstr(x+dx,y-i)].id==mget(x,y-i) and gates[posstr(x+dx,y-i)].count>0 then return true end
				i=i+1
		end
		
		if not can_turn(dx) then return false end

		local i=1
		while fget(mget(x,y-i),2) do
				--trace(hidden[posstr(x,y-i)],2)
				if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)] and gates[posstr(x,y-i)].id==mget(x,y-i) and gates[posstr(x,y-i)].count>0 then return true end
				i=i+1
		end
		
		return false
end

TIC=update
-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 005:7777777777bb227777baa277777b277777baa27777baa27777baa277777b2777
-- 006:7777777777bbbb7777b77b77777bb77777b77b7777b77b7777b77b77777bb777
-- 007:5555555555336655553556555553655555355655553556555535565555536555
-- 008:0000000000555500005005000005500000500500005005000050050000055000
-- 009:00000000000000000eeddff000dfff000eeffff00efffff000ffff00000ff000
-- 010:0000000000000000deeeeeedddffffdddfdffdfddffddffddffffffddeeeeeed
-- 011:0000000000000000065667700067770006577770067777700077770000077000
-- 012:5555555550000005500000055000000550000005500000055000000555555555
-- 013:5555555550000005500000055006600550066005500000055000000555555555
-- 014:5555555550000005506666055060060550600605506666055000000555555555
-- 015:5555555556666665560000655600006556000065560000655666666555555555
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 021:bbbbbbbab7777772b7777772b7777772b7777772b7777772b7777772a2222222
-- 022:bbbbbbbbb7bbbbbbbb777bbbbb77b7bbbb7b77bbbbb777bbbbbbbb7bbbbbbbbb
-- 025:eeeeeeefeffffff0effffff0eff00ef0eff00ef0effeeef0effffff0f0000000
-- 027:5555555656666667566666675667756756677567566555675666666767777777
-- 028:0067000000567000000076000007650000670000005670000000760000076500
-- 029:0076556006556000755700006576700056076700500076706000076700000076
-- 030:0077777700777777000566600006566006566666666566667666667707777770
-- 033:00000c00dc000c00c0000cc0c0000c2dcddccccc0dccccd00cc00dd00c0000d0
-- 034:00000c00cc000c00c0000cc0c0000c2ccccccccc0cccccc00cc00cc00c0000c0
-- 035:00000c00cc000c00c0000cc0c0000c2ccccccccc0cccccc00cc00cc00c0000c0
-- 036:00000c00cc000c00c0000cc0c0000c2ccccccccc0cccccc00cc00cc00c0000c0
-- 037:7777777777777777777777777777777777777777777777777777777777777777
-- 038:7777777777777777777777777777777777777777777777777777777777777777
-- 043:6666666767777770677777706770067067700670677666706777777070000000
-- 044:0067000000667000000076000007660000670000006670000000760000076600
-- 045:0000000000000000555555555577776657577676577667765777777656666666
-- 046:5000005065000560065056000065600000767000077077007070707077000770
-- 049:000cc00000ceec000ceddec0ceddddeccccddccc00cddc0000cddc00000cc000
-- 050:000cc000000cec000ccceec0ceeeddecceddddec0cccddc0000cdc00000cc000
-- 051:000cc00000ceec0000cddc00cccddcccceeddeec0cddddc000cddc00000cc000
-- 052:000cc00000cec0000ceeccc0ceddeeecceddddec0cddccc000cdc000000cc000
-- 053:000000000cccccc00ceeeec00ccccdc00cceedc00cedccc00cddeec00cccccc0
-- 054:000000000cccccc00ceccec00cdccdc00cceecc00ceccec00cdccdc00cccccc0
-- 055:000000000cccccc00cceecc00ceccec00cdeedc00cdccdc00cdccdc00cccccc0
-- 056:000000000cccccc00cceeec00cedccc00cceecc00cccdec00ceeecc00cccccc0
-- 061:0000000000655556655555775555677766667777666677776666777066667700
-- 065:00022000002222d002dd2dd02ddd2222022222d2000cc22000dcc00000ccc000
-- 066:00055000005555d005dd5dd05ddd5555055555d5000cc55000dcc00000ccc000
-- </TILES>

-- <MAP>
-- 001:0000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:0000000000000000c00000b00000b0b00000b00000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:00000000000000000000b2b1b2b1b2b1b2b1b2b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:0000000000000000b1b2b1b2b1b2b1b2b1b2b1b2b1b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:000000000000c0000000c2c2b2b1b2b1b200c2c2c20000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:00b01200b0b000000000c2c200c0b1b2c000c2c2c2000000b0b00000b0d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:b2b1b2b1b2b1b200000000c20000b2b1000000c2c20000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:b1b2b1b2b1b2b1000000000000b2b1b2b10000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:b2b1b2b1b2b1b2000000000000b1b2b1b20000c2000000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:b1b2b1b2b1b2b1000000000000b2b1b2b10000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:b2b1b2b1b2b1b2000000000000b1b2b1b20000c2000000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:b1b2b1b2b1b2b1000000000000c2b1b2c20000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:00b1b2b1b2b100000000000000c2b2b1c20000c200000000b2b1b2b1b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:00c2c200c2000000000000000000b1b2000000c20000000000c200c2c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:0000c200000000000000000000b1b2b1b20000c200000000000000c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 064:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 066:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 067:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:32000023cdffffdc32000023cdffffdc
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- 003:356789bcdcacdeedca87543322222345
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000
-- 001:009000d000f000f000a00070004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 002:009000d000f000f000a00070004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000384000000700
-- 003:010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100010001000100304000000000
-- 004:030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300500000000000
-- 005:04001400140034004400640074008400a400b400c400d400e400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400f400404000000000
-- 006:00b000d000f000d000b00070009000b00090007000300050007000500030003000500070005000300030003000300030003000300030003000300030357000000000
-- 007:000c000a0008000800080008000a000f0007000700000000000700070000000000070007000000000000000000000000000000000000000000000000c64000000000
-- 008:0000000f000d000b00080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008c04000000000
-- 009:000800080008000800080008000a000f0007000700070007000700070007000700070007000700070007000700070007000700070007000700070007c04000000000
-- 010:000000000000000000000007000700070007000700000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000
-- 011:009000df00fe00fd00ac007b004a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003e4000000707
-- 012:00070005000300040002000f0000000e000c000d000b0009000000000000000000000000000000000000000000000000000000000000000000000000b540000000b1
-- </SFX>

-- <PATTERNS>
-- 000:600048000000100000600048110300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:800048000000900048000000000000000000b00048000000000000000000d00048000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:000000000000d00036000000100000000000d00036000000100000000000d00036000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:60005800000060005a00000060005a00000060005600000060005800000060005a00000060005a00000000000000000000000000000000000000000060005a00000000000000000060005c00000000000000000060005a00000000000000000060005800000060005a00000060005a00000060005600000060005800000060005a00000060005a00000000000000000000000000000000000000000060005c000000000000000000600058000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:1000002c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000410000
-- 001:000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <FLAGS>
-- 000:00000000000000000000006080808080000000000000000000000020000000000040000000000000000000200100000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

