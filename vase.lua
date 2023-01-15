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

--inventory={}

hidden={}

function inv_len()
		local i=1
		while fget(mget(x,y-i),2) do
				i=i+1
		end
		return i-1
end

function inv_rem(iy)
		local i=0
		while fget(mget(x,iy-i),2) do
				if fget(mget(x,iy-i-1),2) then
				mset(x,iy-i,mget(x,iy-i-1))
				else mset(x,iy-i,0) end
				i=i+1
		end
end

function move(dx)
		if can_turn(dx) then
				if dx<0 then plrflip=1 else plrflip=0 end

				dx=0
				local snd=false
				local i=1
				local ir=false
				while fget(mget(x,y-i),2) do
						if hidden[posstr(x+dx,y-i)] and hidden[posstr(x+dx,y-i)].id==12 and gates[posstr(x+dx,y-i)].count>0 then
								--hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
								if gates[posstr(x+dx,y-i)].id==mget(x,y-i) then
										ir=y-i
										gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
										local connect=gates[posstr(x+dx,y-i)].connect
										if connect then
										gates[connect].count=gates[connect].count-1
										end
										sfx(2,'E-4',30,2)
										snd=true
								end
								if mget(x,y-i)==61 then
										local cx,cy=117,64
										while mget(cx,cy)>=0 do
												if mget(cx,cy)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then 
														mset(cx,cy,0)
														gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
														local connect=gates[posstr(x+dx,y-i)].connect
														if connect then
														gates[connect].count=gates[connect].count-1
														end
														sfx(2,'E-4',30,2)
														snd=true
														break
												end
												cx=cx+1
												if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
										end
								end
						end

						i=i+1
				end

				if ir then inv_rem(ir) end
				if not snd then sfx(0,'E-1',6,2) end

				reveal_hidden()

				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) then fall() end
				return
		end
		if can_pickup(dx) then
				if dx<0 then plrflip=1 else plrflip=0 end
				--ins(inventory,{sp=mget(x-1,y)})
				local oldy2=y 
				
				if mget(x,y-1)~=61 and (fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my) then
						local i=0
						while fget(mget(x,y-i),2) do
								mset(x,y-i,mget(x,y-i-1))
								i=i+1
						end
						mset(x,y-i,0)
						y=y+1
				end
				
				if mget(x,y-1)==61 then
						local cx,cy=119,65
						local cont=false
						while mget(cx,cy)>0 do
								cx=cx-1
								if cx==116 then cx=119; cy=cy-1; if cy<64 then cont=true; break end end
						end
						if not cont then
						mset(cx,cy,mget(x+dx,y))
						mset(x+dx,y,0)
						sfx(1,'E-4',22,2)
						return
						end
				end

				local oldy=y-inv_len()-1
				local old=mget(x,oldy)

				local i=inv_len()
				while fget(mget(x,y-i),2) and mget(x,y-i)~=33 do
						if mget(x,y-i-1)>0 then hidden[posstr(x,y-i-1)]={id=mget(x,y-i-1),t=t} end
						mset(x,y-i-1,mget(x,y-i))
						mset(x,y-i,0)
						i=i-1
				end

				if mget(x,y-1)>0 then hidden[posstr(x,y-1)]={id=mget(x,y-1),t=t} end
				mset(x,y-1,mget(x+dx,oldy2))
				mset(x+dx,oldy2,0)

				local i=1
				local ir=false
				local snd=false
				while fget(mget(x,y-i),2) do
						if y-i==oldy and fget(old,3) then
								hidden[posstr(x,y-i)]={id=old,t=t}
								--trace(y-i)
								--trace(mget(x,y-i))
								--trace(old)
								--trace(gates[posstr(x,y-i)].id)
								if mget(x,y-i)==gates[posstr(x,y-i)].id and gates[posstr(x,y-i)].count>0 then
										--trace('inv rem')
										ir=y-i
										gates[posstr(x,y-i)].count=gates[posstr(x,y-i)].count-1
										local connect=gates[posstr(x,y-i)].connect
										if connect then gates[connect].count=gates[connect].count-1 end
										sfx(2,'E-4',30,2)
										snd=true
								end
						end
						i=i+1
				end

				if ir then inv_rem(ir) end

				reveal_hidden()

				if not snd then sfx(1,'E-4',22,2) end

				if mget(x,y-1)==61 and not boxget then
						rooms[4].visited=true
						boxget=true
				end

				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) then fall()	end
		elseif can_move(dx) or can_climb(dx,0) then
				if dx<0 then plrflip=1 else plrflip=0 end
				
				local snd=false
				-- move inventory
				local i=0
				local ir=false
				while fget(mget(x,y-i),2) do
						if fget(mget(x+dx,y-i),3) then
								--hidden[posstr(x+dx,y-i)]={id=mget(x+dx,y-i),t=t}
								if mget(x,y-i)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then
										ir=y-i
										gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
										local connect=gates[posstr(x+dx,y-i)].connect
										if connect then
										gates[connect].count=gates[connect].count-1
										end
										sfx(2,'E-4',30,2)
										snd=true
								end
								if mget(x,y-i)==61 then
										local cx,cy=117,64
										while mget(cx,cy)>=0 do
												if mget(cx,cy)==gates[posstr(x+dx,y-i)].id and gates[posstr(x+dx,y-i)].count>0 then 
														mset(cx,cy,0)
														gates[posstr(x+dx,y-i)].count=gates[posstr(x+dx,y-i)].count-1
														local connect=gates[posstr(x+dx,y-i)].connect
														if connect then
														gates[connect].count=gates[connect].count-1
														end
														sfx(2,'E-4',30,2)
														snd=true
														break
												end
												cx=cx+1
												if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
										end
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
				if ir then inv_rem(ir) end
				
				if not snd then sfx(0,'E-1',6,2) end
				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) and not fget(mget(x,y+1),1) then fall() end

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
						--if r.x>=240 then r.visited=false end
				end
				if r.ty then
						clear=false
						if r.ty<r.y then
						r.y=r.y-3
						if r.y<=r.ty then r.y=r.ty; r.ty=nil end
						elseif r.ty>r.y then
						r.y=r.y+3
						if r.y>=r.ty then r.y=r.ty; r.ty=nil end
						elseif r.ty==r.y then r.ty=nil end
						--if r.y>=136 then r.visited=false end
				end
		end

		cls(0)
		
		for i,r in ipairs(rooms) do
				if r~=rooms[4] and r.x<240 and r.y<136 and r.x+r.mw*8>=0 and r.y+r.mh*8>=0 then 
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
		--[[if x==6 and gatey==6 then
		--gates[posstr(8,3)].count=0
		elseif x==21 and gatey==3 then
		elseif x==23 and gatey==6 then
		rooms[3].visited=false
		elseif x==8 and gatey==3 then
		rooms[2].visited=false
		end]]
		--[[
		for i,r in ipairs(rooms) do
				if r.x>=240 or r.y>=136 or r.x+r.mw*8<0 or r.y+r.mh*8<0 then
						r.visited=false
				end
		end]]
		TIC=update 
		hidden[posstr(gatetx,gatety)]={id=12,t=t}
		mset(x,gatey,12)
		x=gatetx; y=gatety+offy
		cur_room=tgt_room
		cur_room.visited=true
		chat_msg=nil
		chat_t=nil
		end
	
		t=t+1
