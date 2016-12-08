--触摸偏移量--
function touchMoveDistance(x1,y1,x2,y2,dis)
  local ret = false
  local dis_ = dis or 15
  if math.sqrt(math.pow(x1 - x2,2)+math.pow(y1 - y2,2)) > dis_ then
    ret = true
  end
  return ret 
end

function func_remove_tbs(gtb, tb)
	for _,_v in pairs(tb) do
		for id,__v in pairs(gtb) do
			if _v == __v then
				table.remove(gtb, id)
				break
			end
		end
	end
	return gtb
end