end

function delay()
		t=t+1
		if t-dt>=64 then reset() end
end

function fall()
		if not (hidden[posstr(x,y)] and fget(hidden[posstr(x,y)].id,1)) then
		local i=1
		while fget(mget(x,y-i),2) do
				mset(x,y-i+1,mget(x,y-i))
				i=i+1
		end
		if fget(mget(x,y-i+1),2) then mset(x,y-i+1,0) end
		else
		mset(x,y,0)
		end
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

function action()
		if btnp(0) and can_climb(0,-1) then
				local i=inv_len()+1
				while fget(mget(x,y-i+1),2) do
						if mget(x,y-i)>0 then hidden[posstr(x,y-i)]={id=mget(x,y-i),t=t} end
						mset(x,y-i,mget(x,y-i+1))
						mset(x,y-i+1,0)
						i=i-1
				end
				mset(x,y,0)
				
				y=y-1

				sfx(0,'E-1',6,2)

				reveal_hidden()
				
				return
		elseif btnp(0) and can_jump() then 
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
				if inv_len()>0 and gates[posstr(x,y-inv_len())] and gates[posstr(x,y-inv_len())].count>0 then
							if gates[posstr(x,y-inv_len())].id==mget(x,y-inv_len()) then
							gates[posstr(x,y-inv_len())].count=gates[posstr(x,y-inv_len())].count-1
							local connect=gates[posstr(x,y-inv_len())].connect
							if connect then
							gates[connect].count=gates[connect].count-1
							end
							sfx(2,'E-4',30,2)
							snd=true
							inv_rem(y-inv_len())
							else
							if mget(x,y-inv_len())==61 then
									local cx,cy=117,64
									while mget(cx,cy)>=0 do
											if mget(cx,cy)==gates[posstr(x,y-inv_len())].id and gates[posstr(x,y-inv_len())].count>0 then 
													mset(cx,cy,0)
													gates[posstr(x,y-inv_len())].count=gates[posstr(x,y-inv_len())].count-1
													local connect=gates[posstr(x,y-inv_len())].connect
													if connect then
													gates[connect].count=gates[connect].count-1
													end
													sfx(2,'E-4',30,2)
													snd=true
													break
											end
											cx=cx+1
											if cx==120 then cx=117; cy=cy+1; if cy>65 then break end end
									end
							end
							end
				end
				if not snd then sfx(9,'E-5',22,2) end
				
				reveal_hidden()
				
				return
		end
		--local chat=(btnp(2) and can_chat(-1)) or (btnp(3) and can_chat(1))
		--local fell=false
		if btnp(1) and can_fall() then
				fall()
				--fell=true
				if y<cur_room.my+cur_room.mh then 
				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
				sfx(8,'E-5',16,2) 
				else
				sfx(0,'E-1',6,2)
				end
				end
				return
		end
		if btnp(2) and can_chat(-1) then 
				if mget(x-1,y)==65 then chat_msg='The order and orientation of pickups matters.' end
				if mget(x-1,y)==66 then chat_msg='These vases are all mine! You can\'t have them!' end
				if mget(x-1,y)==68 then win=true; chat_msg=fmt('This is the end. Rooms discovered: %d/%d',explored_count(),#rooms) end
				sfx(13,'E-5',#chat_msg,2) 
				if can_fall() then fall() end
				return
		elseif btnp(2) then 
				move(-1)
				return 
		end
		if btnp(3) and can_chat(1) then 
				if mget(x+1,y)==65 then chat_msg='The order and orientation of pickups matters.' end
				if mget(x+1,y)==66 then chat_msg='These vases are all mine! You can\'t have them!' end
				if mget(x+1,y)==68 then win=true; chat_msg=fmt('This is the end. Rooms discovered: %d/%d',explored_count(),#rooms) end
				sfx(13,'E-5',#chat_msg,2)
				if can_fall() then fall() end
				return
		elseif btnp(3) then 
				move(1)
				return 
		end
		if btnp(4) and can_travel() then
				local i=0
				while fget(mget(x,y-i),2) do
				if gates[posstr(x,y-i)] and gates[posstr(x,y-i)].count==0 then 
						gatey=y-i
						if x==6 and y-i==6 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10
						tgt_room=rooms[2]
						if not rooms[2].visited then
						rooms[2].x=240+8
						rooms[2].visited=true
						end
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10
						gatetx=8; gatety=3
						if box_in_room(rooms[1]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
						end
						if x==21 and y-i==3 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4
						tgt_room=rooms[3]
						rooms[3].y=136/2-(17-4)*8/2+8*3
						rooms[3].x=240+8
						rooms[3].visited=true
						rooms[3].tx=240-rooms[3].mw*8-64+24+6-10
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[3]) and boxget or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9; rooms[3].tx=rooms[3].tx-9 end
						gatetx=23; gatety=6
						end
						if x==8 and y-i==3 then
						rooms[1].tx=240/2-7*8/2
						rooms[2].tx=240+8
						tgt_room=rooms[1]
						gatetx=6; gatety=6
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[1]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-10*8 end
						end
						if x==23 and y-i==6 then
						rooms[1].tx=240/2-7*8/2-8*rooms[2].mw+64-12-6-10-8*12+8*3+4+8*12-8*3-4
						rooms[2].tx=240-rooms[2].mw*8-64+24+6-10-8*12+8*3+4+8*12-8*3-4
						rooms[3].tx=240+8
						tgt_room=rooms[2]
						gatetx=21; gatety=3
						if box_in_room(rooms[3]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8; rooms[1].tx=rooms[1].tx-9; rooms[2].tx=rooms[2].tx-9 end
						end
						if x==14 and y-i==1 then
						for i=1,3 do
								rooms[i].ty=rooms[i].y+8*8+16-4
						end
						rooms[5].x=240/2-8*4
						rooms[5].visited=true
						rooms[5].ty=16
						tgt_room=rooms[5]
						gatetx=15; gatety=128
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==15 and y-i==128 then
						for i=1,3 do
								rooms[i].ty=rooms[i].y-(8*8+16-4)
						end
						rooms[5].ty=-(8*8+16-4)
						tgt_room=rooms[2]
						gatetx=14; gatety=1
						if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==16 and y-i==7 then
						for i=1,5 do
								if i~=4 then rooms[i].ty=rooms[i].y-(8*7) end
						end
						rooms[6].visited=true
						rooms[6].ty=136-(12*8-4)
						tgt_room=rooms[6]
						gatetx=21; gatety=19
						if box_in_room(rooms[2]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[6]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==21 and y-i==19 then
						for i=1,5 do
								if i~=4 then rooms[i].ty=rooms[i].y+(8*7) end
						end
						rooms[6].ty=136
						tgt_room=rooms[2]
						gatetx=16; gatety=7
						if box_in_room(rooms[6]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[2]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==16 and y-i==18 then
						for i=1,5 do
								if i~=4 and rooms[i].visited then rooms[i].ty=rooms[i].y+(8*7); rooms[i].tx=rooms[i].x+11*8 end
						end
						rooms[6].ty=136
						tgt_room=rooms[1]
						gatetx=0; gatety=6
						if box_in_room(rooms[6]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[1]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==0 and y-i==6 then
						for i=1,5 do
								if i~=4 and rooms[i].visited then rooms[i].ty=rooms[i].y-(8*7); rooms[i].tx=rooms[i].x-11*8 end
						end
						rooms[6].visited=true
						rooms[6].ty=136-(12*8-4)
						tgt_room=rooms[6]
						gatetx=16; gatety=18
						if box_in_room(rooms[1]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[6]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==17 and y-i==129 then
						for i=1,6 do
								if i~=4 and rooms[i].visited then rooms[i].tx=rooms[i].x-8*4+4 end
						end
						rooms[7].visited=true
						rooms[7].tx=240-8*13
						tgt_room=rooms[7]
						gatetx=20; gatety=129
						if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[7]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==20 and y-i==129 then
						for i=1,6 do
								if i~=4 and rooms[i].visited then rooms[i].tx=rooms[i].x+8*4-4 end
						end
						rooms[7].tx=240+8
						tgt_room=rooms[5]
						gatetx=17; gatety=129
						if box_in_room(rooms[7]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==12 and y-i==131 then
						for i=1,6 do
								if i~=4 and rooms[i].visited then rooms[i].oldvisited=rooms[i].visited; rooms[i].tx=rooms[i].x+240; rooms[i].ty=rooms[i].y+136 end
						end
						rooms[8].visited=true
						rooms[8].tx=240/2-rooms[8].mw*8/2
						tgt_room=rooms[8]
						gatetx=9; gatety=132
						if box_in_room(rooms[5]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[8]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						if x==9 and y-i==132 then
						for i=1,6 do
								if i~=4 and rooms[i].oldvisited then rooms[i].visited=true; rooms[i].tx=rooms[i].x-240; rooms[i].ty=rooms[i].y-136 end
						end
						rooms[8].tx=-8*8
						tgt_room=rooms[5]
						gatetx=12; gatety=131
						if box_in_room(rooms[8]) and not inv_has(61) then rooms[4].tx=240+8 end
						if box_in_room(rooms[5]) or inv_has(61) then rooms[4].visited=true; rooms[4].tx=240-5*8 end
						end
						TIC=transition
						sfx(7,'E-5',70,2) 
						if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
						mset(x,y,33)
						TIC(); return
				end			
				i=i+1
				end
				
				return
		elseif btnp(4) and can_drop() then
				local dx=1
				if plrflip==1 then dx=-1 end
				local sp=mget(x,y-1)
				inv_rem(y-1)
				
				local snd=false
				if mget(x+dx,y)==12 then
						if gates[posstr(x+dx,y)].id==sp and gates[posstr(x+dx,y)].count>0 then
								gates[posstr(x+dx,y)].count=gates[posstr(x+dx,y)].count-1
								local connect=gates[posstr(x+dx,y)].connect
								if connect then gates[connect].count=gates[connect].count-1 end
								sfx(2,'E-4',30,2)
								snd=true
						end
				else
				mset(x+dx,y,sp)
				end
								
				if not snd then
				sfx(10,'E-1',22,2)
				end
				
				if not fget(mget(x,y+1),1) and not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
				fall()
				if y<cur_room.my+cur_room.mh then 
				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then
				sfx(8,'E-5',16,2) 
				else
				sfx(0,'E-1',6,2)
				end
				end
				end
				
				reveal_hidden()
				
				return
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

				local yadjust=false				
				if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then									
						if not fget(mget(x,y+1),1) then
								local i=1 
								while fget(mget(x,y-i),2) do
										mset(x,y-i+1,mget(x,y-i))
										i=i+1
								end
								mset(x,y-i+1,0)
								y=y+1
								yadjust=true
						end
				end
	
				mset(x,y-inv_len()-1,gates[g].id)
				sfx(11,'E-4',43,2)
				
				if not yadjust and not fget(mget(x,y+1),1) then
				fall()
				end
				
				reveal_hidden()
				
				return
		elseif btnp(5) and can_cube() then
				return
		end

end

function update()

		local oldx,oldy=x,y
	
		action()
		
		if mget(oldx,oldy)==33 then mset(oldx,oldy,0) end
		mset(x,y,33)

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

		if win then
				local tw=print('You win!',0,-6)
				for tx=0,240,tw+8 do for ty=0,136,7 do
				--print('You win!',rooms[5].x+rooms[5].mw/2*8-tw/2,rooms[5].y-12,t*0.2)
				print('You win!',tx,ty,t*0.2)
				end end
		end

		for i,r in ipairs(rooms) do 
				if r.x<240 and r.y<136 and r.x+r.mw*8>=0 and r.y+r.mh*8>=0 then
				draw_room(r)
				end
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
		if TIC~=delay then
		ins(sortgates,{x=cur_room.mx-1,y=cur_room.my,count=-1})
		end
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
				
		if cur_room==rooms[3] and box_in_room(rooms[3]) and rooms[4].visited and rooms[4].x>240-5*8 then
				for i=1,4 do 
				if i==4 or (i>=1 and i<=3 and rooms[3].x>240-rooms[3].mw*8-64+24+6-10-9) then
				rooms[i].x=rooms[i].x-3
				end 
				end
		end

		if chat_msg then
				if not chat_t then chat_t=1 end
		  local tw=print('"'..sub(chat_msg,1,chat_t)..'"',0,-6,12,false,1,true)
				rect(cur_room.x+cur_room.mw*8/2-tw/2-1,cur_room.y+cur_room.mh*8+8-1,tw+2,8,0)
		  print('"'..sub(chat_msg,1,chat_t)..'"',cur_room.x+cur_room.mw*8/2-tw/2,cur_room.y+cur_room.mh*8+8,12,false,1,true)
				chat_t=chat_t+1
		end

		--if cur_room==rooms[5] and not win then win=true end
		
		t=t+1
end

function explored_count()
		local out=0
		for i,r in ipairs(rooms) do
				if r.visited then out=out+1 end
		end
		return out
end

rooms={
{mx=0,my=4,mw=7,mh=17-4,x=240/2-7*8/2,y=136/2-(17-4)*8/2,c=15,visited=true,explored=true},
{mx=7,my=1,mw=22-7+1,mh=10-1,x=240/2-10*8/2,y=136/2-(17-4)*8/2,c=8,visited=false},
{mx=23,my=6,mw=7,mh=11,x=240,y=136/2-(17-4)*8/2+8*3,c=2,visited=false},
{mx=116,my=64,mw=4,mh=4,x=240,y=136/2,c=1,visited=false},
{mx=11,my=128,mw=8,mh=8,x=240/2-4*8,y=0-8*8,c=3,visited=false},
{mx=13,my=18,mw=9+1+1,mh=8+1,x=240/2-6*8,y=136,c=0,visited=false},
{mx=19,my=127,mw=11,mh=7,x=240,y=136/2-5*8-4,c=10,visited=false},
{mx=4,my=129,mw=7,mh=7,x=-8*8,y=136/2-4*8,c=13,visited=false},
}
cur_room=rooms[1]
gates={
['6:6']={id=11,count=3,connect='8:3'},
['8:3']={id=11,count=3,connect='6:6'},
['14:1']={id=11,count=6,connect='15:128'},
['21:3']={id=11,count=3,connect='23:6'},
['13:7']={id=44,count=1},
['16:7']={id=11,count=1,connect='21:19'},
['23:6']={id=11,count=3,connect='21:3'},
['15:128']={id=11,count=6,connect='14:1'},
['21:19']={id=11,count=1,connect='16:7'},
['16:18']={id=62,count=1,connect='0:6'},
['0:6']={id=62,count=1,connect='16:18'},
['12:131']={id=46,count=1,connect='9:132'},
['9:132']={id=46,count=1,connect='12:131'},
['17:129']={id=11,count=2,connect='20:129'},
['20:129']={id=11,count=2,connect='17:129'},
['28:128']={id=44,count=2,connect='31:130'},
['31:130']={id=44,count=2,connect='28:128'},
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
		
		local dpx,dpy=can_deposit(-1)
		if dpx and dpy then ins(avail,{'Deposit',id=52,sp=mget(dpx,dpy)})
		elseif can_turn(-1) then ins(avail,{'Turn',id=52})
		elseif can_chat(-1) then ins(avail,{'Chat',id=52})
		elseif can_climb(-1,0) then ins(avail,{'Climb',id=52})
		elseif can_pickup(-1) then ins(avail,{'Get',id=52,sp=mget(x-1,y)}) 
		elseif can_move(-1) then ins(avail,{'Move',id=52}) end
		local dpx,dpy=can_deposit(1)
		if dpx and dpy then ins(avail,{'Deposit',id=50,sp=mget(dpx,dpy)})
		elseif can_turn(1) then ins(avail,{'Turn',id=50})
		elseif can_chat(1) then ins(avail,{'Chat',id=50})
		elseif can_climb(1,0) then ins(avail,{'Climb',id=50})
		elseif can_pickup(1) then ins(avail,{'Get',id=50,sp=mget(x+1,y)})
		elseif can_move(1) then ins(avail,{'Move',id=50}) end
		local dpx,dpy=can_deposit(0)
		if dpx and dpy then ins(avail,{'Deposit',id=49,sp=mget(dpx,dpy)})
		elseif can_climb(0,-1) then ins(avail,{'Climb',id=49})
		elseif can_jump() then ins(avail,{'Jump',id=49}) end
		if can_climb(0,1) then ins(avail,{'Climb',id=51})
		elseif can_fall() then ins(avail,{'Fall',id=51}) end
		if can_travel() then ins(avail,{'Travel',id=53}) 
		elseif can_drop() then ins(avail,{'Drop',id=53,sp=mget(x,y-1)}) end
		local gid=can_reclaim()
		if gid then ins(avail,{'Reclaim',id=54,sp=gid})
		end
		--elseif can_cube() then ins(avail,{'Enter',id=54,sp=61}) end
		
		return avail
end

function can_move(dx)
		if x+dx<cur_room.mx or x+dx>=cur_room.mx+cur_room.mw then return false end
		local i=0
		--local falling=not fget(mget(x,y+1),1)
		--if falling and fget(mget(x+dx,y),1) then return false end
		while fget(mget(x,y-i),2) do
				if fget(mget(x+dx,y-i),1) then return false end
				i=i+1
		end
		return true
end

function can_pickup(dx)
		if not fget(mget(x+dx,y),2) then return false end
		
		if mget(x,y-1)==61 then
				local cx,cy=119,65
				while mget(cx,cy)>=0 do
						if mget(cx,cy)==0 then return true end
						cx=cx-1
						if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
				end
		end

		return (not (fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my))) or not fget(mget(x,y+1),1)
end

function can_jump()
		if not fget(mget(x,y+1),1) and not fget(mget(x,y+1),5) then return false end
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
		local dx=1
		if plrflip==1 then dx=-1 end
		if x+dx>=cur_room.mx+cur_room.mw or x+dx<cur_room.mx then return false end
		if not fget(mget(x,y+1),1) and not fget(mget(x+dx,y+1),1) and not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return false end
		if (mget(x+dx,y)==0 or mget(x+dx,y)==12) and (fget(mget(x+dx,y+1),1) or fget(mget(x+dx,y+1),5)) then return true end
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
		if not connect then return false end
		local gx,gy=strpos(connect)
		local tgt_room
		for i,r in ipairs(rooms) do
				if gx>=r.mx and gy>=r.my and gx<r.mx+r.mw and gy<r.my+r.mh then
						tgt_room=r
						break
				end
		end
		local i=0
		local top=gy
		while not fget(mget(gx,top-1),1) and not (top-1<tgt_room.my) do
				top=top-1
		end
		while i<=inv_len() do 
				if fget(mget(gx,top+i),1) or top+i>=tgt_room.my+tgt_room.mh then
						return false
				end
				i=i+1
		end
		return true
end

function can_reclaim()
		local i=0
		local overlap=false
		while fget(mget(x,y-i),2) do
		if (hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)].count+1<=gates[posstr(x,y-i)].maxcount) then overlap=gates[posstr(x,y-i)]; break end
		i=i+1
		end
		if not overlap or mget(x,y-i-1)==33 then return false end
		if fget(mget(x,y-inv_len()-1),1) or (y-inv_len()-1<cur_room.my) then
				if not fget(mget(x,y+1),1) then
						return overlap.id
				end
				return false
		end
		return overlap.id
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
		if x+dx>=cur_room.mx+cur_room.mw or x+dx<cur_room.mx then return false end
		if dx==0 then
				if can_jump() and inv_len()>0 and fget(mget(x,y-inv_len()-1),3) and gates[posstr(x,y-inv_len()-1)] and gates[posstr(x,y-inv_len()-1)].count>0 then
						if gates[posstr(x,y-inv_len()-1)].id==mget(x,y-inv_len()) then return x,y-inv_len() end
						if mget(x,y-inv_len())==61 then
								local cx,cy=119,65
								while mget(cx,cy)>=0 do
										if mget(cx,cy)==gates[posstr(x,y-inv_len()-1)].id then return cx,cy end
										cx=cx-1
										if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
								end
						end
				end
				return false		
		end
		
		local i=1
		while fget(mget(x,y-i),2) do
				if not can_turn(dx) and mget(x+dx,y)==0 and mget(x+dx,y-i)==12 and gates[posstr(x+dx,y-i)] and gates[posstr(x+dx,y-i)].count>0 then 
				
						if mget(x,y-i)==61 then
								local cx,cy=119,65
								while mget(cx,cy)>=0 do
										if mget(cx,cy)==gates[posstr(x+dx,y-i)].id then return cx,cy end
										cx=cx-1
										if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
								end
						elseif gates[posstr(x+dx,y-i)].id==mget(x,y-i) then
								return x,y-i
						end 
				end
				i=i+1
		end

		--trace(y-inv_len()-1)
		if not can_turn(dx) and fget(mget(x+dx,y),2) and fget(mget(x,y-inv_len()-1),3) and mget(x,y-1)~=61 and mget(x+dx,y)==gates[posstr(x,y-inv_len()-1)].id then return x+dx,y end
		
		if not can_turn(dx) then return false end

		local i=1
		while fget(mget(x,y-i),2) do
				--trace(hidden[posstr(x,y-i)],2)
				if hidden[posstr(x,y-i)] and hidden[posstr(x,y-i)].id==12 and gates[posstr(x,y-i)] and gates[posstr(x,y-i)].count>0 then 
						if mget(x,y-i)==61 then
								local cx,cy=119,65
								while mget(cx,cy)>=0 do
										if mget(cx,cy)==gates[posstr(x,y-i)].id then return cx,cy end
										cx=cx-1
										if cx==116 then cx=119; cy=cy-1; if cy<64 then break end end
								end
						elseif gates[posstr(x,y-i)].id==mget(x,y-i) then
								return x,y-i
						end 
				end
				i=i+1
		end
		
		return false
end

function can_climb(dx,dy)
		if dy==-1 then
				if fget(mget(x,y-inv_len()-1),1) or y-inv_len()-1<cur_room.my then return false end
				if fget(mget(x,y),5) or (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return true end
				if not (hidden[posstr(x,y)] and hidden[posstr(x,y)].id==44) then return false end
		end
		if dy==1 then
				if y+1>=cur_room.my+cur_room.mh then return false end
		end
		return (hidden[posstr(x+dx,y+dy)] and hidden[posstr(x+dx,y+dy)].id==44) or fget(mget(x+dx,y+dy),5)
end

function can_chat(dx)
		return not chat_msg and not can_turn(dx) and fget(mget(x+dx,y),4)
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
-- 059:4444444343333332433333324332243243322432433444324333333232222222
-- 060:0021000000221000000012000001220000210000002210000000120000012200
-- 061:0000000000655556655555775555677766667777666677776666777066667700
-- 062:0000000000565600050000505050060660065007070000700060070000067000
-- 065:00022000002222d002dd2dd02ddd2222022222d2000cc22000dcc00000ccc000
-- 066:00066000006666d006dd6dd06ddd6666066666d6000cc66000dcc00000ccc000
-- 067:00033000003333d003dd3dd03ddd3333033333d3000cc33000dcc00000ccc000
-- 068:000aa00000aaaad00addadd0adddaaaa0aaaaada000ccaa000dcc00000ccc000
-- 075:3333333232222220322222203220032032200320322333203222222020000000
-- 091:bbbbbbbabaaaaaa9baaaaaa9baa99ba9baa99ba9baabbba9baaaaaa9a9999999
-- 107:aaaaaaa9a9999990a9999990a9900a90a9900a90a99aaa90a999999090000000
-- 123:dddddddedeeeeeefdeeeeeefdeeffdefdeeffdefdeedddefdeeeeeefefffffff
-- 139:eeeeeeefeffffff0effffff0eff00ef0eff00ef0effeeef0effffff0f0000000
-- </TILES>

-- <SPRITES>
-- 000:0000000000000000000000000000000000000000000000020000002200000220
-- 001:0000022200022000002000000200000022000000200000000000000000000000
-- 002:2220000000222200000002200000002200000000000000000000000000000000
-- 003:0000000000000000000000000000000022000000022000000022000000022000
-- 016:0000020000002000000220000020022200222200022000000200000002000000
-- 017:0000000000000000000000002222222200000000000000000000000000000000
-- 018:0000000000000000000000000000000022000000002220000000022000000002
-- 019:0000220000000200000002200000002000000020000000200000002020000020
-- 032:2200000020000000220000000222220000000000000000000000000000000000
-- 034:0000000000000000000000000000000000000000000000000000000000000222
-- 035:2200002000220020000222220000022200000022000000020000002200022220
-- 051:2222000000000000000000000000000000000000000000000000000000000000
-- </SPRITES>

-- <MAP>
-- 001:0000000000000000000000c20000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:0000000000000000000000c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:0000000000000000c00000c2b000b0b000b0000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:00000000000000000000b2c2b2b1b2b1b2b1b2b100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:0000000000000000b1b2b1c2b1b2b1b2b1b2b1b2b1b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:c00000000000c0000000c2c2b2b1b2b1b200c2c2c20000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:00b01200b0b000000000c2c2c2c0b1b2c000c2c2c2000000b0b00000b0d3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:b2b1b2b1b2b1b200000000c2c200b2b1000000c2c20000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:b1b2b1b2b1b2b100000000c200b2b1b2b10000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:b2b1b2b1b2b1b2000000000000b1b2b1b20000c2000000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:b1b2b1b2b1b2b1000000000000b2b1b2b10000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:b2b1b2b1b2b1b2000000000000b1b2b1b20000c2000000b1b2b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:b1b2b1b2b1b2b1000000000000c2b1b2c20000c2000000b2b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:00b1b2b1b2b100000000000000c2b2b1c20000c200000000b2b1b2b1b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:00c2c200c2000000000000000000b1b2000000c20000000000c200c2c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:0000c200000000000000000000b1b2b1b20000c200000000000000c20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 018:00000000000000000000000000c20000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 019:00000000000000000000000000c200000000000000c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 020:00000000000000000000000000c200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 021:00000000000000000000000000c200140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 022:00000000000000000000000000c200b1b2b1b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 023:00000000000000000000000000c2b1b2b1b2b10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 024:00000000000000000000000000c200c2c2c20000b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 025:00000000000000000000000000c200c2e3c200b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 026:00000000000000000000000000c2000000c200c2b1b2b1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 064:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 066:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 067:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 124:000000000000000000000000000000000000000000000000000000000000b2b1b2b1b2b1b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 125:000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0b0b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 126:00000000000000000000000000000000000000000000000000000000000000b0b0b0b0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 127:0000000000000000000000000000000000000000000000000000000000000000b0b0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 128:0000000000000000000000c2000000c00000c2000000000000000000c000000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 129:00000000b1b2b1b2b1b2b1c20000000000c0c200c00000000000000000000000b1b2b1c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 130:00000000b2b1000000b1b2c2b2b1b2b1b2b1c2b100000000000000b1b2b100c0000000c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 131:00000000b10000000000b1c2c0b2b1b2b10000b2b1b200b200e200b200000000000024c2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 132:00000000b200000000c0b2c2b2b1b2b1b2b10000000000b1b2b10000000000b1b2b1b2b1000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 133:00000000b10000000000b100b1b2b1b2b1b2000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 134:00000000b2b1440000b1b20000b1b2b1b200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 135:00000000b1b2b1b2b1b2b1000000b1b20000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
-- 013:000300070007000c00080009000b0004000700060004000c000800080000000000000000000000000000000000000000000000000000000000000000c0400000000f
-- </SFX>

-- <PATTERNS>
-- 000:700048000000000000100000700048110300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:900048000000a00048000000000000000000c00048000000000000000000e0004800000000000000000070004a000000000000000000e00048000000000000000000c00048000000a00048000000c00048000000a00048000000900048000000000000000000a00048000000900048000000500048000000000000000000700048000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000700048000000000000100000700048100000
-- 002:000000000000e00036000000100000000000e00036000000100000000000e00036000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:60005800000060005a00000060005a00000060005600000060005800000060005a00000060005a00000000000000000000000000000000000000000060005a00000000000000000060005c00000000000000000060005a00000000000000000060005800000060005a00000060005a00000060005600000060005800000060005a00000060005a00000000000000000000000000000000000000000060005c000000000000000000600058000000000000000000000000000000000000000000
-- 004:900048000000a00048000000000000000000c00048000000000000000000e0004800000000000000000070004a000000000000000000e00048000000000000000000c00048000000a0004800000040004a000000e00048000000c0004800000000000000000060004a00000040004a000000e0004800000000000000000040004a000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000c00048000000000000100000c00048100000
-- 005:e0004810000040004a00000000000000000000000000000010000000000060004a00000010000000000060004a000000e00048000000900048000000000000000000000000000000100000000000700048000000900048000000a00048000000000000100000a00048c00048900048000000c00048000000000000000000400048000000000000000000e00046000000000000000000900046000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:1000002c0000500000600000000000000000000000000000000000000000000000000000000000000000000000000000410000
-- 001:000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <FLAGS>
-- 000:00000000000000000000006080808080000000000000000000000020006060000040000000000000000000200260600000000000000000000000002042606000002121212100000000000020000000000000000000000000000000200000000000000000000000000000002000000000000000000000000000000020000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <SCREEN>
-- 010:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:555555555555555555555555555555555555555555555555555000055555555555555555555555555555555555555555555555555555555555550cccc05555555555555555555555555555555555555555555555555555555555555555555550000000000000000000000000000000000000000000000000
-- 013:000000000000000000000000000000000000000000000000005000050000000000000000000000000000000000000000000000000000000000000000cc0000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000
-- 014:0000000000ccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000
-- 015:0000000000c000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000000000000000
-- 016:ffffffffffc0000cc000000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888855555555888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 017:ffffffffffc000cec0000ccc00000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888855555555888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 018:ffffffffffc00ceeccc00ccc00c00c0c00cc00000000000000000000c008888888888888888888888888888888888888888888888888888888850000005888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 019:ffffffffffc0ceddeeec0c0c0c0c0c0c0c0c00000000000000000000c008888888888888888888888888888888888888888888888888888888855000055888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 020:ffffffffffc0ceddddec0c0c0c0c0c0c0cc000000000000000000000c008888888888888888888888888888888888888888888888888888888850000005888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 021:ffffffffffc00cddccc00c0c00c000c000cc00000000000000000000c008888888888888888888888888888888888888888888888888888888850000005888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 022:ffffffffffc000cdc000000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888855000055888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 023:ffffffffffc0000cc000000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888855500555888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 024:ffffffffffc000000000000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 025:ffffffffffc0000cc000000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888888655556888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 026:ffffffffffc0000cec000ccc00000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888865555577888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 027:ffffffffffc00ccceec000c00c0c0c0c0cc000000000000000000000c008888888888888888888888888888888888888888888888888888888855556777888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 028:ffffffffffc0ceeeddec00c00c0c0cc00c0c00000000000000000000c008888888888888888888888888888888888888888888888888888888866667777888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 029:ffffffffffc0ceddddec00c00c0c0c000c0c00000000000000000000c008888888888888888888888888888888888888888888888888888888866667777888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 030:ffffffffffc00cccddc000c000cc0c000c0c00000000000000000000c008888888888888888888888888888888888888888888888888888888866667778888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 031:ffffffffffc0000cdc00000000000000000000000000000000000000c008888888888888888888888888888888888888888888888888888888866667788888888888888888888888888888888888888888888888888888888888888888800050000000000000000000000000000000000000000000000000
-- 032:ffffffffffc0000cc000000000000000000000000000000000000000c008888888855555555888888888888888888888888888888888888888888c88888888888888888888888888888888888888888888888888888555555558888888800050000000000000000000000000000000000000000000000000
-- 033:ffffffffffc000000000000000000000000000000000000000000000c008888888858888885888888888888888888888888888888888888888888c888cd888888888888888888888888888888888888888888888888588888858888888800050000000000000000000000000000000000000000000000000
-- 034:ffffffffffc0000cc000000000000000000000000000000000000000c00888888885888888588888888888888888888888886566778888888888cc8888c888888888888888888888888888888888888888888888888588888858888888800050000000000000000000000000000000000000000000000000
-- 035:ffffffffffc000ceec000cc000000000000000000c00c00065667700c0088888888588668858888888888888888888888888867778888888888d2c8888c888888888888888888888888888888888888888888888888588668858888888800050000000000000000000000000000000000000000000000000
-- 036:ffffffffffc00ceddec00c0c00cc0cc000c000cc000ccc0006777000c0088888888588668858888888888888888888888888657777888888888cccccddc888888888888888888888888888888888888888888888888588668858888888800050000000000000000000000000000000000000000000000000
-- 037:ffffffffffc0ceddddec0c0c0c0c0c0c0c0c0cc00c00c00065777700c00888888885888888588888888888888888888888886777778888888888dccccd8888888888888888888888888888888888888888888888888588888858888888800050000000000000000000000000000000000000000000000000
-- 038:ffffffffffc0cccddccc0c0c0cc00c0c0c0c000c0c00c00067777700c00888888885888888588888888888888888888888888777788888888888dd88cc8888888888888888888888888888888888888888888888888588888858888888800050000000000000000000000000000000000000000000000000
-- 039:ffffffffffc000cddc000cc000cc0cc000c00cc00c000c0007777000c00888888885555555588888888888888888888888888877888888888888d8888c8888888888888888888888888888888888888888888888888555555558888888800050000000000000000000000000000000000000000000000000
-- 040:ffffffffffc000cddc00000000000c00000000000000000000770000c008888888888888888888888886666666755555556666666675555555666666667555555566666666755555556666666675555555688888888888888888888888800050000000000000000000000000000000000000000000000000
-- 041:ffffffffffc0000cc000000000000000000000000000000000000000c008888888888888888888888886777777856666667677777785666666767777778566666676777777856666667677777785666666788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 042:ffffffffffc000000000000000000000000000000000000000000000c008888888888888888888888886777777856666667677777785666666767777778566666676777777856666667677777785666666788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 043:ffffffffffc000000000000000000000000000065555600000000000c008888888888888888888888886778867856677567677886785667756767788678566775676778867856677567677886785667756788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 044:ffffffffffc00cccccc00cc000000000000006555557700000000000c008888888888888888888888886778867856677567677886785667756767788678566775676778867856677567677886785667756788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 045:ffffffffffc00ceeeec00c0c0c0c00c00cc005555677700000000000c008888888888888888888888886776667856655567677666785665556767766678566555676776667856655567677666785665556788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 046:ffffffffffc00ccccdc00c0c0cc00c0c0c0c06666777700000000000c008888888888888888888888886777777856666667677777785666666767777778566666676777777856666667677777785666666788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 047:ffffffffffc00cceedc00c0c0c000c0c0c0c06666777700000000000c008888888888888888888888887888888867777777788888886777777778888888677777777888888867777777788888886777777788888888888888888888888800050000000000000000000000000000000000000000000000000
-- 048:5555556666c00cedccc00cc00c0000c00cc006666777000000000000c008888888855555556666666675555555666666667555555566666666755555556666666675555555666666667555555566666666755555556666666678888888800050000000000000000000000000000000000000000000000000
-- 049:6666667677c00cddeec00000000000000c0006666770000000000000c008888888856666667677777785666666767777778566666676777777856666667677777785666666767777778566666676777777856666667677777788888888800050000000000000000000000000000000000000000000000000
-- 050:6666667677c00cccccc0000000000000000000000000000000000000c008888888856666667677777785666666767777778566666676777777856666667677777785666666767777778566666676777777856666667677777788888888800050000000000000000000000000000000000000000000000000
-- 051:6677567677c000000000000000000000000000000000000000000000c008888888856677567677886785667756767788678566775676778867856677567677886785667756767788678566775676778867856677567677886788888888800050000000000000000000000000000000000000000000000000
-- 052:6677567677ccccccccccccccccccccccccccccccccccccccccccccccc008888888856677567677886785667756767788678566775676778867856677567677886785667756767788678566775676778867856677567677886788888888800050000000000000000000000000000000000000000000000000
-- 053:66555676776667f566555676776667f566555676776667f0005000050008888888856655567677666785665556767766678566555676776667856655567677666785665556767766678566555676776667856655567677666788888888800050000000000000000000000000000000000000000000000000
-- 054:66666676777777f566666676777777f566666676777777f0005000050008888888856666667677777785666666767777778566666676777777856666667677777785666666767777778566666676777777856666667677777788888888800050000000000000000000000000000000000000000000000000
-- 055:77777777fffffff677777777fffffff677777777fffffff0005000050008888888867777777788888886777777778888888677777777888888867777777788888886777777778888888677777777888888867777777788888888888888800050000000000000000000000000000000000000000000000000
-- 056:666666755555556666666675555555666666667555555560005000050008888888888888888888888888867888888678888666666675555555666666667555555566666666788888888886788888867888888678888888888888888888800050000000000000000000000000000000000000000000000000
-- 057:777777f566666676777777f566666676777777f566666670005000050008888888888888888888888888866788888667888677777785660066767777778566666676770077888888888886678888866788888667888888888888888888800050000000000000000000000000000000000000000000000000
-- 058:777777f566666676777777f566666676777777f56666667000500005000888888888888888888888888888876888888768867777778560cc0676777777856666667670cc07888888888888876888888768888887688888888888888888800050000000000000000000000000000000000000000000000000
-- 059:77ff67f56677567677ff67f56677567677ff67f5667756700050000500088888888888888888888888888876688888766886778867850ccc067677886785667756760ccc07888888888888766888887668888876688888888888888888800050000000000000000000000000000000000000000000000000
-- 060:77ff67f56677567677ff67f56677567677ff67f56677567000500005000888888888888888888888888886788888867888867788678560cc0676778867856677567670cc07888888888886788888867888888678888888888888888888800050000000000000000000000000000000000000000000000000
-- 061:776667f566555676776667f566555676776667f56655567000500005000888888888888888888888888886678888866788867766678560cc0676776667856655567670cc07888888888886678888866788888667888888888888888888800050000000000000000000000000000000000000000000000000
-- 062:777777f566666676777777f566666676777777f5666666700050000500088888888888888888888888888887688888876886777777850cccc07677777785666666760cccc0888888888888876888888768888887688888888888888888800050000000000000000000000000000000000000000000000000
-- 063:fffffff677777777fffffff677777777fffffff677777770005000050008888888888888888888888888887668888876688788888886700007778888888677777777800008888888888888766888887668888876688888888888888888800050000000000000000000000000000000000000000000000000
-- 064:555555666666667555555566666666755555556666666670005000050008888888888888888888888888867888888678888888888885500555555555556666666675555555588888888886788888867888888678888888888888888888800050000055555555555555555555555555555555555555550000
-- 065:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888866788888667888888888885500055556666667677777785555555588888888886678888866788888667888888888888888888800050000050000000000000000000000000000000000000050000
-- 066:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888888768888887688888888885555005556666667677777785000000588888888888876888888768888887688888888888888888800050000050000000000000000000000000000000000000050000
-- 067:6677567677ff67f56677567677ff67f56677567677ff67f0005000050008888888888888888888888888887668888876688888888885550005556677567677886785500005588888888888766888887668888876688888888888888888800050000050000000000000000000000000000000000000050000
-- 068:6677567677ff67f56677567677ff67f56677567677ff67f0005000050008888888888888888888888888867888888678888888888885500555556677567677886785000000588888888886788888867888888678888888888888888888800050000050005555555511111111111111111111111100050000
-- 069:66555676776667f566555676776667f566555676776667f0005000050008888888888888888888888888866788888667888888888885500055556655567677666785000000588888888886678888866788888667888888888888888888800050000050005111111511111111111111111111111100050000
-- 070:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888888768888887688888888885555005556666667677777785500005588888888888876888888768888887688888888888888888800050000050005111111511111111111111111111111100050000
-- 071:77777777fffffff677777777fffffff677777777fffffff0005000050008888888888888888888888888887668888876688888888885550005567777777788888885550055588888888888766888887668888876688888888888888888800050000050005116611511111111111111111111111100050000
-- 072:666666755555556666666675555555666666667555555560005000050008888888888888888888888888888888888678888888888888888888866666667555555568888888888888888888888888867888888678888888888888888888800050000050005116611511111111111111111111111100050000
-- 073:777777f566666676777777f566666676777777f566666670005000050008888888888888888888888888888888888667888888888888888888867777778566666678888888888888888888888888866788888667888888888888888888800050000050005111111511111111111111111111111100050000
-- 074:777777f566666676777777f566666676777777f566666670005000050008888888888888888888888888888888888887688888888888888888867777778566666678888888888888888888888888888768888887688888888888888888800050000050005111111511111111111111111111111100050000
-- 075:77ff67f56677567677ff67f56677567677ff67f566775670005000050008888888888888888888888888888888888876688888888888888888867788678566775678888888888888888888888888887668888876688888888888888888800050000050005555555511111111111111111111111100050000
-- 076:77ff67f56677567677ff67f56677567677ff67f566775670005000050008888888888888888888888888888888888678888888888888888888867788678566775678888888888888888888888888867888888678888888888888888888800050000050001111111111111111111111111111111100050000
-- 077:776667f566555676776667f566555676776667f566555670005000050008888888888888888888888888888888888667888888888888888888867766678566555678888888888888888888888888866788888667888888888888888888800050000050001111111111111111111111111111111100050000
-- 078:777777f566666676777777f566666676777777f566666670005000050008888888888888888888888888888888888887688888888888888888867777778566666678888888888888888888888888888768888887688888888888888888800050000050001111111116566771165667711111111100050000
-- 079:fffffff677777777fffffff677777777fffffff677777770005000050008888888888888888888888888888888888876688888888888888888878888888677777778888888888888888888888888887668888876688888888888888888800050000050001111111111677711116777111111111100050000
-- 080:555555666666667555555566666666755555556666666670005000050008888888888888888888888888888888888888888888888886666666755555556666666675555555688888888888888888867888888888888888888888888888800050000050001111111116577771165777711111111100050000
-- 081:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888888888888888888888888886777777856666667677777785666666788888888888888888866788888888888888888888888888800050000050001111111116777771167777711111111100050000
-- 082:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888888888888888888888888886777777856666667677777785666666788888888888888888888768888888888888888888888888800050000050001111111111777711117777111111111100050000
-- 083:6677567677ff67f56677567677ff67f56677567677ff67f0005000050008888888888888888888888888888888888888888888888886778867856677567677886785667756788888888888888888887668888888888888888888888888800050000050001111111111177111111771111111111100050000
-- 084:6677567677ff67f56677567677ff67f56677567677ff67f0005000050008888888888888888888888888888888888888888888888886778867856677567677886785667756788888888888888888867888888888888888888888888888800050000050005555555666666667555555566666666700050000
-- 085:66555676776667f566555676776667f566555676776667f0005000050008888888888888888888888888888888888888888888888886776667856655567677666785665556788888888888888888866788888888888888888888888888800050000050005666666767777771566666676777777100050000
-- 086:66666676777777f566666676777777f566666676777777f0005000050008888888888888888888888888888888888888888888888886777777856666667677777785666666788888888888888888888768888888888888888888888888800050000050005666666767777771566666676777777100050000
-- 087:77777777fffffff677777777fffffff677777777fffffff0005000050008888888888888888888888888888888888888888888888887888888867777777788888886777777788888888888888888887668888888888888888888888888800050000050005667756767711671566775676771167100050000
-- 088:666666755555556666666675555555666666667555555560005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050005667756767711671566775676771167100050000
-- 089:777777f566666676777777f566666676777777f566666670005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050005665556767766671566555676776667100050000
-- 090:777777f566666676777777f566666676777777f566666670005000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050005666666767777771566666676777777100050000
-- 091:77ff67f56677567677ff67f56677567677ff67f566775670005000055555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555550000050006777777771111111677777777111111100050000
-- 092:77ff67f56677567677ff67f56677567677ff67f566775670005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006666666755555556666666675555555600050000
-- 093:776667f566555676776667f566555676776667f566555670005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006777777156666667677777715666666700050000
-- 094:777777f566666676777777f566666676777777f566666670005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006777777156666667677777715666666700050000
-- 095:fffffff677777777fffffff677777777fffffff677777770005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006771167156677567677116715667756700050000
-- 096:555555666666667555555566666666755555556ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006771167156677567677116715667756700050000
-- 097:66666676777777f566666676777777f56666667ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006776667156655567677666715665556700050000
-- 098:66666676777777f566666676777777f56666667ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050006777777156666667677777715666666700050000
-- 099:6677567677ff67f56677567677ff67f56677567ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050007111111167777777711111116777777700050000
-- 100:6677567677ff67f56677567677ff67f56677567ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000050000
-- 101:66555676776667f566555676776667f56655567ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000050000
-- 102:66666676777777f566666676777777f56666667ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000000000000000000000000000000000000050000
-- 103:77777777fffffff677777777fffffff67777777ffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555555555555555555555555550000
-- 104:f67ffffff67ffffffffffffff67ffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 105:f667fffff667fffffffffffff667fffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 106:fff76ffffff76ffffffffffffff76ffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 107:ff766fffff766fffffffffffff766ffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 108:f67ffffff67ffffffffffffff67ffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 109:f667fffff667fffffffffffff667fffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 110:fff76ffffff76ffffffffffffff76ffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 111:ff766fffff766fffffffffffff766ffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 112:fffffffff67ffffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 113:fffffffff667fffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 114:fffffffffff76ffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 115:ffffffffff766ffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 116:fffffffff67ffffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 117:fffffffff667fffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 118:fffffffffff76ffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 119:ffffffffff766ffffffffffffffffffffffffffffffffff0005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 120:000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 121:000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 122:000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 123:555555555555555555555555555555555555555555555555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </SCREEN>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

